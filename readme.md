This is a node.js wrapper for gemini cryptocurrency exchange, based on git://github.com/gferrin/bitfinex.git [API]https://docs.gemini.com/

### Install

`npm install gemini-exchange-api`

### Example

```js
var Gemini = require('gemini');

var gemini = new Gemini(your_key, your_secret);

gemini.new_order("btcusd", 42, 802.7, "all", "buy", "limit", 
	function(err, res, order_id){
		console.log(order_id);
});
```

### Error

If your getting the error `[Error: Nonce is too small.]` then your most likely
running the same process twice using the same API keys.

## Functions

`orderbook(symbol, options, cb) `

`trades(symbol, cb)`	

`get_symbols(cb)`

##### AUTHENTICATED REQUESTS 

`new_deposit(currency, method, wallet_name, cb)`

`new_order(symbol, amount, price, exchange, side, type, cb)`

`cancel_order(order_id, cb)`

`cancel_all_orders(cb)`

`replace_order(order_id, symbol, amount, price, exchange, side, type, cb)`

`order_status(order_id, cb)`

`active_orders(cb)`

`past_trades(symbol, [options,] cb)`

`wallet_balances(cb)`





