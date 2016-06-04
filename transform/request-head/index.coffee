class RequestHeadTransform
  base: no
  pluginName: 'request-head-transform'
  handle: (req, res, next) ->
    {cfg} = req
    req.specHeader = cfg
    next()
    
module.exports = -> new RequestHeadTransform()