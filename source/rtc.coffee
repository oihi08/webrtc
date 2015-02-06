# https://code.google.com/p/natvpn/source/browse/trunk/stun_server_list (DE AQUÍ HE SACADO LA LISTA DE STUNS SERVERS)
ICE_SERVERS =  "iceServers" : [{ "url" :
        if navigator.mozGetUserMedia then 'stun:stun.services.mozilla.com' else if navigator.webkitGetUserMedia then 'stun:stun.l.google.com:19302' else 'stun:23.21.150.121'
    },
        {url: "stun:stun.l.google.com:19302"},
        {url: "stun:stun1.l.google.com:19302"},
        {url: "stun:stun2.l.google.com:19302"},
        {url: "stun:stun3.l.google.com:19302"},
        {url: "stun:stun4.l.google.com:19302"},
        {url: "stun:23.21.150.121"},
        {url: "stun:stun01.sipphone.com"},
        {url: "stun:stun.ekiga.net"},
        {url: "stun:stun.fwdnet.net"},
        {url: "stun:stun.ideasip.com"},
        {url: "stun:stun.iptel.org"},
        {url: "stun:stun.rixtelecom.se"},
        {url: "stun:stun.schlund.de"},
        {url: "stun:stunserver.org"},
        {url: "stun:stun.softjoys.com"},
        {url: "stun:stun.voiparound.com"},
        {url: "stun:stun.voipbuster.com"},
        {url: "stun:stun.voipstunt.com"},
        {url: "stun:stun.voxgratia.org"},
        {url: "stun:stun.xten.com"}
    ]

OPTIONS      = "optional"  : [{"RtpDataChannels": true }]

SDPCONTRAINS =
  optional: []
  mandatory: OfferToReceiveAudio: true, OfferToReceiveVideo: true

events = [ "offer", "answer", "ice", "connected", "hangUp", "error" ]

SOCKET_URL = "http://localhost:8008"

class window.webRTC
  constructor: ->
    $("#login").click => @login()
    $("#call").click => @_getCamera friend=true
    $("#hangup").click => @hangup()

    @initialize()
    @socket = io.connect SOCKET_URL
    @peer = new window.webkitRTCPeerConnection ICE_SERVERS, OPTIONS
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
      @peer.setLocalDescription description
      @socket.emit "answer", user, description
    , null, SDPCONTRAINS)

  onRemoteStream: (remote_stream) =>
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
    @_getCamera()

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
        if friend
          @offer @_getUserInLocalStorage "friend"
        else
          @accept @peer.info.user, @peer.info.description
      , (error) -> console.log "error", error

  _close: ->
    if @peer then @peer.info = null
    @local_stream = null
    $(@localVideo).attr "src", null
    $(@remoteVideo).attr "src", null
    $(@localVideo).stop()
    $(@remoteVideo).stop()
    $(@localVideo).removeClass "active"

