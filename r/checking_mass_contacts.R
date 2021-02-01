
library(data.table)

## Compare A and B misisng in cnt_home
nnn <- qs::qread('data/clean/archive/2020-12-04_contacts.qs')

new <- qs::qread('data/clean/contacts_v1.qs')
old <- nnn[panel %in% c("A", "B")]
table(old$cnt_home  , old$survey_round, useNA = "ifany")
table(new$cnt_home  , new$survey_round, useNA = "ifany")
table(old$cnt_work  , old$survey_round, useNA = "ifany")
table(new$cnt_work  , new$survey_round, useNA = "ifany")
table(old$cnt_school, old$survey_round, useNA = "ifany")
table(new$cnt_school, new$survey_round, useNA = "ifany")
table(old$cnt_other , old$survey_round, useNA = "ifany")
table(new$cnt_other , new$survey_round, useNA = "ifany")
nrow(new) 
nrow(old)

## There is an issue with a large number of other contacts missing a value. Should probably be zero. 
## But the data is now consistent with how it was previously

## Panel C and D
new <- qs::qread('data/clean/households_v2.qs')
#nnn <- qs::qread('data/clean/archive/2020-12-04_households.qs')
old <- nnn[panel %in% c("C", "D")]

nrow(old)-nrow(new)


new <- qs::qread('data/clean/contacts_v2.qs')
old <- nnn[panel %in% c("C", "D")]
nrow(old)-nrow(new)

new[, table(cnt_mass)]
old[, table(cnt_mass)]

old[part_wave_uid == "uk_C2_30002", ]
new[part_wave_uid == "uk_C2_30002", ]
old[part_wave_uid == "uk_C1_30318", .(cnt_age_group, cnt_home, cnt_other, cnt_work, cnt_age)]
new[part_wave_uid == "uk_C1_30318", .(cnt_age_group, cnt_home, cnt_other, cnt_work, cnt_age)]

table(old$cnt_home  , old$survey_round, useNA = "ifany")
table(new$cnt_home  , new$survey_round, useNA = "ifany")
table(old$cnt_work  , old$survey_round, useNA = "ifany")
table(new$cnt_work  , new$survey_round, useNA = "ifany")
table(old$cnt_school, old$survey_round, useNA = "ifany")
table(new$cnt_school, new$survey_round, useNA = "ifany")
table(old$cnt_other , old$survey_round, useNA = "ifany")
table(new$cnt_other , new$survey_round, useNA = "ifany")

table(old$cnt_school, old$cnt_mass, useNA = "ifany")
table(new$cnt_school, new$cnt_mass, useNA = "ifany")
table(new$cnt_home, new$cnt_mass, useNA = "ifany")
table(new$cnt_work, new$cnt_mass, useNA = "ifany")
table(new$cnt_school, new$cnt_mass, useNA = "ifany")
table(old$cnt_other, old$cnt_mass, useNA = "ifany")
table(new$cnt_other, new$cnt_mass, useNA = "ifany")

## We are dropping 3,499 observations
x5 <- qs::qread('data/processing/combined_5_v3.qs')
x6 <- qs::qread('data/processing/combined_6_v3.qs')
x8 <- qs::qread('data/processing/combined_8_v3.qs')

x5[, table(cnt_home, useNA = "ifany")]
x6[, table(multiple_contacts_child_school, useNA = "ifany")]
sum(as.numeric(x6[survey_round<37]$multiple_contacts_adult_work), na.rm = T)
sum(as.numeric(x6[survey_round<37]$multiple_contacts_adult_school), na.rm = T)
sum(as.numeric(x6[survey_round<37]$multiple_contacts_child_school), na.rm = T)
sum(as.numeric(x6[survey_round<37]$multiple_contacts_child_other), na.rm = T)


library(data.table)
x7 <- qs::qread('data/processing/combined_7_v3.qs')
x7[!is.na(cnt_mass), table(cnt_home, useNA = "ifany")]


x7[!is.na(cnt_mass), table(cnt_home, cnt_mass, useNA = "ifany")]
x7[!is.na(cnt_mass), table(cnt_home, parent_child, useNA = "ifany")]

x7[!is.na(cnt_mass) & is.na(cnt_home), .(part_id, row_id, cnt_mass, cnt_home, cnt_age, parent_child, hhm_contact)]
x5[part_id == "30002", .(cnt_mins, part_id, panel)]
x6[part_id == "30002", .(cnt_mins, part_id, panel)]
x7[part_id == "30002", .(cnt_mins, part_id, panel)]

table(old$cnt_home, old$cnt_age, useNA = "ifany")
table(new$cnt_home, new$cnt_age, useNA = "ifany")
table(new$cnt_home, useNA = "ifany")
table(x5$cnt_home)
table(x6$cnt_home)
table(x7$cnt_home, useNA = "ifany")
table(x8$cnt_home)
x5[row_id %in% c(0,999), table(multiple_contacts_adult_work,row_id, useNA = "ifany")]
x6[row_id %in% c(0,999), table(multiple_contacts_adult_work,row_id, useNA = "ifany")]
x5[row_id %in% c(0,999), table(cnt_home, row_id,useNA = "ifany")]
x6[row_id %in% c(0,999), table(cnt_home, row_id,useNA = "ifany")]
x5[row_id %in% c(0,999), table(hhm_contact, row_id,useNA = "ifany")]
x6[row_id %in% c(0,999), table(hhm_contact, cnt_home, useNA = "ifany")]



table(new$cnt_home)
table(old$cnt_home)
table(new$cnt_work)
table(old$cnt_work)
table(new$cnt_school, new$cnt_mass)
table(old$cnt_school)
table(new$cnt_other)
table(old$cnt_other)
table(x5$cnt_home, useNA = "ifany")
table(x6$cnt_home, useNA = "ifany")

x6[multiple_contacts_child_school>500, .(part_id, multiple_contacts_child_school, row_id, wave)]

table(x5$multiple_contacts_adult_other, useNA = "ifany")
table(x6$multiple_contacts_adult_other, useNA = "ifany")

nrow(x5)
nrow(x6)
table(x6$cnt_home, useNA = "ifany")

table(new$survey_round)
table(x5$survey_round)
table(x6$survey_round)
table(x7$survey_round, useNA = "ifany")
table(x8$survey_round)
nrow(new) 
nrow(old)

## Difference in the missing values and the total number of contacts
new <- qs::qread('data/clean/contacts_v3.qs')
new <- new[survey_round<37]
old <- nnn[panel %in% c("E", "F")]
table(old$cnt_home  , old$survey_round, useNA = "ifany")
table(new$cnt_home  , new$survey_round, useNA = "ifany") # More missing home as contact
table(old$cnt_work  , old$survey_round, useNA = "ifany")
table(new$cnt_work  , new$survey_round, useNA = "ifany") # More missing work as contact
table(old$cnt_school, old$survey_round, useNA = "ifany")
table(new$cnt_school, new$survey_round, useNA = "ifany") ## school contacts have increased quite a bit
table(old$cnt_other , old$survey_round, useNA = "ifany")
table(new$cnt_other , new$survey_round, useNA = "ifany") ## Other contacts have also increased quite a bit.

### check old and new contacts
table(old$cnt_home, useNA = "ifany")
table(new$cnt_home, useNA = "ifany")

table(new$cnt_work, useNA = "ifany")
table(old$cnt_work, useNA = "ifany")

table(new$cnt_other, useNA = "ifany")
table(old$cnt_other, useNA = "ifany")

table(new$cnt_school, useNA = "ifany")
table(old$cnt_school, useNA = "ifany")
table(new$cnt_school, new$cnt_mass, useNA = "ifany")
table(old$cnt_school, old$cnt_mass, useNA = "ifany")
table(new$cnt_other, new$cnt_mass, useNA = "ifany")
table(old$cnt_other, old$cnt_mass, useNA = "ifany")
## Also way more missing values. 
nrow(new)
nrow(old)

## We are dropping 3,499 observations
nrow(new[survey_round<37]) 
nrow(old)
nrow(old) - nrow(new[survey_round<37]) 
## 700643 rows difference. 16*500


## I might have been missing the mass school contacts for E and F or it's double counting them now. 

table(old$cnt_home, old$cnt_mass, useNA = "ifany")
table(new$cnt_home, new$cnt_mass, useNA = "ifany")
## There are 9,427 with cnt_home missing now. Must be the kids
table(old$cnt_work, old$cnt_mass, useNA = "ifany")
table(new$cnt_work, new$cnt_mass, useNA = "ifany")
## Same 9,427 figure out who they are
table(old$cnt_school, old$cnt_mass, useNA = "ifany")
table(new$cnt_school, new$cnt_mass, useNA = "ifany")
# Same with school


table(old$cnt_other, old$cnt_mass, useNA = "ifany")
table(new$cnt_other, new$cnt_mass, useNA = "ifany")

