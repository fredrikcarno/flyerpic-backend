# Dependencies
async		= require 'async'
validator	= require 'validator'
crypto		= require 'crypto'

# Kanban modules
log			= require './../../node/log'
middleware	= require './../../node/middleware'

# Variables
db = null

setAvatar = (user, url, callback) ->

	if not validator.isInt(user)

		callback 'Wrong type for parameter user'
		return false

	if not validator.isURL(url)

		callback 'Avatar needs to be URL'
		return false

	db.source.query "UPDATE lychee_users SET avatar = ? WHERE id = ?", [url, user], callback
	return true

setPassword = (user, password, callback) ->

	if not validator.isInt(user)

		callback 'Wrong type for parameter user'
		return false

	if not password? or password is ''

		callback 'Wrong type for parameter password'
		return false

	password = crypto.createHash('md5').update(password).digest('hex')

	db.source.query "UPDATE lychee_users SET password = ? WHERE id = ?", [password, user], callback
	return true

setBackground = (user, url, callback) ->

	if not validator.isInt(user)

		callback 'Wrong type for parameter user'
		return false

	if not validator.isURL(url)

		callback 'Avatar needs to be URL'
		return false

	db.source.query "UPDATE lychee_users SET background = ? WHERE id = ?", [url, user], callback
	return true

setMail = (user, mail, callback) ->

	if not validator.isInt(user)

		callback 'Wrong type for parameter user'
		return false

	if not validator.isEmail(mail)

		callback 'Wrong type for parameter mail'
		return false

	db.source.query "UPDATE lychee_users SET primarymail = ? WHERE id = ?", [mail, user], callback
	return true

setPricePerAlbum = (user, amount, callback) ->

	if not validator.isInt(user)

		callback 'Wrong type for parameter user'
		return false

	if	not amount? or
		amount.length < 1

			callback 'Wrong type for parameter amount'
			return false

	if amount.indexOf(',') isnt -1

		# Replace comma with dot
		amount = amount.replace ',', '.'

	# Validate amount
	reg = /^[0-9]{1,}[\.,]{1}[0-9]{2}$/
	if not reg.test amount

		callback 'Wrong type for parameter amount. Pattern does not match.'
		return false

	db.source.query "UPDATE lychee_users SET priceperalbum = ? WHERE id = ?", [amount, user], callback
	return true

setPricePerPhoto = (user, amount, callback) ->

	if not validator.isInt(user)

		callback 'Wrong type for parameter user'
		return false

	if	not amount? or
		amount.length < 1

			callback 'Wrong type for parameter amount'
			return false

	if amount.indexOf(',') isnt -1

		# Replace comma with dot
		amount = amount.replace ',', '.'

	# Validate amount
	reg = /^[0-9]{1,}[\.,]{1}[0-9]{2}$/
	if not reg.test amount

		callback 'Wrong type for parameter amount. Pattern does not match.'
		return false

	db.source.query "UPDATE lychee_users SET priceperphoto = ? WHERE id = ?", [amount, user], callback
	return true

module.exports = (app, _db) ->

	db = _db

	app.get '/api/m/settings/avatar', middleware.auth, (req, res) ->

		setAvatar req.session.user, req.query.url, (err) ->

			if err?
				log.error 'settings', 'Could not save avatar', err
				res.json { error: 'Could not save avatar', details: err }
				return false
			else
				res.json true
				return true

	app.get '/api/m/settings/password', middleware.auth, (req, res) ->

		setPassword req.session.user, req.query.password, (err) ->

			if err?
				log.error 'settings', 'Could not save password', err
				res.json { error: 'Could not save password', details: err }
				return false
			else
				res.json true
				return true

	app.get '/api/m/settings/background', middleware.auth, (req, res) ->

		setBackground req.session.user, req.query.url, (err) ->

			if err?
				log.error 'settings', 'Could not save background', err
				res.json { error: 'Could not save background', details: err }
				return false
			else
				res.json true
				return true

	app.get '/api/m/settings/mail', middleware.auth, (req, res) ->

		setMail req.session.user, req.query.mail, (err) ->

			if err?
				log.error 'settings', 'Could not save PyaPal mail', err
				res.json { error: 'Could not save PyaPal mail', details: err }
				return false
			else
				res.json true
				return true

	app.get '/api/m/settings/priceperalbum', middleware.auth, (req, res) ->

		setPricePerAlbum req.session.user, req.query.amount, (err) ->

			if err?
				log.error 'settings', 'Could not save price per session', err
				res.json { error: 'Could not save price per session', details: err }
				return false
			else
				res.json true
				return true

	app.get '/api/m/settings/priceperphoto', middleware.auth, (req, res) ->

		setPricePerPhoto req.session.user, req.query.amount, (err) ->

			if err?
				log.error 'settings', 'Could not save price per photo', err
				res.json { error: 'Could not save price per photo', details: err }
				return false
			else
				res.json true
				return true