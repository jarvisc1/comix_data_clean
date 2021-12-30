# Running all of the data cleaning from begining to end. 

# This probably unwise as it would make it hard to see errors.


# sh run_version_1_mac.sh
# sh run_version_2_mac.sh
# sh run_version_3_mac.sh
# sh run_version_3_mac.sh 'latest'
# sh run_version_4_mac.sh 'G1'
# sh run_version_4_mac.sh 'G2'
# sh run_version_5_mac.sh
# sh run_version_6_mac.sh

# sh run_version_1_mac.sh 'download'
# sh run_version_2_mac.sh 'download'
# sh run_version_3_mac.sh 'download'
# sh run_version_4_mac.sh 'G1download'
# sh run_version_4_mac.sh 'G2download'
# sh run_version_5_mac.sh 'download'
# sh run_version_6_mac.sh 'download'

Rscript "r/validation/dm00_combine.r"
Rscript "r/validation/dm01_update_values.r"
Rscript "r/validation/dm100_save_locally.r"
Rscript "r/validation/dm101_save_remote.r"
Rscript "r/validation/dm_count_contacts.r"

