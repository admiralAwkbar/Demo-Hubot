# Description:
#   GitHub Enterprise appliance utilities.
#
# Notes:
#   GitHub Enterprise appliance utilities.
#
# Commands:
#   hubot ghe-announce <message> : Sets a global announcement banner to be displayed to all users.
#   hubot ghe-announce-rm : Removes the global announcement banner.
#   hubot ghe-check-disk : Checks disk for large files that have been deleted but still have file handles and uploads file to admins chat.
#   hubot ghe-clean-caches : This utility cleans up a variety of caches that might potentially take up extra disk space on the root volume.
#   hubot ghe-repl-status : Checks replication status of Primary to replica.
#   hubot ghe-service-list : Lists services and their status.
#   hubot ghe-system-info : Uploads list of specs for the host system.
#   hubot ghe-ls-logs : ls -al /var/log/github/*.log
#   hubot ghe-ls-all : ls -al /var/log/github
#   hubot ghe-du-vlg : du -sh /var/log/github
#   hubot ghe-du-vlgAll : du -sh /var/log/github/*
#   hubot ghe-maintenance-s : Sets instance on maintenance mode.
#   hubot ghe-maintenance-u : Sets instance off maintenance mode.
#   hubot ghe-maintenance-q : Returns current mode of instance.
#   hubot ghe-user-promote <username> : Promotes the given user to admin status.
#   hubot ghe-user-demote <username> : Demotes the given user from admin status.
#   hubot ghe-csv-users : Counts non-admin users.
#   hubot ghe-csv-admins : Counts admin users.
#   hubot ghe-csv-suspended: Counts suspended users.
#   hubot ghe-support <ticket_number> : Creates support bundle and uploads to GHE support thread with that ticket number.
#   hubot ghe-diagnostics : Uploads diagnostics log to admins chat.
#   hubot ghe-config : Uploads config settings to admins chat.
#   hubot ghe-suspend <username> : Suspends the given user.
#   hubot ghe-unsuspend <username> : Unsuspends the given user.
#
# Author
#  admiralAwkbar@github.com
#


module.exports = (robot) ->

 robot.respond /ghe-announce (.*)/i, (res) ->
      role = 'ghe-admin'
      unless robot.auth.hasRole(res.envelope.user, role)
        res.send "Access denied. You must have this role to use this command: #{role}"
        return
      {spawn} = require 'child_process'
      args = []
      args.push("ghe-announce")
      for arg, index in res.match
         if 0 < index
            args.push(arg.trim())
      #res.send "```\n#{args.toString()}\n```"
      cmd =  spawn './GHE-utilities.py' , args

      # Turn on stdout and send it to flowdock and mallot.log
      cmd.stdout.on 'data', (data) ->
         res.send "```\n#{data.toString().trim()}\n```"
         console.log data.toString().trim()
      cmd.stderr.on 'data', (data) ->
         console.log data.toString().trim()

 

 robot.respond /ghe-announce-rm/i, (res) ->
      role = 'ghe-admin'
      unless robot.auth.hasRole(res.envelope.user, role)
        res.send "Access denied. You must have this role to use this command: #{role}"
        return
      {spawn} = require 'child_process'
      args = []
      args.push("ghe-announce-rm")
      #res.send "```\n#{args.toString()}\n```"
      cmd =  spawn './GHE-utilities.py' , args

      # Turn on stdout and send it to flowdock and mallot.log
      cmd.stdout.on 'data', (data) ->
         res.send "```\n#{data.toString().trim()}\n```"
         console.log data.toString().trim()
      cmd.stderr.on 'data', (data) ->
         console.log data.toString().trim()

 robot.respond /ghe-check-disk/i, (res) ->
      role = 'ghe-admin'
      unless robot.auth.hasRole(res.envelope.user, role)
        res.send "Access denied. You must have this role to use this command: #{role}"
        return
      {spawn} = require 'child_process'
      args = []
      args.push("ghe-check-disk-usage")
      cmd =  spawn './GHE-utilities.py' , args

      # Turn on stdout and send it to flowdock and mallot.log
      cmd.stdout.on 'data', (data) ->
         res.send "```\n#{data.toString().trim()}\n```"
         console.log data.toString().trim()
      cmd.stderr.on 'data', (data) ->
         console.log data.toString().trim()

 robot.respond /ghe-clean-caches/i, (res) ->
      role = 'ghe-admin'
      unless robot.auth.hasRole(res.envelope.user, role)
        res.send "Access denied. You must have this role to use this command: #{role}"
        return
      {spawn} = require 'child_process'
      args = []
      args.push("ghe-cleanup-caches")
      cmd =  spawn './GHE-utilities.py' , args

      # Turn on stdout and send it to flowdock and mallot.log
      cmd.stdout.on 'data', (data) ->
         res.send "```\n#{data.toString().trim()}\n```"
         console.log data.toString().trim()
      cmd.stderr.on 'data', (data) ->
         console.log data.toString().trim()


 robot.respond /ghe-repl-status/i, (res) ->
      role = 'ghe-admin'
      unless robot.auth.hasRole(res.envelope.user, role)
        res.send "Access denied. You must have this role to use this command: #{role}"
        return
      {spawn} = require 'child_process'
      args = []
      args.push("ghe-repl-status")
      cmd =  spawn './GHE-utilities.py' , args

      # Turn on stdout and send it to flowdock and mallot.log
      cmd.stdout.on 'data', (data) ->
         res.send "```\n#{data.toString().trim()}\n```"
         console.log data.toString().trim()
      cmd.stderr.on 'data', (data) ->
         console.log data.toString().trim()

 robot.respond /ghe-service-list/i, (res) ->
      role = 'ghe-admin'
      unless robot.auth.hasRole(res.envelope.user, role)
        res.send "Access denied. You must have this role to use this command: #{role}"
        return
      {spawn} = require 'child_process'
      args = []
      args.push("ghe-service-list")
      cmd =  spawn './GHE-utilities.py' , args

      # Turn on stdout and send it to flowdock and mallot.log
      cmd.stdout.on 'data', (data) ->
         res.send "```\n#{data.toString().trim()}\n```"
         console.log data.toString().trim()
      cmd.stderr.on 'data', (data) ->
         console.log data.toString().trim()

 robot.respond /ghe-system-info/i, (res) ->
      role = 'ghe-admin'
      unless robot.auth.hasRole(res.envelope.user, role)
        res.send "Access denied. You must have this role to use this command: #{role}"
        return
      {spawn} = require 'child_process'
      args = []
      args.push("ghe-system-info")
      cmd =  spawn './GHE-utilities.py' , args

      # Turn on stdout and send it to flowdock and mallot.log
      cmd.stdout.on 'data', (data) ->
         res.send "```\n#{data.toString().trim()}\n```"
         console.log data.toString().trim()
      cmd.stderr.on 'data', (data) ->
         console.log data.toString().trim()

 robot.respond /ghe-ls-logs/i, (res) ->
      role = 'ghe-admin'
      unless robot.auth.hasRole(res.envelope.user, role)
        res.send "Access denied. You must have this role to use this command: #{role}"
        return
      {spawn} = require 'child_process'
      args = []
      args.push("ghe-ls-logs")
      cmd =  spawn './GHE-utilities.py' , args

      # Turn on stdout and send it to flowdock and mallot.log
      cmd.stdout.on 'data', (data) ->
         res.send "```\n#{data.toString().trim()}\n```"
         console.log data.toString().trim()
      cmd.stderr.on 'data', (data) ->
         console.log data.toString().trim()

 robot.respond /ghe-ls-all/i, (res) ->
      role = 'ghe-admin'
      unless robot.auth.hasRole(res.envelope.user, role)
        res.send "Access denied. You must have this role to use this command: #{role}"
        return
      {spawn} = require 'child_process'
      args = []
      args.push("ghe-ls-all")
      cmd =  spawn './GHE-utilities.py' , args

      # Turn on stdout and send it to flowdock and mallot.log
      cmd.stdout.on 'data', (data) ->
         res.send "```\n#{data.toString().trim()}\n```"
         console.log data.toString().trim()
      cmd.stderr.on 'data', (data) ->
         console.log data.toString().trim()



 robot.respond /ghe-du-vlg$/i, (res) ->
      role = 'ghe-admin'
      unless robot.auth.hasRole(res.envelope.user, role)
        res.send "Access denied. You must have this role to use this command: #{role}"
        return
      {spawn} = require 'child_process'
      args = []
      args.push("ghe-du-vlg")
      cmd =  spawn './GHE-utilities.py' , args

      # Turn on stdout and send it to flowdock and mallot.log
      cmd.stdout.on 'data', (data) ->
         res.send "```\n#{data.toString().trim()}\n```"
         console.log data.toString().trim()
      cmd.stderr.on 'data', (data) ->
         console.log data.toString().trim()

 robot.respond /ghe-du-vlgAll$/i, (res) ->
      role = 'ghe-admin'
      unless robot.auth.hasRole(res.envelope.user, role)
        res.send "Access denied. You must have this role to use this command: #{role}"
        return
      {spawn} = require 'child_process'
      args = []
      args.push("ghe-du-vlgAll")
      cmd =  spawn './GHE-utilities.py' , args

      # Turn on stdout and send it to flowdock and mallot.log
      cmd.stdout.on 'data', (data) ->
         res.send "```\n#{data.toString().trim()}\n```"
         console.log data.toString().trim()
      cmd.stderr.on 'data', (data) ->
         console.log data.toString().trim()
 robot.respond /ghe-maintenance-s$/i, (res) ->
      role = 'ghe-admin'
      unless robot.auth.hasRole(res.envelope.user, role)
        res.send "Access denied. You must have this role to use this command: #{role}"
        return
      {spawn} = require 'child_process'
      args = []
      args.push("ghe-maintenance-s")
      cmd =  spawn './GHE-utilities.py' , args

      # Turn on stdout and send it to flowdock and mallot.log
      cmd.stdout.on 'data', (data) ->
         res.send "```\n#{data.toString().trim()}\n```"
         console.log data.toString().trim()
      cmd.stderr.on 'data', (data) ->
         console.log data.toString().trim()

 robot.respond /ghe-maintenance-u$/i, (res) ->
      role = 'ghe-admin'
      unless robot.auth.hasRole(res.envelope.user, role)
        res.send "Access denied. You must have this role to use this command: #{role}"
        return
      {spawn} = require 'child_process'
      args = []
      args.push("ghe-maintenance-u")
      cmd =  spawn './GHE-utilities.py' , args

      # Turn on stdout and send it to flowdock and mallot.log
      cmd.stdout.on 'data', (data) ->
         res.send "```\n#{data.toString().trim()}\n```"
         console.log data.toString().trim()
      cmd.stderr.on 'data', (data) ->
         console.log data.toString().trim()

 robot.respond /ghe-maintenance-q$/i, (res) ->
      role = 'ghe-admin'
      unless robot.auth.hasRole(res.envelope.user, role)
        res.send "Access denied. You must have this role to use this command: #{role}"
        return
      {spawn} = require 'child_process'
      args = []
      args.push("ghe-maintenance-q")
      cmd =  spawn './GHE-utilities.py' , args

      # Turn on stdout and send it to flowdock and mallot.log
      cmd.stdout.on 'data', (data) ->
         res.send "```\n#{data.toString().trim()}\n```"
         console.log data.toString().trim()
      cmd.stderr.on 'data', (data) ->
         console.log data.toString().trim()

 robot.respond /ghe-user-promote (.*)/i, (res) ->
      role = 'ghe-admin'
      unless robot.auth.hasRole(res.envelope.user, role)
        res.send "Access denied. You must have this role to use this command: #{role}"
        return
      {spawn} = require 'child_process'
      args = []
      args.push("ghe-user-promote")
      for arg, index in res.match
         if index != 0
            args.push(arg.trim())

      cmd =  spawn './GHE-utilities.py' , args

      # Turn on stdout and send it to flowdock and mallot.log
      cmd.stdout.on 'data', (data) ->
         res.send "```\n#{data.toString().trim()}\n```"
         console.log data.toString().trim()
      cmd.stderr.on 'data', (data) ->
         console.log data.toString().trim()

 robot.respond /ghe-user-demote (.*)/i, (res) ->
      role = 'ghe-admin'
      unless robot.auth.hasRole(res.envelope.user, role)
        res.send "Access denied. You must have this role to use this command: #{role}"
        return
      {spawn} = require 'child_process'
      args = []
      args.push("ghe-user-demote$")
      for arg, index in res.match
         if index != 0
            args.push(arg.trim())

      cmd =  spawn './GHE-utilities.py' , args

      # Turn on stdout and send it to flowdock and mallot.log
      cmd.stdout.on 'data', (data) ->
         res.send "```\n#{data.toString().trim()}\n```"
         console.log data.toString().trim()
      cmd.stderr.on 'data', (data) ->
         console.log data.toString().trim()
 robot.respond /ghe-csv-users$/i, (res) ->
      role = 'ghe-admin'
      unless robot.auth.hasRole(res.envelope.user, role)
        res.send "Access denied. You must have this role to use this command: #{role}"
        return
      {spawn} = require 'child_process'
      args = []
      args.push("ghe-csv-users")
      cmd =  spawn './GHE-utilities.py' , args

      # Turn on stdout and send it to flowdock and mallot.log
      cmd.stdout.on 'data', (data) ->
         res.send "```\n#{data.toString().trim()}\n```"
         console.log data.toString().trim()
      cmd.stderr.on 'data', (data) ->
         console.log data.toString().trim()

 robot.respond /ghe-csv-admins$/i, (res) ->
      role = 'ghe-admin'
      unless robot.auth.hasRole(res.envelope.user, role)
        res.send "Access denied. You must have this role to use this command: #{role}"
        return
      {spawn} = require 'child_process'
      args = []
      args.push("ghe-csv-admins")
      cmd =  spawn './GHE-utilities.py' , args

      # Turn on stdout and send it to flowdock and mallot.log
      cmd.stdout.on 'data', (data) ->
         res.send "```\n#{data.toString().trim()}\n```"
         console.log data.toString().trim()
      cmd.stderr.on 'data', (data) ->
         console.log data.toString().trim()

 robot.respond /ghe-csv-suspended$/i, (res) ->
      role = 'ghe-admin'
      unless robot.auth.hasRole(res.envelope.user, role)
        res.send "Access denied. You must have this role to use this command: #{role}"
        return
      {spawn} = require 'child_process'
      args = []
      args.push("ghe-csv-suspended")
      cmd =  spawn './GHE-utilities.py' , args

      # Turn on stdout and send it to flowdock and mallot.log
      cmd.stdout.on 'data', (data) ->
         res.send "```\n#{data.toString().trim()}\n```"
         console.log data.toString().trim()
      cmd.stderr.on 'data', (data) ->
         console.log data.toString().trim()

 robot.respond /ghe-support (.*)/i, (res) ->
      role = 'ghe-admin'
      unless robot.auth.hasRole(res.envelope.user, role)
        res.send "Access denied. You must have this role to use this command: #{role}"
        return
      {spawn} = require 'child_process'
      args = []
      args.push("ghe-support")
      for arg, index in res.match
         if 0 < index
            args.push(arg.trim())
      cmd =  spawn './GHE-utilities.py' , args

      # Turn on stdout and send it to flowdock and mallot.log
      cmd.stdout.on 'data', (data) ->
         res.send "```\n#{data.toString().trim()}\n```"
         console.log data.toString().trim()
      cmd.stderr.on 'data', (data) ->
         console.log data.toString().trim()

 robot.respond /ghe-diagnostics$/i, (res) ->
      role = 'ghe-admin'
      unless robot.auth.hasRole(res.envelope.user, role)
        res.send "Access denied. You must have this role to use this command: #{role}"
        return
      {spawn} = require 'child_process'
      args = []
      args.push("ghe-diagnostics")
      cmd =  spawn './GHE-utilities.py' , args

      # Turn on stdout and send it to flowdock and mallot.log
      cmd.stdout.on 'data', (data) ->
         res.send "```\n#{data.toString().trim()}\n```"
         console.log data.toString().trim()
      cmd.stderr.on 'data', (data) ->
         console.log data.toString().trim()

 robot.respond /ghe-config$/i, (res) ->
      role = 'ghe-admin'
      unless robot.auth.hasRole(res.envelope.user, role)
        res.send "Access denied. You must have this role to use this command: #{role}"
        return
      {spawn} = require 'child_process'
      args = []
      args.push("ghe-config")
      cmd =  spawn './GHE-utilities.py' , args

      # Turn on stdout and send it to flowdock and mallot.log
      cmd.stdout.on 'data', (data) ->
         res.send "```\n#{data.toString().trim()}\n```"
         console.log data.toString().trim()
      cmd.stderr.on 'data', (data) ->
         console.log data.toString().trim()
 robot.respond /ghe-suspend (.*)/i, (res) ->
      role = 'ghe-admin'
      unless robot.auth.hasRole(res.envelope.user, role)
        res.send "Access denied. You must have this role to use this command: #{role}"
        return
      {spawn} = require 'child_process'
      args = []
      args.push("ghe-suspend")
      for arg, index in res.match
         if index != 0
            args.push(arg.trim())
      #res.send "```\n#{args.toString()}\n```"
      cmd =  spawn './GHE-utilities.py' , args

      # Turn on stdout and send it to flowdock and mallot.log
      cmd.stdout.on 'data', (data) ->
         res.send "```\n#{data.toString().trim()}\n```"
         console.log data.toString().trim()
      cmd.stderr.on 'data', (data) ->
         console.log data.toString().trim()


 robot.respond /ghe-unsuspend (.*)/i, (res) ->
      role = 'ghe-admin'
      unless robot.auth.hasRole(res.envelope.user, role)
        res.send "Access denied. You must have this role to use this command: #{role}"
        return
      {spawn} = require 'child_process'
      args = []
      args.push("ghe-unsuspend")
      for arg, index in res.match
         if index != 0
            args.push(arg.trim())
      #res.send "```\n#{args.toString()}\n```"
      cmd =  spawn './GHE-utilities.py' , args


      # Turn on stdout and send it to flowdock and mallot.log
      cmd.stdout.on 'data', (data) ->
         res.send "```\n#{data.toString().trim()}\n```"
         console.log data.toString().trim()
      cmd.stderr.on 'data', (data) ->
         console.log data.toString().trim()
