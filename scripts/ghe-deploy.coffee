# Description:
#  Runs backup of GHE instance using Flow
#  Runs upgrade of GHE instance using Flow
#
# Configuration:
#   FLOW_BASE
#   FLOW_USER
#   FLOW_PASSWORD
#
# Commands:
#   hubot backup list - list instances of GHE that can be backed up
#   hubot backup instance <GHE INSTANCE> - run a backup of GHE instance (as long as you have backup role, do hubot help role for more details)
#   hubot upgrade instance <instance> <version> - upgrades GHE instance specified to specified version
#
# Author:
#   admiralAwkbar@github.com
#

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

  robot.respond /backup list/i, (msg) ->
    msgRoomSrc = msg.message.room
    unless msgRoomSrc == ghe_room_id
      msg.send "This command cannot be executed in this room"
      return

    path = "/properties/backups/backupList?projectName=GHE"
    return_msg ="Run backups of the following GHE instances\n"
    get robot, path, (body) ->
      msg.send return_msg + body.property.value

  robot.respond /backup instance (.*)/i, (msg) ->
    role = 'backup'
    unless robot.auth.hasRole(msg.envelope.user, role)
      msg.send "Access denied. You must have this role to use this command: #{role}"
      return
    msgRoomSrc = msg.message.room
    unless msgRoomSrc == ghe_room_id
      msg.send "This command cannot be executed in this room"
      return

    instance = msg.match[1]
    project = "GHE"
    procedure = "RunBackup"

    postBody =
      parameters:
        actualParameter: [
          value: instance
          actualParameterName: "00.GHEInstance"
        ]

    basePath = "/jobs?request=runProcedure&projectName="
    path = basePath + project + "&procedureName=" + procedure

    return_msg = "jobID is :"
    post robot, path, JSON.stringify(postBody), (body) ->
      msg.send return_msg + body.jobId

  robot.respond /room test/i, (msg) ->
    msg.send "this room is " + msg.message.room

  robot.respond /upgrade instance (.*) (.*)/i, (msg) ->
    role = 'upgrade'
    unless robot.auth.hasRole(msg.envelope.user, role)
      msg.send "Access denied. You must have this role to use this command: #{role}"
      return
    msgRoomSrc = msg.message.room
    unless msgRoomSrc == ghe_room_id
      msg.send "This command cannot be executed in this room"
      return

    instance = msg.match[1]
    version = msg.match[2]
    project = "GHE"
    procedure = "RunUpgrade"

    postBody =
      parameters:
        actualParameter: [
          { value: instance
          actualParameterName: "00.GHEInstance"},
          {value: version
          actualParameterName: "01.GHEVersion"}
        ]

    basePath = "/jobs?request=runProcedure&projectName="
    path = basePath + project + "&procedureName=" + procedure

    return_msg = "Please be patient, this can take a few mintes... Upgrade jobID is :"
    post robot, path, JSON.stringify(postBody), (body) ->
      msg.send return_msg + body.jobId
