
{assert, isValid} = require "validate"

request = require "./request"

Service = (name, config) ->
  assert config, {url: "string"}

  self = Object.create Service::
  self.name = name
  self.url = config.url

  if isValid config.auth, "string"
    cons self, "_auth", "Basic " + new Buffer(config.auth).toString "base64"

  else if isValid config.auth, "function"
    cons self, "_auth", config.auth()

  else if isValid config.key, "string"
    cons self, "_key", config.key

  if config.certAuth
    cons self, "_certAuth", config.certAuth

  # NOTE: This is not used anywhere yet.
  if isValid config.rate, "number"
    self._rate = config.rate
    self._rateLimit = config.rateLimit

  cons self, "_dataType", config.dataType or "json"
  return self

Service::get = (uri) ->
  assert uri, "string"

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
  assert uri, "string"

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
