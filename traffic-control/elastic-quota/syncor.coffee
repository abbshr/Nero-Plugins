# 同步器
net = require 'net'
cbor = require 'cbor'
{EventEmitter} = require 'events'

syncor = null
class Syncor extends EventEmitter

  constructor: (args) ->
    if syncor? then return syncor
    syncor = @
    @_timer = null
    # the Set remain to sync
    @_entrties = {}

  get: (query = "") ->
    selector @_entrties, query

  set: (query = "", value) ->
    selector @_entrties, query, value

  push: (key, value, callback) ->

  fetch: (key, callback) ->

  sync: (fn) =>
    fn => @_timer = setTimeout @sync, 1000, fn

# 选择器
# O(n)
# object: {a: {b: c: "hi"}}
# query: "a ~> b ~> c"
# => "hi"
selector = (object, query, value) ->
  unless object?
    return null
  query = query.split '~>'
  .map (token) -> token.trim()

  [token, ...] = query
  if query.length isnt 1
    selector object[token], query.slice(1).join("~>"), value
  else if token.length
    object[token] = value if value?
    object[token]
  else
    object = value if value?
    object

module.exports = (args = {}) -> new Syncor args
