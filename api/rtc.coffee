Hapi = require('hapi')
server = new (Hapi.Server)
server.connection
  'host': 'filmit.watch'
  'port': 3000
socketio = require('socket.io')
io = socketio(server.listener)
twilio = require('twilio')('AC44a6567b84e9c9496479312d11fbd64a', '4f9461ca2983b6223b27e5e3af24378a')
# Serve static assets
server.route
  method: 'GET'
  path: '/{path*}'
  handler: directory:
    path: './public'
    listing: false
    index: true

server.start ->
  console.log('Server running at:', server.info.uri)

module.exports = (server) ->
  io.on "connection", (socket) ->
    socket.on "join", (room) ->
      clients = io.sockets.adapter.rooms[room]
      numClients = if typeof clients isnt "undefined" then Object.keys(clients).length else 0
      if numClients is 0
        socket.join room
      else if numClients is 1
        socket.join room
        socket.emit "ready", room
        socket.broadcast.emit "ready", room
      else
        socket.emit "full", room

    socket.on "token", ->
      twilio.tokens.create (error, response) ->
        if error
          console.log "error", error
        else
          socket.emit "token", response

    socket.on "candidate", (candidate) ->
      socket.broadcast.emit "candidate", candidate

    socket.on "offer", (offer) ->
      socket.broadcast.emit "offer", offer

    socket.on "answer", (answer) ->
      socket.broadcast.emit "answer", answer

