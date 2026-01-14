library(lavaan)

# 1. Setup
setwd('D:/Dropbox/Publications/2024_Heat_Disparity/upload_v0114') # specify your own working directory

# Create sub folders of results and fit_stats
target_folders <- c("results", "fit_stats")

for (folder in target_folders) {
  # 1. Delete the directory if it exists
  if (dir.exists(folder)) {
    # recursive = TRUE is mandatory to delete a non-empty folder
    unlink(folder, recursive = TRUE)
    message(paste("Deleted existing folder:", folder))
  }
  
  # 2. Create the fresh directory
  dir.create(folder)
  message(paste("Created fresh folder:", folder))
}

# read the analytical dataset
data <- read.csv("data0114.csv")

coefs_export <- c('total','direct',"direct_price_compact","direct_price_large_low_rise",
                  "direct_price_UGS","direct_compact_LST","direct_large_low_rise_LST",
                  "direct_UGS_LST","indirect_compact","indirect_large_low_rise",
                  "indirect_UGS","indirect_all")

core_predictors <- c("compact", "large_low_rise", "UGS", "housing_price", "Distance", "District_id")
all_dist_cols <- grep("^Dist_", colnames(data), value = TRUE)

for (var_name in colnames(data)) {
  # Isolating the columns starting with T20 - which represent LST observations from different times
  if (startsWith(var_name, "T20")) {
    
    # 2. Complete Case Subset for this specific iteration
    cols_needed <- c(var_name, core_predictors, all_dist_cols)
    sub_data <- data[complete.cases(data[, cols_needed]), ]
    
    # 3. Identify the Reference District (Largest Observation Count)
    # Calculate sums for each Dist_ column in the current subset
    dist_counts <- colSums(sub_data[, all_dist_cols])
    ref_district <- names(which.max(dist_counts))
    
    # 4. Filter Valid Districts (Excluding the dynamic reference group)
    # Must have variance > 0 AND not be the reference district
    valid_dists <- all_dist_cols[all_dist_cols != ref_district & 
                                   sapply(sub_data[all_dist_cols], function(x) var(x, na.rm=TRUE) > 0)]
    
    dist_string <- if(length(valid_dists) > 0) paste0(" + ", paste(valid_dists, collapse = " + ")) else ""
    
    print(paste("Iteration:", var_name, "| Reference Dist (Dropped):", ref_district, "| Sample Size:", nrow(sub_data)))
    
    # 5. Construct Model
    model <- sprintf("
          %s ~ A*compact + B*large_low_rise + C*UGS + d*housing_price + Distance %s
          compact ~ a*housing_price + Distance %s
          large_low_rise ~ b*housing_price + Distance %s
          UGS ~ c*housing_price + Distance %s
          
          total := d + A*a + B*b + C*c
          direct := d
          direct_price_compact := a
          direct_price_large_low_rise := b
          direct_price_UGS := c
          direct_compact_LST := A
          direct_large_low_rise_LST := B
          direct_UGS_LST := C
          indirect_compact := A*a
          indirect_large_low_rise := B*b
          indirect_UGS := C*c
          indirect_all := A*a + B*b + C*c", 
                     var_name, dist_string, dist_string, dist_string, dist_string)
    
    # 6. Fit Model
    fit <- try(sem(model, data = sub_data, estimator = "mlm", cluster = 'District_id'), silent = TRUE)
    
    if(!inherits(fit, "try-error")) {
      # Rounding and Exporting Coefficients
      coef <- parameterEstimates(fit, level = 0.95)
      coef <- coef[coef[,"label"] %in% coefs_export, ]
      num_cols_coef <- sapply(coef, is.numeric)
      coef[num_cols_coef] <- round(coef[num_cols_coef], 4)
      write.csv(coef, sprintf("results/coef_%s.csv", var_name), row.names = TRUE)
      
      # Rounding and Exporting Fit Measures
      fits <- fitMeasures(fit, c("chisq.scaled","pvalue.scaled","srmr",
                                 "cfi.scaled","rmsea.scaled",
                                 "rmsea.ci.lower.scaled","rmsea.ci.upper.scaled"))
      fits <- round(fits, 4)
      write.csv(fits, sprintf("fit_stats/fit_%s.csv", var_name), row.names = TRUE)
    } else {
      message(paste("Model failure for:", var_name))
    }
  }
}


