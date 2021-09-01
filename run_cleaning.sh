
# Running all of the data cleaning from begining to end. 

# This probably unwise as it would make it hard to see errors.


# sh run_version_1.sh
# sh run_version_2.sh
# sh run_version_3.sh
# sh run_version_3.sh 'latest'
# sh run_version_4.sh 'G1'
# sh run_version_4.sh 'G2'
# sh run_version_5.sh
# sh run_version_6.sh

# sh run_version_1.sh 'download'
# sh run_version_2.sh 'download'
# sh run_version_3.sh 'download'
# sh run_version_4.sh 'G1download'
# sh run_version_4.sh 'G2download'
# sh run_version_5.sh 'download'
# sh run_version_6.sh 'download'

Rscript "r/validation/dm00_combine.r"
Rscript "r/validation/dm01_update_values.r"
Rscript "r/validation/dm100_save_locally.r"
Rscript "r/validation/dm101_save_remote.r"
Rscript "r/validation/dm_count_contacts.r"
 
