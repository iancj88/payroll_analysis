
source("./r_scripts/1_load_pr_files.R")
require(dplyr)
# set constants for script
src_pr_folder <- "./src/"

# Load the pr_data
pr_data <- load_payroll_files(src_pr_folder)

# Add a job key comprised of GID, Position Number, and suffix
pr_data$Job_Key <- paste0(pr_data$GID, pr_data$`Position Number`, pr_data$Suffix)

# load the total wage lookup table and add the boolean applicability to the
# master file
total_wage_lu <- load_earn_code_lu()
total_wage_lu <- select(total_wage_lu, -earn_code_desc)
pr_data <- left_join(x = pr_data,
                     y = total_wage_lu,
                     by = c("Earn Code" = "earn_code"))

# # get the earn code documentation for inclusion on any summary tables
# earn_code_defs <- read_csv(file = "./used_ec_documentation.csv")

# base gross earn codes defined by Max T.
base_gross_earn_codes <- c("REG", "STU", "ANX", "MIL", "SCK", "OT" )

# # get the all ee data on hand from 2016, this is sourced from the emr_v2 project
# all_ee_2016 <- readRDS("./2016_data.rds")
# 
# # get the 2016 pr data
# pr_2016 <- filter(pr_data, Year == 2016)
# 
# # only look at base wages
# pr_2016_base <- filter(pr_2016, `Earn Code` %in% base_gross_earn_codes)
# 
# # summarize per person onto which the job title will be joined
# pr_2016_base$Job_Date_Key <- paste0(pr_2016_base$Job_Key, pr_2016_base$Month)
# 
# pr_2016_summary <- group_by(pr_2016_base, Job_Key) %>%
#   summarize(total_base_annual_salary = sum(Amount), month_count = n_distinct(Month))
# 
# # add the name, job title from the all ee dataset
# all_ee_subcols <- select(all_ee_2016, 
#                          Key, 
#                          GID,
#                          FullName, 
#                          `Job Title`, 
#                          EMRJobType)
# 
# pr_2016_summary <- left_join(pr_2016_summary,
#                              all_ee_subcols,
#                              by = c("Job_Key" = "Key")) %>%
#   distinct(Job_Key, .keep_all = TRUE) %>%   # remove duplicate rows of the job keys 
#                                             # corresponding to each month of payment
#   filter(!EMRJobType %in% c("Student",      # remove employee types and NA values
#                             "Grad Asst.", 
#                             "Non-Job Payment",
#                             "Temporary"),
#          !is.na(EMRJobType)) %>%
#   select(-Job_Key)
# 
# openxlsx::write.xlsx(pr_2016_summary, file = "./Salary_Data_2016.xlsx")
# 
