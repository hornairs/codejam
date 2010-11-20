EventEmitter = require('events').EventEmitter
class InputResponder extends EventEmitter
	MINBIDVALUE: 0
	MAXBIDVALUE: 100
	MAXBIDATONCE: 10000
	TOTALSHARES: 1000

	ACCEPTSTRING: "A\r\n"
	ERRORSTRING: "E\r\n"
	BIDCLOSEDSTRING: "C\r\n"

	# Start up accepting bids.
	acceptingBids: true
	parseInput: (inputString) ->

		# return error: not acepting bids anymore
		return @BIDCLOSEDSTRING unless @acceptingBids

		lastchar1 = inputString.charAt(inputString.length-2)
		lastchar2 = inputString.charAt(inputString.length-1)

		if !lastchar1? || !lastchar2? || (lastchar1 != "\r" ) || (lastchar2 != "\n" )
			return @ERRORSTRING
		# Trim input string to get rid of any shenanigans
		inputString = inputString.replace(/[\s]*$/, "").replace(/^[\s]*/, "")
		stringSplit = inputString.split("|")

		# Ensure string was split and stuff
		unless stringSplit[0]? && typeof stringSplit[0] == "string"
			return @ERRORSTRING

		switch stringSplit[0].toUpperCase()
			when "B" then	return this.parseSubmission(stringSplit, inputString)
			when "C" then return this.parseClose(stringSplit, inputString)
			when "S" then	return this.parseSummary(stringSplit, inputString)
			when "R" then return this.parseReset(stringSplit, inputString)
			else return @ERRORSTRING

	parseSubmission: (split, full) ->
		shares = parseFloat(split[1])
		if shares > @MAXBIDATONCE
			return @ERRORSTRING

		price = parseFloat(split[2])
		if (price < @MINBIDVALUE) || (price > @MAXBIDVALUE)
			return @ERRORSTRING

		this.emit("bid", shares, price, split[3])
		return @ACCEPTSTRING

	parseClose: (split, full) ->
		if full != "C|TERMINATE"
			#return input error
			return @ERRORSTRING
		else
			#terminate bid submission
			@acceptingBids = false
			this.emit("close")
			return @ACCEPTSTRING
			#send returnString

	parseSummary: (split, full) ->
		if full != "S|SUMMARY"
			#malformed request
			return @ERRORSTRING
		else
			#print to stdout or something
			this.emit("summaryRequest")
			return @ACCEPTSTRING

	parseReset: (split, full) ->
		if full != "R"
			return @ERRORSTRING
		else
			this.emit("resetDatabase")
			return @ACCEPTSTRING

exports.InputResponder = InputResponder
