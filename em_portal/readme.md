SETUP:
https://laravel.com/docs/5.4/homestead

Clone this repo.

mysql> CREATE USER 'emportalUser'@'localhost' IDENTIFIED BY 'some_pass';
Query OK, 0 rows affected (0.00 sec)

mysql> GRANT ALL PRIVILEGES ON *.* TO 'emportalUser'@'localhost' WITH GRANT OPTION;
Query OK, 0 rows affected (0.00 sec)

mysql> create database emportal;

Exit MySql

cd em_portal

php artisan migrate

php artisan serve