sudo apt-get install git
sudo apt-get install python-pip
sudo apt-get install mysql-server
sudo apt-get install libmysqlclient-dev python-dev
sudo apt-get install tmux
sudo apt-get install nginx

sudo pip install -r requirements.txt

# mysql setup
mysql --user=root mysql --password=password
GRANT ALL PRIVILEGES ON *.* TO 'john'@'localhost' IDENTIFIED BY 'some_pass' WITH GRANT OPTION;
CREATE DATABASE food_truck_db;

# setup db
python data/sql_orm.py
# load data
cd data
python data_engineering.py
