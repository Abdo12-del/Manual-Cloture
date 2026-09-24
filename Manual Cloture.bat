mysqldump --skip-triggers --routines -uroot -pgamadev ssSourceDB articlesliste codbar personnez fav favliste userz dosse > ".\\DBCloture.sql
mysql -uroot -pgamadev -P3306 mysql -e "DROP DATABASE ssDesticationDB;"  > ".\ss2018.txt"
mysql -uroot -pgamadev -P3306 mysql -e "CREATE DATABASE ssDesticationDB;"  > ".\ss2018.txt"
mysql -uroot -pgamadev -P3306 ssDesticationDB < ".\Schema16102016.sql"
mysql -uroot -pgamadev -P3306 ssDesticationDB < ".\PrimaryData20150428.sql"
mysql -uroot -pgamadev -P3306 sssDesticationDB <  ".\\DBCloture.sql
mysql -uroot -pgamadev -P3306 mysql -e "UPDATE ssDesticationDB.personnez SET CreditInitial = Solde, DetteInitial = Soldefx"  > ".\ss2017.txt"
mysql -uroot -pgamadev -P3306 mysql -e "SET GLOBAL FOREIGN_KEY_CHECKS=1;"  > ".\ss2017.txt"
pause
exit
