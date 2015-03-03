class window.VC

  constructor: ->
    Appnima.key = "NTRmMDQ3YzhhMGYyMDU5OTQ2YWYzM2NjOmhwMzRyVHFhY3F5SUVod3NmaDNUU0ZCZmhjdVdCeWw="
    Appnima.User.session()

    @peer = new Appnima.Peer()
    @peer.on "onAddStream", @onAddStream
    CATA = "54f0571e9e06f4a0298946ac"
    OIHI = "54f047e44330a8831395093d"
    @peer.users OIHI, CATA

    @videoButton = document.getElementById "get-video"
    @videoButton.addEventListener "click", @getVideo, false

    @callButton = document.getElementById "call"
    @callButton.addEventListener "click", @startCall, false

  getVideo: =>
    getUserMedia {video: true, audio: true}, @onMediaStream, @failMediaStream

  onMediaStream: (stream) =>
    @localVideo = document.getElementById "local-video"
    @localVideo.volume = 0
    @peer.addStream stream
    @localVideo.src = window.URL.createObjectURL stream
    @peer.connected()

  failMediaStream: ->
    console.log "failMediaStream"

  startCall: =>
    @peer.getToken()

  onAddStream: (event) =>
    @remoteVideo = document.getElementById "remote-video"
    @remoteVideo.src = window.URL.createObjectURL event.stream
