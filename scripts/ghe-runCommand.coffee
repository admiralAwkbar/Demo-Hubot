# Description:
#  Runs commands on GHE instance using Flow
#
# Configuration:
#   FLOW_BASE
#   FLOW_USER
#   FLOW_PASSWORD
#
# Commands:
#   hubot ghe commands list - list GHE commands that can be ran
#   hubot ghe command <command> <instance> - run a command on GHE instance (as long as you have execute role, do hubot help role for more details)
#
# Author:
#   admiralAwkbar@github.com

Url = require 'url'
request = require '../node_modules/request'

base_url = process.env.FLOW_BASE
user = process.env.FLOW_USER
password = process.env.FLOW_PASSWORD
ghe_room_id = process.env.GHE_ROOM_ID

get = (robot,path,handler) ->
  options =
    url: base_url + path
    method: 'GET'
    rejectUnauthorized: false
    auth:
      user: user
      password: password
    headers:
      'Content-Type': 'application/json'
  request options, (err, res, body) ->
    if err?
      robot.logger.error "REST issue detected. Url is #{options.url}"
    else
      if res.statusCode < 400
        robot.logger.info "Success #{res.statusCode}: #{JSON.stringify(body)}"
        data = null
        try
          data = JSON.parse(body)
        catch error
          msg.send "Ran into an error parsing JSON #{options.url}"
          handler
        handler data
      else
        robot.logger.error "Err stats #{res.statusCode} #{JSON.stringify(body)}"
        handler

post = (robot,path,postData,handler) ->
  options =
    url: base_url + path
    method: 'POST'
    rejectUnauthorized: false
    auth:
      user: user
      password: password
    headers:
      'Content-Type': 'application/json'
    body: postData
  request options, (err, res, body) ->
    if err?
      robot.logger.error "REST issue detected. Url is #{options.url}"
    else
      if res.statusCode < 400
        robot.logger.info "Success #{res.statusCode}: #{JSON.stringify(body)}"
        data = null
        try
          data = JSON.parse(body)
        catch error
          msg.send "Ran into an error parsing JSON #{options.url}"
          handler
        handler data
      else
        robot.logger.error "Err stats #{res.statusCode} #{JSON.stringify(body)}"
        handler

module.exports = (robot) ->

  robot.respond /ghe list commands/i, (msg) ->
    msgRoomSrc = msg.message.room
    unless msgRoomSrc == ghe_room_id
      msg.send "This command cannot be executed in this room"
      return

    path = "/properties/GHE-ActionsCommands?projectName=GHE"
    return_msg ="GHE commands\n"
    get robot, path, (body) ->
      msg.send return_msg + body.property.value

  robot.respond /ghe command (.*) (.*)/i, (msg) ->
    role = 'execute'
    unless robot.auth.hasRole(msg.envelope.user, role)
      msg.send "Access denied. You must have this role to use this command: #{role}"
      return
    msgRoomSrc = msg.message.room
    unless msgRoomSrc == ghe_room_id or msgRoomSrc == does_demo_room_id
      msg.send "This command cannot be executed in this room"
      return

    action = msg.match[1]
    instance = msg.match[2]
    project = "GHE"
    procedure = "PerformAction"

    postBody =
      parameters:
        actualParameter: [
          { value: instance
          actualParameterName: "00.GHEInstance"},
          {value: action
          actualParameterName: "Action"}
        ]

    basePath = "/jobs?request=runProcedure&projectName="
    path = basePath + project + "&procedureName=" + procedure

    return_msg = "Please be patient, this could take a few moments... jobID is :"
    post robot, path, JSON.stringify(postBody), (body) ->
      msg.send return_msg + body.jobId
