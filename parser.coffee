cson = require 'cson'
require.extensions['.cson'] = (module, filename) ->
  module.exports = cson.load filename