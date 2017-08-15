
mock = require "mock-require"

# The default values of every response.
resDefaults =
  error: null
  status: 200
  headers: {}
  data: new Buffer ""

mock "https",

  # The default values of the next response.
  _res: null

  # The request and response of the last `request` call.
  req: null
  res: null

  request: (opts, cb) ->
    res = Object.assign {}, resDefaults, @_res
    {error, status, headers, data} = res
    @_res = null

    @req = req = Object.assign {}, opts
    @res = res = {statusCode: status, headers, data}

    res.on = (event, cb) ->

      if event is "data"
        error or cb @data

      else if event is "end"
        error or cb()

      else if event is "error"
        error and cb error

    write: (data) -> req.data = data
    end: -> cb res
