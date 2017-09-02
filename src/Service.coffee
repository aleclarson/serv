
assertValid = require "assertValid"
isValid = require "isValid"

request = require "./request"

configTypes =
  url: "string"
  key: "string?"
  auth: "string|function?"
  ssl: "object?"
  rate: "number?"
  rateLimit: "number?"
  dataType: "string?"

sslConfigTypes =
  key: "string?"
  cert: "string?"
  ca: "string|array?"

Service = (name, config) ->
  assertValid name, "string"
  assertValid config, configTypes

  self = Object.create Service::
  self.name = name
  self.url = config.url

  if config.key
    cons self, "_key", config.key

  else if config.auth
    cons self, "_auth",
      if isValid config.auth, "string"
      then "Basic " + new Buffer(config.auth).toString "base64"
      else config.auth()

  if config.ssl
    assertValid config.ssl, sslConfigTypes
    cons self, "_ssl", config.ssl

  # NOTE: This is not used anywhere yet.
  if config.rate
    self._rate = config.rate
    self._rateLimit = config.rateLimit

  cons self, "_dataType", config.dataType or "json"
  return self

Service::get = (uri) ->
  assertValid uri, "string"

  query = arguments[1] or {}
  headers = query.headers or {}
  delete query.headers

  if @_auth
    headers["Authorization"] = @_auth

  else if @_key
    query.key = @_key

  request @url + uri, {
    headers
    query
    ssl: @_ssl
  }

Service::post = (uri, data) ->
  assertValid uri, "string"

  headers = arguments[2]
  unless isValid headers, "object"
    if isValid data, "object"
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
    contentType
    data
    headers
    query
    ssl: @_ssl
  }

module.exports = Service

#
# Helpers
#

# Define a constant, non-enumerable property
cons = (obj, key, value) ->
  Object.defineProperty obj, key, {value}
