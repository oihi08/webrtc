
    # main    : "http://localhost:1337"
    # socket  : "http://socket.appnima.com"
    # rtc     : "http://localhost:3001"
    # storage : "http://storage.appnima.com"


window.VC =
  socket: io "http://filmit.watch:3000"

  requestMediaStream: (event) ->
    getUserMedia {video: true, audio: true}, VC.onMediaStream, VC.noMediaStream

  onMediaStream: (stream) ->
    VC.localVideo = document.getElementById "local-video"
    VC.localVideo.volume = 0
    VC.localStream = stream
    VC.videoButton.setAttribute "disabled", "disabled"
    VC.localVideo.src = window.URL.createObjectURL stream
    VC.socket.emit "join", "test"
    VC.socket.on "ready", VC.readyToCall
    VC.socket.on "offer", VC.onOffer

  noMediaStream: ->
    alert "No media stream for us."

  readyToCall: (event) ->
    VC.callButton.removeAttribute "disabled"

  startCall: (event) ->
    VC.socket.on "token", VC.onToken VC.createOffer
    VC.socket.emit "token"

  onToken: (callback) ->
    (token) ->
      VC.peerConnection = new RTCPeerConnection iceServers: token.iceServers
      VC.peerConnection.addStream VC.localStream
      VC.peerConnection.onicecandidate = VC.onIceCandidate
      VC.peerConnection.onaddstream = VC.onAddStream
      VC.socket.on 'candidate', VC.onCandidate
      VC.socket.on 'answer', VC.onAnswer
      callback()
      return

  onIceCandidate: (event) ->
    if event.candidate
      VC.socket.emit "candidate", JSON.stringify event.candidate
      VC.callButton.setAttribute "disabled", "disabled"

  onCandidate: (candidate) ->
    rtcCandidate = new RTCIceCandidate JSON.parse candidate
    VC.peerConnection.addIceCandidate rtcCandidate
    VC.callButton.setAttribute "disabled", "disabled"

  createOffer: ->
    VC.peerConnection.createOffer (offer) ->
      VC.peerConnection.setLocalDescription offer
      VC.socket.emit "offer", JSON.stringify offer

  createAnswer: (offer) ->
    ->
      rtcOffer = new RTCSessionDescription JSON.parse offer
      VC.peerConnection.setRemoteDescription rtcOffer
      VC.peerConnection.createAnswer (answer) ->
        VC.peerConnection.setLocalDescription answer
        VC.socket.emit 'answer', JSON.stringify answer
        return
      , (error) ->
        alert "error", error
        return
      return

  onOffer: (offer) ->
    VC.socket.on "token", VC.onToken VC.createAnswer offer
    VC.socket.emit "token"

  onAnswer: (answer) ->
    rtcAnswer = new RTCSessionDescription JSON.parse answer
    VC.peerConnection.setRemoteDescription rtcAnswer

  onAddStream: (event) ->
    VC.remoteVideo = document.getElementById "remote-video"
    VC.remoteVideo.src = window.URL.createObjectURL event.stream

  sendText: (text) ->
    data = user: "Friend", text: text
    VC.socket.emit "message", data

  onMessage: (user, text) ->
    $(document.createElement("div"))
      .html("<strong>" + user + ": </strong>" + text)
      .appendTo("#messages");

      $('#messages-container').scrollTop($('#messages').height());

VC.videoButton = document.getElementById "get-video"
VC.videoButton.addEventListener "click", VC.requestMediaStream, false

VC.callButton = document.getElementById "call"
VC.callButton.addEventListener "click", VC.startCall, false

VC.socket.on "message", VC.onMessage
