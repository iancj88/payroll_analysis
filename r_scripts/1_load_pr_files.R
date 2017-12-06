add_col_to_df_list <- function(dfs, values, new_col_name) {
  dfs_out <- mapply(FUN = add_values, dfs, values, new_col_name, SIMPLIFY = F)
}

add_values <- function(df, values, new_col_name) {
  value_vec <- c(rep(values, nrow(df)))
  df$new_name <- value_vec
  names(df)[names(df) == "new_name"] <- new_col_name
  return(df)
}

load_payroll_files <- function(src_folder_path = "./src/") {
  
  require(readr)
  require(data.table)
  require(magrittr)
  require(dplyr)
  
  # Load payroll files contained in the source directory file
  filenames <- list.files(path = src_folder_path)
  filepaths <- list.files(path = src_folder_path, 
                          full.names = T)
  
  col_types_fread <- list(character = c("GID",
                                        "Name",
                                        "Position Number",
                                        "Suffix", 
                                        "Earn Code", 
                                        "Earn Code Desc", 
                                        "Index", 
                                        "Activity Code", 
                                        "Organization"),
                          double = c("Hours or Units", 
                                     "Amount", 
                                     "Percent"))
  
  pr_data <- lapply(filepaths, 
                    FUN = fread,
                    sep = ";",
                    skip = 8,
                    colClasses = col_types_fread) #%>%
  #lapply(setDF)
  
  #add data stored in file names
  pr_year <- as.numeric(substr(filenames, 1, 4))
  pr_number <- as.numeric(substr(filenames, 7, 8))
  pr_month <- pr_number - 1
  pr_month[pr_month == 0] <- 12
  pr_year[pr_month == 12] <- pr_year[pr_month == 12] - 1
  pr_quarter <- cut(pr_month,
                    breaks = 4,
                    labels = F)
  pr_fy <- pr_year
  pr_fy[pr_quarter > 2] <- pr_year[pr_quarter > 2] + 1
  
  pr_data <- add_col_to_df_list(pr_data, values = pr_year, new_col_name = "Year") %>%
    add_col_to_df_list(values = pr_fy, new_col_name = "Fiscal Year") %>%
    add_col_to_df_list(values = pr_month, new_col_name = "Month") %>%
    add_col_to_df_list(values = pr_number, new_col_name = "Payroll Number")
  
  pr_data <- bind_rows(pr_data) %>%
    setDF()
  
  
  return(pr_data)
}