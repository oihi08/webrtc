
    # main    : "http://localhost:1337"
    # socket  : "http://socket.appnima.com"
    # rtc     : "http://localhost:3001"
    # storage : "http://storage.appnima.com"


class window.VideoChat

  constructor: ->

    #DEVELOPMENT
    # Appnima.key = "NTRmMDQ3YzhhMGYyMDU5OTQ2YWYzM2NjOmhwMzRyVHFhY3F5SUVod3NmaDNUU0ZCZmhjdVdCeWw="
    #REAL
    Appnima.key = "NTRmMDNkNmYzNzg1NWYzMzI5YzMzNzc5OlZLT3JOd00xM1N6ZjVtY2ZDaXhFOUU5ZmVYRUhPa1g="
    Appnima.User.session()
    @peer = new Appnima.Peer()
    @peer.on 'onAddStream', @onAddStream

    @videoButton = document.getElementById "get-video"
    @videoButton.addEventListener "click", @requestMediaStream, false

    @callButton = document.getElementById "call"
    @callButton.addEventListener "click", @startCall, false

    @loginButton = document.getElementById "login"
    @loginButton.addEventListener "click", @onLogin, false

  requestMediaStream: (event) =>
    getUserMedia {video: true, audio: true}, @onMediaStream, @noMediaStream

  onMediaStream: (stream) =>
    @localVideo = document.getElementById "local-video"
    @localVideo.volume = 0
    @localVideo.src = window.URL.createObjectURL stream
    @peer.stream stream, @callButton, Appnima.User.session().id
    @videoButton.setAttribute "disabled", "disabled"
    @peer.join()

  noMediaStream: ->
    alert "No media stream for us."

  startCall: =>
    @peer.token()

  onAddStream: (event) =>
    @remoteVideo = document.getElementById "remote-video"
    @remoteVideo.src = window.URL.createObjectURL event.stream

  onLogin: ->
    mail = $(document.getElementById("mail")).val()
    password = $(document.getElementById("pass")).val()
    Appnima.User.login(mail, password)
    console.log "Login DONE!"
