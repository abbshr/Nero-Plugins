class Throttle
  constructor: ->
    @window = {}
    @counter = {}
  
  pluginName: "strict-limit"
  
  detectHead: (window, ts, counter, i = 0) ->
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
  
  handle: (req, res, next) ->
    {threshold, interval} = req.cfg[@pluginName]
    {serviceName} = req

    window = @window[serviceName] ?= []
    counter = @counter[serviceName] ?= 0

    now = Date.now()
    head = @detectHead window, now
    
    @window[serviceName] = window[head..]
    @counter[serviceName] -= head
    
    if counter < threshold
      @window[serviceName].push now + interval
      @counter[serviceName]++
      # granted access
      next()
    else
      # deny
      res.statusCode = 429
      res.end JSON.stringify msg: "max quota exceed"

module.exports = -> new Throttle()
