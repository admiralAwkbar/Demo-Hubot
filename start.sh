#!/bin/bash
#######################################
# Script to start Hubot in background #
#                                     #
# @admiralAwkbar                      #
# pkill -f nono                       #
#######################################

################
# Setting Vars #
################
USER=$(whoami)                            # Account running script
BUILD_DIR=$(pwd)                          # Location script is running
HUBOT_HOME_DIR='/opt/hubot'               # Home directory for the Hubot
HUBOT_BIN="$HUBOT_HOME_DIR/bin/hubot"     # Location of bin file
HUBOT_LOGS_DIR="$HUBOT_HOME_DIR/logs"     # Directory to store logs
ERROR_FILE="/opt/hubot/failError"         # Error file to create
SLEEP_TIME=10                             # time to sleep to allow to startup
PASSWD_FILE="/tmp/ansible.password"       # Password file for decryption of ansible
S3_PASSWORD_FILE="services-demo-artifacts/Defaults/ansible-hubot.passwd" # file stored in AWS S3

################################################################################
############################ FUNCTIONS #########################################
################################################################################
################################################################################
#### Function Header ###########################################################
Header()
{
  echo ""
  echo "-----------------------------------------------------"
  echo "------------ Running Stop/Start of Hubot ------------"
  echo "-----------------------------------------------------"
  echo "Current Working Directory:[$BUILD_DIR]"
}
################################################################################
#### Function GetErrorFileInfo #################################################
GetErrorFileInfo()
{
  echo "-----------------------------------------------------"
  echo "Cleaning env flags..."

  ##########################################
  # Make sure the error flag is cleaned up #
  ##########################################
  if [ -f $ERROR_FILE ]; then
    echo "Found an error flag file [$ERROR_FILE]! Deleting it now for a fresh start"
    rm -f $ERROR_FILE
  fi
}
################################################################################
#### Function VerifyUser #######################################################
VerifyUser()
{
  echo "-----------------------------------------------------"
  echo "Verifying user..."

  #################################
  # Verify root does not run this #
  #################################
  if [ "$USER" = "root" ]; then
    ###################
    # Running as root #
    ###################
    echo "This script should not be ran as root"
    echo "Please run as a Hubot account"
    exit 1
  else
    ###########################
    # Running as a build user #
    ###########################
    echo "Script is ran by Hubot account:[$USER]"
  fi
}
################################################################################
#### Function KillRunningInstance ##############################################
KillRunningInstance()
{
  echo "-----------------------------------------------------"
  echo "killing any currently running process(s)..."

  ##############################
  # Check if currently running #
  ##############################
  if [ "$(pgrep -U $USER node)" != "" ]; then
    echo "Killing previous process... ($(pgrep -U $USER node))"
    ####################
    # Kill the process #
    ####################
    pkill -U $USER node
  fi
}
################################################################################
#### Function ValidateHubotEnv #################################################
ValidateHubotEnv()
{
  echo "-----------------------------------------------------"
  echo "Validation of hubot.env..."

  #########################
  # Need to find env file #
  #########################
  if [ ! -f $HUBOT_HOME_DIR/hubot.env ]; then
    ##################
    # File not found #
    ##################
    echo "ERROR! [$HUBOT_HOME_DIR/hubot.env] file not found!"
    exit 1
  fi

  ################################
  # Copy Ansible secret from AWS #
  ################################
  aws s3 cp s3://$S3_PASSWORD_FILE $PASSWD_FILE

  ############################
  # Validate the file exists #
  ############################
  if [ ! -f $PASSWD_FILE ]; then
    ##################
    # File not found #
    ##################
    echo "ERROR! Failed to find:[$PASSWD_FILE]!"
    exit 1
  fi

  #########################
  # Decrypt the hubot.env #
  #########################
  echo "Decrypting hubot.env for sourcing"
  ansible-vault decrypt $HUBOT_HOME_DIR/hubot.env --vault-password-file=$PASSWD_FILE

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $? -ne 0 ]; then
    #####################
    # Failed to decrypt #
    #####################
    echo "ERROR! Failed to decrypt:[$HUBOT_HOME_DIR/hubot.env]!"
    exit 1
  fi
}
################################################################################
#### Function ValidateHomeDir ##################################################
ValidateHomeDir()
{
  echo "-----------------------------------------------------"
  echo "Validating Hubot home directory..."

  #########################
  # Create Logs Directory #
  #########################
  echo "Creating Hubot log directory"
  mkdir -p $HUBOT_LOGS_DIR

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $? -ne 0 ]; then
    echo "ERROR! Failed to create logs directory:[$HUBOT_LOGS_DIR]!"
    exit 1
  fi

  ###############
  # Chown it up #
  ###############
  echo "Updating file ownership file ownership"
  sudo chown -R $USER:$USER $HUBOT_HOME_DIR/.git
}
################################################################################
#### Function StartHubot #######################################################
StartHubot()
{
  echo "-----------------------------------------------------"
  echo "Starting the application..."
  echo "Running command:[nohup ${HUBOT_BIN} --name ${HUBOT_NAME} --adapter ${ADAPTER} 2>&1 > ${HUBOT_LOGS_DIR}/${HUBOT_NAME}.log &]"

  #########################
  # Start the application #
  #########################
  nohup source $HUBOT_HOME_DIR/hubot.env ; ${HUBOT_BIN} --name ${HUBOT_NAME} --adapter ${ADAPTER} 2>&1 > ${HUBOT_LOGS_DIR}/${HUBOT_NAME}.log &

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $? -ne 0 ]; then
    echo "ERROR! Failed to start Hubot process!"
    exit 1
  fi

  #####################
  # Encrypt hubot.env #
  #####################
  ansible-vault encrypt $HUBOT_HOME_DIR/hubot.env --vault-password-file=$PASSWD_FILE

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $? -ne 0 ]; then
    echo "ERROR! Failed to encrypt:[$HUBOT_HOME_DIR/hubot.env]!"
    exit 1
  fi

  #########################
  # Remove ansible secret #
  #########################
  rm -f $PASSWD_FILE

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $? -ne 0 ]; then
    echo "ERROR! Failed to remove ansible secret!"
    exit 1
  fi
}
################################################################################
#### Function ValidateHubotProcess #############################################
ValidateHubotProcess()
{
  echo "-----------------------------------------------------"
  echo "Validating Hubot process..."

  #######################################
  # Need small sleep to let it start up #
  #######################################
  echo "sleeping for $SLEEP_TIME seconds before log tail..."
  sleep $SLEEP_TIME
  tail -n 40 ${HUBOT_LOGS_DIR}/${HUBOT_NAME}.log

  #############################
  # Getting current hubot pid #
  #############################
  PID=$(pgrep -U $USER node)

  ##########################
  # Validate we have a pid #
  ##########################
  if [ -z $PID ]; then
    ################
    # No pid found #
    ################
    echo "Error! no pid!"
    exit 1
  else
    ###########
    # Success #
    ###########
    echo "Script completed with pid:[$PID]"
  fi
}
################################################################################
#### Function Footer ###########################################################
Footer()
{
  echo ""
  echo "-----------------------------------------------------"
  echo "The script has completed"
  echo "-----------------------------------------------------"
}
################################################################################
############################### MAIN ###########################################
################################################################################

##########
# Header #
##########
Header

#######################
# Get ERROR file info #
#######################
GetErrorFileInfo

###################
# Verify not root #
###################
VerifyUser

##################################
# Kill Previous Running instance #
##################################
KillRunningInstance

######################
# Validate Hubot Env #
######################
ValidateHubotEnv

###########################
# Validate Home directory #
###########################
ValidateHomeDir

#########################
# Start the application #
#########################
StartHubot

##########################
# Validate Hubot running #
##########################
ValidateHubotProcess

##########
# Footer #
##########
Footer

################################################################################
####################### Script Has Completed ###################################
################################################################################
