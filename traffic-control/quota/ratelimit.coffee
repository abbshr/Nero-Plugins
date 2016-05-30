Redis = require 'ioredis'
{port, addr} = require './config'

class RateLimit
  constructor: ->
    @redis = new Redis port, addr
  
  pluginName: "rate-limit"
  
  handle: (req, res, next) ->
    now = Date.now()
    {capacity, interval} = req.cfg
    {serviceName} = req
    @redis.hmget "rate-limit::#{serviceName}", "lst_ts", "remain", (err, [lst_ts = now, remain = 0]) =>
      rate = capacity / interval
      
      duration = now - lst_ts
      remain = Math.max 0, +remain - rate * duration
      if remain < capacity
        @redis.hmset "rate-limit::#{serviceName}", "lst_ts", now, "remain", remain + 1
        # granted access
        next()
      else
        res.statusCode = 429
        res.end JSON.stringify msg: "max request rate exceed"
    
module.exports = -> new RateLimit()