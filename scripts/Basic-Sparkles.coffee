# Description:
#   sparkle your brains out
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot sparkle <username> - award sparkles to <username>
#   hubot desparkle <username> - take away sparkles from <username>
#   hubot how many sparkles does <username> have? - list how many sparkles <username> has
#   hubot take all sparkles from <username> - removes all sparkles from <username>
#
# Author:
#   admiralAwkbar
#

########################
# Set up them sparkles #
########################
sparkles = {}

#######################
# Award them sparkles #
#######################
award_sparkles = (msg, userName, pts) ->
  sparkles[userName] ?= 0
  sparkles[userName] += parseInt(pts)
  msg.send "Awww yiss, @#{userName} now has #{sparkles[userName]} :sparkles::sparkle::sparkles: points!"

########################
# Remove them sparkles #
########################
remove_sparkles = (msg, userName, pts) ->
  sparkles[userName] ?= 0
  sparkles[userName] += parseInt(pts)
  msg.send "Awww nooooo, @#{userName} must be punished... now has #{sparkles[userName]} :sparkles::sparkle::sparkles: points..."

#######################
# Save those sparkles #
#######################
save = (robot) ->
  robot.brain.data.sparkles = sparkles

#############################
# Start the robot listening #
#############################
module.exports = (robot) ->
  robot.brain.on 'loaded', ->
    sparkles = robot.brain.data.sparkles or {}

    #############################
    #############################
    ## Give sparkles to a user ##
    #############################
    #############################
    robot.respond /sparkle (.*?)\s?$/i, (msg) ->
      pts = 1
      userName = msg.match[1].replace /^\s+|\s+$/g, ""
      userName = userName.replace /^\@/g, ""
      # add 1 point to userName
      award_sparkles(msg, userName, pts)
      save(robot)

    ################################
    ################################
    ## Remove sparkle from a user ##
    ################################
    ################################
    robot.respond /desparkle (.*?)\s?$/i, (msg) ->
      # remove 1 point from userName
      pts = -1
      userName = msg.match[1].replace /^\s+|\s+$/g, ""
      userName = userName.replace /^\@/g, ""
      remove_sparkles(msg, userName, pts)
      ###########
      # Save it #
      ###########
      save(robot)

    ######################################
    ######################################
    ## Take all the sparkle from a user ##
    ######################################
    ######################################
    robot.respond /take all sparkles from (.*?)\s?$/i, (msg) ->
      userName = msg.match[1].replace /^\s+|\s+$/g, ""
      userName = userName.replace /^\@/g, ""
      role = 'sparkle'
      unless robot.auth.hasRole(msg.envelope.user, role)
        msg.send "Access denied. You must have this role to use this command: #{role}"
        return
      sparkles[userName] = 0
      ################################
      # Send the message to the user #
      ################################
      msg.send "DAAAAANG! @#{userName} has been set back to 0 :sparkles::sparkle::sparkles: points... You think darkness is your ally. But you merely adopted the dark; I was born in it,moulded by it. I didn't see the light until I was already a man, by then it was nothing to me but BLINDING!"
      ###########
      # Save it #
      ###########
      save(robot)

    ###############################
    ###############################
    ## Get sparkle count of user ##
    ###############################
    ###############################
    robot.respond /how many sparkles does (.*?) have\??/i, (msg) ->
      userName = msg.match[1].replace /^\s+|\s+$/g, ""
      userName = userName.replace /^\@/g, ""
      sparkles[userName] ?= 0
      ################################
      # Send the message to the user #
      ################################
      msg.send "@#{userName} has #{sparkles[userName]} :sparkles::sparkle::sparkles: points!"

#######################
#######################
## END OF THE SCRIPT ##
#######################
#######################
