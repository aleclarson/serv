
# The map of `Service` instances.
registry = Object.create null

Service = require "./Service"

serv = (name) ->
  return registry[name]

serv.set = (name, config) ->
  if config is null
    delete registry[name]
  else registry[name] = Service name, config

module.exports = serv
