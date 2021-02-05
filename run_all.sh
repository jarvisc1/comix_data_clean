
  # 
#sh run_version_1.sh
#sh run_version_2.sh
#sh run_version_3.sh
#sh run_version_3.sh 'latest'
# sh run_version_5.sh

Rscript.exe r/post_processing/dm_combine.r
Rscript.exe r/post_processing/dm_count_contacts.r
Rscript.exe r/dm100_save_locally.r
Rscript.exe r/dm101_save_remote.r