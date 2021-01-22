

# Test for age groups: --------------------

cnt <- qs::qread("data/clean/contacts_v4.qs")
part <- qs::qread("data/clean/part_v4.qs")

# Contacts -------------------
table(cnt$country, cnt$wave, useNA = "always")
table(cnt$cnt_age_group, cnt$wave, useNA = "always")

table(cnt$cnt_age, cnt$wave, useNA = "always")
table(cnt$cnt_age_group, cnt$cnt_mass, useNA = "always")
table(cnt[cnt_mass == "individual"]$cnt_gender, 
      cnt[cnt_mass == "individual"]$wave, useNA = "always")
table(cnt[cnt_household == 1]$cnt_gender, 
      cnt[cnt_household == 1]$wave, useNA = "always")

table(cnt[cnt_mass == "mass"]$cnt_age, 
      cnt[cnt_mass == "mass"]$wave, useNA = "always")

table(cnt$cnt_work, cnt$wave, useNA =  "always")
table(cnt$cnt_prec_1_and_half_m_plus, cnt$cnt_mass, useNA =  "always")

message(paste("Empty cnt_age_group: ", nrow(cnt[is.na(cnt_age_group)])))
message(paste("Empty cnt_age: ", nrow(cnt[is.na(cnt_age)])))
message(paste("Empty individually reported cnt_gender: ", 
              nrow(cnt[is.na(cnt_gender) & cnt_mass == "individual"])))
message(paste("Empty household cnt_gender: ", 
              nrow(cnt[is.na(cnt_gender) & cnt_household == 1])))

message(paste("Empty cnt_work: ", 
              nrow(cnt[is.na(cnt_work)])))

message(paste("Empty cnt_work: ", 
              nrow(cnt[is.na(cnt_home)])))


message(paste("Empty cnt_work: ", 
              nrow(cnt[is.na(cnt_school)])))

message(paste("Empty mass reported age: ", 
              nrow(cnt[is.na(cnt_age) & cnt_mass == "mass"])))


# Participant -----------------

table(part$country, part$wave, useNA = "always")
table(part$part_age_group, part$wave, useNA = "always")
table(part$part_age_group_be, part$wave, useNA = "always")

table(part$part_age, part$wave, useNA = "always")
table(part$part_age_group, part$part_mass, useNA = "always")
table(part[sample_type == "adult"]$part_gender, 
      part[part_mass == "individual"]$wave, useNA = "always")
table(part[part_household == 1]$part_gender, 
      part[part_household == 1]$wave, useNA = "always")
table(part[multiple_contacts_adult_work > 0]$multiple_contacts_work_precautions,
      part[multiple_contacts_adult_work > 0]$wave, useNA = "always")
table(part[multiple_contacts_adult_other > 0]$multiple_contacts_other_precautions,
      part[multiple_contacts_adult_other > 0]$wave, useNA = "always")



message(paste("Empty part_age_group: ", nrow(part[is.na(part_age_group)])))
message(paste("Empty part_age: ", nrow(part[is.na(part_age)])))
message(paste("Empty part symptoms fever (adult sample only): ", 
              nrow(part[is.na(part_symp_fever) & sample_type == "adult"])))
message(paste("Empty mask: ", 
              nrow(part[is.na(part_face_mask)])))

table(part$multiple_contacts_work_precautions)


