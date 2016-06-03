class SizeLimit    
  base: no
  pluginName: "size-limit"
  handle: (req, res, next) ->
    {limit} = req.cfg
    
    content_length = req.headers['content-length']
    console.log req.headers, limit
    if content_length > limit
      res.end JSON.stringify msg: "request packet too large"
    else
      next()

module.exports = -> new SizeLimit()