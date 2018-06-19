################################################################################
##################### Preflight AWS Pull Events @LukasG ########################
################################################################################
# Description:
#   Preflight for Pull events in Jenkins in AWS. Github actions trigger the
#   build process.
#
#
# Configuration:
#   FLOW_ROOM - This is pulled from the AWS config/aws_config_repo.coffee
#   GLADOS_WEBOOK_SECRET - Secret used to varify SHA1 hash from github webhook.

#
#   There is a bug in the hubot-github-webhook-listener module that requires you to
#   patch the header fields received form webhook events by github. Hubot does not understand
#   the case-sensitive header fields so add this to your deploy scripts to fix that once NPM install step is done
#
#   export DIR=/PATH/TO/YOUR/HUBOT/INSTALL
#
#   cd $DIR
#
#   echo "Fixing hubot-github-webhook-listener"
#   WEBHOOK_PATH="$DIR/node_modules/hubot-github-webhook-listener/src/hubot-github-webhook-listener.coffee"
#   echo "PATH IS $WEBHOOK_PATH"
#
#   sed -i 's/X-Hub-Signature/x-hub-signature/' $WEBHOOK_PATH | tr '[:upper:]' '[:lower:]'
#   sed -i 's/X-Github-Delivery/x-github-delivery/' $WEBHOOK_PATH | tr '[:upper:]' '[:lower:]'
#
#   Add this to fix proxy issues to do animate me type commands
#
#   echo "Fixing node-scoped-http module"
#   HTTP_MODULE_PATH="$DIR/node_modules/hubot/node_modules/scoped-http-client/src/index.js"
#   echo "PATH IS $HTTP_MODULE_PATH"
#
#   sed -i 's|https = require('\''https'\'');|https = require('\''http'\'');|' $HTTP_MODULE_PATH
#   sed -i 's|port: port,|port: 8080,|' $HTTP_MODULE_PATH
#   sed -i 's|host: this.options.hostname,|host: '\''web-proxy.corp.hpecorp.net'\'',|' $HTTP_MODULE_PATH
#   sed -i 's|path: this.fullPath(),|path: '\''http://'\'' + this.options.hostname + this.fullPath(),|' $HTTP_MODULE_PATH
#
#
# Author:
#   admiralAwkbar@github.com
#
# NOTE:

##################
# Basic requires #
##################
fs = require 'fs'
request = require 'request'
crypto = require 'crypto'
#triggerRepos = require '../config/AWS-TriggerRepos.json'
###################################
# Grabbing the secrets from hubot #
###################################
flow_room = "b16c7dd9-e7fe-4687-921c-8b2d5c1048b9"      # Default devops team only flow
secret = process.env.GLADOS_WEBOOK_SECRET               # Get the webhook secret
jenkins_preflight_job = ""                              # Place holder for main job
jenkins_preflight_job_cft = "AWS-CFT-Preflight"         # Jenkins job to trigger
jenkins_preflight_job_api = "AWS-API-Preflight"         # Jenkins job to trigger
jenkins_preflight_job_npm = "AWS-NPM-Preflight"         # Jenkins job to trigger
jenkins_preflight_job_cpp = "AWS-CPP-Preflight"         # Jenkins job to trigger
jenkins_preflight_job_mvn = "AWS-MVN-Preflight"         # Jenkins job to trigger
jenkins_preflight_job_python = "AWS-Python-Preflight"   # Jenkins job to trigger
orgName = ""                # Name of the GHE org, built later
match = ""                  # If we find a key match
pipelineBranch = "master"   # Branch of the pipeline to run                        
repository = ""             # GHEOrg/GHERepo
branch = ""                 # Branch of the repo
sha = ""                    # SHA sum from GHE
buildType = ""              # TYpe of Preflight to start
callback = ""               # Callback from scripts

########################
# Setting debug levels #
########################
debug = false

################################################################################
################################################################################
#################################################
# Verify signiture to prevent man in the middle #
#################################################
verify_signature = (robot, payload, signature, handler) ->
  calculated_sig = 'sha1=' + crypto.createHmac('sha1', secret).update(JSON.stringify(payload)).digest('hex')
  if(debug)
    robot.logger.debug ("[DEBUG] calculated signature is #{calculated_sig}. header sig is #{signature}.")
  if calculated_sig == signature
    if(debug)
      robot.logger.debug("[DEBUG] It's a match. Valid payload....")
    handler "MATCH"
  else
    if(debug)
      robot.logger.error("[DEBUG] SHA1 hash does NOT match. INVALID PAYLOAD. YOU SHALL NOT PAAAASSSSSS")
    handler "NO_MATCH"

################################################################################
################################################################################    
#####################################################
# Need to call script to download devops-config.yml #
# and read the BuildType of the repo                #
#####################################################
get_build_type = (repository, branch, handler) ->
  #console.log "BT: Repo:#{repository} branch:#{branch}"
  args = []
  args.push(repository + '/' + branch)
  # instantiate child process to be able to create a subprocess
  {spawn} = require 'child_process'
  # create new subprocess and have it run the script
  cmd = spawn('/opt/hubot/scripts/utilities/perl/getBuildType.pl', args)
  # catch stdout and output into hubot's log
  cmd.stdout.on 'data', (data) ->
    #robot.messageRoom flow_room, "```\n#{data.toString()}\n```"
    #console.log data.toString().trim()
    buildType = data.toString().trim()
    #console.log "The BuildType is:#{buildType}"
    handler buildType
  
################################################################################
################################################################################
#################################
# Run the jenkins preflight job #
#################################
run_jenkins_preflight_job = (repository, branch, sha, robot, handler) ->
  #console.log "BT: Repo:#{repository} branch:#{branch} Sha:#{sha}"
  ################################################
  # String all the parameters to send to Jenkins #
  # FORMAT: KEY=Value&Key=Value                  #
  ################################################
  parameters = "OrgRepoBranch=#{repository}/#{branch}&PipelineBranch=#{pipelineBranch}&SHA=#{sha}"
        
  console.log "DEBUG: parameters being sent are:[#{parameters}] for job:[#{jenkins_preflight_job}]"
  message = "Preflight for push event on repo:[#{repository}]\n"
  message = message + "Started Preflight Build, Waiting for Jenkins JobID...\n"
  message.trim()
  robot.messageRoom flow_room, message
        
  args = []
  args.push(jenkins_preflight_job + ',' + parameters)
  # instantiate child process to be able to create a subprocess
  {spawn} = require 'child_process'
  # create new subprocess and have it run the script
  cmd = spawn '/opt/hubot/scripts/utilities/py_utils/Launch-Jenkins-Job.py', args
  # catch stdout and output into hubot's log
  cmd.stdout.on 'data', (data) ->
    robot.messageRoom flow_room, "```\n#{data.toString()}\n```"
    console.log data.toString().trim()
  # catch stderr and output into hubot's log
  cmd.stderr.on 'data', (data) ->
    console.log data.toString().trim()
    robot.messageRoom flow_room, "```\n#{data.toString()}\n```" 

  handler parameters
       
################################################################################
################################################################################
######################################
# Need to take the buildType and set #
# the correct Jenkins Preflight Job  #
# To launch Preflight                #
######################################
set_jenkins_job = (buildType, handler) ->
  if /cft/i.test(buildType)
    jenkins_preflight_job = jenkins_preflight_job_cft
    #console.log "Set JenkinsJob to:#{jenkins_preflight_job}"
    handler  jenkins_preflight_job
  if /mvn/i.test(buildType)
    jenkins_preflight_job = jenkins_preflight_job_mvn
    #console.log "Set JenkinsJob to:#{jenkins_preflight_job}"
    handler  jenkins_preflight_job
  if /cpp/i.test(buildType)
    jenkins_preflight_job = jenkins_preflight_job_cpp
    #console.log "Set JenkinsJob to:#{jenkins_preflight_job}"
    handler  jenkins_preflight_job
  if /npm/i.test(buildType)
    jenkins_preflight_job = jenkins_preflight_job_npm
    #console.log "Set JenkinsJob to:#{jenkins_preflight_job}"
    handler  jenkins_preflight_job
  if /python/i.test(buildType)
    jenkins_preflight_job = jenkins_preflight_job_python
    #console.log "Set JenkinsJob to:#{jenkins_preflight_job}"
    handler  jenkins_preflight_job
  if /api/i.test(buildType)
    jenkins_preflight_job = jenkins_preflight_job_api
    #console.log "Set JenkinsJob to:#{jenkins_preflight_job}"
    handler  jenkins_preflight_job
  null

################################################################################
################################################################################
################################################
# Parse org name from the full repository path #
################################################
parse_org = (repository) ->
  arrOrgs = repository.split("/")
  if arrOrgs.length > 0
    return arrOrgs[0]
  ""

################################################################################
################################################################################
##################################
# Parse branch name from the ref #
##################################
parse_branch = (repoBranch) ->
  arrBranches = repoBranch.split("/")
  if arrBranches.length > 0
    return arrBranches[2]
  ""

################################################################################
################################################################################  
##############################################
# Find the flow id for a specific GitHub Org #
##############################################
#find_flow = (orgName) ->
#  for org in triggerRepos['keys']
#    #console.log "watched org is set to #{org['orgname']}"
#    if org['orgname'] == orgName
#      return org['flowid']
#  null

################################################################################
################################################################################    
##################################
# Start The Hubot for listening  #
##################################
module.exports = (robot) ->
  robot.on "github-preflight-event-pull", (repo_event) ->
    ghePayload = repo_event.payload
    signature = repo_event.signature
    if(debug)
      console.log "payLoad received is: #{JSON.stringify(ghePayload,null,2)} with signature #{signature}"
    verify_signature robot, ghePayload, signature, (match) ->        
      if match == "MATCH"
        if(debug)
          robot.messageRoom flow_room, "[DEBUG] sha1 signature verified"
        switch(repo_event.eventType)
          when "pull_request"
            #############################
            # root level values/objects #
            #############################
            action = ghePayload.action
            repository = ghePayload.repository.full_name
            repoBranch = ghePayload.pull_request.head.ref
            sha = ghePayload.pull_request.head.sha
            branch = repoBranch
            orgName = parse_org repository
            #flow_room = find_flow orgName

            ###############################
            # See if debug is on to print #
            ###############################
            if(debug)
              robot.logger.debug "Action = #{action}"
              robot.logger.debug "Sha = #{sha}"
              robot.logger.debug "Repository = #{repository}"
              robot.logger.debug "RepoBranch = #{repoBranch}"
              robot.logger.debug "Branch = #{branch}"
              robot.logger.debug "OrgName = #{orgName}"
              robot.logger.debug "FlowRoom = #{flow_room}"

            #####################################
            # Print to console for logging help #
            #####################################
            console.log "Preflight pull request event: #{repository}\n"

            # Set the buildType
            get_build_type repository, branch, (callback) ->
              # Set the job type    
              set_jenkins_job buildType, (callback) ->
                # Run the preflight
                run_jenkins_preflight_job repository, branch, sha, robot, (callback) ->
                

      ######################################################
      # The sha sum doesnt match, maybe man in the middle? #
      ######################################################        
      else
        if(debug)
          robot.messageRoom flow_room, "SHA1 hash from payload does NOT match. Please verify webhook secret is valid and set in HUBOT.env"
