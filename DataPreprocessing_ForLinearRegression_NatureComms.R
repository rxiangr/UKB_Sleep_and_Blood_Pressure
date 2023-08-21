# Data Processing and filtering UK Biobank data
# Access to UK biobank data was through application to UK biobank (www.ukbiobank.ac.uk) 
# All filtering and preprocessing was done on the BAKER server. 
# Note baseline data was used in the analysis

# load libraries
library(ggplot2)
library(ukbtools)
library(data.table)
library(dplyr) # union function for dataframe
library(tidyr)
library(lubridate)
library(stringr)
library(R.utils)
library(summarytools)

# load the data 
load("ukb_data.rda")

#1. Filter the data to keep individuals who have self reported ethnicity is British White
data$British_White <- ifelse((!is.na(data$ethnic_background_f21000_0_0)) &
                                  data$ethnic_background_f21000_0_0 == "British", TRUE, FALSE)

data <- data %>% filter(British_White == "TRUE")

#2. Sleep duration 
## set individuals with value -3 (Prefer not to answer); value -1 (Do not know) to NA 
data <- data %>% mutate(sleep_duration = case_when(!is.na(sleep_duration_f1160_0_0) &
                                       sleep_duration_f1160_0_0 < 0 ~ NA_character_,
                                       is.na(sleep_duration_f1160_0_0) ~ NA_character_,
                                       sleep_duration_f1160_0_0 > 0 & sleep_duration_f1160_0_0 <= 5 ~ "<=5",
                                       sleep_duration_f1160_0_0 > 0 & sleep_duration_f1160_0_0 <= 6 ~ "6",
                                       sleep_duration_f1160_0_0 > 0 & sleep_duration_f1160_0_0 <= 7 ~ "7",
                                       sleep_duration_f1160_0_0 > 0 & sleep_duration_f1160_0_0 <= 8 ~ "8",
                                       sleep_duration_f1160_0_0 > 0 & sleep_duration_f1160_0_0 >= 9 ~ ">=9"))
  

#3. Chronotype 
## set individuals who responded “Prefer not to answer” and “Do not know” to NA 
data <- data %>% mutate(chronotype = case_when(!is.na(morningevening_person_chronotype_f1180_0_0) &
                        morningevening_person_chronotype_f1180_0_0 %in% c("Do not know", "Prefer not to answer") ~ NA_character_,
                        is.na(morningevening_person_chronotype_f1180_0_0) ~ NA_character_,
                        morningevening_person_chronotype_f1180_0_0 %in% c("Definitely a 'morning' person",
                                                                          "More a 'morning' than 'evening' person") ~ "Morning",
                        morningevening_person_chronotype_f1180_0_0 %in% c("Definitely an 'evening' person",
                                                                          "More an 'evening' than a 'morning' person") ~ "Night"))
                        
#4. Shift work
## Shift work variable was derived from two variables 
## a."Does your work involve shift work? (field - 826)"
### Here we set individuals who answered “Prefer not to answer” and “Do not know” tp NA 
data <- data %>% mutate(shiftwork = ifelse(!is.na(job_involves_shift_work_f826_0_0) &
                                         job_involves_shift_work_f826_0_0 %in% c("Do not know", "Prefer not to answer"), NA_character_, 
                                         as.character(job_involves_shift_work_f826_0_0)))

data$shiftwork[data$shiftwork== "Never/rarely"] <- "noshift"
                          
## b."Does your work involve night shifts?** (field - 3426)"
### Here we set individuals who answered “Prefer not to answer” and “Do not know” tp NA                          

data <- data %>% mutate(nightshift = ifelse(!is.na(job_involves_night_shift_work_f3426_0_0) &
                                              job_involves_night_shift_work_f3426_0_0 %in% c("Do not know", "Prefer not to answer"), NA_character_, 
                                           as.character(job_involves_night_shift_work_f3426_0_0)))


## c. Now combine the different combinations from a. Shift work and b. nightshift



#table(paste(dat$night, dat$shift))
data$shiftwork_status<- paste(data$shiftwork, data$nightshift,sep="_")

data <- data %>% mutate(shiftwork_status_new = case_when(shiftwork_status ==  "Always_Always" ~ "PermanentNight",
                                                         shiftwork_status %in% c("Sometimes_Never/rarely", "Usually_Never/rarely", "Always_Never/rarely") ~ "DayShift",
                                                         shiftwork_status %in% c("Always_Sometimes", "Sometimes_Sometimes", "Usually_Sometimes") ~  "MixedShift",
                                                         shiftwork_status %in% c("Always_Usually", "Usually_Usually","Usually_Always", "Sometimes_Always", "Sometimes_Usually") ~  "NightShift",
                                                         shiftwork_status %in% c("noshift_NA") ~  "noshift",
                                                         TRUE ~ NA_character_))

                       
#5. Processing BP variable 
# Note we used automated blood pressure and only used manual reading when automated reading was not available
## Step 1
### There were two readings for automated blood pressure - We took the average between the two for the analysis
### But first we set individuals whose difference between reading1 and reading2 difference was 3sd away from the mean BP difference of the population
##### automated reading ########
## take the average between the two readings
data$BP_diastolic_Mean <- rowMeans(data[, c("diastolic_blood_pressure_automated_reading_f4079_0_0", "diastolic_blood_pressure_automated_reading_f4079_0_1")], na.rm=TRUE)
data$BP_diastolic_Mean[which(is.na(data$BP_diastolic_Mean))] <- NA
data$BP_systolic_Mean <- rowMeans(data[, c("systolic_blood_pressure_automated_reading_f4080_0_0", "systolic_blood_pressure_automated_reading_f4080_0_1")], na.rm=TRUE)
data$BP_systolic_Mean[which(is.na(data$BP_systolic_Mean))] <- NA

## calculate the difference between the two readings 
data$BP_systolic_diff <- data$systolic_blood_pressure_automated_reading_f4080_0_0 -  data$systolic_blood_pressure_automated_reading_f4080_0_1
data$BP_diastolic_diff <- data$diastolic_blood_pressure_automated_reading_f4079_0_0 - data$diastolic_blood_pressure_automated_reading_f4079_0_1

## calculate the mean and sd of the difference
m_sys <- mean(data$BP_systolic_diff, na.rm=TRUE)
s_sys <- sd(data$BP_systolic_diff, na.rm=TRUE)
m_dia <- mean(data$BP_diastolic_diff, na.rm=TRUE)
s_dia <- sd(data$BP_diastolic_diff, na.rm=TRUE)

## calculate 3sd away from mean for systolic
m3sd_sys_up <- m_sys + 3*s_sys
m3sd_sys_down <- m_sys - 3*s_sys

## correct for systolic BP 
data$BP_systolic_corrected <- data$BP_systolic_Mean
data$BP_systolic_corrected[which(data$BP_systolic_diff < m3sd_sys_down)] <- NA
data$BP_systolic_corrected[which(data$BP_systolic_diff > m3sd_sys_up)] <- NA

## calculate 3sd away from mean for diastolic
m3sd_dia_up <- m_dia + 3*s_dia
m3sd_dia_down <- m_dia - 3*s_dia

## correct for diastolic BP
data$BP_diastolic_corrected <- data$BP_diastolic_Mean
data$BP_diastolic_corrected[which(data$BP_diastolic_diff < m3sd_dia_down)] <- NA
data$BP_diastolic_corrected[which(data$BP_diastolic_diff > m3sd_dia_up)] <- NA

## Step 2 - processing the manual reading
## Take the average between the two manual readings systolic
data$Manual_diastolic_Mean <- rowMeans(data[, c("diastolic_blood_pressure_manual_reading_f94_0_0", "diastolic_blood_pressure_manual_reading_f94_0_1")], na.rm=TRUE)
data$Manual_diastolic_Mean[which(is.na(data$Manual_diastolic_Mean))] <- NA

## Take the average between the two manual readings diastolic
data$Manual_systolic_Mean <- rowMeans(data[, c("systolic_blood_pressure_manual_reading_f93_0_0", "systolic_blood_pressure_manual_reading_f93_0_1")], na.rm=TRUE)
data$Manual_systolic_Mean[which(is.na(data$Manual_systolic_Mean))] <- NA

## calculate the difference
data$Manual_systolic_diff <- data$systolic_blood_pressure_manual_reading_f93_0_0 -  data$systolic_blood_pressure_manual_reading_f93_0_1
data$Manual_diastolic_diff <- data$diastolic_blood_pressure_manual_reading_f94_0_0 -  data$diastolic_blood_pressure_manual_reading_f94_0_1

## calclate the 3sd away from mean difference
m_sys <- mean(data$Manual_systolic_diff, na.rm=TRUE)
s_sys <- sd(data$Manual_systolic_diff, na.rm=TRUE)
m_dia <- mean(data$Manual_diastolic_diff, na.rm=TRUE)
s_dia <- sd(data$Manual_diastolic_diff, na.rm=TRUE)

m3sd_sys_up <- m_sys + 3*s_sys
m3sd_sys_down <- m_sys - 3*s_sys

m3sd_dia_up <- m_dia + 3*s_dia
m3sd_dia_down <- m_dia - 3*s_dia

# set readings 3sd away from the average of the difference between reading 1 and reading 2 to NA
data$Manual_systolic_corrected <- data$Manual_systolic_Mean
data$Manual_systolic_corrected[which(data$Manual_systolic_diff < m3sd_sys_down)] <- NA
data$Manual_systolic_corrected[which(data$Manual_systolic_diff > m3sd_sys_up)] <- NA

data$Manual_diastolic_corrected <- data$Manual_diastolic_Mean
data$Manual_diastolic_corrected[which(data$Manual_diastolic_diff < m3sd_dia_down)] <- NA
data$Manual_diastolic_corrected[which(data$Manual_diastolic_diff > m3sd_dia_up)] <- NA


## Step 3 - # Colease individuals with NA for automated BP reading with manual
data <- data %>% mutate(BP_systolic_coalesced = coalesce(BP_systolic_corrected, Manual_systolic_corrected))
data <- data %>% mutate(BP_diastolic_coalesced = coalesce(BP_diastolic_corrected, Manual_diastolic_corrected))


# Step4  - adjust the BP of individuals on BP medication by adding 15 and 10 respectively for 
data$BP_systolic_adjusted <- ifelse(is.na(data$Medication_BloodPressureMed), data$BP_systolic_coalesced , 
                                    ifelse(data$Medication_BloodPressureMed == "BloodPressureMed", data$BP_systolic_coalesced  + 15, data$BP_systolic_coalesced))
data$BP_diastolic_adjusted <- ifelse(is.na(data$Medication_BloodPressureMed), data$BP_diastolic_coalesced, 
                                     ifelse(data$Medication_BloodPressureMed == "BloodPressureMed", data$BP_diastolic_coalesced + 10, data$BP_diastolic_coalesced))