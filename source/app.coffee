#REAL
# CATA = "54f5cbe233b84d9e6eb8dadf"
# OIHI = "54f5cbd733b84d9e6eb8dadc"
#DEVELOPMENT
CATA = "54f0571e9e06f4a0298946ac"
OIHI = "54f047e44330a8831395093d"

class window.VideoChat

  constructor: ->

    #DEVELOPMENT
    Appnima.key = "NTRmMDQ3YzhhMGYyMDU5OTQ2YWYzM2NjOmhwMzRyVHFhY3F5SUVod3NmaDNUU0ZCZmhjdVdCeWw="
    #REAL
    # Appnima.key = "NTRmMDNkNmYzNzg1NWYzMzI5YzMzNzc5OlZLT3JOd00xM1N6ZjVtY2ZDaXhFOUU5ZmVYRUhPa1g="
    @peer = new Appnima.Peer()
    @peer.on 'connected', @onConnected
    @peer.on 'answer', @onAnswer
    @peer.on 'offer', @onOffer
    @peer.on 'onAddStream', @onAddStream
    @peer.on 'candidate', @onCandidate
    @peer.on 'hangUp', @onHangUpPeer

    session = JSON.parse localStorage.getItem Appnima.key
    if session?.id is CATA then @friend = OIHI else @friend = CATA

    if session?
      document.getElementById("get-video").disabled = false
      document.getElementById("call").disabled = false
    @videoButton = document.getElementById "get-video"
    @videoButton.addEventListener "click", @requestMediaStream, false

    @callButton = document.getElementById "call"
    @callButton.addEventListener "click", @startCall, false

    @loginButton = document.getElementById "login"
    @loginButton.addEventListener "click", @onLogin, false

    @hangupButton = document.getElementById "hangup"
    @hangupButton.addEventListener "click", @onHangUp, false

  requestMediaStream: (event) =>
    getUserMedia {video: true, audio: true}, @onMediaStream, @noMediaStream

  onMediaStream: (stream) =>
    @localVideo = document.getElementById "local-video"
    @localVideo.volume = 0
    @localVideo.src = window.URL.createObjectURL stream
    @peer.stream stream
    @peer.join()

  noMediaStream: ->
    alert "No media stream for us."

  startCall: =>
    @peer.token()

  onAddStream: (event) =>
    console.log "onAddStream"
    @remoteVideo = document.getElementById "remote-video"
    @remoteVideo.src = window.URL.createObjectURL event.stream

  onConnected: (connected) =>
    console.log "connected", connected

  onLogin: =>
    mail = $(document.getElementById("mail")).val()
    password = $(document.getElementById("pass")).val()
    Appnima.User.login(mail, password).then (error, user) ->
      if user
        document.getElementById("get-video").disabled = false
        document.getElementById("call").disabled = false
        console.log "#{user.mail} Logged!"
      else
        console.log "[Error] #{error.message}"

  onHangUp: =>
    @_disconnect()
    @peer.hangUp()

  onHangUpPeer: =>
    @_disconnect()

  _disconnect: =>
    @remoteVideo.pause()
    @localVideo.pause()
    @remoteVideo.src = ""
    @localVideo.src = ""

  onOffer: =>
    @peer.offer CATA

  onAnswer: (answer) =>
    @peer.answer answer, OIHI

  onCandidate: (candidate) =>
    @peer.candidate candidate, @friend
