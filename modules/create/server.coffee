# Dependencies
crypto	= require 'crypto'
Encoder = require('qr').Encoder
encoder = new Encoder

# Variables
db = null

hash = ->

	currentDate = (new Date()).valueOf().toString()
	random = Math.random().toString()
	return crypto.createHash('sha1').update(currentDate + random).digest('hex')

qr = (req, res) ->

	encoder.encode 'test', "./data/#{ hash() }.png"

module.exports = (app, _db) ->

	db = _db

	app.all '/api/m/create/qr/:code', qr