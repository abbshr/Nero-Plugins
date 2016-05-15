config = require './config'
syncor = require('./syncor')()

module.exports = ->
  # 每次sync时间复杂度: O(n)
  # 异步并发任务回调的复杂度为: O(n)

  syncor.on 'quota', (deltas) ->
    for api, newQuota in deltas
      currentTime = Date.now()
      {lstUpdateTime, quota, threshold, interval} = data = syncor.get api
      constant = threshold * 1.2
      # 惰性Quota
      # O(1)
      switch
        # quota不变
        when newQuota is 0
          data.count = 0
        # 重置quota
        when newQuota is constant
          if not lstUpdateTime? or currentTime - lstUpdateTime >= interval
            data.quota = newQuota
            data.count = 0
            data.lstUpdateTime = currentTime
        # 更新quota
        when newQuota < quota
          data.quota = newQuota

  syncor.sync (callback) ->
    syncor.push "dump::#{config.localaddr}=#{process.pid}", syncor.get(""), (err) ->
      console.error "[process #{process.pid}] - 推送count更新出错", err?.message
      callback()

    # count_dump = {}
    # for api, {count} of syncor.get ""
    #   count_dump[api] = count ? 0

    # # 同步计数器更新
    # # cmd: count::<localaddr>=<pid>, data: count dump
    # syncor.push "count::#{config.localaddr}=#{process.pid}", count_dump, (err) ->
    #   console.error "[process #{process.pid}] - 推送count更新出错", err?.message
    #   callback()
    # syncor.push "quota::*", {}, (err) ->