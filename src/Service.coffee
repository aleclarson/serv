
assertType = require "assertType"
isType = require "isType"

request = require "./request"

Service = (config) ->
  assertType config, Object
  assertType config.url, String

  self = Object.create Service::
  self.url = config.url

  if isType config.auth, String
    cons self, "_auth", "Basic " + new Buffer(config.auth).toString "base64"

  else if isType config.auth, Function
    cons self, "_auth", config.auth()

  else if isType config.key, String
    cons self, "_key", config.key

  if config.certAuth
    cons self, "_certAuth", config.certAuth

  # NOTE: This is not used anywhere yet.
  if isType config.rate, Number
    self._rate = config.rate
    self._rateLimit = config.rateLimit

  cons self, "_dataType", config.dataType or "json"
  return self

Service::get = (uri) ->
  assertType uri, String

  query = arguments[1] or {}
  headers = query.headers or {}
  delete query.headers

  if @_auth
    headers["Authorization"] = @_auth

  else if @_key
    query.key = @_key

  request @url + uri, {
    certAuth: @_certAuth
    headers
    query
  }

Service::post = (uri, data) ->
  assertType uri, String

  headers = arguments[2]
  unless isType headers, Object
    if isType data, Object
      headers = data.headers or {}
      delete data.headers
    else
      headers = {}

  unless headers["Content-Type"]
    contentType = @_dataType

  if @_auth
    headers["Authorization"] = @_auth

  else if @_key
    query = {key: @_key}

  request @url + uri, {
    method: "POST"
    certAuth: @_certAuth
    contentType
    data
    headers
    query
  }

module.exports = Service

#
# Helpers
#

# Define a constant, non-enumerable property
cons = (obj, key, value) ->
  Object.defineProperty obj, key, {value}
