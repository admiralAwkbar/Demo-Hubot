# Description:
#   Interact with your ElectricFlow server
#
# Dependencies:
#   "request": "~2"
#
# Configuration:
#   FLOW_BASE
#   FLOW_USER
#   FLOW_PASSWORD
#

request = require 'request'

# Reding in the base info needed for rest calls
flow_base_url = process.env.FLOW_BASE
flow_user = process.env.FLOW_USER
flow_password = process.env.FLOW_PASSWORD

# List EF projects
listProjects = (cb) =>
  path = "/projects"
  httpGet path, (err, result) =>
    return cb err if err?
    cb null, result.project

# List EF environments
listEnvironments = (cb) =>
  path = "/projects/default/environments"
  httpGet path, (err, result) =>
    return cb err if err?
    cb null, result.environment

# List EF pipelines    
listPipelines = (project, cb) =>
  path = "/projects/#{project}/pipelines"
  httpGet path, (err, result) =>
    return cb err if err?
    cb null, result.pipeline

# List EF schedules
listSchedules = (project, cb) =>
  path = "/projects/#{project}/schedules"
  httpGet path, (err, result) =>
    return cb err if err?
    cb null, result.schedule

# List EF jobs of schedules
listJobsOfSchedule = (project, schedule, cb) =>
  path = "/project/#{project}/schedules/#{schedule}/jobs"
  httpGet path, (err, result) =>
    return cb err if err?
    cb null, result.job

# List EF procedures of project
listProcedures = (project, cb) =>
  path = "/projects/#{project.projectName}/procedures"
  httpGet path, (err, result) =>
    return cb err if err?
    cb null, result.procedure

# Run EF pipeline    
runPipeline = (project, pipeline, parameters, cb) =>
  path = "/pipelines?pipelineName=#{pipeline}&projectName=#{project}"

  data = {}
  if parameters?
    actualParameter = []
    for key, value of parameters
      actualParameter.push({actualParameterName: key, value: value})
    data =
      parameters:
        actualParameter: actualParameter

  httpPost path, data, (err, result) =>
    return cb err if err?
    cb null, result

# Run EF schedule    
runSchedule = (project, schedule, parameters, cb) =>
  path = "/jobs?request=runProcedure&projectName=#{project}&scheduleName=#{schedule}"

  data = {}
  if parameters?
    actualParameter = []
    for key, value of parameters
      actualParameter.push({actualParameterName: key, value: value})
    data =
      parameters:
        actualParameter: actualParameter

  httpPost path, data, (err, result) =>
    return cb err if err?
    cb null, result

# Run EF procedure of project
runProcedure = (project, procedure, parameters, cb) =>
  path = "/jobs?request=runProcedure&projectName=#{project}&procedureName=#{procedure}"

  data = {}
  if parameters?
    actualParameter = []
    for key, value of parameters
      actualParameter.push({actualParameterName: key, value: value})
    data =
      parameters:
        actualParameter: actualParameter

  httpPost path, data, (err, result) =>
    return cb err if err?
    cb null, result

# Get EF job details
getJob = (jobId, cb) =>
  path = "/jobs/#{jobId}"
  httpGet path, (err, result) =>
    return cb err if err?
    cb null, result.job

# Delete EF environment
deleteEnv = (environment, cb) =>
  path = "/projects/default/environments/#{environment}"
  httpDelete path, (err, result) =>
    return cb err if err?
    cb null, result

# Base HTTP get command
httpGet = (path, cb) =>
  url = "#{flow_base_url}#{path}"
  options =
    method: 'GET'
    url: url
    rejectUnauthorized: false
    auth:
      user: flow_user
      password: flow_password
    json: true

  httpRequest options, cb

# Base HTTP delete command  
httpDelete = (path, cb) =>
  url = "#{flow_base_url}#{path}"
  options =
    method: 'DELETE'
    url: url
    rejectUnauthorized: false
    auth:
      user: flow_user
      password: flow_password
    json: true

  httpRequest options, cb

# Base HTTP Post command
httpPost = (path, data, cb) =>
  url = "#{flow_base_url}#{path}"
  options =
    method: 'POST'
    url: url
    rejectUnauthorized: false
    auth:
      user: flow_user
      password: flow_password
    json: true
    body: data

  httpRequest options, cb

# Base HTTP Request command
httpRequest = (options, cb) =>
  request options, (err, res, body) ->
    if err?
      return cb err
    if 200 != res.statusCode
      err = new Error res.statusCode
      err.body = body
      return cb err
    if body.responses? and body.responses[0]?.error?.message?
      err = new Error body.responses[0].error.message
      err.body = body
      return cb err

    cb null, body

# Exports back to main coffeescript
exports.runSchedule= runSchedule
exports.listJobsOfSchedule = listJobsOfSchedule
exports.runPipeline= runPipeline
exports.listPipelines= listPipelines
exports.listSchedules = listSchedules
exports.listProjects = listProjects
exports.listProcedures = listProcedures
exports.runProcedure = runProcedure
exports.getJob = getJob
exports.listEnvironments = listEnvironments
exports.deleteEnv = deleteEnv
