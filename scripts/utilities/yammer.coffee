# Description:
#   Interact with Yammer
#
# Dependencies:
#   "request": "~2"
#
# Configuration:
#

request = require 'request'

yammer_base_url = 'https://api.yammer.com/api/v1/'
yammer_oauth2_token_url = "https://www.yammer.com/oauth2/access_token"

oauth2_getToken = (robot, client_id, client_secret, code, cb) =>
  url = yammer_oauth2_token_url
  data = "client_id=#{client_id}&client_secret=#{client_secret}&code=#{code}&grant_type=authorization_code"
  options =
    method: 'POST'
    url: url
    #rejectUnauthorized: false
    body: data

  message = "\n\nurl is #{url}\n"
  message = message + "data is #{data}\n"
  message = message + "options are #{JSON.stringify(options,null,2)}\n"

  robot.logger.debug message
  httpRequest options, cb

listUserGroups = (token, callback) =>
  path = 'groups.json?mine=1'
  httpGet token, path, (error, result) =>
    return callback error if error?
    groups = ({id: g.id, name: g.name, full_name: g.full_name} for g in result)
    callback null, groups

postMessage = (token, group, message, callback) =>
  path = 'messages.json'
  listUserGroups token, (error, groups) =>
    return callback error if error?
    groups =(g for g in groups when g.name.toLowerCase() == group.toLowerCase())
    if groups.length == 0
      return callback(new Error "Not found group #{group}")

    data = 
      body: message
      group_id: groups[0].id
    httpPost token, path, data, (error, result) =>
      return callback error if error?
      callback null, result

httpGet = (token, path, callback) =>
  url = "#{yammer_base_url}#{path}"
  options =
    method: 'GET'
    url: url
    rejectUnauthorized: false
    auth:
      bearer: token
    json: true

  httpRequest options, callback

httpPost = (token, path, data, callback) =>
  url = "#{yammer_base_url}#{path}"
  options =
    method: 'POST'
    url: url
    rejectUnauthorized: false
    auth:
      bearer: token
    json: true
    body: data

  httpRequest options, callback

httpRequest = (options, callback) =>
  request options, (err, res, body) ->
    if err?
      return callback err
    if res.statusCode >= 300
      err = new Error res.statusCode
      err.body = body
      return callback err

    callback null, body

exports.postMessage = postMessage
exports.listUserGroups = listUserGroups
exports.oauth2_getToken = oauth2_getToken
