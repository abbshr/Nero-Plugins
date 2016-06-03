config = require './config'

class Cors  
  
  base: no
  pluginName: "cors"

  handle: (req, res, next) ->
    {cfg} = req
    res.setHeader "Access-Control-Allow-Headers", cfg.allow_headers ? config.allow_headers
    res.setHeader "Access-Control-Allow-Origin", cfg.allow_origin ? config.allow_origin
    res.setHeader "Access-Control-Allow-Methods", cfg.allow_methods ? config.allow_methods
    next()

module.exports = -> new Cors()