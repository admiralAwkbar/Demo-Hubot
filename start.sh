#!/bin/bash
# created by team
# pkill -f nono


# Setting Vars
ME=`whoami`
HUBOT_HOME_DIR=/opt/hubot
HUBOT_BIN=$HUBOT_HOME_DIR/bin/hubot
HUBOT_LOGS_DIR=$HUBOT_HOME_DIR/logs
ERROR_FILE=/opt/hubot/failError
SLEEP_TIME=10

# Make sure the error flag is cleaned up
if [ -f $ERROR_FILE ]
 then
   echo "found an error flag file $ERROR_FILE, deleting it now for a fresh start"
   rm -f $ERROR_FILE
fi

# Verify root does not run this
if [ "$ME" = "root" ]; then
   echo "This script should not be ran as root"
   echo "Please run as a hubot account"
   exit 1
fi

# Get to Home
cd ${HUBOT_HOME_DIR}
if [ "$(pgrep -U $ME node)" != "" ]; then
    echo "Killing previous process... ($(pgrep -U $ME node))"
    pkill -U $ME node
fi
mkdir -p ${HUBOT_LOGS_DIR}

# Need to find env file
if [ ! -f $HUBOT_HOME_DIR/hubot.env ]; then
    echo "hubot.env file not found!"
    exit 1
fi

# Source the data'
echo "sourcing the env"
source $HUBOT_HOME_DIR/hubot.env

# Chown it up
echo "validating file ownership"
sudo chown -R $ME:$ME $HUBOT_HOME_DIR/.git

# Start the application
echo "starting the application"
${HUBOT_BIN} --name ${HUBOT_NAME} --adapter ${ADAPTER} >${HUBOT_LOGS_DIR}/${HUBOT_NAME}.log 2>&1 &

# Need small sleep to let it start up
echo "sleeping for $SLEEP_TIME seconds before log tail..."
sleep $SLEEP_TIME
tail -n 40 ${HUBOT_LOGS_DIR}/${HUBOT_NAME}.log
echo -n "$ME's hubot active pid: "
pgrep -U $ME node
