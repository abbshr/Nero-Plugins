Nero Plugins Lib
===

1. How to write a plugin for Nero?

```coffee
class TestPlugin
  constructor: ->
  
  pluginName: "test-plugin"
  
  handle: (req, res, next) ->
    # plugin logic body
  
module.exports = (args) -> new TestPlugin args
```

2. How to load my plugin?

使用自定义扩展前需要在`./etc/plugins.yaml`中注册新的名字和查找路径.

`./etc/plugins.yaml`中的插件路径相对于`./plugins`.

在`./etc/Nero.yaml`配置文件的`request_phase`和`response_phase`字段里可以选择性启用/禁用`./etc/plugins.yaml`中的插件.