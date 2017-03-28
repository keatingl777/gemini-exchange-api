# https://bitfinex.com/pages/api

process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"

request = require 'request'
crypto = require 'crypto'
qs = require 'querystring'

module.exports = class Bitfinex

	constructor: (key, secret, nonceGenerator) ->

		@url = "https://api.gemini.com"
		@version = 'v1'
		@key = key
		@secret = secret
		@nonce = new Date().getTime()
		@_nonce = if typeof nonceGenerator is "function" then nonceGenerator else () -> return ++@nonce

	make_request: (sub_path, params, cb) ->

		if !@key or !@secret
			return cb(new Error("missing api key or secret"))

		path = '/' + @version + '/' + sub_path
		url = @url + path
		nonce = JSON.stringify(@_nonce())

		payload = 
			request: path
			nonce: nonce

		for key, value of params
			payload[key] = value

		payload = new Buffer(JSON.stringify(payload)).toString('base64')
		signature = crypto.createHmac("sha384", @secret).update(payload).digest('hex')

		headers = 
			'X-BFX-APIKEY': @key
			'X-BFX-PAYLOAD': payload
			'X-BFX-SIGNATURE': signature

		request { url: url, method: "POST", headers: headers, timeout: 15000 }, (err,response,body)->
			
			if err || (response.statusCode != 200 && response.statusCode != 400)
				return cb new Error(err ? response.statusCode)
				
			try
				result = JSON.parse(body)
			catch error
				return cb(null, { messsage : body.toString() } )
			
			if result.message?
				return cb new Error(result.message)

			cb null, result
	
	make_public_request: (path, cb) ->

		url = @url + '/v1/' + path  

		request { url: url, method: "GET", timeout: 15000}, (err,response,body)->
			
			if err || (response.statusCode != 200 && response.statusCode != 400)
				return cb new Error(err ? response.statusCode)
			
			try
				result = JSON.parse(body)
			catch error
				return cb(null, { messsage : body.toString() } )

			if result.message?
				return cb new Error(result.message)
			
			cb null, result
	
	#####################################
	########## PUBLIC REQUESTS ##########
	#####################################                            

	orderbook: (symbol, options, cb) ->

		index = 0
		uri = 'book/' + symbol 

		if typeof options is 'function'
			cb = options
		else 
			try 
				for option, value of options
					if index++ > 0
						query_string += '&' + option + '=' + value
					else
						query_string = '/?' + option + '=' + value

				if index > 0 
					uri += query_string
			catch err
				return cb(err)

		@make_public_request(uri, cb)
	
	trades: (symbol, cb) ->

		@make_public_request('trades/' + symbol, cb)

	get_symbols: (cb) ->

		@make_public_request('symbols', cb)

	symbols_details: (cb) ->

		@make_public_request('symbols_details', cb)

	# #####################################
	# ###### AUTHENTICATED REQUESTS #######
	# #####################################   

	new_order: (symbol, amount, price, exchange, side, type, cb) ->

		params = 
			symbol: symbol
			amount: amount
			price: price
			exchange: exchange
			side: side
			type: type

		@make_request('order/new', params, cb)  

	cancel_order: (order_id, cb) ->

		params = 
			order_id: parseInt(order_id)

		@make_request('order/cancel', params, cb)

	cancel_all_orders: (cb) ->

		@make_request('order/cancel/all', {}, cb)

	order_status: (order_id, cb) ->

		params = 
			order_id: order_id

		@make_request('order/status', params, cb)  

	active_orders: (cb) ->

		@make_request('orders', {}, cb) 

	account_infos: (cb) ->

		@make_request('account_infos', {}, cb)

	###
		POST /v1/withdraw

		Parameters:
		'withdraw_type' :string (can be "bitcoin", "litecoin" or "darkcoin" or "mastercoin")
		'walletselected' :string (the origin of the wallet to withdraw from, can be "trading", "exchange", or "deposit")
		'amount' :decimal (amount to withdraw)
		'address' :address (destination address for withdrawal)
	###
	withdraw: (withdraw_type, walletselected, amount, address, cb) ->

		params = 
			withdraw_type: withdraw_type
			walletselected: walletselected
			amount: amount
			address: address

		@make_request('withdraw', params, cb)

	###
		POST /v1/transfer

		Parameters:
		‘amount’: decimal (amount to transfer)
		‘currency’: string, currency of funds to transfer
		‘walletfrom’: string. Wallet to transfer from
		‘walletto’: string. Wallet to transfer to 
	###
	transfer: (amount, currency, walletfrom, walletto, cb) ->

		params = 
			amount: amount
			currency: currency
			walletfrom: walletfrom
			walletto: walletto

		@make_request('transfer', params, cb)


