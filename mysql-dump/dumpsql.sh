db_user="lpzadmin"
db_passwd="root"
db_name="db_test"
# the directory for story your backup file.you shall change this dir
backup_dir="/usr/software/backup/mysqlbackup"
# date format for backup file (dd-mm-yyyy)
time="$(date +"%Y%m%d%H%M%S")"     

mysqldump -u$db_user  -p$db_passwd $db_name  > "$backup_dir/$db_name"_"$time.sql"
