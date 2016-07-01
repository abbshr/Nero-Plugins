resp = (req, res, next) ->
  {limit} = req.cfg
  req_size = req.headers['content-length']
  if req_size > limit
    res.end JSON.stringify msg: "request packet too large"
  else
    next()

class RequestBodySizeLimit    
  base: no
  pluginName: "request-body-size-limit"
  handle: (req, res, next) -> 
    {limit} = req.cfg
    return next() unless limit?
    return next() unless req.hasbody
    
    req_size = req.headers['content-length']
    if req_size?
      resp req, res, next
    else
      req.on 'end', ->
        req_size = req._readableState.length
        resp req, res, next

module.exports = -> new RequestBodySizeLimit()