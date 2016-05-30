Redis = require 'ioredis'
{port, addr} = require './config'

detectHead = (window, ts, counter, i = 0) ->
  if window.length > 1
    mid = parseInt window.length / 2
    if ts > window[mid]
      detectHead window[mid + 1..], ts, counter, i + mid + 1
    else
      detectHead window[...mid], ts, counter, i
  else if window[0]? and ts > window[0]
    i + 1
  else
    i

class Throttle
  constructor: ->
    @redis = new Redis port, addr

  pluginName: "strict-limit"
  
  handle: (req, res, next) ->
    {threshold, interval} = req.cfg
    {serviceName} = req
    
    @redis.lrange "strict-limit::#{serviceName}", 0, -1, (err, window = []) =>
      now = Date.now()
      head = detectHead window, now
      
      @redis.ltrim "strict-limit::#{serviceName}", head, -1
      counter = window.length - head
      
      if counter < threshold
        @redis.rpush "strict-limit::#{serviceName}", now + interval
        # granted access
        next()
      else
        # deny
        res.statusCode = 429
        res.end JSON.stringify msg: "max quota exceed"

module.exports = -> new Throttle()
