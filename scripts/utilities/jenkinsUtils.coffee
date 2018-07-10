# Description:
#   Interact with your Jenkins server
#
# Dependencies:
#   "request": "~2"
#
# Configuration:
#
#   HUBOT_JENKINS_URL
#   HUBOT_JENKINS_AUTH
#
# Author
# @admiralAwkbar

request = require 'request'

#################################################
# Reding in the base info needed for rest calls #
# Pullikng in path and Auth                     #
#################################################
jenkins_base_url = process.env.HUBOT_JENKINS_URL
jenkins_auth = process.env.HUBOT_JENKINS_AUTH
jenkinsUserName = process.env.HUBOT_JENKINS_AUTH_USER
jenkinsPasswd = process.env.HUBOT_JENKINS_AUTH_PASSWD
jenkinsToken = process.env.HUBOT_JENKINS_SECRET

#####################
# List Jenkins Jobs #
#####################
listJobs = (cb) =>
  path = "/api/json"
  httpGet path, (err, result) =>
    return cb err if err?
    cb null, result.jobs

########################
# Describe Jenkins Job #
########################
describeJob = (job,cb) =>
  path = "/job/#{job}/api/json"
  httpGet path, (err, result) =>
    return cb err if err?
    cb null, result

########################
# Get Jenkins Last job #
########################
lastJob = (job, cb) =>
  path = "/job/#{job}/lastBuild/api/json"
  httpGet path, (err, result) =>
    return cb err if err?
    cb null, result

#####################
# Build Jenkins Job #
#####################
buildJob = (job, parameters, cb) =>
  path = "/job/#{job}"

  data = {}
  if parameters?
    path = "#{path}" + "/buildWithParameters?#{parameters}&token=#{jenkinsToken}"
  else
    path = "#{path}" + "/build?token=#{jenkinsToken}"
  console.log "DEBUG: full path being sent to jenkins #{path}"
  httpPost path, data, (err, result) =>
    return cb err, result if err?
    cb null, result

##########################
# Build Jenkins Json Job #
##########################
buildJsonJob = (job, parameters, cb) =>
  path = "/job/#{job}"

  data = {}
  if parameters?
    path = "#{path}" + "/buildWithParameters?jsonpayload={\"payload\":#{JSON.stringify(parameters)}}&token=#{jenkinsToken}"
  else
    path = "#{path}" + "/build?token=#{jenkinsToken}"
  console.log "DEBUG: full path being sent to jenkins #{path}"
  httpPost path, data, (err, result) =>
    return cb err, result if err?
    cb null, result

################################
################################
####### BASE CALLS BELOW #######
################################
################################

# Base HTTP get command
httpGet = (path, cb) =>
  url = "#{jenkins_base_url}#{path}"
  options =
    method: 'GET'
    url: url
    rejectUnauthorized: false
    auth:
      user: jenkinsUserName
      password: jenkinsPasswd
    json: true

  httpRequest options, cb

# Base HTTP delete command
httpDelete = (path, cb) =>
  url = "#{jenkins_base_url}#{path}"
  options =
    method: 'DELETE'
    url: url
    rejectUnauthorized: false
    auth:
      user: jenkinsUserName
      password: jenkinsPasswd
    json: true

  httpRequest options, cb

# Base HTTP Post command
httpPost = (path, data, cb) =>
  url = "#{jenkins_base_url}#{path}"
  console.log "DEBUG: full url being sent to jenkins #{url}"
  options =
    method: 'POST'
    url: url
    rejectUnauthorized: false
    auth:
      user: jenkinsUserName
      password: jenkinsPasswd
    json: true
    body: data

  httpRequest options, cb

# Base HTTP Request command
httpRequest = (options, cb) =>
  request options, (err, res, body) ->
    if err?
      return cb err
    if 200 != res.statusCode
      err= {}
      err.status = res.statusCode
      return cb err
    if body.responses? and body.responses[0]?.error?.message?
      err = new Error body.responses[0].error.message
      err.body = body
      return cb err
    cb null, body, res

# Exports back to main coffeescript
exports.listJobs= listJobs
exports.buildJob = buildJob
exports.buildJsonJob = buildJsonJob
exports.describeJob= describeJob
exports.lastJob= lastJob
