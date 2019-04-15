# Description:
#   Interact with your Jenkins CI server
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_JENKINS_URL
#   HUBOT_JENKINS_AUTH
#
#   Auth should be in the "user:password" format.
#
# Commands:
#   `hubot jenkins build <job>` - builds the specified Jenkins job
#   `hubot jenkins build <job>, <params>` - builds the specified Jenkins job with parameters as key=value&key2=value2
#   `hubot jenkins describe <job>` - Describes the specified Jenkins job
#   `hubot jenkins last <job>` - Details about the last build for the specified Jenkins job
#
# Author:
#   @admiralAwkbar

###########
# Globals #
###########
url = process.env.HUBOT_JENKINS_URL

############################
# Pointing to utils script #
############################
jenkin = require './utilities/jenkinsUtils'
request = require 'request'
module.exports = (robot) ->
  ####################################################
  # Jenkins build Jobs Loop ##########################
  ####################################################
  robot.respond /j(?:enkins)? build ([\w\.\-_ ]+)(, (.+))?/i, (msg) ->
    jobName = msg.match[1].replace /^\s+|\s+$/g, ""
    if msg.match[3]?
      remainder = msg.match[3].replace /^\s+|\s+$/g, ""
    robot.logger.info "Build job #{jobName}"

    # set up args
    args = []
    parameters = null
    if remainder?
      parameters = remainder
      args.push(jobName + ',' + parameters)
    else
      args.push(jobName)

    # Start the job
    msg.send "Generating Jenkins job for #{jobName}..."
    args = []
    args.push(jobName + ',' + parameters)
    # instantiate child process to be able to create a subprocess
    {spawn} = require 'child_process'
    # create new subprocess and have it run the script
    cmd = spawn 'scripts/utilities/py_utils/Launch-Jenkins-Job.py', args
    # catch stdout and output into hubot's log
    cmd.stdout.on 'data', (data) ->
      msg.send "```\n#{data.toString()}\n```"
      console.log data.toString().trim()
    # catch stderr and output into hubot's log
    cmd.stderr.on 'data', (data) ->
      console.log data.toString().trim()
      msg.send "```\n#{data.toString()}\n```"

  ############ END OF LOOP ###########################
  ####################################################


  ####################################################
  # Jenkins Describe Jobs Loop #######################
  ####################################################
  robot.respond /(?:jenkins)? describe(?:\s)?(.*)/i, (msg) ->
    jobName = msg.match[1].replace /^\s+|\s+$/g, ""
    robot.logger.info "Describe job #{jobName}"
    jenkin.describeJob jobName, (err, job) =>
      if err?
        robot.logger.error "Failed to describe job", err
        return msg.send "Jenkins says: #{err.message}"

      response = "Job:#{jobName}\n"
      try
        response += "JOB: #{job.displayName}\n"
        response += "URL: #{job.url}\n"

        if content.description
          response += "DESCRIPTION: #{job.description}\n"

        response += "ENABLED: #{job.buildable}\n"
        response += "STATUS: #{job.color}\n"

        tmpReport = ""
        if job.healthReport.length > 0
          for report in job.healthReport
            tmpReport += "\n  #{report.description}"
        else
          tmpReport = " unknown"
        response += "HEALTH: #{tmpReport}\n"

        parameters = ""
        for item in job.actions
          if item.parameterDefinitions
            for param in item.parameterDefinitions
              tmpDescription = if param.description then " - #{param.description} " else ""
              tmpDefault = if param.defaultParameterValue then " (default=#{param.defaultParameterValue.value})" else ""
              parameters += "\n  #{param.name}#{tmpDescription}#{tmpDefault}"

        if parameters != ""
          response += "PARAMETERS: #{parameters}\n"

        response.trim()
        msg.send response

        if not job.lastBuild
          return
  ############ END OF LOOP ###########################
  ####################################################


  ####################################################
  # Jenkins last Jobs Loop ###########################
  ####################################################
  robot.respond /(?:jenkins)? last(?:\s)?(.*)/i, (msg) ->
    jobName = msg.match[1].replace /^\s+|\s+$/g, ""
    robot.logger.info "Last job #{jobName}"
    jenkin.lastJob jobName, (err, job) =>
      if err?
        robot.logger.error "Failed to get last job", err
        return msg.send "Jenkins says: #{err.message}"

      response = "Last Job:#{jobName}"
      response += "NAME: #{job.fullDisplayName}\n"
      response += "URL: #{job.url}\n"

      if content.description
        response += "DESCRIPTION: #{job.description}\n"
        response += "BUILDING: #{job.building}\n"

      response.trim()
      msg.send response
  ############ END OF LOOP ###########################
  ####################################################
