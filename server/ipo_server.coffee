CLEARINGSHARES = 1000000
require.paths.unshift('.')
hexy = require("hexy")
net = require('net')
InputResponder = require('./input_responder.js').InputResponder
BidDatabase = require('./bid_database.js').BidDatabase
BidAnalyser = require('./bid_analyser.js').BidAnalyser

server = net.createServer (stream) ->
	stream.removeAllListeners 'error'
	stream.on 'error', (error) ->
		console.log("Node errror!", error)

	stream.setEncoding 'ascii'

	buffer = ""
	stream.on 'data', (data) ->
		buffer += data
		lineEnd = buffer.indexOf("\r\n")
		if lineEnd
      data = buffer.substring(0, lineEnd)
      retStr = responder.parseInput(data)
			stream.write(retStr, 'ascii')
			buffer = buffer.substring(data.length + 1, buffer.length)
		# console.log(hexy.hexy(data))
		# console.log(hexy.hexy(retStr))
		# console.log("Message "+data+" being returned "+retStr)

	stream.on 'end', () ->
		stream.end()

# Initialize our components
responder = new InputResponder()
database = new BidDatabase()
database.watchResponder(responder)
# database.reInitialize()
analyser = new BidAnalyser(CLEARINGSHARES, database, responder)

server.maxConnections = 10000
server.listen(8124)
