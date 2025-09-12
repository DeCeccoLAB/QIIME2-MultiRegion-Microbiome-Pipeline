##############################
library(phyloseq) #v1.46.0
library(tidyverse) #v2.0
library(tidyr) #v1.3
library(purrr) #v1.0.2
library(microbiomeMarker) #v1.4.0
library(ggpubr) #0.6.1
######################
#Analysis on raw data#
######################

#Ensure you have downloaded the .rds files from https://github.com/DeCeccoLAB/QIIME2-MultiRegion-Microbiome-Pipeline/tree/main/R_scripts
otu_raw_gen <- readRDS("path//to//otu_raw_gen.rds")
metadata_total <- readRDS("path//to//metadata_total.rds")


otu_raw_pivot_gen<- otu_raw_gen%>%pivot_longer(-Genus, values_to = "value", names_to = "ID")%>%
  left_join(metadata_total, by="ID")%>%as.data.frame()  #pivot_longer + metadata merging

raw_data_notheoric <- otu_raw_pivot_gen %>%
  filter(analysis_type != "theoric")


sequencing_depths <- raw_data_notheoric %>%
  group_by(ID, sample, analysis_type, region) %>%
  summarise(
    sequencing_depth = sum(value, na.rm = TRUE),
    .groups = 'drop' # Ungroup the data frame after summarizing
  )

group_levels <- c("IR", "V2-9", "V2", "V3", "V4", "V6-7", "V8", "V9")

# Ensure 'region' is a factor with specified levels
sequencing_depths$region <- factor(sequencing_depths$region, levels = group_levels)

# Define specific comparisons 
my_comparisons <- lapply(setdiff(group_levels, "IR"), function(x) c(x, "IR"))

head(sequencing_depths)


# boxplot to compare seq.depth distributions.

depth_plot <- ggplot(sequencing_depths, aes(x = region, y = sequencing_depth+1, fill = analysis_type)) +
  geom_boxplot(position = position_dodge(width = 0.8)) +
  geom_jitter(shape = 16, alpha = 0.4, position = position_jitterdodge(jitter.width = 0.2, dodge.width = 0.8)) +
  stat_compare_means(
    method = "wilcox.test",
    label = "p.signif",
    comparisons = my_comparisons,
    size = 4,
    step.increase = 0.15,
    aes(group = region),
    inherit.aes = TRUE
  )+
  scale_y_log10(
    breaks = scales::trans_breaks("log10", function(x) 10^x),
    labels = scales::trans_format("log10", scales::math_format(10^.x))
  ) +
  annotation_logticks(sides = "l") +
  labs(
    x = "16S Hypervariable Region",
    y = "Sequencing Depth",
    fill = "Pipeline"
  ) +
  
  theme_pubr(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


print(depth_plot)

##################################
#Analysis on TSS normalizaed data#
##################################


#pre-processing
otu_tot_gen<- otu_raw_gen%>%column_to_rownames("Genus")%>%otu_table(taxa_are_rows = T)

otu_tot_TSS_gen <- norm_tss(otu_tot_gen) #normalization

otu_tot_TSS_df_gen <- as.data.frame(otu_table(otu_tot_TSS_gen))

otu_tot_TSS_df_gen[otu_tot_TSS_df_gen == "NaN"] <- 0

otu_tss_pivot_gen<- otu_tot_TSS_df_gen%>%rownames_to_column("Genus")%>%pivot_longer(-Genus, values_to = "value", names_to = "ID")%>%
  left_join(metadata_total, by="ID")%>%as.data.frame()  #pivot_longer + metadata merging

str(otu_tss_pivot_gen)

# extract the "Ground Truth" data
ground_truth_df <- otu_tss_pivot_gen %>%
  filter(analysis_type == "theoric"&value>0)

# vector of the true genera names for presence/absence checks
truth_genera <- unique(ground_truth_df$Genus)

#data frame of only the "Observed" results
observed_data <- otu_tss_pivot_gen %>%
  filter(analysis_type != "theoric" & value > 0)

# This function will compare a list of observed genera to the truth set
calculate_metrics <- function(observed_genera, truth_genera) {
  TP <- length(intersect(observed_genera, truth_genera))
  FP <- length(setdiff(observed_genera, truth_genera))
  FN <- length(setdiff(truth_genera, observed_genera))
  
  sensitivity <- if ((TP + FN) > 0) TP / (TP + FN) else 0
  precision <- if ((TP + FP) > 0) TP / (TP + FP) else 0
  f1_score <- if ((precision + sensitivity) > 0) 2 * (precision * sensitivity) / (precision + sensitivity) else 0
  
  return(data.frame(TP, FP, FN, sensitivity, precision, f1_score))
}

# Apply this function to every group in our OBSERVED data
performance_metrics <- observed_data %>%
  
  dplyr::group_by(analysis_type, region, Genus) %>%
  summarise(mean_abundance = mean(value, na.rm = TRUE), .groups = "drop") %>%
  dplyr::filter(mean_abundance > 0) %>% # Keep only detected genera
  dplyr::group_by(analysis_type, region) %>%
  reframe(calculate_metrics(Genus, truth_genera))


print(performance_metrics)


########################################
#pairwise correlation analysis 


meta_df <- observed_data %>%
  dplyr::select(sampleID = ID, paired_id=sample, region)%>%distinct()%>%
  column_to_rownames("sampleID")%>%
  mutate(sampleID=rownames(.))

otu_df<- observed_data%>%
  dplyr::group_by(sampleID=ID, Genus)%>%
  dplyr::summarise(abu=value*100)%>%
  pivot_wider(names_from = Genus, values_from = abu, values_fill = 0 )%>%
  as.data.frame(., stringsAsFactors = FALSE)

regions    <- sort(unique(meta_df$region))
comparisons <- combn(regions, 2, simplify = FALSE) %>%
  map_chr(~ paste(.x, collapse = " vs "))


safe_cor  <- safely(cor.test)

all_results <- map_dfr(comparisons, function(comp_label) {
  regs <- str_split(comp_label, " vs ", simplify = TRUE)
  r1 <- regs[1]; r2 <- regs[2]
  
  common_ids <- intersect(
    filter(meta_df, region == r1)$paired_id,
    filter(meta_df, region == r2)$paired_id
  )
  
  map_dfr(common_ids, function(fam) {
    s1 <- filter(meta_df, paired_id == fam, region == r1)$sampleID
    s2 <- filter(meta_df, paired_id == fam, region == r2)$sampleID
    
    mat <- otu_df %>%
      filter(sampleID %in% c(s1, s2)) %>%
      column_to_rownames("sampleID") %>%
      as.matrix() %>%
      .[, colSums(.) > 0, drop = FALSE]
    
    n_otus <- ncol(mat)
    
    
    if (n_otus >= 3) {
      
      result <- safe_cor(mat[1, ], mat[2, ], method = "pearson") 
      if (is.null(result$error)) {
        ct <- result$result
        tibble(
          paired_id  = fam,
          comparison = comp_label,
          R_value    = unname(ct$estimate),
          P_value    = ct$p.value,
          n_otus     = n_otus
        )
      } else {
        tibble(
          paired_id  = fam,
          comparison = comp_label,
          R_value    = NA_real_,
          P_value    = NA_real_,
          n_otus     = n_otus
        )
      }
    } else {
      # This part correctly handles cases with not enough shared taxa
      tibble(
        paired_id  = fam,
        comparison = comp_label,
        R_value    = NA_real_,
        P_value    = NA_real_,
        n_otus     = n_otus
      )
    }
  })
})


#plot preparation

comparison_filter <- c("IR vs V2-9","IR vs V2","IR vs V3","IR vs V4","IR vs V6-7","IR vs V8", "IR vs V9" )
all_results_fil <- all_results%>%dplyr::filter(comparison%in%comparison_filter)

all_results_fil <- all_results_fil%>%mutate(p.adj=p.adjust(P_value, method = "BH"))

summary_cor_res <- all_results_fil%>%na.omit()%>%
  dplyr::group_by(comparison)%>%
  dplyr::summarise(mean_log10padj=(-log10(mean(p.adj))),
                   mean_R=mean(R_value))


# Ensure 'region' is a factor with specified levels
all_results_fil$comparison <- factor(all_results_fil$comparison, levels = comparison_filter)


pairwise_corr_plot<- ggplot(all_results_fil, aes(x = comparison, y = -log10(p.adj), fill="gray30", )) +
  geom_boxplot(outlier.shape = NA, fill="gray30") +
  geom_jitter( size = 1, alpha = 0.6,position = position_dodge(width=0.15)) +
  geom_line(aes(group = paired_id), color="grey70", alpha=0.3) +
  labs(
    x     = "Pearson Correlation of Abundance Profiles",
    y     = "-Log(p-adjust)"
  ) +
  guides(y = guide_axis(minor.ticks = T))+
  theme_pubr(base_size = 14)+
  theme(
    axis.text.x = element_text(angle = 30, hjust = 1)
  )+
  theme(legend.position="none")+
  geom_hline(yintercept=-log(0.05), linetype="dashed", color="black")

print(pairwise_corr_plot)

######################
