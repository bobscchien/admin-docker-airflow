#!/bin/bash

####################################################################
# For the very first time, the scritp will search the LOCALHOST_DIR.
# If the directory is empty, then do "airflow db init" command.
####################################################################

### Build docker-compose

# Preparation
cd bin && bash network-builder.sh && cd ..

# Start the service
docker-compose build --force-rm --no-cache
docker-compose up -d



### Initialize the configuration

source ./config/conf.ini

sudo chown -R $AIRFLOW_USER:$AIRFLOW_USER $LOCALHOST_DIR

if [ "$(ls -A $LOCALHOST_DIR)" ];then
    status=normal

    echo "Reset Airflow..."
    docker exec -it $AIRFLOW_NAME $PIPENV_DIR shell "airflow db reset; exit"
else
    status=init

    echo "Initialize Airflow..."
    docker exec -it $AIRFLOW_NAME $PIPENV_DIR shell "airflow db init; exit" 
fi



### Setup the configuration

cfg_file=$LOCALHOST_DIR/airflow.cfg

echo "Modify Airflow's default configurations..."
sudo sed -i 's/default_timezone = utc/default_timezone = Asia\/Taipei/g' $cfg_file
sudo sed -i 's/SequentialExecutor/LocalExecutor/g' $cfg_file
sudo sed -i "s/sqlite:\/\/\/\/home\/airflow\/airflow\/airflow.db/mysql:\/\/$DB_USER:$DB_PASS@$DB_HOST:$DB_PORT\/$DB_NAME/g" $cfg_file
sudo sed -i 's/load_examples = True/load_examples = False/g' $cfg_file

echo "Modify Airflow's email configurations..."
source ./config/credential.ini
sudo sed -i "s/smtp_host = localhost/smtp_host = smtp.gmail.com/g" $cfg_file
sudo sed -i "s/smtp_mail_from = airflow@example.com/smtp_mail_from = $EMAIL/g" $cfg_file
sudo sed -i "s/# smtp_user =/smtp_user = $EMAIL/g" $cfg_file
sudo sed -i "s/# smtp_password =/smtp_password = $GMAIL_PASSWORD/g" $cfg_file

echo "Re-initialize Airflow..."
[ "$status" = "init" ] && docker exec -it $AIRFLOW_NAME $PIPENV_DIR shell "airflow db init; exit"

echo "Setup the user account..."
cmd="airflow users create -e $EMAIL -f $NAME_FIRST -l $NAME_LAST -u $NAME_USER -p $USER_PASSWORD -r Admin; exit"
[ "$status" = "init" ] && docker exec -it $AIRFLOW_NAME $PIPENV_DIR shell $cmd



### Start the service daemon

docker exec -it $AIRFLOW_NAME $PIPENV_DIR shell "airflow webserver -D -p 8080; exit"
docker exec -it $AIRFLOW_NAME $PIPENV_DIR shell "airflow scheduler -D; exit"
