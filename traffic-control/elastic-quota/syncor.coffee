# 同步器
net = require 'net'
{Encoder, Decoder} = require 'cbor'
{EventEmitter} = require 'events'
{quota_addr, quota_port} = require './config'

syncor = null
class Syncor extends EventEmitter

  constructor: (args) ->
    if syncor? then return syncor
    syncor = @
    @_timer = null
    # the Set remain to sync
    @_entrties = {}
    @slaves = new Set()
    super()
    if args.server
      @init_quota_server()
    else
      @init_quota_conn()
      
  init_quota_server: ->
    @quota_server = net.createServer (socket) =>
      es = new Encoder()
      ds = new Decoder()
      es.pipe socket
      .pipe ds
      .on 'data', ({cmd, data}) =>
        [cmd, meta] = cmd.split '::'
        @emit cmd, meta, data, es
      .on 'end', -> console.info "transmission end"
    
  init_quota_conn: ->
    @quota_socket = net.connect quota_port, quota_addr, =>
      @es = new Encoder()
      ds = new Decoder()
      @es.pipe @quota_socket
      .pipe ds
      .on 'data', ({cmd, receipt}) =>
        @emit cmd, receipt
      .on 'end', ->
        console.info "transmission end"
      @quota_socket.on 'close', ->
        console.log "quota connection closed"
    .on 'error', (err) ->
      console.error err.message

  get: (query = "") ->
    selector @_entrties, query

  set: (query = "", value) ->
    selector @_entrties, query, value

  push: (cmd, data, callback) ->
    @es?.write {cmd, data}, callback

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
