config = require './config'
net = require 'net'
cbor = require 'cbor'
syncor = require('./syncor')()

# syncor =
#   sync: (fn) =>
#     fn => @_timer = setTimeout @sync, 1000, fn

module.exports = ->
  # 每次sync时间复杂度: O(n)
  # 异步并发任务回调的复杂度为: O(n)

  syncor.sync (callback) ->
    # O(n)
    data = ("#{api}::#{item.count ? 0}" for api, item of syncor.get "").join "\n"
    # 本地数据初始化之前不同步数据
    unless data.length
      return callback()

    # 同步计数器更新
    syncor.push "count::#{config.local}:#{process.pid}", data, (err) ->
      console.error "[process #{process.pid}] - 推送count更新出错", err.toString() if err?
      callback()

    # 获取quota变化
    syncor.fetch "quota::*", (err, group) ->
      if err?
        console.error "[process #{process.pid}] - 获取quota更新出错", err.toString()
      else
        # O(n)
        for item in group
          # console.log "取得Quota", item
          {key, value} = item
          [..., api] = key.split '::'
          newQuota = +value
          currentTime = Date.now()
          {constant, lstUpdateTime, quota, config: {interval}} = data = syncor.get api
          # 惰性Quota
          # O(1)
          switch
            # quota不变
            when +newQuota is 0
              data.count = 0
            # 重置quota
            when +newQuota is +constant
              if not lstUpdateTime? or currentTime - lstUpdateTime >= interval
                data.quota = +newQuota
                data.count = 0
                data.lstUpdateTime = currentTime
            # 更新quota
            when +newQuota < +quota
              data.quota = +newQuota
              # console.log "[process #{process.pid}] - 更新#{api}的quota为#{quota}"
