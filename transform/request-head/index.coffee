class RequestHeadTransform
  base: no
  pluginName: 'request-head-transform'
  handle: (req, res, next) ->
    {cfg} = req
    
    Object.assign req.headers, cfg
    console.error req.headers, cfg
    next()
    
module.exports = -> new RequestHeadTransform()