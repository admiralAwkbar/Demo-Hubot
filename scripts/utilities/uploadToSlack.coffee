#  Description:
#   Upload file to slack
#
# Dependencies:
#   "request": "~2"
#
# Configuration:
#   HUBOT_SLACK_TOKEN
#

request = require 'request'
fs = require 'fs'

hubot_api_token = process.env.HUBOT_SLACK_TOKEN
slack_base_url = "https://slack.com/api/files.upload"

uploadToSlack = (robot, file, flowRoom, cb) ->
  robot.logger.info "file is:[#{file}] flow room is:[#{flowRoom}]"

  url = slack_base_url
  options =
    method: 'POST'
    url: url
    formData:
      channels: flowRoom
      token: hubot_api_token
      file: fs.createReadStream(file)

  robot.logger.info "url is #{url}"
  httpRequest options, cb

httpRequest = (options, cb) ->
  request options, (err, res, body) ->
    if err?
      return cb err
    if 200 != res.statusCode
      if 201 != res.statusCode
        err = new Error res.statusCode
        err.body = body
        return cb err
    if body.responses? and body.responses[0]?.error?.message?
      err = new Error body.responses[0].error.message
      err.body = body
      return cb err

    cb null, body

exports.uploadToSlack = uploadToSlack
