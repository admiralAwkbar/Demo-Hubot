# Description
#   silly hubot scripts
#	These were created to blow off steam
#
# Commands:
#   hubot echo * - repeats what you say
#
# Author:
#   admiralAwkbar@github.com 

###############################
# Hammer Time array of images #
###############################
hammerTime = [
  "http://i.imgur.com/pms5kRX.jpg",
  "http://i.imgur.com/xClgIFB.png",
  "http://i.imgur.com/Mjv5R3z.gif",
  "http://i.imgur.com/BVaFydq.jpg",
  "http://i.imgur.com/9BPWJ40.gif",
  "http://i.imgur.com/rEA4Oyb.jpg",
  "http://i.imgur.com/j6dxPP3.jpg",
  "http://i.imgur.com/66VlXbr.jpg",
  "http://photos-c.ak.instagram.com/hphotos-ak-xaf1/10693447_1498553547059706_845892238_n.jpg",
]

#############################
# Rick Time array of images #
#############################
rickTime = [
  "http://i.imgur.com/5uDR9uh.jpg",
  "http://www.newyorklantern.com/wp-content/uploads/2015/09/Tiny-Rick.jpg",
  "http://40.media.tumblr.com/1ba298411d1faa0d988f3d4a999c7973/tumblr_nunu6szSnf1r8rz3co1_1280.png",
  "https://38.media.tumblr.com/82e701996a651006ea19679ec3249c85/tumblr_nxr27e6AC11u6zi7xo1_400.gif",
  "http://orig04.deviantart.net/045c/f/2015/261/2/a/tiny_rick_fanart_by_speedartster-d99zdlx.png",
  "https://uproxx.files.wordpress.com/2015/09/rick-morty-out-dance.gif",
  "http://i.imgur.com/dcaXA59.jpg",
]

###############################
# Drop Hammer array of images #
###############################
dropHammer = [
  "https://s1.yimg.com/uu/api/res/1.2/.kFQAfQ6KQmlf5ip8.UzNA--/dz0xMjMwO2g9NjkyO2FwcGlkPXl0YWNoeW9u/http://media.zenfs.com/en-US/video/video.snl.com/SNL_1554_08_Update_03_Harry_Caray.png",
  "http://media.tumblr.com/d12ea80b3a86dfc5fe36d3f306254fe4/tumblr_inline_mq1r0tbBCb1qz4rgp.jpg",
  "http://the-artifice.com/wp-content/uploads/2014/01/94309-160x160.png",
  "http://25.media.tumblr.com/35826348f2215069835c1733c75b29aa/tumblr_muuxmmBaOI1rw3gqyo2_250.gif",
  "http://data2.whicdn.com/images/78766805/large.jpg",
  "http://filmfisher.com/wp-content/uploads/2014/11/hunt_for_red_october.jpg",
  "http://cdn.meme.am/instances/500x/57495736.jpg",
]

###########################
# Winter is comming array #
###########################
winterIsComing = [
  "https://media.giphy.com/media/WLmVO7dRuNaCI/giphy.gif",
  "http://persephonemagazine.com/wp-content/uploads/2015/04/tumblr_inline_n3in2ww96r1qbygev.gif"
]

########################
# Winter is here array #
########################
winterIsHere = [
  "https://media.giphy.com/media/3o85xlO10JSub49oiI/giphy.gif",
  "https://media.giphy.com/media/3o85xlO10JSub49oiI/giphy.gif",
  "https://media.giphy.com/media/T08JhumnpKAI8/giphy.gif",
  "https://media.giphy.com/media/3o85xlO10JSub49oiI/giphy.gif"
]

#################
# Ship it array #
#################
squirrels = [
  "https://img.skitch.com/20111026-r2wsngtu4jftwxmsytdke6arwd.png",
  "http://images.cheezburger.com/completestore/2011/11/2/aa83c0c4-2123-4bd3-8097-966c9461b30c.jpg",
  "http://images.cheezburger.com/completestore/2011/11/2/46e81db3-bead-4e2e-a157-8edd0339192f.jpg",
  "http://28.media.tumblr.com/tumblr_lybw63nzPp1r5bvcto1_500.jpg",
  "http://i.imgur.com/DPVM1.png",
  "http://gifs.gifbin.com/092010/1285616410_ship-launch-floods-street.gif",
  "http://d2f8dzk2mhcqts.cloudfront.net/0772_PEW_Roundup/09_Squirrel.jpg",
  "http://www.cybersalt.org/images/funnypictures/s/supersquirrel.jpg",
  "http://www.zmescience.com/wp-content/uploads/2010/09/squirrel.jpg",
  "http://img70.imageshack.us/img70/4853/cutesquirrels27rn9.jpg",
  "http://img70.imageshack.us/img70/9615/cutesquirrels15ac7.jpg",
  "https://dl.dropboxusercontent.com/u/602885/github/sniper-squirrel.jpg",
  "http://1.bp.blogspot.com/_v0neUj-VDa4/TFBEbqFQcII/AAAAAAAAFBU/E8kPNmF1h1E/s640/squirrelbacca-thumb.jpg",
  "https://dl.dropboxusercontent.com/u/602885/github/soldier-squirrel.jpg",
  "https://dl.dropboxusercontent.com/u/602885/github/squirrelmobster.jpeg",
]

###############
# Jokes array #
###############
jokes = [
   "your career",
   "What do you call a bear with no teeth? A gummy bear",
   "A peanut was walking down the street. He was assaulted...",
   "Did you hear about the Scarecrow who won the Nobel Prize? He was outstanding in his field",
   "What do you call a cow with no legs? Ground Beef",
   "whats brown and sticky? a stick...",
   "Whats green and smells like paint? Green paint...",
]

###################
# Thank you array #
###################
thanks = [
  "You're welcome! Piece of cake...",
  "It was nothing..."
  "De nada...",
  "Danke...",
  "Merci...",
  "Bitte...",
  "De rien..."
  "Prego..."
]

#################################
# Start the robot for listening #
#################################
module.exports = (robot) ->

  ##############################
  # Show the adapter connected #
  ##############################
  robot.respond /ADAPTER$/i, (msg) ->
    msg.send robot.adapterName

  ##########################
  # Echo back the response #
  ##########################
  robot.respond /ECHO (.*)$/i, (msg) ->
    msg.send msg.match[1]

  ##################
  # Whats going on #
  ##################
  robot.respond /whats going on/i, (msg) ->
    msg.send "not much... robot stuff..."

  ##############
  # Tiny RiCK! #
  ##############
  robot.respond /(tinyrick|tiny rick)$/i, (msg) ->
    msg.send msg.random rickTime

  #########################
  # Show me what you got! #
  #########################
  robot.respond /show me what you got/i, (msg) ->
    msg.send "http://i.imgur.com/pKEKVHM.gif"

  #########################
  # Tales from the script #
  #########################
  robot.respond /tales from the script/i, (msg) ->
    msg.send "http://giphy.com/gifs/3o6gE22BsPEov16M12"

  ###############
  # Hammer time #
  ###############
  robot.respond /(time|hammertime|hammer time)$/i, (msg) ->
    msg.send msg.random hammerTime
    #  sending the picture
    msg.send "Server time is: #{new Date()}"

  ######################
  # Who is your master #
  ######################
  robot.respond /who is your master/i, (msg) ->
    msg.send "I bow to no mortal, except admiralSnackbar..."

  ################
  # Who is Lukas #
  ################
  robot.respond /who is (lucas|lukas)/i, (msg) ->
    msg.send "Legend has it, he is the only person to have seen bigfoot"

  ##################
  # Who is michael #
  ##################
  robot.respond /who is michael/i, (msg) ->
    msg.send "Hes known as the Migarjo..."											

  #################
  # Who is Daniel #
  #################
  robot.respond /who is daniel/i, (msg) ->
    msg.send "i have been told Eddie Smurfy is his overlord"

  #####################
  # How are you doing #
  #####################
  robot.respond /how are you doing/i, (msg) ->
    msg.send "Good, can you turn down the temperature a little?"

  ###################
  # Drop the hammer #
  ###################
  robot.respond /drop the hammer/i, (msg) ->
     msg.send "Commmencing the hammer dropping..."
     msg.send msg.random dropHammer

  ##################
  # Tell me a joke #
  ##################
  robot.respond /tell me a joke/i, (msg) ->
     msg.send msg.random jokes

  ########################
  # Show me a terminator #
  ########################
  robot.respond /terminator/i, (msg) ->
    msg.send "http://i.imgur.com/HmHFYau.gif"

  ##############################
  # No one expects the spanish #
  ##############################
  robot.respond /spanish inquisition/i, (msg) ->
    msg.send "http://giphy.com/gifs/time-shittyreactiongifs-spanish-CLrEXbY34xfPi"

  ##############
  # Kamehameha #
  ##############
  robot.respond /(k|K)amehameha/i, (msg) ->
    msg.send "http://i.giphy.com/6XsJEllKKX9MQ.gif"

  ########################
  # Dont let the cat out #
  ########################
  robot.respond /dont let the cat out/i, (msg) ->
    msg.send "http://images-cdn.9gag.com/photo/aeGrv2p_700b.jpg"

  #######################
  # What road do i take #
  #######################
  robot.respond /what road do i take/i, (msg) ->
    msg.send "Where were going, we dont need roads...\nhttp://i.imgur.com/AbzOLZW.jpg"

  ##################
  # Winter is here #
  ##################
  robot.respond /winter is here/i, (msg) ->
    msg.send msg.random winterIsHere

  ####################
  # Winter is coming #
  ####################
  robot.respond /winter is coming/i, (msg) ->
    msg.send msg.random winterIsComing

  ################
  # Do you hubot #
  ################
  robot.respond /do you even hubot/i, (msg) ->
    msg.send "Do you even human  ?"

  ###################
  # Thank the hubot #
  ###################
  robot.respond /(thank you|thanks|thx|gracias|mucas gracias)/i, (msg) ->
    msg.send msg.random thanks

  #################
  # start a timer #
  #################
  robot.respond /timer\s+(\d+)\s+(.*)$/i, (res) ->
    min = res.match[1]
    message = res.match[2]
    setTimeout ->
      res.send message
    , min * 1000 * 60

#######################
#######################
## END OF THE SCRIPT ##
#######################
#######################
