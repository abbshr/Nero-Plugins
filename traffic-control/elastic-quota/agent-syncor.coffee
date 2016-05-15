path = require 'path'
syncor = require('./syncor') server: yes
async = require 'async'

module.exports = ->
  # 每次sync复杂度O(n)
  # 并发异步任务中存在回调为O(n^2)的代码, 考虑优化

  syncor.on 'dump', (meta, dump, es) ->
    syncor.slaves.add meta
    if entire = syncor.get ''
      for api, {count, threshold, interval} of dump
        entire[api] ?= {}
        entire[api].count = count
        entire[api].threshold = threshold
        entire[api].interval = interval
    else
      syncor.set "", dump

    currentTime = Date.now()
    apisNeedUpdate = {}
    for api, data of syncor.get ""
      {threshold, count} = data
      # 只有配置数据找到时才更新
      if threshold?
        if count >= threshold
          # 根据计数器数值更新quota
          apisNeedUpdate[api] = data.quota = parseInt((threshold * 1.2 - count) / syncor.slaves.size)

    for api, data of syncor.get ""
      # {count, config: { interval, limits }} = data
      data.count ?= 0
      data.fstAccessTime ?= currentTime
      {count, interval, fstAccessTime} = data
      # 检查计数器重置周期
      if currentTime - fstAccessTime > interval
        data.count = 0
        data.fstAccessTime = currentTime
        # 重置周期触发对应api的quota更新
        # syncor.set "#{api}~>quota", limits * 1.2
        apiNeedUpdate[api] = data.quota = limits * 1.2
    
    es.write cmd: "quota", apisNeedUpdate

    # # 重置之后再进入下一个tick
    # async.parallel apisNeedReset, (err, api) ->
    #   console.error "[agent] - 无法重置#{api}的quota", err if err?
    #   callback()
    #   # 读取计数器
    #   syncor.fetch "count::*", (err, group) ->
    #     if err?
    #       console.error "[agent] - 读取计数器出错", err.toString()
    #     else
    #       # TODO: 优化Tn
    #       # O(n^2)
    #       entry = group.reduce (a, b) ->
    #         for item in b.value.split "\n"
    #           [k, v] = item.split '::'
    #           if k in a
    #             a[k] += +v
    #           else
    #             a[k] = +v
    #         a
    #       , {}

    #       apiNeedUpdate = (for api, count of entry
    #         config = syncor.get "#{api} ~>config"
    #         # 只有配置数据找到时才更新
    #         if config?.limits?
    #           {limits} = config
    #           if count >= limits
    #             # 根据计数器数值更新quota
    #             do (api, limits, count) ->
    #               newValue = parseInt((limits * 1.2 - count) / group.length)
    #               (cb) ->
    #                 syncor.set "quota ~> #{api}", newValue, (err) ->
    #                   cb err, api
    #       ).filter (e) -> e?

    #       async.parallel apiNeedUpdate, (err) ->
    #         console.error "[agent] - 无法推送#{api}的quota更新", err.toString() if err?

  # # 同步quota静态配置
  # syncor.on "config", (meta, config_dump) ->
  #   if err?
  #     console.error "[agent] - 静态配置获取错误", err?.message
  #   else
  #     # 获取静态配置信息
  #     # O(n)
  #     if o = syncor.get 'config'
  #       Object.assign o, config_dump
  #     else
  #       syncor.set "config", config_dump
      # for api, {interval, limits} of config_dump
      #   # O(1)
      #   if syncor.get api
      #     syncor.set "#{api}~>config", {interval, limits}
      #   else
      #     syncor.set api, config: {interval, limits}
