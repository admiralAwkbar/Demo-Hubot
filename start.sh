#!/bin/bash -x
#######################################
# Script to start Hubot in background #
#                                     #
# @admiralAwkbar                      #
# pkill -f nono                       #
#######################################

################
# Setting Vars #
################
ME=$(whoami)                           # Account running script
HUBOT_HOME_DIR=/opt/hubot              # Home directory for the Hubot
HUBOT_BIN=$HUBOT_HOME_DIR/bin/hubot    # Location of bin file
HUBOT_LOGS_DIR=$HUBOT_HOME_DIR/logs    # Directory to store logs
ERROR_FILE=/opt/hubot/failError        # Error file to create
SLEEP_TIME=10                          # time to sleep to allow to startup

################################################################################
############################### MAIN ###########################################
################################################################################

######################
# Print the location #
######################
LOCATION=$(pwd)
echo "Current Working Directory:[$LOCATION]"

##########################################
# Make sure the error flag is cleaned up #
##########################################
if [ -f $ERROR_FILE ]
 then
   echo "found an error flag file $ERROR_FILE, deleting it now for a fresh start"
   rm -f $ERROR_FILE
fi

#################################
# Verify root does not run this #
#################################
if [ "$ME" = "root" ]; then
   echo "This script should not be ran as root"
   echo "Please run as a Hubot account"
   exit 1
else
   echo "Script is ran by Hubot account:[$ME]"
fi

###############
# Get to Home #
###############
cd ${HUBOT_HOME_DIR}

##############################
# Check if currently running #
##############################
if [ "$(pgrep -U $ME node)" != "" ]; then
    echo "Killing previous process... ($(pgrep -U $ME node))"
    pkill -U $ME node
fi

#########################
# Create Logs Directory #
#########################
mkdir -p ${HUBOT_LOGS_DIR}

#########################
# Need to find env file #
#########################
if [ ! -f $HUBOT_HOME_DIR/hubot.env ]; then
    echo "hubot.env file not found!"
    exit 1
fi

###################
# Source the data #
###################
echo "sourcing the env"
source $HUBOT_HOME_DIR/hubot.env

###############
# Chown it up #
###############
echo "validating file ownership"
sudo chown -R $ME:$ME $HUBOT_HOME_DIR/.git

#########################
# Start the application #
#########################
echo "starting the application"
echo "Running command:[nohup ${HUBOT_BIN} --name ${HUBOT_NAME} --adapter ${ADAPTER} 2>&1 > ${HUBOT_LOGS_DIR}/${HUBOT_NAME}.log &]"
nohup ${HUBOT_BIN} --name ${HUBOT_NAME} --adapter ${ADAPTER} 2>&1 > ${HUBOT_LOGS_DIR}/${HUBOT_NAME}.log &

#######################################
# Need small sleep to let it start up #
#######################################
echo "sleeping for $SLEEP_TIME seconds before log tail..."
sleep $SLEEP_TIME
tail -n 40 ${HUBOT_LOGS_DIR}/${HUBOT_NAME}.log

#############################
# Getting current hubot pid #
#############################
PID=$(pgrep -U $ME node)

if [ -z $PID ]; then
  echo "Error! no pid!"
  exit 1
else
  echo "Script completed with pid:[$PID]"
  exit 0
fi
################################################################################
####################### Script Has Completed ###################################
################################################################################
