client = require('./redis-store')

class Graph

  ###################
  # Class functions #
  ###################

  ###############
  # Constructor #
  ###############
  constructor: (graphKey, redisKey) ->
    @graphKey = graphKey
    @redisKey = redisKey
    @url = ""

    console.log("inside constructor. graphKey is #{@graphKey} redisKey is #{@redisKey}")
  
  getUrl: ->
    console.log("inside getUrl")
    @.updateUrl()
    return @url

  setUrl: (url) ->
    console.log("inside getUrl. setting url to #{url}")
    @url = url

  updateUrl: ->
    client().hget(@graphKey, @redisKey, (err, resp) ->
      console.log("Inside updateUrl, resp is: #{resp}")
      return @.setUrl(resp)
    )

module.exports = Graph

