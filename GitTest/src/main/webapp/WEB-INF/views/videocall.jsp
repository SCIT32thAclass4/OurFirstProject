<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>

<title>Conference</title>

<style>
#sentMSG{
	position:absolute;
	bottom:3px;
	text-align:left;
	width:145px;
}
</style>

	<meta name="viewport" content="width=device-width, initial-scale=1">
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	<script src="https://code.jquery.com/jquery-3.1.1.min.js" integrity="sha256-hVVnYaiADRTO2PzUGmuLJr8BLUSjGIZsDYGmIJLv2b8=" crossorigin="anonymous"></script>
	<script>
	$(function(){
		$.ajax({
			 type : "get"
		     , url : "logoutCheck"
		     , success : function(data) {
		    	 if(data != "true") {
		    		 location.href = "login";
		    	 }
		     }
		});
	});

	$(function(){
		$.ajax({
			 type : "get"
		     , url : "lockCheck"
		     , success : function(data) {
		    	 if(data != "true") {
		    		 location.href = "lockscreen";
		    	 }
		     }
		});
	});
	</script>
	<!-- We've provide some simple styling to get you started. -->
	<link   href="resources/Vidyo/VidyoConnector.css" rel="stylesheet" type="text/css" >

	<!-- Here we load the application which knows how to
	invoke the VidyoConnector API. -->
	<script src="resources/Vidyo/VidyoConnector.js"></script>
	<script type="text/javascript">
	function onVidyoClientLoaded(status) {
		console.log("Status: " + status.state + "Description: " + status.description);
		switch (status.state) {
			case "READY":    // The library is operating normally
				$("#clientVersion").html("Ready to Connect");
				$("#helper").addClass("hidden");
				// After the VidyoClient is successfully initialized a global VC object will become available
				// All of the VidyoConnector gui and logic is implemented in VidyoConnector.js
				StartVidyoConnector(VC);
				break;
			case "RETRYING": // The library operating is temporarily paused
				$("#clientVersion").html("Temporarily unavailable retrying in " + status.nextTimeout/1000 + " seconds");
				break;
			case "FAILED":   // The library operating has stopped
				ShowFailed(status);
				$("#clientVersion").html("Failed: " + status.description);
				break;
			case "FAILEDVERSION":   // The library operating has stopped
				UpdateHelperPaths(status);
				ShowFailedVersion(status);
				$("#clientVersion").html("Failed: " + status.description);
				break;
			case "NOTAVAILABLE": // The library is not available
				UpdateHelperPaths(status);
				$("#clientVersion").html(status.description);
				break;
		}
		return true; // Return true to reload the plugins if not available
	}
	function UpdateHelperPaths(status) {
		$("#helperPlugInDownload").attr("href", status.downloadPathPlugIn);
		$("#helperAppDownload").attr("href", status.downloadPathApp);
	}
	function ShowFailed(status) {
		var helperText = '';
		 // Display the error
		helperText += '<h2>An error occurred, please reload</h2>';
		helperText += '<p>' + status.description + '</p>';

		$("#helperText").html(helperText);
		$("#failedText").html(helperText);
		$("#failed").removeClass("hidden");
	}
	function ShowFailedVersion(status) {
		var helperText = '';
		 // Display the error
		helperText += '<h4>Please Download a new plugIn and restart the browser</h4>';
		helperText += '<p>' + status.description + '</p>';

		$("#helperText").html(helperText);
	}

	function loadVidyoClientLibrary(webrtc, plugin) {
		//We need to ensure we're loading the VidyoClient library and listening for the callback.
		var script = document.createElement('script');
		script.type = 'text/javascript';
		script.src = 'https://static.vidyo.io/4.1.11.4/javascript/VidyoClient/VidyoClient.js?onload=onVidyoClientLoaded&webrtc=' + webrtc + '&plugin=' + plugin;    
		document.getElementsByTagName('head')[0].appendChild(script);
	}
	function joinViaBrowser() {
		$("#helperText").html("Loading...");
		$("#helperPicker").addClass("hidden");
		loadVidyoClientLibrary(true, false);
	}

	function joinViaPlugIn() {
		$("#helperText").html("Don't have the PlugIn?");
		$("#helperPicker").addClass("hidden");
		$("#helperPlugIn").removeClass("hidden");
		loadVidyoClientLibrary(false, true);
	}

	function joinViaApp() {
		$("#helperText").html("Don't have the app?");
		$("#helperPicker").addClass("hidden");
		$("#helperApp").removeClass("hidden");
		var protocolHandlerLink = 'vidyoconnector://' + window.location.search;
		/* launch */
		$("#helperAppLoader").attr('src', protocolHandlerLink);
		loadVidyoClientLibrary(false, false);
	}

	function joinViaOtherApp() {
		$("#helperText").html("Don't have the app?");
		$("#helperPicker").addClass("hidden");
		$("#helperOtherApp").removeClass("hidden");
		var protocolHandlerLink = 'vidyoconnector://' + window.location.search;
		/* launch */
		$("#helperOtherAppLoader").attr('src', protocolHandlerLink);
		loadVidyoClientLibrary(false, false);
	}

	function loadHelperOptions() {
		var userAgent = navigator.userAgent || navigator.vendor || window.opera;

		// Opera 8.0+
		var isOpera = (userAgent.indexOf("Opera") || userAgent.indexOf('OPR')) != -1 ;
		// Firefox
		var isFirefox = userAgent.indexOf("Firefox") != -1;
		// Chrome 1+
		var isChrome = userAgent.indexOf("Chrome") != -1;
		// Safari
		var isSafari = !isChrome && userAgent.indexOf("Safari") != -1;
		// AppleWebKit
		var isAppleWebKit = !isSafari && !isChrome && userAgent.indexOf("AppleWebKit") != -1;
		// Internet Explorer 6-11
		var isIE = (userAgent.indexOf("MSIE") != -1 ) || (!!document.documentMode == true );
		// Edge 20+
		var isEdge = !isIE && !!window.StyleMedia;
		// Check if Mac
		var isMac = navigator.platform.indexOf('Mac') > -1;
		// Check if Windows
		var isWin = navigator.platform.indexOf('Win') > -1;
		// Check if Linux
		var isLinux = navigator.platform.indexOf('Linux') > -1;
		// Check if Android
		var isAndroid = userAgent.indexOf("android") > -1;

		if (!isMac && !isWin && !isLinux) {
			/* Mobile App*/
			if (isAndroid) {
				$("#joinViaApp").removeClass("hidden");
			} else {
				$("#joinViaOtherApp").removeClass("hidden");
			}
			if (isChrome) {
				/* Supports WebRTC */
				$("#joinViaBrowser").removeClass("hidden");
			}
		} else {
			/* Desktop App */
			$("#joinViaApp").removeClass("hidden");

			if (isChrome || isFirefox) {
				/* Supports WebRTC */
				$("#joinViaBrowser").removeClass("hidden");
			}
			if (isSafari || isFirefox || (isAppleWebKit && isMac) || (isIE && !isEdge)) {
				/* Supports Plugins */
				$("#joinViaPlugIn").removeClass("hidden");
			}
		}
	}
	
	 // Get voice
	var transcriptSent = '';
   var transcriptOld = '';
   var transcriptNew = '';
   var recognizing = false;
   var ignore_onend;
   var start_timestamp;
   var recognition;

   if (!('webkitSpeechRecognition' in window)) {
      //upgrade();
   } else {
      recognition = new webkitSpeechRecognition();
      recognition.continuous = true;
      recognition.interimResults = true;
      recognition.onstart = function() {
         recognizing = true;
         $("#messages").html("speaking now");
      };
      recognition.onerror = function(event) {
         if (event.error == 'no-speech') {
            $("#messages").html("no-speech");
         }
         if (event.error == 'audio-capture') {
            $("#messages").html("no microphone");
         }
      };
      recognition.onend = function() {
         recognizing = false;
         if (ignore_onend) {
            return;
         }
         if (!transcriptNew) {
            return;
         }
      };
      recognition.onresult = function(event) {
         var interim_transcript = '';
         for (var i = event.resultIndex; i < event.results.length; ++i) {
            if (event.results[i].isFinal) {
               transcriptNew = event.results[i][0].transcript;
            } else {
               transcriptNew = event.results[i][0].transcript;
            }
         }
         transcriptNew = capitalize(transcriptNew);
      };
      
   }
   function filter(){
      if(transcriptOld == transcriptNew){
         if(transcriptSent == transcriptOld){
            return;
         }else{
        	myMic($("#displayName").val(), transcriptOld);
            vidyoConnector.SendChatMessage("voice<mmm>"+transcriptOld);
            transcriptSent = transcriptOld;
         }
      }else{
         transcriptOld = transcriptNew;
      }
   }
   
	var two_line = /\n\n/g;
	var one_line = /\n/g;
	function linebreak(s) {
		return s.replace(two_line, '<p></p>').replace(one_line, '<br>');
	}
	var first_char = /\S/;
	function capitalize(s) {
		return s.replace(first_char, function(m) {
			return m.toUpperCase();
		});
	}

	function startButton(event) {
		var userLanguage = $("#language").val();
		if (recognizing) {
			recognition.stop();
			return;
		}
		final_transcript = '';
		if (userLanguage == 'ko') {
			recognition.lang = 'ko-KR';
		} else if (userLanguage == 'ja') {
			recognition.lang = 'ja-JP';
		}
		;
		recognition.start();
		ignore_onend = false;
	}
	var current_style;
	function showButtons(style) {
		if (style == current_style) {
			return;
		}
		current_style = style;
	}
	
	
	// Runs when the page loads
	$(function() {
			joinViaBrowser();
	});
	
	function startB(){
		startButton(event);
	};
	
	
	function keydown(){
		if(event.keyCode=="107"){
			startButton(event);
		}
	};
	
	function insertTextFile(){
		$.ajax({
		  	type : "post"
		    , url : "insertTextFile"
		    , success : function(data) {
		    	alert("complete");
		    }
		});
	}

	//Sending Message
	function sendingMSG(){
		var userN = $("#displayName").val();
		var lang = $("#language1").val();
		var msg = $("#sentMSG").val();
		myText(userN, lang, msg);
		vidyoConnector.SendChatMessage("msg<mmm>"+msg);
		
		$("#sentMSG").val("");
	};
	
	</script>
</head>

<!-- We execute the VidyoConnectorApp library on page load
to hook up all of the events to elements. -->
<body id="vidyoConnector" onkeydown="keydown()">

	<!-- This button toggles the visibility of the options. -->
	<button id="optionsVisibilityButton" title="Toggle Options" class="optionsVisibiliyButtonElements hideOptions hidden"></button>

	<div id="options" class="hidden">
		<a href="main"><img class="logo" src="resources/assets/images/miyou.png" /></a>

		<form>
		<div id="optionsParameters">
		<p>
			<!-- The host of our backend service. -->
			<!-- <label>Host</label> -->
			<input type="hidden" id="host" value="prod.vidyo.io">
		</p>
		<p>
			<!-- A token that is derived from the deveoper key assigned to your account which will allow access for this particular instance.
			The token will contain user ID, expiration date and an optional vCard of the user.
			For test purposes, you can skip this and just insert anything you like, but your video sessions will be limited by duration.
			For more information visit the developer section of http://vidyo.io -->
			<!-- <label>Token</label> -->
			<input type="hidden" id="token" placeholder="ACCESS-TOKEN" value="${token}">
		</p>
		<p>
			<!-- This is the display name that other users will see.
			-->
			<label for="displayName">User Name</label>
			<input id="displayName" type="text" placeholder="Display Name" value="${user.name}"> 
		</p>
		<p>
			<!-- This is the "room" or "space" to which you're connecting
			the user. Other users who join this same Resource will be able to see and hear each other.
			-->
			<label for="resourceId">Conference ID</label>
			<input id="resourceId" type="text" placeholder="Conference Reference" value="${roomNum}">
		</p>
		</div>
		<p>
			<!-- On page load, this input is filled with a list of all the available cameras on the user's system. -->
			<label for="cameras">Cameras</label>
			<select id="cameras">
				<option value='0'>None</option>
			</select>
		</p>
		<p>
			<!-- On page load, this input is filled with a list of all the available microphones on the user's system. -->
			<label for="microphones">Microphones</label>
			<select id="microphones">
				<option value='0'>None</option>
			</select>
		</p>
		<p>
			<!-- On page load, this input is filled with a list of all the available microphones on the user's system. -->
			<label for="speakers">Speakers</label>
			<select id="speakers">
				<option value='0'>None</option>
			</select>
		</p>
		</form>
		<div id="messages">
			<!-- All Vidyo-related messages will be inserted into these spans. -->
			<span id="error"></span>
			<span id="message"></span>
		</div>
	</div>
	<!-- This is the div into which the Vidyo component will be inserted. -->
	<div id="renderer" class="rendererWithOptions pluginOverlay hidden">
	</div>
	<div id="toolbar">
		<span id="participantStatus"></span>

		<div id="mytext"></div>

		<!-- This button toggles the camera privacy on or off. -->
		<button id="cameraButton" title="Camera Privacy" class="toolbarButton cameraOn"></button>

		<!-- This button joins and leaves the conference. -->
		<button id="joinLeaveButton" title="Join Conference" class="toolbarButton callStart"></button>

		<!-- This button mutes and unmutes the users' microphone. -->
		<button id="microphoneButton" title="Microphone Privacy" class="toolbarButton microphoneOn"></button>

		<!-- 안건 요약 보기 -->
		<input type="button" title="Topic List" class="toolbarButton topic" onclick="<c:if test="${conf_num == null}">javascript:alert('Nothing found.');</c:if><c:if test="${conf_num != null}">javascript:window.open('confSummary', '', 'width=355,height=420');</c:if>">
		
		<!-- 메모 열기 -->
		<input type="button" title="Memo" class="toolbarButton memo" onclick="javascript:window.open('memo', '', 'width=400,height=390,resizable=no');">
		
		<!-- 채팅창 열기 -->
		<input type="text" id="sentMSG" placeholder="Sending message..." size="41" autofocus="autofocus" onkeypress="if(event.keyCode==13) {sendingMSG();}">
		<!-- <input type="button" title="Chat" class="toolbarButton chatMessage" onclick="chat()"> -->

		<input type="hidden" id="language" value="${user.language}">
		
		<span id="connectionStatus"></span>

		<span id="clientVersion"></span>
	</div>
	<div id="helper">
		<table>
		<tr>
			<td><img class="logo" src="resources/assets/images/miyou.png"/></td>
		</tr>
		<tr>
			<td id="helperText">How would you like to join the call?</td>
		</tr>
		<tr id="helperPicker">
			<td >
				<table>
				<tr>
					<td id="joinViaBrowser" class="hidden">
						<div class="helperHeader">
							<img src="resources/Vidyo/Images/web.svg" onclick="javascript:joinViaBrowser()"/>
						</div>
						<ul>
							<li class="helperCheck"><img src="resources/Vidyo/Images/checkmark.svg"/>&nbsp;&nbsp;
								Join the call immediately
							</li>
							<li class="helperCheck"><img src="resources/Vidyo/Images/checkmark.svg"/>&nbsp;&nbsp;
								No downloads or installations
							</li>
							<li class="helperCheck"><img src="resources/Vidyo/Images/checkmark.svg"/>&nbsp;&nbsp;
								Good quality
							</li>
						</ul>
						<div class="helperFooter">
							<a href="javascript:joinViaBrowser()">Join via the browser</a>
						</div>
					</td>
					<td id="joinViaPlugIn" class="hidden">
						<div class="helperHeader">
							<img src="resources/Vidyo/Images/download.svg" onclick="javascript:joinViaPlugIn()"/>
						</div>
						<ul>
							<li class="helperCheck"><img src="resources/Vidyo/Images/checkmark.svg"/>&nbsp;&nbsp;
								Join meetings right from the browser
							</li>
							<li class="helperCheck"><img src="resources/Vidyo/Images/checkmark.svg"/>&nbsp;&nbsp;
								Share seamlessly without extensions
							</li>
							<li class="helperCheck"><img src="resources/Vidyo/Images/checkmark.svg"/>&nbsp;&nbsp;
								Best quality
							</li>
						</ul>
						<div class="helperFooter">
							<a href="javascript:joinViaPlugIn()">Join via the plugin</a>
						</div>
					</td>
					<td id="joinViaApp" class="hidden">
						<div class="helperHeader">
							<img src="resources/Vidyo/Images/desktop.svg" onclick="javascript:joinViaApp()"/>
						</div>
						<ul>
							<li class="helperCheck"><img src="resources/Vidyo/Images/checkmark.svg"/>&nbsp;&nbsp;
								Join meetings faster with fewer clicks
							</li>
							<li class="helperCheck"><img src="resources/Vidyo/Images/checkmark.svg"/>&nbsp;&nbsp;
								Share seamlessly without extensions
							</li>
							<li class="helperCheck"><img src="resources/Vidyo/Images/checkmark.svg"/>&nbsp;&nbsp;
								Best quality
							</li>
						</ul>
						<div class="helperFooter">
							<a href="javascript:joinViaApp()">Join via the app</a>
						</div>
                    </td>
					<td id="joinViaOtherApp" class="hidden">
						<div class="helperHeader">
							<img src="resources/Vidyo/Images/download.svg" onclick="javascript:joinViaOtherApp()"/>
						</div>
						<ul>
							<li class="helperCheck"><img src="resources/Vidyo/Images/checkmark.svg"/>&nbsp;&nbsp;
								Join from any device
							</li>
							<li class="helperCheck"><img src="resources/Vidyo/Images/checkmark.svg"/>&nbsp;&nbsp;
								Best quality
							</li>
						</ul>
						<div class="helperFooter">
							<a href="javascript:joinViaOtherApp()">Join via the app</a>
						</div>
                    </td>
				</tr>
				</table>
			</td>
		</tr>
		<tr id="helperPlugIn" class="hidden">
			<td>
				<div class="helperHeader">
					<img src="resources/Vidyo/Images/download.svg" onclick="javascript:joinViaBrowser()"/>
				</div>
				<ul>
					<li class="helperCheck"><img src="resources/Vidyo/Images/checkmark.svg"/>&nbsp;&nbsp;
						Download and install it now
					</li>
					<li class="helperCheck"><img src="resources/Vidyo/Images/checkmark.svg"/>&nbsp;&nbsp;
						The plugin will launch automatically once installed
					</li>
				</ul>
				<div class="helperFooter">
					<a id="helperPlugInDownload" href="">Download</a>
				</div>
			</td>
		</tr>
		<tr id="helperApp" class="hidden">
			<td>
				<div class="helperHeader">
					<img src="resources/Vidyo/Images/download.svg" onclick="javascript:joinViaApp()"/>
				</div>
				<div><iframe id="helperAppLoader" src="" class="hidden"></iframe></div>
				<ul>
					<li class="helperCheck"><img src="resources/Vidyo/Images/checkmark.svg"/>&nbsp;&nbsp;
						Download and install it now
					</li>
					<li class="helperCheck"><img src="resources/Vidyo/Images/checkmark.svg"/>&nbsp;&nbsp;
						Launch once installed
					</li>
				</ul>
				<div class="helperFooter">
					<a id="helperAppDownload" href="">Download</a>
					<a href="javascript:joinViaApp()">Launch</a>
				</div>
			</td>
		</tr>
		<tr id="helperOtherApp" class="hidden">
			<td>
				<div class="helperHeader">
					<img src="resources/Vidyo/Images/download.svg" onclick="javascript:joinViaOtherApp()"/>
				</div>
				<div><iframe id="helperOtherAppLoader" src="" class="hidden"></iframe></div>
				<ul>
					<li class="helperCheck"><img src="resources/Vidyo/Images/checkmark.svg"/>&nbsp;&nbsp;
						Build and install from the SDK
					</li>
					<li class="helperCheck"><img src="resources/Vidyo/Images/checkmark.svg"/>&nbsp;&nbsp;
						Launch once installed
					</li>
				</ul>
				<div class="helperFooter">
					<a href="javascript:joinViaOtherApp()">Launch</a>
				</div>
			</td>
		</tr>
		<tr>
			<td>
				<div id="downloadContainerLegal">
					By clicking &quot;Join&quot; or &quot;Download&quot;, you agree to our <a target="_blank" style="color: #6a6a6a;" href="http://www.vidyo.com/eula/">End-User License Agreement</a> & <a target="_blank" style="color: #6a6a6a;" href="http://www.vidyo.com/privacy-policy/">Privacy Policy</a>.
				</div>
        	</td>
		</tr>
		</table>
	</div>
	<div id="failed" class="hidden">
		<table>
		<tr>
			<td><img class="logo" src="resources/assets/images/error.png"/></td>
		</tr>
		<tr>
			<td id="failedText">Error</td>
		</tr>
		</table>
	</div>
</body>
</html>