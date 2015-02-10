var SDPCONTRAINS, SOCKET_URL, events,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

SDPCONTRAINS = {
  optional: [],
  mandatory: {
    OfferToReceiveAudio: true,
    OfferToReceiveVideo: true
  }
};

events = ["offer", "answer", "ice", "connected", "hangUp", "error"];

SOCKET_URL = "http://localhost:8008";

window.webRTC = (function() {

  function webRTC() {
    console.log("holaa")
    this._answer = __bind(this._answer, this);
    this._offer = __bind(this._offer, this);
    this._hangUp = __bind(this._hangUp, this);
    this._connected = __bind(this._connected, this);
    this._ice = __bind(this._ice, this);
    this.onRemoteStream = __bind(this.onRemoteStream, this);
    var event, _i, _len;
    $("#login").click((function(_this) {
      return function() {
        return _this.login();
      };
    })(this));
    $("#call").click((function(_this) {
      return function() {
        var friend;
        return _this._getCamera(friend = true);
      };
    })(this));
    $("#hangup").click((function(_this) {
      return function() {
        return _this.hangup();
      };
    })(this));
    this.initialize();
    this.socket = io.connect(SOCKET_URL);
    window.turnserversDotComAPI.iceServers((function(_this) {
      return function(data) {
        _this.peer = new webkitRTCPeerConnection({
          iceServers: data
        }, {});
      };
    })(this));
    this.peer.onicecandidate = (function(_this) {
      return function(ice) {
        console.log("ice", ice)
        if (ice.candidate && !_this.offerer) {
          _this.peer.addIceCandidate(_this._iceCandidate(ice.candidate));
          return _this.socket.emit("ice", _this.connected_user, ice);
        }
      };
    })(this);
    for (_i = 0, _len = events.length; _i < _len; _i++) {
      event = events[_i];
      this.socket.on(event, this["_" + event]);
    }
  }

  webRTC.prototype.initialize = function() {
    this.localVideo = document.getElementById("localVideo");
    this.remoteVideo = document.getElementById("remoteVideo");
    localStorage.clear();
    this.connected = false;
    return this.connected_user = null;
  };

  webRTC.prototype.login = function() {
    var session;
    session = $("#user").val();
    localStorage.setItem("session", session);
    return this.socket.emit("open", session);
  };

  webRTC.prototype.hangup = function() {
    this.socket.emit("hangUp", this._getUserInLocalStorage("friend"));
    return this._close();
  };

  webRTC.prototype.offer = function(user) {
    this.offerer = true;
    return this.peer.createOffer((function(_this) {
      return function(description) {
        _this.peer.setLocalDescription(description);
        return _this.socket.emit("offer", user, description);
      };
    })(this), null, SDPCONTRAINS);
  };

  webRTC.prototype.accept = function(user, remote_description) {
    this.offerer = false;
    this.peer.setRemoteDescription(this._sessionDescription(remote_description));
    return this.peer.createAnswer((function(_this) {
      return function(description) {
        _this.peer.setLocalDescription(description);
        return _this.socket.emit("answer", user, description);
      };
    })(this), null, SDPCONTRAINS);
  };

  webRTC.prototype.onRemoteStream = function(remote_stream) {
    $(this.remoteVideo).attr("src", window.URL.createObjectURL(remote_stream));
    return $(this.remoteVideo).addClass("active");
  };

  webRTC.prototype._sessionDescription = function(remote) {
    var session_description;
    session_description = RTCSessionDescription || mozRTCSessionDescription;
    return new session_description(remote);
  };

  webRTC.prototype._iceCandidate = function(candidate) {
    var ice_candidate;
    ice_candidate = window.mozRTCIceCandidate || window.RTCIceCandidate;
    return new ice_candidate(candidate);
  };

  webRTC.prototype._ice = function(ice) {
    if (this.offerer && ice.candidate) {
      return this.peer.addIceCandidate(this._iceCandidate(ice.candidate));
    }
  };

  webRTC.prototype._connected = function(friend) {
    this.connected = true;
    if (!this._getUserInLocalStorage("friend")) {
      localStorage.setItem("friend", friend);
      return this.socket.emit("connected", this._getUserInLocalStorage("session"));
    }
  };

  webRTC.prototype._hangUp = function(friend) {
    $(this.remoteVideo).removeClass("active");
    return this._close();
  };

  webRTC.prototype._offer = function(_at_message) {
    this.message = _at_message;
    this.connected_user = this.message.user;
    $(this.localVideo).addClass("active");
    this.peer.info = this.message;
    return this._getCamera();
  };

  webRTC.prototype._answer = function(data) {
    return this.peer.setRemoteDescription(this._sessionDescription(data.description));
  };

  webRTC.prototype._error = function(error) {
    return console.error("[ERROR] :: ", error);
  };

  webRTC.prototype._getUserInLocalStorage = function(user) {
    return localStorage.getItem(user);
  };

  webRTC.prototype._getCamera = function(friend) {
    if (friend == null) {
      friend = null;
    }
    if (navigator.webkitGetUserMedia) {
      return navigator.webkitGetUserMedia({
        video: true,
        audio: true
      }, (function(_this) {
        return function(_at_local_stream) {
          _this.local_stream = _at_local_stream;
          $(_this.localVideo).attr("muted", true).attr("src", window.URL.createObjectURL(_this.local_stream));
          $(_this.localVideo).addClass("active");
          _this.peer.addStream(_this.local_stream);
          _this.peer.onaddstream = function(event) {
            return _this.onRemoteStream(event.stream);
          };
          if (friend) {
            return _this.offer(_this._getUserInLocalStorage("friend"));
          } else {
            return _this.accept(_this.peer.info.user, _this.peer.info.description);
          }
        };
      })(this), function(error) {
        return console.log("error", error);
      });
    }
  };

  webRTC.prototype._close = function() {
    if (this.peer) {
      this.peer.info = null;
    }
    this.local_stream = null;
    $(this.localVideo).attr("src", null);
    $(this.remoteVideo).attr("src", null);
    $(this.localVideo).stop();
    $(this.remoteVideo).stop();
    return $(this.localVideo).removeClass("active");
  };

  return webRTC;

})();

// ---
// generated by coffee-script 1.9.0
