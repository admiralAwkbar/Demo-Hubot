# Description
#   silly hubot scripts
#	These were created to blow off steam
#
# Commands:
#   hubot echo * - repeats what you say
#
# Author:
#   admiralAwkbar@github.com 


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

rickTime = [
  "http://i.imgur.com/5uDR9uh.jpg",
  "http://www.newyorklantern.com/wp-content/uploads/2015/09/Tiny-Rick.jpg",
  "http://40.media.tumblr.com/1ba298411d1faa0d988f3d4a999c7973/tumblr_nunu6szSnf1r8rz3co1_1280.png",
  "https://38.media.tumblr.com/82e701996a651006ea19679ec3249c85/tumblr_nxr27e6AC11u6zi7xo1_400.gif",
  "http://orig04.deviantart.net/045c/f/2015/261/2/a/tiny_rick_fanart_by_speedartster-d99zdlx.png",
  "https://uproxx.files.wordpress.com/2015/09/rick-morty-out-dance.gif",
  "http://i.imgur.com/dcaXA59.jpg",
]

dropHammer = [
  "https://s1.yimg.com/uu/api/res/1.2/.kFQAfQ6KQmlf5ip8.UzNA--/dz0xMjMwO2g9NjkyO2FwcGlkPXl0YWNoeW9u/http://media.zenfs.com/en-US/video/video.snl.com/SNL_1554_08_Update_03_Harry_Caray.png",
  "http://media.tumblr.com/d12ea80b3a86dfc5fe36d3f306254fe4/tumblr_inline_mq1r0tbBCb1qz4rgp.jpg",
  "http://the-artifice.com/wp-content/uploads/2014/01/94309-160x160.png",
  "http://25.media.tumblr.com/35826348f2215069835c1733c75b29aa/tumblr_muuxmmBaOI1rw3gqyo2_250.gif",
  "http://data2.whicdn.com/images/78766805/large.jpg",
  "http://filmfisher.com/wp-content/uploads/2014/11/hunt_for_red_october.jpg",
  "http://cdn.meme.am/instances/500x/57495736.jpg",
]

jokes = [
   "your career",
   "What do you call a bear with no teeth? A gummy bear",
   "A peanut was walking down the street. He was assaulted...",
   "Did you hear about the Scarecrow who won the Nobel Prize? He was outstanding in his field",
   "What do you call a cow with no legs? Ground Beef",
   "whats brown and sticky? a stick...",
   "Whats green and smells like paint? Green paint...",
]
winterIsComing = [
  "https://media.giphy.com/media/WLmVO7dRuNaCI/giphy.gif",
  "http://persephonemagazine.com/wp-content/uploads/2015/04/tumblr_inline_n3in2ww96r1qbygev.gif"
]
winterIsHere = [
  "https://media.giphy.com/media/3o85xlO10JSub49oiI/giphy.gif",
  "https://media.giphy.com/media/3o85xlO10JSub49oiI/giphy.gif",
  "https://media.giphy.com/media/T08JhumnpKAI8/giphy.gif",
  "https://media.giphy.com/media/3o85xlO10JSub49oiI/giphy.gif"
]
module.exports = (robot) ->

  robot.respond /ADAPTER$/i, (msg) ->
    msg.send robot.adapterName
  
  robot.respond /PING$/i, (msg) ->
    msg.send "PONG"

  robot.respond /ECHO (.*)$/i, (msg) ->
    msg.send msg.match[1]
    
  robot.respond /whats going on/i, (msg) ->
    msg.send "not much... robot stuff..."
  
  robot.respond /tinyrick$/i, (msg) ->
    msg.send msg.random rickTime
    
  robot.respond /show me what you got/i, (msg) ->
    msg.send "http://i.imgur.com/pKEKVHM.gif"
    
  robot.respond /tales from the script/i, (msg) ->
    msg.send "http://giphy.com/gifs/3o6gE22BsPEov16M12"
  
  robot.respond /time$/i, (msg) ->
    msg.send msg.random hammerTime
    #  sending the picture
    msg.send "Server time is: #{new Date()}"

  robot.respond /who is your master/i, (msg) ->
    msg.send "I bow to no mortal, except Lukas..."
    
  robot.respond /who is lucas/i, (msg) ->
    msg.send "Legend has it, he is the only person to have seen bigfoot"
											
  robot.respond /who is michael/i, (msg) ->
    msg.send "Hes known as the Migarjo..."											
											
  robot.respond /who is daniel/i, (msg) ->
    msg.send "i have been told Eddie Smurfy is his overlord"
    
  robot.respond /how are you doing/i, (msg) ->
    msg.send "Good, can you turn down the temperature a little?"
  
  robot.respond /drop the hammer/i, (msg) ->
     msg.send "Commmencing the hammer dropping..."
     msg.send msg.random dropHammer
    
  robot.respond /tell me a joke/i, (msg) ->
     msg.send msg.random jokes
  
  robot.respond /terminator/i, (msg) ->
    msg.send "http://i.imgur.com/HmHFYau.gif"
    
  robot.respond /spanish inquisition/i, (msg) ->
    msg.send "http://giphy.com/gifs/time-shittyreactiongifs-spanish-CLrEXbY34xfPi"
	
  robot.respond /(k|K)amehameha/i, (msg) ->
    msg.send "http://i.giphy.com/6XsJEllKKX9MQ.gif"
    
  robot.respond /dont let the cat out/i, (msg) ->
    msg.send "http://images-cdn.9gag.com/photo/aeGrv2p_700b.jpg"
     
  robot.respond /what road do i take/i, (msg) ->
    msg.send "Where were going, we dont need roads...\nhttp://i.imgur.com/AbzOLZW.jpg"
				
  robot.respond /winter is here/i, (msg) ->
    msg.send msg.random winterIsHere

  robot.respond /winter is coming/i, (msg) ->
    msg.send msg.random winterIsComing
    
  robot.respond /do you even hubot/i, (msg) ->
    msg.send "Do you even human  ?"

  robot.respond /(thank you|thanks|thx|gracias|mucas gracias)/i, (msg) ->
    msg.send "You're welcome! Piece of cake."

  robot.respond /(gracias|mucas gracias)/i, (msg) ->
    msg.send "De nada."

  robot.respond /timer\s+(\d+)\s+(.*)$/i, (res) ->
    min = res.match[1]
    message = res.match[2]
    setTimeout ->
      res.send message
    , min * 1000 * 60
