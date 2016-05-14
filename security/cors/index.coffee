config = require './config'

class Cors  

  pluginName: "cors"

  handle: (req, res, next) ->
    cfg = req.cfg[@pluginName]
    res.set
      "Access-Control-Allow-Headers": cfg.allow_headers ? config.allow_headers
      "Access-Control-Allow-Origin": cfg.allow_origin ? config.allow_origin
      "Access-Control-Allow-Methods": cfg.allow_methods ? config.allow_methods
    next()

module.exports = -> new Cors()