
assertValid = require "assertValid"
isValid = require "isValid"
request = require "request"

configTypes =
  url: "string"
  auth: "string|function?"
  query: "object?"
  ssl: [key: "string?", cert: "string?", ca: "string|array?", "?"]
  throttle: [rate: "number", limit: "number", "?"]
  dataType: "string?"
  debug: "boolean?"

Service = (name, config) ->
  assertValid name, "string"
  assertValid config, configTypes

  self = Object.create Service::
  self.name = name
  self.url = config.url

  if config.debug
    cons self, "_debug", true

  if config.auth
    cons self, "_auth",
      if isValid config.auth, "string"
      then "Basic " + new Buffer(config.auth).toString "base64"
      else config.auth()

  if config.query
    cons self, "_query", config.query

  if config.ssl
    cons self, "_ssl", config.ssl

  # NOTE: This is not used anywhere yet.
  if config.throttle
    cons self, "_throttle", config.throttle

  cons self, "_dataType", config.dataType or "json"
  return self

Service::get = (uri, query) ->
  assertValid uri, "string"
  assertValid query, "object?"
  sendQuery.call this, "GET", uri, query

Service::delete = (uri, query) ->
  assertValid uri, "string"
  assertValid query, "object?"
  sendQuery.call this, "DELETE", uri, query

Service::post = (uri, data) ->
  assertValid uri, "string"
  assertValid data, "object|buffer|string?"
  sendBody.call this, "POST", uri, data

Service::put = (uri, data) ->
  assertValid uri, "string"
  assertValid data, "object|buffer|string?"
  sendBody.call this, "PUT", uri, data

Service::patch = (uri, data) ->
  assertValid uri, "string"
  assertValid data, "object|buffer|string?"
  sendBody.call this, "PATCH", uri, data

module.exports = Service

#
# Helpers
#

# Define a constant, non-enumerable property
cons = (obj, key, value) ->
  Object.defineProperty obj, key, {value}

sendQuery = (method, uri, query) ->

  if query?
    if isValid query.headers, "object"
      {headers} = query
      delete query.headers
    else headers = {}
  else headers = {}

  if @cookie
    headers["Cookie"] = @cookie

  if @_auth
    headers["Authorization"] = @_auth

  if @_query
    if query
    then Object.assign query, @_query
    else query = @_query

  request @url + uri, {
    headers
    query
    ssl: @_ssl
    debug: @_debug
  }

sendBody = (method, uri, data) ->

  if data?
    {query, headers} = data
    unless data.data?
      if query?
        delete data.query
      if headers?
        delete data.headers
      else headers = {}
    else
      {data} = data
      headers ?= {}
  else headers = {}

  unless headers["Content-Type"]
    contentType = @_dataType

  if @cookie
    headers["Cookie"] = @cookie

  if @_auth
    headers["Authorization"] = @_auth

  if @_query
    if query
    then Object.assign query, @_query
    else query = @_query

  request @url + uri, {
    method: "POST"
    contentType
    data
    headers
    query
    ssl: @_ssl
    debug: @_debug
  }
