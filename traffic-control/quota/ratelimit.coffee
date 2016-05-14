class RateLimit
  constructor: (@) ->
    @buckets = {}
  
  pluginName: "rate-limit"
  
  handle: (req, res, next) ->
    now = Date.now()
    {capacity, interval} = req.cfg[@pluginName]
    {serviceName} = req
    bucket = @buckets[serviceName] ?=
      lst_ts: now
      remain: 0
      rate: capacity / interval
    
    {remain, lst_ts, rate} = bucket
    duration = now - lst_ts
    remain = Math.max 0, remain - rate * duration

    if remain < capacity
      bucket.remain = remain + 1
      bucket.lst_ts = now
      # granted access
      next()
    else
      res.statusCode = 429
      res.end JSON.stringify msg: "max request rate exceed"
    
module.exports = -> new RateLimit()