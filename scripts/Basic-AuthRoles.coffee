# Description:
#   Auth allows you to assign roles to users which can be used by other scripts
#   to restrict access to Hubot commands
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_AUTH_ADMIN
#
# Commands:
#   `hubot <user> has <role> role` - Assigns a role to a user
#   `hubot <user> doesn't have <role> role` - Removes a role from a user
#   `hubot what role does <user> have` - Find out what roles are assigned to a specific user
#   `hubot who has admin role` - Find out who's an admin and can assign roles
#
# Notes:
#   * Call the method: robot.Auth.hasRole('<user>','<role>')
#   * returns bool true or false
#
#   * the 'admin' role can only be assigned through the environment variable
#   * roles are all transformed to lower case
#
# Author:
#   @admiralAwkbar

############################
# Start the script listner #
############################
module.exports = (robot) ->

  ###########################
  # Pull in the admin Users #
  ###########################
  admin = process.env.HUBOT_AUTH_ADMIN

  ####################
  # Create the array #
  ####################
  if admin?
    admins = admin.toLowerCase().split(',')
  else
    admins = []

  ############################
  # Set up the Class actions #
  ############################
  class Auth

    #######################
    # Validate admin user #
    #######################
    isAdmin: (user) ->
      user.id.toString() in admins

    ######################
    # Validate user role #
    ######################
    hasRole: (user, roles) ->
      userRoles = @userRoles(user)
      if userRoles?
        roles = [roles] if typeof roles is 'string'
        for role in roles
          return true if role in userRoles
      return false

    #######################
    # Get users with role #
    #######################
    usersWithRole: (role) ->
      users = []
      for own key, user of robot.brain.data.users
        if @hasRole(user, role)
          users.push(user.name)
      users

    ##################
    # Get user roles #
    ##################
    userRoles: (user) ->
      roles = []
      if user? and robot.auth.isAdmin user
        roles.push('admin')
      if user.roles?
        roles = roles.concat user.roles
      roles

  ################
  # Set the Auth #
  ################
  robot.auth = new Auth

  #######################
  # Assign role to user #
  #######################
  robot.respond /@?(.+) (has) (["'\w: -_]+) (role)/i, (msg) ->
    name    = msg.match[1].trim().toLowerCase()
    newRole = msg.match[3].trim().toLowerCase()

    unless name in ['', 'who', 'what', 'where', 'when', 'why']
      user = robot.brain.userForName(name)
      if !user?
        msg.reply "@#{name} does not exist"
        return

      user.roles = user.roles or [ ]

      ############################
      # Check if the role exists #
      ############################
      if newRole in user.roles
        msg.reply "@#{name} already has the '#{newRole}' role."
      else
        if newRole == 'admin'
          msg.reply "Sorry, the 'admin' role can only be defined in the HUBOT_AUTH_ADMIN env variable."
        else
          myRoles = msg.message.user.roles or [ ]
          if msg.message.user.name.toLowerCase() in admin.toLowerCase().split(',')
            user.roles.push(newRole)
            msg.reply "Ok, @#{name} has the '#{newRole}' role."

  #############################
  # Remove a user from a role #
  #############################
  robot.respond /@?(.+) (doesn't have|does not have) (["'\w: -_]+) (role)/i, (msg) ->
    name    = msg.match[1].trim().toLowerCase()
    newRole = msg.match[3].trim().toLowerCase()

    unless name in ['', 'who', 'what', 'where', 'when', 'why']
      user = robot.brain.userForName(name)
      if !user?
        msg.reply "@#{name} does not exist"
        return

      user.roles = user.roles or [ ]
      if newRole == 'admin'
        msg.reply "Sorry, the 'admin' role can only be removed from the HUBOT_AUTH_ADMIN env variable."
      else
        myRoles = msg.message.user.roles or [ ]
        if msg.message.user.name.toLowerCase() in admin.toLowerCase().split(',')
          user.roles = (role for role in user.roles when role isnt newRole)
          msg.reply "Ok, @#{name} doesn't have the '#{newRole}' role."

  #######################
  # Find roles per user #
  #######################
  robot.respond /(what role does|what roles does) @?(.+) (have)\?*$/i, (msg) ->
    name = msg.match[2].trim()

    user = robot.brain.userForName(name)
    if !user?
      msg.reply "@#{name} does not exist"
      return

    user.roles = user.roles or [ ]

    if name.toLowerCase() in admin.toLowerCase().split(',') then isAdmin = ' and is also an admin' else isAdmin = ''
    msg.reply "@#{name} has the following roles: " + user.roles + isAdmin + "."

  ########################
  # List all admin users #
  ########################
  robot.respond /who has admin role\?*$/i, (msg) ->
    msg.reply "The following people have the 'admin' role: @#{admins.join(', @')}"

###################
###################
## END OF SCRIPT ##
###################
###################
