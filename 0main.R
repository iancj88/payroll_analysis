
source("./r_scripts/1_load_pr_files.R")
require(dplyr)
# set constants for script
src_pr_folder <- "./src/"

# Load the pr_data
pr_data <- load_payroll_files(src_pr_folder)

# compile each individuals yearly payout
total_person_wages <- group_by(pr_data, `Fiscal Year`, GID) %>%
  summarize(total_wages = sum(Amount))