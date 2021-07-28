## Name: dm_count_contacts.R
## Description: Clean variables not need for the contacts - less important for R.
## Input file: combined_8.qs
## Functions:
## Output file: combined_9.qs



# Packages ----------------------------------------------------------------
library(data.table)

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# I/O Data ----------------------------------------------------------------

  
## Save participant data

pt <- qs::qread("../comix/data/part_min.qs")
ct <- qs::qread("../comix/data/contacts.qs")
pt <- pt[country == "uk"]
ct <- ct[country == "uk"]

ct$cnt_inside <- as.numeric(ct$cnt_inside)
ct$cnt_outside <- as.numeric(ct$cnt_outside)

# Map objects for labels --------------------------------------------------
cnt_main_vars <- c(
  "cnt_home", 
  "cnt_work",
  "cnt_school",
  "cnt_other",
  "cnt_phys"
)

cnt_other_vars <- c(
  "cnt_inside", 
  "cnt_outside", 
  "cnt_sport", 
  "cnt_outside_other",
  "cnt_other_place", 
  "cnt_other_house",
  "cnt_worship",
  "cnt_public_transport", 
  "cnt_supermarket",
  "cnt_shop",
  "cnt_bar_rest",
  "cnt_health_facility", 
  "cnt_salon",
  "cnt_public_market",
  "cnt_household"
)

cnt_vars <- c(cnt_main_vars, cnt_other_vars)
all_vars <- c(cnt_vars, "part_wave_uid")
ct <- ct[, ..all_vars]

sumna <- function(x) sum(x, na.rm = TRUE)

cp_n_cnts <- ct[, .(
  n_cnt = .N,
  n_cnt_home               = sumna(cnt_home),
  n_cnt_home_not_household = sumna(cnt_home*((cnt_household-1)^2)),
  n_cnt_home_household = sumna(cnt_home*((cnt_household))),
  n_cnt_work               = sumna(cnt_work),
  n_cnt_school             = sumna(cnt_school),
  n_cnt_other              = sumna(cnt_other),
  n_cnt_phys               = sumna(cnt_phys),
  n_cnt_inside             = sumna(cnt_inside),
  n_cnt_outside            = sumna(cnt_outside),
  n_cnt_sport              = sumna(cnt_sport),
  n_cnt_outside_other      = sumna(cnt_outside_other),
  n_cnt_other_place        = sumna(cnt_other_place),
  n_cnt_other_house        = sumna(cnt_other_house),
  n_cnt_worship            = sumna(cnt_worship),
  n_cnt_public_transport   = sumna(cnt_public_transport),
  n_cnt_supermarket        = sumna(cnt_supermarket),
  n_cnt_shop               = sumna(cnt_shop),
  n_cnt_bar_rest           = sumna(cnt_bar_rest),
  n_cnt_health_facility    = sumna(cnt_health_facility),
  n_cnt_salon              = sumna(cnt_salon)
),
by = part_wave_uid]

tail(cp_n_cnts, 15)


pt_cnt = merge(pt, cp_n_cnts, by = c("part_wave_uid"), all.x = TRUE)

var_list <- names(cp_n_cnts)
for (j in var_list){
  set(pt_cnt,which(is.na(pt_cnt[[j]])),j,0)
}

cnt_names <- grep("n_cnt", names(pt_cnt), value = TRUE)
cnt_names <- c("part_wave_uid", cnt_names)
pt_cnt <- pt_cnt[, ..cnt_names]

qs::qsave(pt_cnt, "../comix/data/part_cnts.qs")
