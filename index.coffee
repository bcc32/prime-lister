express = require 'express'
morgan = require 'morgan'
redis = require 'redis'

client = redis.createClient()

client.on 'connect', () =>
  console.log 'connected to redis'

app = express()
app.use morgan('combined')

app.get '/primes', (req, res) =>
  limit = req.query.limit
  limit = if limit? and limit > 0 and limit < 100000 then limit else 500
  client.lrange 'primes', 0, limit - 1, (err, obj) =>
    if err?
      console.err err
      res.status 500
      res.end
    else
      res.send obj

app.get '/primes/:index', (req, res) =>
  index = +req.params.index
  if index? and index >= 0 and index < 100000
    client.lindex 'primes', index, (err, obj) =>
      if err?
        console.err err
        res.status 500
        res.end()
      else
        res.send obj
  else
    res.status 404
    res.end()

port = process.argv[2] or 3000
app.listen port
console.log "listening on port #{port}"
