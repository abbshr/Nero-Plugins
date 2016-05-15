workerSyncor = require './worker-syncor'
syncor = require('./syncor')()

class ElasticQuota
  constructor: (@) ->
    # @cfgs = {}
    # 与Quota分配器建立长连接
    workerSyncor()
    
  pluginName: "elastic-quota"
  
  为保证Nero主进程的响应实时性, 这里仅保留quota判断和计数器累加
  handle: (req, res, next) ->
    {serviceName} = req
    {threshold, interval} = req.cfg[@pluginName]
    cfg = syncor.get serviceName 
    {count, quota} = cfg ?= syncor.set serviceName,
      count: 0
      quota: threshold * 1.2
    
    if quota > 0
      cfg.count++
      cfg.quota--
      next()
    else
      res.statusCode = 429
      res.end JSON.stringify msg: "max elastic quoto exceed"
    
    syncor.set "#{serviceName}~>threshold", threshold
    syncor.set "#{serviceName}~>interval", interval