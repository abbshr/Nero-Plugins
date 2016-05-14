Nero Plugins Lib
===

1. How to write a plugin for Nero?

```coffee
class TestPlugin
  constructor: ->
    # 这里可以暂存插件的运行时动态数据
  
  # 表示该插件是否应用到集群(yes表示应用范围是插件, no表示为基础插件)
  base: no
  
  pluginName: "test-plugin"
  
  handle: (req, res, next) ->
    # handle中可以使用Nero的全局配置对象@settings, 
    # 包含当前调用的服务名字, 请求参数, 上游应用服务器地址, 该插件的配置

    # 当前插件的配置:
    # cfg = req.cfg[@pluginName]
    
    # plugin logic body

module.exports = (args) -> new TestPlugin args
```

2. How to load my plugin?

使用自定义扩展前需要在`./etc/plugins.yaml`中注册新的名字和查找路径.

`./etc/plugins.yaml`中的插件路径相对于`./plugins`.

在`./etc/Nero.yaml`配置文件的`request_phase`和`response_phase`字段里可以选择性启用/禁用`./etc/plugins.yaml`中的插件.