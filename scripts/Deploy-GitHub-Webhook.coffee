# Description:
#   Deploy hubot using Jenkins. Github pull requests trigger the
#   deployment when PR is closed and merged to master successfully.
#   Deployment script does a clean rebuild of hubot with latest
#   code changes from master.
#
#   updated October to use Jenkins
#
# Configuration:
#   FLOW_ROOM - Send deploy messages to this room. Make sure hubot is added to room
#   hubot_WEBOOK_SECRET - Secret used to varify SHA1 hash from githu webhook.
#   jenkins_hubot_job_TO_DEPLOY_hubot - EC project that holds deploy procedure
#   LISTENED_REPO_TO_DEPLOY_hubot - What GHE repo to listen for hamer PR's
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
# Author:
#   admiralAwkbar@github.com

############
# Includes #
############
request = require 'request'
crypto = require 'crypto'
jenkin = require './utilities/jenkinsUtils'

#############
# Variables #
#############
flow_room = process.env.FLOW_ROOM
secret = process.env.HUBOT_WEBOOK_SECRET
jenkins_url = process.env.HUBOT_JENKINS_URL

##############
# Hubot Vars #
##############
jenkins_hubot_job = process.env.HUBOT_BUILD_HUBOT_JOB
jenkins_hubot_preflight_job = process.env.HUBOT_BUILD_HUBOT_PREFLIGHT_JOB
hubot_repo = process.env.HUBOT_REPO

####################
# Build Agent Vars #
####################
jenkins_build_agents = process.env.HUBOT_BUILD_AGENT_JOB
agent_repo = process.env.AGENT_REPO
agent_preflight_job = process.env.AGENT_PREFLIGHT_JOB

####################
# Build Agent Vars #
####################
ci_repo_job = "holding"
ci_repo = "HoldingForNow"

###################
# Set debug level #
###################
debug = false

##################################
# Parse branch name from the ref #
##################################
parse_branch = (repoBranch) ->
  arrBranches = repoBranch.split("/")
  if arrBranches.length > 0
    return arrBranches[2]
  ""
  
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

###################
# Start Listening #
###################
module.exports = (robot) ->
  robot.respond /webhook test$/i, (msg) ->
    msg.send "I'm listening..."
    robot.messageRoom flow_room, "testing new messageRoom functionality"

  robot.on "github-repo-event", (repo_event) ->
    ghePayload = repo_event.payload
    signature = repo_event.signature
    if(debug)
      console.log "payLoad received is: #{JSON.stringify(ghePayload,null,2)} with signature #{signature}"
    verify_signature robot, ghePayload, signature, (match) ->
      if match == "MATCH"
        if(debug)
          robot.messageRoom flow_room, "[DEBUG] sha1 signature verified"
        switch(repo_event.eventType)
          ######################################################################
          #### PREFLIGHT PUSH EVENTS BELOW #####################################
          ######################################################################
          when "push"
            #############################
            # root level values/objects #
            #############################
            repository = ghePayload.repository.full_name
            repoBranch = ghePayload.ref
            beforeSha = ghePayload.before
            sha = ghePayload.after
            branch = parse_branch repoBranch

            ###############################
            # See if debug is on to print #
            ###############################
            if(debug)
              robot.logger.debug "Repository = #{repository}"
              robot.logger.debug "Branch = #{branch}"
              robot.logger.debug "Sha = #{sha}"

            ###########################
            # Check for dead push     #
            # Create/delete of branch #
            ###########################
            # A dead SHA is all 0's
            deadSha = "0000000000000000000000000000000000000000"
            if  beforeSha == deadSha || sha == deadSha || branch == "master"
              console.log "Close/Open of branch, not valid push\n"
            else
              #####################################
              # Print to console for logging help #
              #####################################
              console.log "Preflight push event: #{repository}\n"

              ########################
              # Check if Hubot Build #
              ########################
              if hubot_repo == repository
                parameters = "OrgRepo=#{repository}&Branch=#{branch}&SHA=#{sha}"
                # No messages for preflight.. its noise...
                #message = "Detected Preflight for Hubot on repo:[#{repository}]\n"
                #message = "Passing Parameters:[#{parameters}]\n"
                #message = message + "Started Build, Waiting for Jenkins JobID...\n"
                #message.trim()
                #robot.messageRoom flow_room, message

                args = []
                args.push(jenkins_hubot_preflight_job + ',' + parameters)
                # instantiate child process to be able to create a subprocess
                {spawn} = require 'child_process'
                # create new subprocess and have it run the script
                cmd = spawn '/opt/hubot/scripts/utilities/py_utils/Launch-Jenkins-Job.py', args
                # catch stdout and output into hubot's log
                cmd.stdout.on 'data', (data) ->
                  #robot.messageRoom flow_room, "```\n#{data.toString()}\n```"
                  console.log data.toString().trim()
                # catch stderr and output into hubot's log
                cmd.stderr.on 'data', (data) ->
                  console.log data.toString().trim()
                  #robot.messageRoom flow_room, "```\n#{data.toString()}\n```"
               
              #########################
              # Check if Agents Build #
              #########################
              if agent_repo == repository
                parameters = "OrgRepo=#{repository}&Branch=#{branch}&SHA=#{sha}"
                # No messages for preflight.. its noise...
                #message = "Detected Preflight for Hubot on repo:[#{repository}]\n"
                #message = "Passing Parameters:[#{parameters}]\n"
                #message = message + "Started Build, Waiting for Jenkins JobID...\n"
                #message.trim()
                #robot.messageRoom flow_room, message

                args = []
                args.push(agent_preflight_job + ',' + parameters)
                # instantiate child process to be able to create a subprocess
                {spawn} = require 'child_process'
                # create new subprocess and have it run the script
                cmd = spawn '/opt/hubot/scripts/utilities/py_utils/Launch-Jenkins-Job.py', args
                # catch stdout and output into hubot's log
                cmd.stdout.on 'data', (data) ->
                  #robot.messageRoom flow_room, "```\n#{data.toString()}\n```"
                  console.log data.toString().trim()
                # catch stderr and output into hubot's log
                cmd.stderr.on 'data', (data) ->
                  console.log data.toString().trim()
                  #robot.messageRoom flow_room, "```\n#{data.toString()}\n```"
                
          ######################################################################
          #### PULL REQUESTS BELOW #############################################
          ######################################################################
          when "pull_request"
            #####################
            # Root Level Values #
            #####################
            action = ghePayload.action
            pull_request = ghePayload.pull_request
            repository = ghePayload.repository.full_name

            #######################
            # Pull Request Values #
            #######################
            number = pull_request.number
            merged = pull_request.merged
            pr_url = pull_request.html_url
            title  = pull_request.title

            ###############
            # Head Values #
            ###############
            head = pull_request.head
            head_repo = head.repo.full_name
            head_branch = head.ref
            head_sha = head.sha
            head_shortSha = head_sha.substring(0,7)
            head_htmlUrl = head.repo.html_url

            ###############
            # Base Values #
            ###############
            base = pull_request.base
            base_repo = base.repo.full_name
            base_branch = base.ref
            base_sha = base.sha
            base_shortSha = base_sha.substring(0,7)
            base_htmlUrl = base.repo.html_url

            ####################
            # Print debug info #
            ####################
            if(debug)
              robot.logger.debug "action = #{action}"
              robot.logger.debug "repository = #{repository}"
              robot.logger.debug "number = #{number}"
              robot.logger.debug "merged = #{merged}"
              robot.logger.debug "head_branch = #{head_branch}"
              robot.logger.debug "head_sha = #{head_sha}"
              robot.logger.debug "head_shortSha = #{head_shortSha}"
              robot.logger.debug "head_htmlUrl = #{head_htmlUrl}"
              robot.logger.debug "base_branch = #{base_branch}"
              robot.logger.debug "base_sha = #{base_sha}"
              robot.logger.debug "base_shortSha = #{base_shortSha}"
              robot.logger.debug "base_htmlUrl = #{base_htmlUrl}"
                    
            #################################
            # Check if Jenkins Agents Build #
            #################################
            if agent_repo == repository
              if action == "closed" and merged == true
                message = "Detected merged GitHub pull request:##{number} for Build Agents on repo:[#{repository}]\n"
                message = message + "Started Build, Waiting for Jenkins JobID...\n"
                message.trim()
                robot.messageRoom flow_room, message

                args = []
                args.push(jenkins_build_agents)
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

            ########################
            # Check if Hubot Build #
            ########################
            if hubot_repo == repository
              if action == "closed" and merged == true
                message = "Detected merged GitHub pull request:##{number} for Hubot on repo:[#{repository}]\n"
                message = message + "Rebuilding myself, Waiting for Jenkins JobID...\n"
                message.trim()
                robot.messageRoom flow_room, message

                args = []
                args.push(jenkins_hubot_job)
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
                  
            #####################
            # Check if CI Build #
            #####################
            if ci_repo == repository
              if action == "closed" and merged == true
                message = "Detected merged GitHub pull request:##{number} for CI on repo:[#{repository}]\n"
                message = message + "Started Build, Waiting for Jenkins JobID...\n"
                message.trim()
                robot.messageRoom flow_room, message

                args = []
                parameters =
                  repository: repository
                  pr: number
                  pr_url: pr_url
                  head: "#{head_repo} : #{head_branch} (<a href=\"#{head_htmlUrl}/commit/#{head_sha}\">#{head_shortSha}</a>)"
                  base: "#{base_repo} : #{base_branch} (<a href=\"#{base_htmlUrl}/commit/#{base_sha}\">#{base_shortSha}</a>)"
                
                console.log "DEBUG: parameters being sent are: #{JSON.stringify(parameters)} for job #{ci_repo_job}"
                args.push(ci_repo_job + ',' + parameters)
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
