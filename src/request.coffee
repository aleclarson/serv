
assertType = require "assertType"
isType = require "isType"
https = require "https"
qs = require "querystring"

urlRE = /([^\/]+)(\/.*)?/

contentTypes =
  binary: "application/octet-stream"
  form: "application/x-www-form-urlencoded; charset=utf-8"
  json: "application/json"
  text: "text/plain; charset=utf-8"

request = (url, options) ->
  assertType url, String
  assertType options, Object

  unless url.startsWith "https://"
    throw Error "Only HTTPS requests are supported!"

  headers = options.headers or {}
  assertType headers, Object

  # Default headers
  headers["Accept"] ?= "*/*"

  if query = options.query
    if isType query, Object
      query = qs.stringify query
    query = "?" + query if query
  else query = ""

  if data = options.data
    contentType = headers["Content-Type"]

    if options.contentType
      assertType options.contentType, String
      contentType = contentTypes[options.contentType]

    if isType data, Object

      if contentType is contentTypes.form
        data = encodeForm data

      else
        data = JSON.stringify data
        contentType ?= contentTypes.json

    else if Buffer.isBuffer data
      contentType ?= contentTypes.binary

    else
      assertType data, String
      contentType ?= contentTypes.text

    headers["Content-Type"] = contentType
    headers["Content-Length"] =
      if Buffer.isBuffer data
      then data.length
      else Buffer.byteLength data

  parts = urlRE.exec url.slice 8
  opts =
    host: parts[1]
    path: (parts[2] or "/") + query
    method: options.method
    headers: options.headers
    ca: options.certAuth
    rejectUnauthorized: options.certAuth?

  return new Promise (resolve, reject) ->
    req = https.request opts, (res) ->
      status = res.statusCode
      readStream res, (error, data) ->
        if error
        then reject error
        else resolve {
          __proto__: responseProto
          success: status >= 200 and status < 300
          headers: res.headers
          status
          data
        }

    req.write data if data
    req.end()

module.exports = request

#
# Helpers
#

encodeForm = do ->
  pairs = []

  encodePair = (key, value) ->
    return if value is undefined

    if isType value, Object
      encodeObject value, key
      return

    if isType value, Array
      encodeArray value, key
      return

    pairs.push encodeURIComponent(key) + "=" + encodeURIComponent(value)
    return

  encodeObject = (values, parent) ->
    for key of values
      encodePair parent + "[" + key + "]", values[key]
    return

  encodeArray = (values, parent) ->
    index = -1
    while ++index < values.length
      encodePair parent + "[" + index + "]", values[index]
    return

  return (values) ->
    for key of values
      encodePair key, values[key]
    str = pairs.join "&"
    pairs.length = 0
    return str

readStream = (stream, callback) ->
  chunks = []

  stream.on "data", (chunk) ->
    chunks.push chunk

  stream.on "end", ->
    callback null, Buffer.concat chunks

  stream.on "error", callback

responseProto = do ->
  proto = {}

  Object.defineProperty proto, "json",
    get: -> JSON.parse @data.toString()
    set: -> throw Error "Cannot set `json`"

  Object.defineProperty proto, "text",
    get: -> @data.toString()
    set: -> throw Error "Cannot set `text`"

  return proto
