# Description:
#   This is a Hubot integation that allows the user to request Admin Stats for the GitHub Instances from Flowdock.
#
# Notes:
#   This integration uses GitHub tokens to authenticate when using the GitHub API. You will need 
#   to generate these and place this information in your hubot.env file.
#
# Commands:
#   hubot ghe-stats is : Get all admin statistics on the GitHub Inner Source Instance.
#   hubot ghe-stats sc : Get all admin statistics on the GitHub Social Coding Instance.
#
# Author:
#   admiralAwkbar@github.com

Url = require 'url'
request = require 'request'
http = require 'http'
ghe_sc_token = 'token '+process.env.GHE_SC_TOKEN
ghe_is_token = 'token '+process.env.GHE_IS_TOKEN
base_url_is = process.env.GHE_URL_IS
base_url_sc = process.env.GHE_URL_SC

module.exports = (robot) ->

   robot.respond /ghe-stats is/i, (msg) ->
     path = "/api/v3/enterprise/stats/all"

     url = Url.parse(base_url_is)
     url.pathname = path

     options =
       url: Url.format(url)
       method: 'GET'
       rejectUnauthorized: false
       headers:
         'Authorization': ghe_is_token,
         'Content-Type': 'application/json'

     request options, (err, res, body) ->
       if err?
         robot.logger.error "Error communication with GitHub Enterprise-SC API: #{err}"
       else
         if res.statusCode < 400
           robot.logger.info "Success #{res.statusCode}: #{JSON.stringify(body)}"
           data = null
           try
             data = JSON.parse(body)
           catch error
             msg.send "Ran into an error parsing JSON"
             return
           response = "GitHub Enterprise Inner Source Statistics\n\n"
           for key of data
             response = response + "#{key}"+":\n"
             nested_data = data[key]
             for nested_key of nested_data
               response = response + "#{nested_key}"+" : "+"#{nested_data[nested_key]}"+"\n"
             response = response + "\n"
           msg.send "```\n#{response}\n```"
         else
           robot.logger.error "Error, status #{res.statusCode}: #{JSON.stringify(body)}"


   robot.respond /ghe-stats sc/i, (msg) ->
     path = "/api/v3/enterprise/stats/all"

     url = Url.parse(base_url_sc)
     url.pathname = path

     options =
       url: Url.format(url)
       method: 'GET'
       rejectUnauthorized: false
       headers:
         'Authorization': ghe_sc_token, 
         'Content-Type': 'application/json'

     request options, (err, res, body) ->
       if err?
         robot.logger.error "Error communication with GitHub Enterprise-SC API: #{err}"
       else
         if res.statusCode < 400
           robot.logger.info "Success #{res.statusCode}: #{JSON.stringify(body)}"
           data = null
           try
             data = JSON.parse(body)
           catch error
             msg.send "Ran into an error parsing JSON"
             return
           response = "GitHub Enterprise Social Coding Statistics\n\n"
           for key of data
             response = response + "#{key}"+":\n"
             nested_data = data[key]
             for nested_key of nested_data
               response = response + "#{nested_key}"+" : "+"#{nested_data[nested_key]}"+"\n"
             response = response + "\n"
           msg.send "```\n#{response}\n```"
         else
           robot.logger.error "Error, status #{res.statusCode}: #{JSON.stringify(body)}"
