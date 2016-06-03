class ResponseHeadTransform
  base: no
  pluginName: 'response-head-transform'
  handle: (req, res, next) ->
    {cfg} = req
    
    res.setHeader k, v for k, v of cfg
    console.error cfg
    next()
    
module.exports = -> new ResponseHeadTransform()