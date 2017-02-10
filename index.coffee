coffee = require 'coffee-middleware'
engines = require 'consolidate'
express = require 'express'
fs = require 'fs'
morgan = require 'morgan'
path = require 'path'
redis = require 'redis'

num_primes = 100000
port = process.argv[2] or 3000

app = express()
app.use morgan 'combined'
app.engine 'haml', engines.haml
app.set 'view engine', 'haml'
app.use coffee src: path.join(__dirname, 'public'), compress: true, bare: true

client = redis.createClient process.env.REDIS_URL

client.on 'ready', ->
  console.log 'connected to redis'

client.on 'error', (err) ->
  console.error "Redis error: #{err}"

client.exists 'primes', (err, reply) ->
  if reply
    console.log 'primes list exists'
  else
    console.log 'generating primes...'
    fs.readFile __dirname + '/lua/generate.lua', 'utf8', (err, lua) ->
      client.eval lua, 1, 'primes', num_primes, (err, reply) ->
        if err?
          console.error err
          process.exit 1
        console.log 'done generating primes'

app.use express.static 'public'

app.use '/js', express.static 'bower_components'

app.get '/', (req, res) ->
  res.render 'index'

app.get '/primes', (req, res) ->
  limit = +req.query.limit
  limit = if limit? and limit > 0 and limit <= num_primes then limit else 500
  client.lrange 'primes', 0, limit - 1, (err, obj) ->
    if err?
      console.error err
      res.status 500
      res.end()
    else
      res.send obj

app.get '/primes/:index', (req, res) ->
  index = +req.params.index
  if index? and index >= 0 and index < num_primes
    client.lindex 'primes', index, (err, obj) ->
      if err?
        console.error err
        res.status 500
        res.end()
      else
        res.send obj
  else
    res.status 404
    res.end()

app.listen port
console.log "listening on port #{port}"
