// Run StartVidyoConnector when the VidyoClient is successfully loaded
var iStartB;
var iFilter;
var iSave;

function StartVidyoConnector(VC) {
    var vidyoConnector;
    var cameras = {};
    var microphones = {};
    var speakers = {};
    var cameraPrivacy = false;
    var microphonePrivacy = false;
    var configParams = {};

    $("#options").removeClass("hidden");
    $("#optionsVisibilityButton").removeClass("hidden");
    $("#renderer").removeClass("hidden");
    
    VC.CreateVidyoConnector({
        viewId: "renderer", // Div ID where the composited video will be rendered, see VidyoConnectorSample.html
        viewStyle: "VIDYO_CONNECTORVIEWSTYLE_Default", // Visual style of the composited renderer
        remoteParticipants: 16,     // Maximum number of participants
        logFileFilter: "warning info@VidyoClient info@VidyoConnector",
        logFileName:"",
        userData:""
    }).then(function(vc) {
        vidyoConnector = vc;
        parseUrlParameters(configParams);
        registerDeviceListeners(vidyoConnector, cameras, microphones, speakers);
        handleDeviceChange(vidyoConnector, cameras, microphones, speakers);
        handleParticipantChange(vidyoConnector);

     // Populate the connectionStatus with the client version
        vidyoConnector.GetVersion().then(function(version) {
            //$("#clientVersion").html("v " + version);
        }).catch(function() {
            console.error("GetVersion failed");
        });

        // If enableDebug is configured then enable debugging
        if (configParams.enableDebug === "1") {
            vidyoConnector.EnableDebug({port:7776, logFilter: "warning info@VidyoClient info@VidyoConnector"}).then(function() {
                console.log("EnableDebug success");
            }).catch(function() {
                console.error("EnableDebug failed");
            });
        }

        // Join the conference if the autoJoin URL parameter was enabled
        if (configParams.autoJoin === "1") {
          joinLeave();
        } else {
          // Handle the join in the toolbar button being clicked by the end user.
          $("#joinLeaveButton").one("click", joinLeave);
        }
    }).catch(function(err) {
        console.error("CreateVidyoConnector Failed " + err);
    });

    // Handle the camera privacy button, toggle between show and hide.
    $("#cameraButton").click(function() {
        // CameraPrivacy button clicked
        cameraPrivacy = !cameraPrivacy;
        vidyoConnector.SetCameraPrivacy({
            privacy: cameraPrivacy
        }).then(function() {
            if (cameraPrivacy) {
                $("#cameraButton").addClass("cameraOff").removeClass("cameraOn");
            } else {
                $("#cameraButton").addClass("cameraOn").removeClass("cameraOff");
            }
            console.log("SetCameraPrivacy Success");
        }).catch(function() {
            console.error("SetCameraPrivacy Failed");
        });
    });

    // Handle the microphone mute button, toggle between mute and unmute audio.
    $("#microphoneButton").click(function() {
        // MicrophonePrivacy button clicked
        microphonePrivacy = !microphonePrivacy;
        vidyoConnector.SetMicrophonePrivacy({
            privacy: microphonePrivacy
        }).then(function() {
            if (microphonePrivacy) {
                $("#microphoneButton").addClass("microphoneOff").removeClass("microphoneOn");
            } else {
                $("#microphoneButton").addClass("microphoneOn").removeClass("microphoneOff");
            }
            console.log("SetMicrophonePrivacy Success");
        }).catch(function() {
            console.error("SetMicrophonePrivacy Failed");
        });
    });

    // Handle the options visibility button, toggle between show and hide options.
    $("#optionsVisibilityButton").click(function() {
        // OptionsVisibility button clicked
        if ($("#optionsVisibilityButton").hasClass("hideOptions")) {
            $("#options").addClass("hidden");
            $("#optionsVisibilityButton").addClass("showOptions").removeClass("hideOptions");
            $("#renderer").addClass("rendererFullScreen").removeClass("rendererWithOptions");
        } else {
            $("#options").removeClass("hidden");
            $("#optionsVisibilityButton").addClass("hideOptions").removeClass("showOptions");
            $("#renderer").removeClass("rendererFullScreen").addClass("rendererWithOptions");
        }
    });
    
    function joinLeave() {
        // join or leave dependent on the joinLeaveButton, whether it
        // contains the class callStart of callEnd.
        if ($("#joinLeaveButton").hasClass("callStart")) {
        	//$("#clientVersion").html("v " + version);
        	//$("#connectionStatus").html("Connecting...");
            $("#clientVersion").html("Connecting...");
            
            $("#joinLeaveButton").removeClass("callStart").addClass("callEnd");
            $('#joinLeaveButton').prop('title', 'Leave Conference');
//            iStartB = setInterval(startB,10000);
            iFilter = setInterval(filter,500);
            iSave = setInterval(saveText,600000);
            connectToConference(vidyoConnector);
        } else {
            $("#clientVersion").html("Disconnecting...");
            vidyoConnector.Disconnect().then(function() {
                console.log("Disconnect Success");
//                clearInterval(iStartB);
                clearInterval(iFilter);
                clearInterval(iSave);
                saveText();
            }).catch(function() {
                console.error("Disconnect Failure");
            });
        }
        $("#joinLeaveButton").one("click", joinLeave);
    }
}

function registerDeviceListeners(vidyoConnector, cameras, microphones, speakers) {
    // Map the "None" option (whose value is 0) in the camera, microphone, and speaker drop-down menus to null since
    // a null argument to SelectLocalCamera, SelectLocalMicrophone, and SelectLocalSpeaker releases the resource.
    cameras[0]     = null;
    microphones[0] = null;
    speakers[0]    = null;

    // Handle appearance and disappearance of camera devices in the system
    vidyoConnector.RegisterLocalCameraEventListener({
        onAdded: function(localCamera) {
            // New camera is available
            $("#cameras").append("<option value='" + window.btoa(localCamera.id) + "'>" + localCamera.name + "</option>");
            cameras[window.btoa(localCamera.id)] = localCamera;
        },
        onRemoved: function(localCamera) {
            // Existing camera became unavailable
            $("#cameras option[value='" + window.btoa(localCamera.id) + "']").remove();
            delete cameras[window.btoa(localCamera.id)];
        },
        onSelected: function(localCamera) {
            // Camera was selected/unselected by you or automatically
            if(localCamera) {
                $("#cameras option[value='" + window.btoa(localCamera.id) + "']").prop('selected', true);
            }
        },
        onStateUpdated: function(localCamera, state) {
            // Camera state was updated
        }
    }).then(function() {
        console.log("RegisterLocalCameraEventListener Success");
    }).catch(function() {
        console.error("RegisterLocalCameraEventListener Failed");
    });

 // Handle appearance and disappearance of microphone devices in the system
    vidyoConnector.RegisterLocalMicrophoneEventListener({
        onAdded: function(localMicrophone) {
            // New microphone is available
            $("#microphones").append("<option value='" + window.btoa(localMicrophone.id) + "'>" + localMicrophone.name + "</option>");
            microphones[window.btoa(localMicrophone.id)] = localMicrophone;
        },
        onRemoved: function(localMicrophone) {
            // Existing microphone became unavailable
            $("#microphones option[value='" + window.btoa(localMicrophone.id) + "']").remove();
            delete microphones[window.btoa(localMicrophone.id)];
        },
        onSelected: function(localMicrophone) {
            // Microphone was selected/unselected by you or automatically
            if(localMicrophone)
                $("#microphones option[value='" + window.btoa(localMicrophone.id) + "']").prop('selected', true);
        },
        onStateUpdated: function(localMicrophone, state) {
            // Microphone state was updated
        }
    }).then(function() {
        console.log("RegisterLocalMicrophoneEventListener Success");
    }).catch(function() {
        console.error("RegisterLocalMicrophoneEventListener Failed");
    });

 // Handle appearance and disappearance of speaker devices in the system
    vidyoConnector.RegisterLocalSpeakerEventListener({
        onAdded: function(localSpeaker) {
            // New speaker is available
            $("#speakers").append("<option value='" + window.btoa(localSpeaker.id) + "'>" + localSpeaker.name + "</option>");
            speakers[window.btoa(localSpeaker.id)] = localSpeaker;
        },
        onRemoved: function(localSpeaker) {
            // Existing speaker became unavailable
            $("#speakers option[value='" + window.btoa(localSpeaker.id) + "']").remove();
            delete speakers[window.btoa(localSpeaker.id)];
        },
        onSelected: function(localSpeaker) {
            // Speaker was selected/unselected by you or automatically
            if(localSpeaker)
                $("#speakers option[value='" + window.btoa(localSpeaker.id) + "']").prop('selected', true);
        },
        onStateUpdated: function(localSpeaker, state) {
            // Speaker state was updated
        }
    }).then(function() {
        console.log("RegisterLocalSpeakerEventListener Success");
    }).catch(function() {
        console.error("RegisterLocalSpeakerEventListener Failed");
    });
}

function handleDeviceChange(vidyoConnector, cameras, microphones, speakers) {
    // Hook up camera selector functions for each of the available cameras
    $("#cameras").change(function() {
        // Camera selected from the drop-down menu
        $("#cameras option:selected").each(function() {
            camera = cameras[$(this).val()];
            vidyoConnector.SelectLocalCamera({
                localCamera: camera
            }).then(function() {
                console.log("SelectCamera Success");
            }).catch(function() {
                console.error("SelectCamera Failed");
            });
        });
    });

    // Hook up microphone selector functions for each of the available microphones
    $("#microphones").change(function() {
        // Microphone selected from the drop-down menu
        $("#microphones option:selected").each(function() {
            microphone = microphones[$(this).val()];
            vidyoConnector.SelectLocalMicrophone({
                localMicrophone: microphone
            }).then(function() {
                console.log("SelectMicrophone Success");
            }).catch(function() {
                console.error("SelectMicrophone Failed");
            });
        });
    });

    // Hook up speaker selector functions for each of the available speakers
    $("#speakers").change(function() {
        // Speaker selected from the drop-down menu
        $("#speakers option:selected").each(function() {
            speaker = speakers[$(this).val()];
            vidyoConnector.SelectLocalSpeaker({
                localSpeaker: speaker
            }).then(function() {
                console.log("SelectSpeaker Success");
            }).catch(function() {
                console.error("SelectSpeaker Failed");
            });
        });
    });
}

function getParticipantName(participant, cb) {
    if (!participant) {
        cb("Undefined");
        return;
    }

    if (participant.name) {
        cb(participant.name);
        return;
    }

    participant.GetName().then(function(name) {
        cb(name);
    }).catch(function() {
        cb("GetNameFailed");
    });
}

var confText='Conference Start';

function myText(id, lang, myTexts){
	var userid = id;
	var original = myTexts;
	var selectLang;
	var userLang = lang;
	if(userLang=="ko"){
	  selectLang="ja";
	}else if(userLang=="ja"){
	  selectLang="ko";
	}
	var myData = {"userLanguage":selectLang, "inputText":original};
	$.ajax({
		method:"get"
		,url:"translate"
		,data:myData
		,success:function(resp){
			confText = confText+"<br>"+id+":"+myText;
			confText = confText+"<br>"+id+":"+resp;
			//readMSG();
		}
	});
}

function myMic(id, myText){
	var selectLang;
	var userLang = $("#language").val();
	if(userLang=="ko"){
	  selectLang="ja";
	}else if(userLang=="ja"){
	  selectLang="ko";
	}
	var myData = {"userLanguage":selectLang, "inputText":myText};
	$.ajax({
		method:"get"
		,url:"translate"
		,data:myData
		,success:function(resp){
			confText = confText+"<br>"+id+":"+myText;
			confText = confText+"<br>"+id+":"+resp;
			//readMSG();
		}
	});
}

//function readMSG(){
//	$.ajax({
//		method:"get"
//		,url:"saveChat"
//		,data:{"saveChat":confText,"sw":"0"}
//	});
//	$("#record").html(confText);
//	chat();
//}


function saveText(){
	$.ajax({
		method:"post"
		,url:"saveText"
		,data:{"confText":confText}
	});
}



function handleParticipantChange(vidyoConnector) {
	
	// message
	vidyoConnector.RegisterMessageEventListener({
		  onChatMessageReceived: function(participant, chatMessage) { /*Message received from other participant */ 
			  //startButton(event);
			  getParticipantName(participant, function(name) {
				var selectLang;
				var userLang = $("#language").val();
				if(userLang=="ko"){
				  selectLang="ko";
				}else if(userLang=="ja"){
				  selectLang="ja";
				}
								
				var sum="";
			    var res = chatMessage.body.split(" ");
			    
			    for(var i=0; i<res.length;i++){
			    	var strs = res[i].substr(0,3);
			    	if(strs=="www"){
			            res[i] = "<a href='http://"+res[i]+"' target='_blank'>"+res[i]+"</a>"
			        };
			        sum += res[i]+" ";
			    }
				
			    var originalText=sum;
//				var originalText=chatMessage.body;
				var header = originalText.split("<mmm>",2);
				var myData = {userLanguage:userLang, inputText:header[1]};					
				$.ajax({
					method:"get"
					,url:"translate"
					,data:myData
					,success:function(resp){
						confText = confText+"<br>"+name+":"+originalText;
						confText = confText+"<br>"+name+":"+resp;
						//$("#record").html(confText);
						if(header[0]=="msg"){
//							var sum="";
//						    var res = resp.split(" ");
//						    for(var i=0; i<res.length;i++){
//						    	var strs = res[i].substr(0,3);
//						    	if(strs=="www"){
//						            res[i] = "<a href='https://"+res[i]+"' target='_blank'>"+res[i]+"</a>"
//						        };
//						        sum += res[i]+" ";
//						    }
							$("#connectionStatus").html(name+":"+resp);
						}else{
							var yy = $(".guest").attr("id");
							var head = yy.split("_",1);
							for (var i=0; i<9 ; i++) {
								var divId = head+"_renderer_vidyoRemoteName"+String(i);
								var userId = $("#"+divId).html();
								var head2 = userId.split(":",1);
								if(head2 == name){
									$("#"+divId).html(name+":"+resp);
									break;
								};
							}
						}
					}
				});
		      });
		  }
		}).then(function() {
		  console.log("RegisterParticipantEventListener Success");
		}).catch(function() {
		  console.err("RegisterParticipantEventListener Failed");
		});
    
	
	vidyoConnector.RegisterParticipantEventListener({
        onJoined: function(participant) {
            getParticipantName(participant, function(name) {
                $("#participantStatus").html("" + name + " Joined");
            });
        },
        onLeft: function(participant) {
            getParticipantName(participant, function(name) {
                $("#participantStatus").html("" + name + " Left");
            });
        },
        onDynamicChanged: function(participants, cameras) {
            // Order of participants changed
        },
        onLoudestChanged: function(participant, audioOnly) {
            getParticipantName(participant, function(name) {
                $("#participantStatus").html("" + name + " Speaking");
            });
        }
    }).then(function() {
        console.log("RegisterParticipantEventListener Success");
    }).catch(function() {
        console.err("RegisterParticipantEventListener Failed");
    });
}

function parseUrlParameters(configParams) {
    // Fill in the form parameters from the URI
    var host = getUrlParameterByName("host");
    if (host)
        $("#host").val(host);
    var token = getUrlParameterByName("token");
    if (token)
        $("#token").val(token);
    var displayName = getUrlParameterByName("displayName");
    if (displayName)
        $("#displayName").val(displayName);
    var resourceId = getUrlParameterByName("resourceId");
    if (resourceId)
        $("#resourceId").val(resourceId);
    configParams.autoJoin    = getUrlParameterByName("autoJoin");
    configParams.enableDebug = getUrlParameterByName("enableDebug");
    var hideConfig = getUrlParameterByName("hideConfig");

    // If the parameters are passed in the URI, do not display options dialog
    if (host && token && displayName && resourceId) {
        $("#optionsParameters").addClass("hiddenPermanent");
    }

    if (hideConfig=="1") {
        $("#options").addClass("hiddenPermanent");
        $("#optionsVisibilityButton").addClass("hiddenPermanent");
        $("#renderer").addClass("rendererFullScreenPermanent");
    }

    return;
}

// Attempt to connect to the conference
// We will also handle connection failures
// and network or server-initiated disconnects.
function connectToConference(vidyoConnector) {
    // Clear messages
    $("#error").html("");
    $("#message").html("<h3 class='blink'>CONNECTING...</h3>");

    vidyoConnector.Connect({
        // Take input from options form
        host: $("#host").val(),
        token: $("#token").val(),
        displayName: $("#displayName").val(),
        resourceId: $("#resourceId").val(),

        // Define handlers for connection events.
        onSuccess: function() {
            // Connected
            console.log("vidyoConnector.Connect : onSuccess callback received");
            $("#clientVersion").html("Connected");
            $("#options").addClass("hidden");
            $("#optionsVisibilityButton").addClass("showOptions").removeClass("hideOptions");
            $("#renderer").addClass("rendererFullScreen").removeClass("rendererWithOptions");
            $("#message").html("");
        },
        onFailure: function(reason) {
            // Failed
            console.error("vidyoConnector.Connect : onFailure callback received");
            connectorDisconnected("Failed", "");
            $("#error").html("<h3>Call Failed: " + reason + "</h3>");
        },
        onDisconnected: function(reason) {
            // Disconnected
            console.log("vidyoConnector.Connect : onDisconnected callback received");
            connectorDisconnected("Disconnected", "Call Disconnected: " + reason);

            $("#options").removeClass("hidden");
            $("#optionsVisibilityButton").addClass("hideOptions").removeClass("showOptions");
            $("#renderer").removeClass("rendererFullScreen").addClass("rendererWithOptions");
        }
    }).then(function(status) {
        if (status) {
            console.log("Connect Success");
        } else {
            console.error("Connect Failed");
            connectorDisconnected("Failed", "");
            $("#error").html("<h3>Call Failed" + "</h3>");
        }
    }).catch(function() {
        console.error("Connect Failed");
        connectorDisconnected("Failed", "");
        $("#error").html("<h3>Call Failed" + "</h3>");
    });
}
  
// Connector either fails to connect or a disconnect completed, update UI elements
function connectorDisconnected(connectionStatus, message) {
    $("#clientVersion").html(connectionStatus);
    $("#message").html(message);
    $("#participantStatus").html("");
    $("#joinLeaveButton").removeClass("callEnd").addClass("callStart");
    $('#joinLeaveButton').prop('title', 'Join Conference');
}

// Extract the desired parameter from the browser's location bar
function getUrlParameterByName(name) {
    var match = RegExp('[?&]' + name + '=([^&]*)').exec(window.location.search);
    return match && decodeURIComponent(match[1].replace(/\+/g, ' '));
}
