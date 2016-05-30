Redis = require 'ioredis'
{createHash, createHmac} = require 'crypto'
{redis: {port, addr}} = require './config'

class HmacSig
  constructor: (@) ->
    @red = new Redis port, addr
    
  handle: (req, res, next) ->
    cfg = req.cfg[@pluginName]
    {url, method, headers: {nonce, timestamp, signature}} = req
    switch 
      when not nonce?
        return res.end 
          JSON.stringify msg: "Signature verification failed: need nonce"
      else not timestamp?
        return res.end 
          JSON.stringify msg: "Signature verification failed: need timestamp"
      when not signature?
        return res.end 
          JSON.stringify msg: "Signature verification failed: need signature"
    
    hash = createHash('md5').update(timestamp).digest 'hex'
    unless nonce is hash
      return res.end
        JSON.stringify msg: "Signature verification failed: invaild nonce"
    
    now = Date.now()
    if Math.abs(now - timestamp) > cfg.duration
      return res.end
        JSON.stringify msg: "Signature verification failed: invaild timestamp"
    
    @red.get nonce, (err, exist) =>
      if exist?
        return res.end
          JSON.stringify msg: "Signature verification failed: key exist"

      plaintext = encodeURIComponent [method, url, nonce, timestamp, body].join '&'
      sign = createHmac('sha1', cfg.secret).update(plaintext).digest 'base64'
      unless sign is signature
        return res.end
          JSON.stringify msg: "Signature verification failed: can not verify the signature"
      
      @red.set nonce, 1, "EX", 6 * 60 + 1, "NX"
      next()
    
  pluginName: "hmac-signature"
  base: no
  
module.exports = -> new HmacSig()