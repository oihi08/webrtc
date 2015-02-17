"use strict"

module.exports = (server) ->

  server.get "/", (request, response) ->
    response.page "index"
