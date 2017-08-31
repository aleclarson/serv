
{assert, isValid} = require "validate"

formUrlEncoded = require "form-urlencoded"
https = require "https"
qs = require "querystring"

urlRE = /([^\/]+)(\/.*)?/

contentTypes =
  binary: "application/octet-stream"
  form: "application/x-www-form-urlencoded"
  json: "application/json"
  text: "text/plain; charset=utf-8"

request = (url, options) ->
  assert url, "string"
  assert options, "object"

  unless url.startsWith "https://"
    throw Error "Only HTTPS requests are supported!"

  headers = options.headers or {}
  assert headers, "object"

  # Default headers
  headers["Accept"] ?= "*/*"

  if query = options.query
    if isValid query, "object"
      query = qs.stringify query
    query = "?" + query if query
  else query = ""

  if data = options.data
    contentType = headers["Content-Type"]

    if options.contentType
      assert options.contentType, "string"
      contentType = contentTypes[options.contentType]

    if isValid data, "object"

      if contentType is contentTypes.form
        data = formUrlEncoded data
        contentType += "; charset=utf-8"

      else
        data = JSON.stringify data
        contentType ?= contentTypes.json

    else if Buffer.isBuffer data
      contentType ?= contentTypes.binary

    else
      assert data, "string"
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
