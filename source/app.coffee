class window.VideoChat

  constructor: ->
    Appnima.key = "NTRmMDQ3YzhhMGYyMDU5OTQ2YWYzM2NjOmhwMzRyVHFhY3F5SUVod3NmaDNUU0ZCZmhjdVdCeWw="
    Appnima.User.session()

    @peer = new Appnima.Peer()
    @peer.on "onAddStream", @onAddStream
    @peer.on "onHangUp", @onHangUp

    loginBtn = document.getElementById "onLogin"
    loginBtn.addEventListener "click", @onLogin, false

    videoBtn = document.getElementById "get-video"
    videoBtn.addEventListener "click", @onGetCamera, false

    callBtn = document.getElementById "call"
    callBtn.addEventListener "click", @onCall, false

  onLogin: ->
    mail = $(document.getElementById("mail")).val()
    password = $(document.getElementById("password")).val()
    if mail is "oihane@tapquo.com" then Appnima.Network.shieldFollow("54f0571e9e06f4a0298946ac")
    Appnima.User.login(mail, password)
    console.log "Login!"

  onGetCamera: =>
    getUserMedia {video: true, audio: true}, @onMediaStream, @failMediaStream

  onMediaStream: (stream) =>
    @localVideo = document.getElementById "local-video"
    @localVideo.volume = 0
    @localVideo.src = window.URL.createObjectURL stream
    @peer.stream = stream
    @peer.join()

  failMediaStream: ->
    console.log "failMediaStream"

  onCall: =>
    @peer.token()

  onAddStream: (event) =>
    @remoteVideo = document.getElementById "remote-video"
    @remoteVideo.src = window.URL.createObjectURL event.stream

  onHangUp: =>
    @peer.stream.stop()
    @localVideo.src = ""
    @remoteVideo.src = ""
    @localVideo.pause()
    @remoteVideo.pause()
