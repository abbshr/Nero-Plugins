class RandomResponseHi
  base: no
  pluginName: "randomhi"

  handle: (req, res, next) ->
    rand = ~~(Math.random() * 10)
    if rand % 2
      res.end JSON.stringify msg: "Hi~"
    else
      next()

module.exports = -> new RandomResponseHi()