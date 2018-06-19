fs = require 'fs'

class Paginator
  constructor: () ->
    @content= ""
    @chunksToBeSent = []
    @maxBuff= 8096
    @delim = /\r\n|\r|\n/
		
  readFile : (fileName) ->
    fs.readFileSync fileName , "utf-8"

  getBlockChunks : ( str, arr ) ->
    totalNumber=str.length
    numberOfCharChunks= parseInt(totalNumber/@maxBuff)
    crumbs = totalNumber % @maxBuff
    buff=""
    for i in [0 ... numberOfCharChunks]
      buff= str.substr(i*@maxBuff, @maxBuff)
      arr.push buff.trim()
    if crumbs>0
      arr.push str.substr(numberOfCharChunks*@maxBuff, crumbs).trim()
			
  getDelimitedChunks  : () ->
    str= @content
    buffWithLines= str.split(@delim)
    thisChunk=''
    buff = str
    for i in [0 ... buffWithLines.length]
      if buffWithLines[i].length  >= @maxBuff
        if(thisChunk.trim() !="")
          @chunksToBeSent.push thisChunk.trim()
        buff= buff.substr(thisChunk.length)
        @getBlockChunks(buffWithLines[i].trim(), @chunksToBeSent)
        buff= buff.substr(buffWithLines[i].length)
        thisChunk= ""
      else if thisChunk.length+buffWithLines[i].length >= @maxBuff
        @chunksToBeSent.push thisChunk.trim()
        buff= buff.substr(thisChunk.length)
        thisChunk= buffWithLines[i].trim()+"\r\n"
      else # keep accumulating
        thisChunk+= buffWithLines[i].trim()+"\r\n"
    if thisChunk.length>0
      @chunksToBeSent.push thisChunk.trim()
    return @chunksToBeSent
  
  setContent: (content) ->
    @content=content
module.exports = Paginator
