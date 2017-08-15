
# The map of `Service` instances.
registry = Object.create null

Service = require "./Service"

serv = (serviceId) ->
  return registry[serviceId]

serv.set = (serviceId, config) ->
  return registry[serviceId] = Service config

serv.del = (serviceId) ->
  delete registry[serviceId]

module.exports = serv
