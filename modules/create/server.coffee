# Dependencies
crypto	= require 'crypto'
joi		= require 'joi'
Encoder = require('qr').Encoder
encoder = new Encoder

# Variables
db = null

hash = ->

	currentDate = (new Date()).valueOf().toString()
	random = Math.random().toString()
	return crypto.createHash('sha1').update(currentDate + random).digest('hex')

qr = (code) ->

	file	= "#{ hash() }.png"
	path	= "./data/" + file

	encoder.encode code, path

	return file

get = (req, res) ->

	data = {
		qr: qr(req.query.code)
	}

	res.json data

module.exports = (app, _db) ->

	db = _db

	app.get '/api/m/create/get', get