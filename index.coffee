express = require 'express'
fs = require 'fs'
morgan = require 'morgan'
redis = require 'redis'

num_primes = 100000
port = process.argv[2] or 3000

app = express()
app.use morgan('combined')

client = redis.createClient()

client.on 'connect', ->
  console.log 'connected to redis'

  client.exists 'primes', (err, reply) =>
    if reply
      console.log 'primes list exists'
      primes_done()
    else
      console.log 'generating primes...'
      lua = fs.readFileSync(__dirname + '/lua/generate.lua').toString()
      client.eval lua, 1, 'primes', num_primes, (err, reply) =>
        if err?
          console.error err
          process.exit(1)
        console.log 'done generating primes'
        primes_done()

app.get '/primes', (req, res) ->
  limit = +req.query.limit
  limit = if limit? and limit > 0 and limit <= num_primes then limit else 500
  client.lrange 'primes', 0, limit - 1, (err, obj) ->
    if err?
      console.err err
      res.status 500
      res.end
    else
      res.send obj

app.get '/primes/:index', (req, res) ->
  index = +req.params.index
  if index? and index >= 0 and index < num_primes
    client.lindex 'primes', index, (err, obj) ->
      if err?
        console.err err
        res.status 500
        res.end()
      else
        res.send obj
  else
    res.status 404
    res.end()

primes_done = ->
  app.listen port
  console.log "listening on port #{port}"
