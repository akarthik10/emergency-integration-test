#!/usr/bin/env bash
brew update
brew install lyft/formulae/set-simulator-location
brew install homebrew/dupes/expect
sudo gem install xcpretty
brew install mongodb
brew services start mongodb
brew install ant
git config --global http.postBuffer 1048576000
GIT_CURL_VERBOSE=1 git clone --depth=1 https://github.com/MobilityFirst/GNS
cd GNS
ant
./bin/gpServer.sh start all
cd ..
brew install mysql
mysql.server start
mysql -u root -e "CREATE USER 'emportalUser'@'localhost' IDENTIFIED BY 'some_pass';"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'emportalUser'@'localhost' WITH GRANT OPTION;"
mysql -u root -e "create database emportal;"
brew tap homebrew/homebrew-php
brew install php56
brew install composer
rm -rf em_portal
git clone git@bitbucket.org:danielsamfdo/em_portal.git
cd em_portal
git checkout development_branch
cp ../custom_files/data.js public/js/alerts/
composer update
composer install
php artisan migrate
php artisan serve &
cd ..
touch iosoutput.log # && ./logger.sh &
sudo pip install selenium &
python commandserver.py localhost 5555 &
rm -rf umassemergency
git clone git@bitbucket.org:goerkem/umassemergency.git
cd umassemergency
git checkout testing_karthik
cd ..