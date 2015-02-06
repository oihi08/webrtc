"use strict"
io = require("socket.io").listen(8008)

room = []

module.exports = (server) ->
  io.sockets.on 'connection', (socket) ->
    socket.on "open", (session) ->
      room.push session
      socket.session = session
      socket.join "#{session}"
      if room.length is 2
        socket.broadcast.to(_getUser(session)).emit "connected", session

    socket.on "connected", (receiver) ->
      socket.broadcast.to(_getUser(receiver)).emit "connected", receiver

    socket.on "ice", (profile, data) ->
      socket.broadcast.to("#{profile}").emit "ice", data

    socket.on "offer", (profile, data) ->
      _broadcast socket, profile, data

    socket.on "answer", (profile, data) ->
      _broadcast socket, profile, data

    socket.on "disconnect", (reason) ->
      for user in room
        _broadcast socket, user, "hangUp", socket.session
      room = []
      socket.leave socket.session

    socket.on "hangUp", (friend) ->
      room = []
      socket.broadcast.to(friend).emit "hangUp", socket.session

  _broadcast = (socket, receiver, data) ->
    message =
      description: data
      type       : data.type
      user       : socket.session
    socket.broadcast.to("#{receiver}").emit message.type, message

  _getUser = (user) ->
    for id, i in room when user is id
      if i is 0 then return room[1] else return room[0]
