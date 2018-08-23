####################################
# This script is for deploying hubot
#
# Owner:
# AdmiralAwkbar@github.com
####################################

################################################
# BOTNAME is updated beforehand in perl script #
################################################
CUR_USER=$(whoami)
BOTNAME=BOTNAMEVALUE
DIR=/opt/hubot
BRANCH=master

###########
# HEADERS #
###########
echo "----------------------------------------------------------------"
echo "Running Deploy of: $BOTNAME"
echo "Build directory is: $DIR"
echo "Banch is: $BRANCH"
echo "Current User: $CUR_USER"
echo ""

#######################
# Tool and Path setup #
#######################
echo "----------------------------------------------------------------"
echo "Setting up tools and paths"

###################
# Reset to origin #
###################
echo "----------------------------------------------------------------"
echo "Resetting to origin: $BRANCH"
echo ""
sudo su - $BOTNAME -c "cd $DIR; git fetch origin ; git reset --hard origin/$BRANCH ; git reset --hard origin/HEAD"

###################
# Clean all files #
###################
echo "----------------------------------------------------------------"
echo "Git Clean all files"
echo ""
sudo su - $BOTNAME -c "cd $DIR; git clean -x -f -d "

#################################
# Pull latest changes (as user) #
#################################
echo "----------------------------------------------------------------"
echo "Git Pulling latest changes"
echo ""
sudo su - $BOTNAME -c "cd $DIR; sudo git pull origin $BRANCH"

###############
# npm install #
###############
echo "----------------------------------------------------------------"
echo "Installing dependencies (npm install)"
echo ""
sudo su - $BOTNAME -c "cd $DIR; npm cache clean -f"
sudo su - $BOTNAME -c "cd $DIR; sudo npm install -g n"
sudo su - $BOTNAME -c "cd $DIR; sudo n stable"
sudo su - $BOTNAME -c "cd $DIR; npm install"
sudo su - $BOTNAME -c "cd $DIR; npm install hubot-github-webhook-listener"
sudo su - $BOTNAME -c "cd $DIR; npm install --save https-proxy-agent"

#######################
# Removed after we moved to AWS
# Fixing proxy for aws
#echo "----------------------------------------------------------------"
#echo "Fixing proxy setting for aws"
#AWS_PATH="$DIR/node_modules/hubot-aws/aws.coffee"
#echo "PATH is $AWS_PATH"
#sed -i 's|aws = require '\''aws-sdk'\''|aws = require '\''aws-sdk'\''\n    proxy = require '\''https-proxy-agent'\''\n    aws.config.update httpOptions: agent: proxy('\''http://grc-americas-sanra-pitc-wkcz.proxy.corporate.gtm.ge.com:80'\'')|' $AWS_PATH
#######################

##############################
# Fix github webhook listner #
##############################
echo "----------------------------------------------------------------"
echo "Fixing hubot-github-webhook-listener"
WEBHOOK_PATH="$DIR/node_modules/hubot-github-webhook-listener/src/hubot-github-webhook-listener.coffee"
echo "PATH IS $WEBHOOK_PATH"
sed -i 's/X-Hub-Signature/x-hub-signature/' $WEBHOOK_PATH | tr '[:upper:]' '[:lower:]'
sed -i 's/X-Github-Delivery/x-github-delivery/' $WEBHOOK_PATH | tr '[:upper:]' '[:lower:]'

#########################
# Fix hubot diagnostics #
#########################
echo "----------------------------------------------------------------"
echo "Fixing hubot-diagnostics"
DIAG_PATH="$DIR/node_modules/hubot-diagnostics/src/diagnostics.coffee"
HOLD_DIAG_PATH="$DIR/node_modules/hubot-diagnostics/src/diagnostics.coffee.hold"
echo "Adding .hold to not parse file"
mv $DIAG_PATH $HOLD_DIAG_PATH

#######################
# Removed after moving to AWS
#echo "----------------------------------------------------------------"
#echo "Fixing node-scoped-http module"
#HTTP_MODULE_PATH="$DIR/node_modules/hubot/node_modules/scoped-http-client/src/index.js"
#echo "PATH IS $HTTP_MODULE_PATH"
#sed -i 's|https = require('\''https'\'');|https = require('\''http'\'');|' $HTTP_MODULE_PATH
#sed -i 's|port: port,|port: 80,|' $HTTP_MODULE_PATH
#sed -i 's|host: this.options.hostname,|host: '\''YOUR_PROXY_URL'\'',|' $HTTP_MODULE_PATH
#sed -i 's|path: this.fullPath(),|path: '\''http://'\'' + this.options.hostname + this.fullPath(),|' $HTTP_MODULE_PATH
#######################


######################################
# Fixing script dir file permissions #
######################################
echo "----------------------------------------------------------------"
echo "Fixing Script Dir file permissions"
sudo su - $BOTNAME -c "chmod -R 755 /opt/hubot/scripts/*"

#####################################
# Need to pull in hubot.env from S3 #
#####################################
echo "----------------------------------------------------------------"
echo "Pulling hubot.env from s3 encrypted and protected storage"
aws s3 cp s3://services-demo-artifacts/Hubot/hubot.env /opt/hubot/hubot.env

###############################
# Need to chown and lock file #
###############################
echo "----------------------------------------------------------------"
echo "Chowning and locking hubot.env file down"
sudo su -c "chown $BOTNAME:$BOTNAME /opt/hubot/hubot.env"
sudo su -c "chmod 600 /opt/hubot/hubot.env"

################
# Sourcing env #
################
echo "----------------------------------------------------------------"
echo "Sourcing the env"
sudo su - $BOTNAME -c "cd $DIR; . /opt/hubot/hubot.env"

####################
# restart $BOTNAME #
####################
echo "----------------------------------------------------------------"
echo "Restarting $BOTNAME"
sudo su - $BOTNAME -c "cd $DIR; /opt/hubot/start.sh"

###############################################
# Need to check the shell code from the start #
###############################################
echo "----------------------------------------------------------------"
if [ $? -eq 0 ]
then
  echo "Successfully Started $BOTNAME"
else
  echo "Failed to start $BOTNAME!"
  exit 1
fi

#####################
# Need to clean git #
#####################
echo "----------------------------------------------------------------"
echo "Running Git Garbage Collection"
sudo su - root -c "cd $DIR; sudo git gc"

################################
# Make sure bot owns all files #
################################
echo "----------------------------------------------------------------"
echo "Chowning files..."
sudo chown -R $BOTNAME:$BOTNAME /opt/hubot

#######################################
# Validate all python scripts compile #
#######################################
echo "----------------------------------------------------------------"
echo "Validating all Python scripts compile"
for i in $(find . -name '*.py'); do python -m py_compile $i; done
if [ $? -eq 0 ]
then
  echo "All files compile"
else
  echo "Failed to compile python code!"
  exit 1
fi

echo "----------------------------------------------------------------"
echo "----------------------------------------------------------------"
#######################################################################
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!! WERE DONE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#######################################################################
