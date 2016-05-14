path = require 'path'
syncor = require('./syncor')()
async = require 'async'
cbor = require 'cbor'

class QuotaAgent
  constructor: (@) ->
  
  
  close: ->

module.exports = ->
  # 每次sync复杂度O(n)
  # 并发异步任务中存在回调为O(n^2)的代码, 考虑优化
  syncor.sync (callback) ->
    # O(n)
    currentTime = Date.now()
    apisNeedReset = (for api, data of syncor.get "" when data?.config?
      {count, config: { interval, limits }} = data
      data.count ?= 0
      data.fstAccessTime ?= currentTime
      # 检查计数器重置周期
      if currentTime - data.fstAccessTime > interval
        data.count = 0
        data.fstAccessTime = currentTime
        # 重置周期触发对应api的quota更新
        do (api) ->
          (cb) ->
            syncor.push "quota::#{api}", limits * 1.2, (err) ->
              cb err, api
    ).filter (e) -> e?

    # 重置之后再进入下一个tick
    async.parallel apisNeedReset, (err, api) ->
      console.error "[agent] - 无法重置#{api}的quota", err if err?
      callback()
      # 读取计数器
      syncor.fetch "count::*", (err, group) ->
        if err?
          console.error "[agent] - 读取计数器出错", err.toString()
        else
          # TODO: 优化Tn
          # O(n^2)
          entry = group.reduce (a, b) ->
            for item in b.value.split "\n"
              [k, v] = item.split '::'
              if k in a
                a[k] += +v
              else
                a[k] = +v
            a
          , {}

          apiNeedUpdate = (for api, count of entry
            config = syncor.get "#{api} ~>config"
            # 只有配置数据找到时才更新
            if config?.limits?
              {limits} = config
              if count >= limits
                # 根据计数器数值更新quota
                do (api, limits, count) ->
                  newValue = parseInt((limits * 1.2 - count) / group.length)
                  (cb) ->
                    syncor.push "quota::#{api}", newValue, (err) ->
                      cb err, api
          ).filter (e) -> e?

          async.parallel apiNeedUpdate, (err) ->
            console.error "[agent] - 无法推送#{api}的quota更新", err.toString() if err?

    # 同步quota静态配置
    syncor.fetch "config::*", (err, group) ->
      if err?
        console.error "[agent] - 静态配置获取错误", err.toString()
      else
        # 获取静态配置信息
        # O(n)
        for config in group when config?.value.length
          [..., api] = config.key.split '::'
          [interval, limits] = config.value.split '\n'
          # O(1)
          if syncor.get api
            syncor.set "#{api}~>config", {interval, limits}
          else
            syncor.set api, config: {interval, limits}
