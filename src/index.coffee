
# The map of `Service` instances.
registry = Object.create null

Service = require "./Service"

serv = (serviceId) ->
  return registry[serviceId]

serv.set = (serviceId, config) ->
  if config is null
    delete registry[serviceId]
  else registry[serviceId] = Service config

module.exports = serv
