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

pt <- qs::qread("../comix/data/apart_min.qs")
ct <- qs::qread("../comix/data/contacts.qs")


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
  "cnt_public_market"
)

cnt_vars <- c(cnt_main_vars, cnt_other_vars)
all_vars <- c(cnt_vars, "part_wave_uid")
ct <- ct[, ..all_vars]

sumna <- function(x) sum(x, na.rm = TRUE)

cp_n_cnts <- ct[, .(
  n_cnt = .N,
  n_cnt_home             = sumna(cnt_home),
  n_cnt_work             = sumna(cnt_work),
  n_cnt_school           = sumna(cnt_school),
  n_cnt_other            = sumna(cnt_other),
  n_cnt_phys             = sumna(cnt_phys),
  n_cnt_inside           = sumna(cnt_inside),
  n_cnt_outside          = sumna(cnt_outside),
  n_cnt_sport            = sumna(cnt_sport),
  n_cnt_outside_other    = sumna(cnt_outside_other),
  n_cnt_other_place      = sumna(cnt_other_place),
  n_cnt_other_house      = sumna(cnt_other_house),
  n_cnt_worship          = sumna(cnt_worship),
  n_cnt_public_transport = sumna(cnt_public_transport),
  n_cnt_supermarket      = sumna(cnt_supermarket),
  n_cnt_shop             = sumna(cnt_shop),
  n_cnt_bar_rest         = sumna(cnt_bar_rest),
  n_cnt_health_facility  = sumna(cnt_health_facility),
  n_cnt_salon            = sumna(cnt_salon)
),
by = part_wave_uid]

tail(cp_n_cnts, 15)


pt_cnt = merge(pt, cp_n_cnts, by = c("part_wave_uid"), all.x = TRUE)

var_list <- names(cp_n_cnts)
for (j in var_list){
  set(pt_cnt,which(is.na(pt_cnt[[j]])),j,0)
}

# Count contacts ----------------------------------------------------------


# count contacts but unique for home work school other --------------------
ct_p <- merge(ct, pt, by = c("part_wave_uid"), all.x = TRUE)

ct_p[, d_home   := cnt_home == 1]
ct_p[, d_school := ifelse(sample_type == "child", cnt_school == 1 & cnt_home == 0, cnt_school == 1 & cnt_home == 0 & cnt_work == 0)]
ct_p[, d_work := ifelse(sample_type == "adult", cnt_work == 1 & cnt_home == 0, cnt_work == 1 & cnt_home == 0 & cnt_school == 0)]
ct_p[, d_other  := cnt_other ]
ct_p[, d_phys  := cnt_phys]


ct_p[part_wave_uid == "be_A3_12092"]
ct_p[part_wave_uid == "uk_F8_64845"]
ct[part_wave_uid == "uk_F8_64845"]

ct_p[, table(d_school, cnt_school)]
ct_p[, table(d_work, cnt_work)]
ct_p[, table(d_other, cnt_other)]

ct_p_cnts <- ct_p[, .(
    all = .N,
     n_cnt_unq_home             = sumna(d_home),
     n_cnt_unq_work             = sumna(d_work),
     n_cnt_unq_school           = sumna(d_school),
     n_cnt_unq_other            = sumna(d_other),
     n_cnt_unq_phys             = sumna(d_phys),
     n_cnt_unq_inside           = sumna(cnt_inside),
     n_cnt_unq_outside          = sumna(cnt_outside),
     n_cnt_unq_sport            = sumna(cnt_sport),
     n_cnt_unq_outside_other    = sumna(cnt_outside_other),
     n_cnt_unq_other_place      = sumna(cnt_other_place),
     n_cnt_unq_other_house      = sumna(cnt_other_house),
     n_cnt_unq_worship          = sumna(cnt_worship),
     n_cnt_unq_public_transport = sumna(cnt_public_transport),
     n_cnt_unq_supermarket      = sumna(cnt_supermarket),
     n_cnt_unq_shop             = sumna(cnt_shop),
     n_cnt_unq_bar_rest         = sumna(cnt_bar_rest),
     n_cnt_unq_health_facility  = sumna(cnt_health_facility),
     n_cnt_unq_salon            = sumna(cnt_salon)
),
by = part_wave_uid]


ct_p_cnts[, n_cnt_unq := n_cnt_unq_home + n_cnt_unq_work + n_cnt_unq_school + n_cnt_unq_other]
ct_p_cnts[, delta := all - n_cnt_unq]
ct_p_cnts[, n_cnt_unq := n_cnt_unq + delta]
ct_p_cnts[, n_cnt_unq_other := n_cnt_unq_other + delta]
ct_p_cnts[, delta := NULL]
ct_p_cnts[, all := NULL]

ct_p_cnts[, n_cnt_unq_workschool := n_cnt_unq_work + n_cnt_unq_school]

pt_cnt <- merge(pt_cnt, ct_p_cnts, by = "part_wave_uid", all = TRUE)

var_list_unq <- names(ct_p_cnts)
for (j in var_list_unq){
  set(pt_cnt,which(is.na(pt_cnt[[j]])),j,0)
}

pt_cnt[, table(is.na(n_cnt))]
pt_cnt[, table(is.na(n_cnt_unq))]


## check how the two counts match up.
pt_cnt[, table(n_cnt == n_cnt_unq)]

pt_cnt

dta = pt_cnt[country == "uk", .(mean(n_cnt), mean(n_cnt_unq), mean(n_cnt_unq_home), mean(n_cnt_unq_workschool), mean(n_cnt_unq_other),.N), by = .(survey_round, sample_type)][order(sample_type, survey_round)]

cnt_names <- grep("n_cnt", names(pt_cnt), value = TRUE)
cnt_names <- c("part_wave_uid", cnt_names)
pt_cnt <- pt_cnt[, ..cnt_names]

qs::qsave(pt_cnt, "../comix/data/part_cnts.qs")
