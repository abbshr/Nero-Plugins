class SizeLimit    
  base: no
  pluginName: "size-limit"
  handle: (req, res, next) ->
    {limit} = req.cfg
    
    return next() unless limit?
    req_size = req.headers['content-length']

    if req_size > limit
      res.end JSON.stringify msg: "request packet too large"
    else
      next()

module.exports = -> new SizeLimit()