class window.VC

  constructor: ->
    Appnima.key = "NTRmMDQ3YzhhMGYyMDU5OTQ2YWYzM2NjOmhwMzRyVHFhY3F5SUVod3NmaDNUU0ZCZmhjdVdCeWw="
    Appnima.User.session()

    @peer = new Appnima.Peer()
    @peer.on "onAddStream", @onAddStream

    @videoButton = document.getElementById "onLogin"
    @videoButton.addEventListener "click", @onLogin, false

    @videoButton = document.getElementById "get-video"
    @videoButton.addEventListener "click", @getVideo, false

    @videoButton = document.getElementById "call"
    @videoButton.addEventListener "click", @call, false

  onLogin: ->
    mail = $(document.getElementById("mail")).val()
    password = $(document.getElementById("password")).val()
    if mail is "oihane@tapquo.com" then Appnima.Network.shieldFollow("54f0571e9e06f4a0298946ac")
    Appnima.User.login(mail, password)
    console.log "Login!"

  getVideo: =>
    getUserMedia {video: true, audio: true}, @onMediaStream, @failMediaStream

  onMediaStream: (stream) =>
    @localVideo = document.getElementById "local-video"
    @localVideo.volume = 0
    @peer.addStream stream
    @localVideo.src = window.URL.createObjectURL stream
    @peer.join Appnima.User.session().access_token

  failMediaStream: ->
    console.log "failMediaStream"

  call: =>
    @peer.token startCall = true

  onAddStream: (event) ->
    console.log "joeee", event.stream
    remoteVideo = document.getElementById "remote-video"
    remoteVideo.src = window.URL.createObjectURL event.stream
