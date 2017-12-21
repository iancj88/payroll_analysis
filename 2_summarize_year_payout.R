summarize_year_payout <- function(year_input, rds_file_path) {
  pacman::p_load(dplyr, readr, lubridate)
  
  # make sure that the pr_data is loaded into the pr_data dataframe
  # will throw an error if the payroll files are not included in the
  # './src/' directory
  if(!exists("pr_data")) {
    source("./0main.R")
  }
  
  # get the all employees data from the input rds file location
  # typically this is produced from the EMR_v2 main script
  all_ee_data <- readRDS(rds_file_path)
  
  # get the all ee data on hand for the requested year, 
  # this is sourced from the emr_v2 project
  # if(!file.exists("./allee_data.rds")) {
  #   source("../EMR_v2/R_scripts/Get_Year_Data.R")
  #   Get_Year_Data(year, "./allee_data.rds")
  # }
  # all_ee_data <- readRDS("./allee_data.rds")
  
  # get the 2016 pr data, all ee data
  pr_year <- filter(pr_data, Year == year_input)
  all_ee_data <- filter(all_ee_data, lubridate::year(Date) == year_input)
  
  # base gross earn codes defined by Max T.
  base_gross_earn_codes <- c("REG", "STU", "ANX", "MIL", "SCK", "OT" )

  # only look at base wages
  pr_year_base <- filter(pr_year, 
                         `Earn Code` %in% base_gross_earn_codes)
  
  # summarize per person onto which the job title will be joined
  # compile total base earning and the number of months in which a
  # payment was made into the account
  pr_year_summary <- group_by(pr_year_base, 
                              Job_Key) %>%
    summarize(total_base_annual_salary = sum(Amount), 
              month_count = n_distinct(Month))
  
  analysis_df <- left_join(pr_year_base, pr_year_summary)
  
  # filter out jobs with 0 total payouts for the year
  # this occurs for some jobs on LWOP and should not be included
  # also remove jobs with only 1 month of payout as 'temp' jobs
  pr_year_summary <- filter(pr_year_summary, 
                            total_base_annual_salary > 0)
                            #month_count > 1)
  
  # add the name, job title from the all ee dataset
  all_ee_subcols <- select(all_ee_data,
                           Key,
                           GID,
                           FullName,
                           `Job Title`,
                           EMRJobType,
                           `Hourly Rate`,
                           BaseAndLongHourly)
  
  pr_year_summary <- left_join(pr_year_summary,
                               all_ee_subcols,
                               by = c("Job_Key" = "Key")) %>%
    distinct(Job_Key, .keep_all = TRUE) %>%   # remove duplicate rows of the job keys 
                                              # corresponding to each month of payment
    filter(!EMRJobType %in% c("Student",      # remove employee types and NA values
                              "Grad Asst.",
                              "Non-Job Payment",
                              "Temporary"),
           !is.na(EMRJobType)) #%>%
    #select(-Job_Key, -GID)
  
  openxlsx::write.xlsx(pr_year_summary, file = paste0("./Salary_Data_", year_input, ".xlsx"))
  return(pr_year_summary)
}