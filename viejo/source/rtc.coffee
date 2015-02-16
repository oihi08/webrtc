
ICE_SERVERS =  "iceServers": [
    {
      url: 'turn:numb.viagenie.ca',
      credential: 'muazkh',
      username: 'webrtc@live.com'
  }, {
      url: 'turn:192.158.29.39:3478?transport=udp',
      credential: 'JZEOEt2V3Qb0y27GRntt2u2PAYA=',
      username: '28224511:1379330808'
  }, {
      url: 'turn:192.158.29.39:3478?transport=tcp',
      credential: 'JZEOEt2V3Qb0y27GRntt2u2PAYA=',
      username: '28224511:1379330808'
  }
]

iceServers = [];

iceServers.push({
    url: 'stun:stun.l.google.com:19302'
});

iceServers.push({
    url: 'stun:stun.anyfirewall.com:3478'
});

iceServers.push({
    url: 'turn:turn.bistri.com:80',
    credential: 'homeo',
    username: 'homeo'
});

iceServers.push({
    url: 'turn:turn.anyfirewall.com:443?transport=tcp',
    credential: 'webrtc',
    username: 'webrtc'
});

console.log "iceServers", iceServers
ICE_SERVERS =  "iceServers": iceServers

SDPCONTRAINS =
  optional: []
  mandatory: OfferToReceiveAudio: true, OfferToReceiveVideo: true

events = [ "offer", "answer", "ice", "connected", "hangUp", "error" ]

SOCKET_URL = "http://filmit.watch:8008"

class window.webRTC
  constructor: ->
    $("#login").click => @login()
    $("#call").click => @offer @_getUserInLocalStorage "friend"#@_getCamera friend=true
    $("#hangup").click => @hangup()

    @initialize()
    @socket = io.connect SOCKET_URL
    # window.turnserversDotComAPI.iceServers (data) =>
    #   @peer = new webkitRTCPeerConnection({ iceServers: data }, {})
    #   return
    @peer = new window.webkitRTCPeerConnection ICE_SERVERS, {}
    @peer.onicecandidate = (ice) =>
      if ice.candidate and not @offerer
        @peer.addIceCandidate @_iceCandidate(ice.candidate)
        @socket.emit "ice", @connected_user, ice

    @socket.on event, @["_#{event}"] for event in events

  initialize: ->
    @localVideo = document.getElementById "localVideo"
    @remoteVideo = document.getElementById "remoteVideo"
    localStorage.clear()
    @connected = false
    @connected_user = null

  login: ->
    session = $("#user").val()
    localStorage.setItem "session", session
    @socket.emit "open", session
    @_getCamera()

  hangup: ->
    @socket.emit "hangUp", @_getUserInLocalStorage "friend"
    @_close()

  offer: (user) ->
    @offerer = true
    @peer.createOffer((description) =>
      @peer.setLocalDescription description
      @socket.emit "offer", user, description
    , null, SDPCONTRAINS)

  accept: (user, remote_description) ->
    @offerer = false
    @peer.setRemoteDescription(@_sessionDescription(remote_description))
    @peer.createAnswer((description) =>
      console.log "netra aqiui"
      @peer.setLocalDescription description
      @socket.emit "answer", user, description
    , null, SDPCONTRAINS)

  onRemoteStream: (remote_stream) =>
    console.log "entra aqui"
    $(@remoteVideo).attr "src", window.URL.createObjectURL remote_stream
    $(@remoteVideo).addClass "active"

  _sessionDescription: (remote) ->
    session_description = RTCSessionDescription or mozRTCSessionDescription
    new session_description remote

  _iceCandidate: (candidate) ->
    ice_candidate = window.mozRTCIceCandidate or window.RTCIceCandidate
    new ice_candidate candidate

  _ice: (ice) =>
    if @offerer and ice.candidate
      @peer.addIceCandidate @_iceCandidate(ice.candidate)

  _connected: (friend) =>
    @connected = true
    if not @_getUserInLocalStorage "friend"
      localStorage.setItem "friend", friend
      @socket.emit "connected", @_getUserInLocalStorage "session"

  _hangUp: (friend) =>
    $(@remoteVideo).removeClass "active"
    @_close()

  _offer: (@message) =>
    @connected_user = @message.user
    $(@localVideo).addClass "active"
    @peer.info = @message
    console.log "ahhh"
    @accept @peer.info.user, @peer.info.description
    # @_getCamera()

  _answer: (data) =>
    @peer.setRemoteDescription @_sessionDescription(data.description)

  _error: (error) -> console.error "[ERROR] :: ", error

  _getUserInLocalStorage: (user) -> localStorage.getItem user

  _getCamera: (friend=null) ->
    if navigator.webkitGetUserMedia
      navigator.webkitGetUserMedia {video: true, audio: true}, (@local_stream) =>
        $(@localVideo)
          .attr "muted", true
          .attr "src", window.URL.createObjectURL @local_stream
        $(@localVideo).addClass "active"
        @peer.addStream @local_stream
        @peer.onaddstream = (event) => @onRemoteStream event.stream
        # if friend
        #   @offer @_getUserInLocalStorage "friend"
        # else
        #   console.log "@ss", @peer
          # @accept @peer.info.user, @peer.info.description
      , (error) -> console.log "error", error

  _close: ->
    if @peer then @peer.info = null
    @local_stream = null
    $(@localVideo).attr "src", null
    $(@remoteVideo).attr "src", null
    $(@localVideo).stop()
    $(@remoteVideo).stop()
    $(@localVideo).removeClass "active"

