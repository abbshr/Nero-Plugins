class IPRestrict    
  base: no
  pluginName: 'ip-restriction'
  
  handle: (req, res, next) ->
    {blacklist} = req.cfg
    
    ip = req.socket.remoteAddress
    if ip in blacklist
      res.end JSON.stringify msg: "your ip address is not allowed to access the resource"
    else
     next()

module.exports = -> new IPRestrict()