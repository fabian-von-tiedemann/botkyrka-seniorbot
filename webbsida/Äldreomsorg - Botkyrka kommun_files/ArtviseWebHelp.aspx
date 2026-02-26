

(function () {
	var debug = false;

	// Our local scope jQuery
	var $;

	var _isWindowed = false;
	var _shallAutoStartChat = false;

	var _extensionId = "QUEUE_MBC_Chat";
	var _enableCoBrowsing = false;
	var _webSessionId;
	var _webSessionGuid;
	var _chatDeedObjectGuid;
	var _chatState;
	var _coBrowsingState;
	var _lastReceivedChatMessageId;
	var _userFullName;
	var _isUserTyping = false;
	var _enableUserInfoPanel = true;
	var _showPublicRecordAccessNotice = true;
	var _lastActivityTimeStamp = null;
	var _initialRetryTimeStamp = null;
	var _customParams = {"extension":"QUEUE_MBC_Chat"};
	var _extensionData = null;

	var _idleTimeoutInMinutes = 5;
	var _retryTimeoutInMinutes = 1;

	var ChatStates = { WaitingForAgent: "WaitingForAgent", WaitingForUser: "WaitingForUser", Running: "Running", Paused: "Paused", Ended: "Ended" };
	var CoBrowsingStates = { WaitingForAgent: "WaitingForAgent", WaitingForUser: "WaitingForUser", Running: "Running", Ended: "Ended" };
	var ChatMessageTypes = { Outgoing: "Outgoing", Incoming: "Incoming", Info: "Info", Error: "Error" };
	var EndChatReasons = { Inactivity: "Inactivity", AgentTimeout: "AgentTimeout", Deactivated: "Deactivated", ReconnectionTimeout: "ReconnectionTimeout", ClientLeave: "ClientLeave", ClientRestart: "ClientRestart" };

	var _hasRegisteredUnloadHandlers = false;
	var _isShuttingDown = false;

	var _notifications = {
		init: function() {
			if (!("Notification" in window)) {
				// Check if the browser supports notifications
				console.log("This browser does not support desktop notification");
			
			} else if (Notification.permission !== "denied") {
				// We need to ask the user for permission
				Notification.requestPermission();
     
			}
		},
		notifyMe: function(text) {

			if (!("Notification" in window)) {
				return;
			}
			try {
				var textArea = document.createElement('textarea');
				textArea.innerHTML = text;

				const notification = new Notification("Artvise chatt", {
					body: textArea.value,
					icon: "Images/notification-icon.png"
				});
			}
			catch(e) {}
		}
	};
	

	var HtmlContentTemplate =

// Start tab
"<div id='ArtviseWebHelpTab' style='display: none'><div role='button' id='ArtviseStartWebHelp' tabindex='0'>KONTAKTA&nbsp;OSS&nbsp;&nbsp;<img src='//artvise-botkyrka.uc.tele2.se/ContactCenter/Images/chatbubble.png?ver=250117_130614_00' class='question-bubble' alt='Pratbubbla'/></div></div>" +

// Outer ui container
"<div id='ArtviseWebHelp' style='display: none'>" +

	// Button for expansion, only displayed when minimized
	"<button id='ArtviseDialogExpandButton' class='ArtviseDialogButton' title='Expandera' aria-label='Expandera'></button>" +

	// Main dialog
	"<div id='ArtviseWebHelpMain'>" +
		"<div id='ArtviseDialogCollapsableContainer'>" +

			// Main dialog header
			"<div id='ArtviseDialogHeader' class='ArtviseTable'>" +
				"<div class='ArtviseTableRow'>" +
					"<div class='ArtviseTableCell' id='ArtviseDialogHeaderText' style='width: 100%; vertical-align: middle;'>Chatt</div>" +
					"<div class='ArtviseTableCell' style='vertical-align: middle'><button id='ArtviseSendMailButton' class='ArtviseDialogButton' title='Skicka konversationen via e-post' aria-label='Skicka konversationen via e-post' style='float: right'></button></div>" +
					(_isWindowed ? "" : "<div class='ArtviseTableCell' style='vertical-align: middle'><button id='ArtviseDialogCollapseButton' class='ArtviseDialogButton' title='Minimera' aria-label='Minimera' style='float: right'></button></div>") +
					"<div class='ArtviseTableCell' style='vertical-align: middle'><button id='ArtviseDialogCancelButton' class='ArtviseDialogButton' title='Avsluta' aria-label='Avsluta' style='float: right'></button></div>" +
				"</div>" +
			"</div>" +

			// Main dialog content
			"<div id='ArtviseDialogContent'>" +

				"<div id='ArtviseSystemMessagePanel'></div>" +

				// Extension selector panel, initially displayed if no extension has been specified
				"<div id='ArtviseSelectExtensionPanel'>" +
					"<div><label for='ArtviseExtension'>Vad gäller ärendet?</label><br/><select id='ArtviseExtension' style='width: 100%;'><option value='ERROR'>Fel: kunde inte läsa in alternativen</option></select></div>" +
					"<button id='ArtviseSelectExtensionButton' style='margin-top: 6px; width: 100%;'>Starta</button>" +
					
					"<div class='ArtviseEstimatedWaitingTime'></div>" +
					
					"<div class='ArtvisePublicRecordAccessNotice'></div>" +
				"</div>" +

				// Panel displayed if the chat is currently closed
				"<div id='ArtviseChatClosedPanel'></div>" +

				// Message panel, displayed if there's no available agent to chat with
				"<div id='ArtviseNoAgentAvailablePanel'>" +
					"<p>Det finns tyvärr ingen ledig handläggare som kan hjälpa dig just nu, men lämna gärna ett meddelande:</p>" +
					"<div><label for='ArtviseCreateMessageCaseFirstName'>Förnamn</label><br/><input type='text' id='ArtviseCreateMessageCaseFirstName' style='width: 100%;'/></div>" +
					"<div><label for='ArtviseCreateMessageCaseLastName'>Efternamn</label><br/><input type='text' id='ArtviseCreateMessageCaseLastName' style='width: 100%;'/></div>" +
					"<div class='ArtviseNoDisplay'><label for='ArtviseCreateMessageCaseSsn'>Personnummer</label><br/><input type='text' id='ArtviseCreateMessageCaseSsn' style='width: 100%;'/></div>" +
					"<div><label for='ArtviseCreateMessageCaseEmail'>E-postadress</label><br/><input type='text' id='ArtviseCreateMessageCaseEmail' style='width: 100%;'/></div>" +
					"<div><label for='ArtviseCreateMessageCasePhone'>Telefonnummer</label><br/><input type='text' id='ArtviseCreateMessageCasePhone' style='width: 100%;'/></div>" +
					"<div><label for='ArtviseCreateMessageCaseText'>Meddelande</label><br/><textarea id='ArtviseCreateMessageCaseText' style='width: 100%; height: 100px'></textarea></div>" +
					"<button id='ArtviseCreateMessageCaseButton' style='margin-top: 6px; width: 100%;'>Skicka meddelande</button>" +
					"<div class='ArtvisePublicRecordAccessNotice'></div>" +
				"</div>" +

				// Message receipt panel, displayed if the user left a message
				"<div id='ArtviseCreateMessageCaseReceiptPanel'>" +
					"<p>Ditt ärendenummer: <span id='ArtviseCreateMessageCaseIdentifier'></span></p>" +
					"<p>Tack för meddelandet!</p>" +
				"</div>" +

				// Chat or co-browsing start panel
				"<div id='ArtviseActionPanel'>" +
					"<div id='ArtviseUserInfoPanel' >" +
						"<div ><label for='ArtviseUserInfoFirstName'>Förnamn</label><br/><input type='text' id='ArtviseUserInfoFirstName' style='width: 100%;'/></div>" +
						"<div ><label for='ArtviseUserInfoLastName'>Efternamn</label><br/><input type='text' id='ArtviseUserInfoLastName' style='width: 100%;'/></div>" +
						"<div class='ArtviseNoDisplay'><label for='ArtviseUserInfoSsn'>Personnummer</label><br/><input type='text' id='ArtviseUserInfoSsn' style='width: 100%;'/></div>" +
						"<div ><label for='ArtviseUserInfoEmail'>E-postadress</label><br/><input type='text' id='ArtviseUserInfoEmail' style='width: 100%;'/></div>" +
						"<div class='ArtviseNoDisplay'><label for='ArtviseUserInfoPhone'>Telefonnummer</label><br/><input type='text' id='ArtviseUserInfoPhone' style='width: 100%;'/></div>" +
						"<div class='ArtviseNoDisplay'><label for='ArtviseInitialMessage'>Din fråga</label><br/><textarea id='ArtviseInitialMessage' style='width: 100%; height: 75px'></textarea></div>" +
					"</div>" +
					"" +
					"<div class='ArtviseTable'>" +
						"<div class='ArtviseTableRow'>" +
							"<div class='ArtviseTableCell' style='width: " + (_enableCoBrowsing ? 50 : 100) + "%'><button id='ArtviseStartChat' style='width: 100%; margin-right: 3px' disabled>Starta chatt</button></div>" +
							(_enableCoBrowsing ? "<div class='ArtviseTableCell' style='width: 50%'><button id='ArtviseStartCoBrowsing' style='width: 100%; margin-left: 3px' disabled>Starta fönsterdelning</button></div>" : "") +
						"</div>" +
					"</div>" +
					"<div class='ArtviseEstimatedWaitingTime'></div>" +
					"<div class='ArtvisePublicRecordAccessNotice'></div>" +
				"</div>" +

				// Chat panel, displayed when a chat has been initiated with an agent
				"<div id='ArtviseChatPanel'>" +
					"<div id='ArtviseChatMessageLog' role='log' tabindex='0'><ol id='ArtviseChatMessageList'></ol></div>" +
					"<div id='ArtviseChatMessageInputPanel' class='ArtviseTable'>" +
						"<div class='ArtviseTableRow'>" +
							"<div class='ArtviseTableCell' style='width: 100%; padding-right: 3px'><label for='ArtviseChatMessageText' class='ArtviseForScreenReaderOnly'>Meddelande</label><textarea id='ArtviseChatMessageText' placeholder='Skriv ett meddelande'></textarea></div>" +
							"<div class='ArtviseTableCell'><button id='ArtviseSendChatMessage' disabled>Skicka</button></div>" +
						"</div>" +
					"</div>" +
				"</div>" +

			"</div>" +

			// Main dialog status message
			"<div id='ArtviseDialogStatusContainer' role='status' aria-live='assertive'>" + // Why aria-live assertive? See 2023PD820.
				"<div id='ArtviseSpinner'></div><div id='ArtviseStatusMessage'></div>" +
				"<div id='ArtviseQueuePositionContainer'>Din plats i kön: <span id='ArtviseQueuePosition'></span></div>" +
			"</div>" +

		"</div>" +
	"</div>" +

"</div>";

	// Called by Surfly when the user has initiated co-browsing
	function coBrowsingQueueHandler(args, callback) {
		var coBrowsingSessionId = args.id;
		callService("StartCoBrowsing", { webSessionGuid: _webSessionGuid, coBrowsingSessionId: coBrowsingSessionId, culture: "sv-SE" }, function () {
			// If the chat is running, send a special message with the co-browsing session id to the agent
			if (_chatState == ChatStates.Running) {
				callService("SendChatMessage", { webSessionGuid: _webSessionGuid, chatDeedObjectGuid: _chatDeedObjectGuid, message: "{{CoBrowsingSessionId=" + coBrowsingSessionId + "}}", name: _userFullName, culture: "sv-SE" });
			}
		});

		if (debug) {
			console.log("Co-browsing queue handler called: id = " + args.id + ", viewer_link = " + args.viewer_link + ", ip_address = " + args.ip_address);

			for (var arg in args)
				console.log(arg + " = " + args[arg]);

			var btnJoinSurflySession = document.createElement("a");
			btnJoinSurflySession.innerHTML = "Gå med i sessionen i ett nytt fönster";
			btnJoinSurflySession.href = args.viewer_link;
			btnJoinSurflySession.target = "_blank";
			btnJoinSurflySession.style.position = "fixed";
			btnJoinSurflySession.style.top = 0;
			btnJoinSurflySession.style.zIndex = 123456789;
			btnJoinSurflySession.style.backgroundColor = "#f0f0f0";
			btnJoinSurflySession.style.display = "block";
			document.body.insertBefore(btnJoinSurflySession, null);
		}

		// Call the supplied callback function with our session id (which Surfly will remember and always pass on to our coBrowsingCallback)
		callback(_webSessionId);
	}

	// Called by Surfly when co-browsing status changes
	function coBrowsingCallback(status, data) {
		// status = true on successful join or rejoin
		// status = false on cancel or close
		// data = what was passed by the callback function call in our coBrowsingQueueHandler, i.e. our session id
		if (debug) {
			console.log("Co-browsing callback function called: status = " + status + ", data = " + data);
		}
	}

	function loadSurfly()
	{
		window['_surfly_settings'] = window['_surfly_settings'] || {
			"widgetkey": "bc45a82afaa34a0aac0eab980e718fb5",
			"enable_sounds": false,
			"videochat": false,
			"QUEUE_CALLBACK": coBrowsingCallback,
			"min_width": 0,
			"agent_can_request_control": false,
			"on_end_redirect_follower_to_queue": true,
			"dock_top_position": false,
			"autohide_control": false,
			"splash": false,
			"theme_font_size": false,
			"hidden": true, // true = don't display the start button
			"theme_font_color": false,
			"set_to_smallest": true,
			"newurl": true,
			"QUEUE_ENDPOINT": "",
			"agent_can_take_control": false,
			"max_height": 0,
			"white_label": true, // true = use our custom design
			"min_height": 0,
			"theme_inverted": true,
			"QUEUE_HANDLER": coBrowsingQueueHandler,
			"autohide_button": true,
			"soft_session_end": true,
			"docked_only": false,
			"theme_font_background": false,
			"ui_off": true, // true = don't display the session control dialog (chat etc)
			"max_width": 0,
			"apiserver": "https://surfly.com/v2/",
			"sharing_button": true,
			"auto_start": false,
			"position": "bottomleft"
		};
		var e = document.createElement("script"); e.type = "text/javascript"; e.async = !0; e.src = "//surfly.com/static/js/widget.js"; var n = document.getElementsByTagName("script")[0]; n.parentNode.insertBefore(e, n);
	}

	function endCoBrowsing() {
		if (!_enableCoBrowsing)
			return;

		if (_coBrowsingState != undefined && _coBrowsingState != CoBrowsingStates.Ended)
			callService("EndCoBrowsing", { webSessionGuid: _webSessionGuid });

		_coBrowsingState = CoBrowsingStates.Ended;

		try {
			Surfly.cancelhelp();
		}
		catch (ex) {
			// TODO: anropa bara cancelhelp om help faktiskt har startats ;)
		}
	}

	function loadScript(url, onLoadCallback) {
		var script = document.createElement("script");
		if (typeof (onLoadCallback) == "function") {
			if (script.readyState) { // IE
				script.onreadystatechange = function () {
					if (script.readyState == "loaded" || script.readyState == "complete") {
						script.onreadystatechange = null;
						onLoadCallback();
					}
				};
			} else { // Other browsers
				script.onload = onLoadCallback;
			}
		}
		script.src = url;
		document.getElementsByTagName("head")[0].appendChild(script);
	}

	function loadCss(url) {
		if (document.createStyleSheet) { // IE
			document.createStyleSheet(url);
		} else { // Other browsers
			var link = document.createElement("link");
			link.rel = "stylesheet";
			link.href = url;
			document.getElementsByTagName("head")[0].appendChild(link);
		}
	}

	function callService(serviceMethodName, parameters, onSuccessCallback, onErrorCallback, async) {
		// Unless explicitly false, set async to true
		if (async !== false)
			async = true;

		$.ajax({
			url: "https://artvise-botkyrka.uc.tele2.se/ContactCenter/Service.svc/json/" + serviceMethodName,
			async: async,
			type: "POST",
			data: JSON.stringify(parameters),
			contentType: "application/json",
			success: onSuccessCallback,
			error: function (xhr, textStatus, errorThrown) {
				var message = "Ett fel uppstod vid anrop till '" + this.url + "':\n\nKod: " + xhr.status + "\nStatus: " + xhr.statusText + "\n\nMer information:\n\n" + xhr.responseText;
				if (debug)
					alert(message);
				else
					console.error(message); // Print the error details to the console instead of throwing it in the face of the user

				if (typeof (onErrorCallback) === "function")
					onErrorCallback(xhr);
			}
		});
	}

	function addChatMessageToLog(messageText, senderName, sentDateTime, chatMessageType) {
		
		var labelHtml = "<div class='ArtviseChatMessageLabel'>";
		if (senderName)
			labelHtml += "<div class='ArtviseChatMessageSenderName'>" + senderName + "</div> "; 
		if (!sentDateTime)
			sentDateTime = new Date();
		labelHtml += "<div class='ArtviseChatMessageTime'>" + getTimeStamp(sentDateTime) + "</div>";
		labelHtml += "</div>";

		
		var list$ = $("#ArtviseChatMessageList");
		list$.append("<li class='Artvise" + chatMessageType + "ChatMessage'><div class='ArtviseChatMessageLabel'>" + labelHtml + "</div>" + messageText + "</li>");

		
		var panel$ = $("#ArtviseChatMessageLog");
		panel$.animate({ scrollTop: panel$.prop("scrollHeight") }, 250);
	}

	function enableChatMessageSendingControls() {
		$("#ArtviseChatMessageText").prop("readonly", false);
		$("#ArtviseSendChatMessage").prop("disabled", false);
	}
	function disableChatMessageSendingControls() {
		$("#ArtviseChatMessageText").prop("readonly", true);
		$("#ArtviseSendChatMessage").prop("disabled", true);
	}

	function startChat() {
		_lastActivityTimeStamp = new Date();
		_chatState = ChatStates.Running;

		hideStatusMessage();

		$("#ArtviseChatPanel").slideDown("fast");
		$("#ArtviseChatMessageText").trigger("focus");
	}

	function pauseChat(pauseMessage) {
		_chatState = ChatStates.Paused;

		showStatusMessage(pauseMessage, true);

		disableChatMessageSendingControls();
	}

	function resumeChat() {
		_lastActivityTimeStamp = new Date();
		_chatState = ChatStates.Running;

		hideStatusMessage();

		enableChatMessageSendingControls();
	}

	function endChat(endChatReason, doAsyncServiceCall, callback) {
		var doServiceCall = (_chatState != undefined && _chatState != ChatStates.Ended);

		$("#ArtviseChatMessageText").prop("readonly", true);
		$("#ArtviseSendChatMessage").prop("disabled", true);

		_chatState = ChatStates.Ended;
		_lastActivityTimeStamp = null;

		addChatMessageToLog("Chatten avslutades", null, new Date(), ChatMessageTypes.Info);

		if (typeof (callback) !== "function") 
			callback = null;

		if (doServiceCall) {
			callService("EndWebSession",
				{ webSessionGuid: _webSessionGuid, chatDeedObjectGuid: _chatDeedObjectGuid, name: _userFullName, endChatReason: endChatReason, culture: "sv-SE" },
				callback, callback, 
				doAsyncServiceCall);
		}
		else {
			
			if (callback != null)
				callback();
		}
	}

	var _updateFetchTimer;
	function startUpdateFetcher() {
		// Make sure there's never more than one running
		stopUpdateFetcher();

		fetchUpdate();
	}
	function stopUpdateFetcher() {
		if (_updateFetchTimer)
			clearTimeout(_updateFetchTimer);
		_updateFetchTimer = null;
	}
	function fetchUpdate() {
		_updateFetchTimer = setTimeout(function() {
			callService("GetUpdates", { webSessionGuid: _webSessionGuid, chatDeedObjectGuid: _chatDeedObjectGuid, lastReceivedChatMessageId: _lastReceivedChatMessageId, isClientTyping: _isUserTyping },
				function(result) { // On success
					
					if (_initialRetryTimeStamp != null) {
						var message = "Återanslutning till servern lyckades";
						addChatMessageToLog(message, null, new Date(), ChatMessageTypes.Info);
						showStatusMessage(message, false, true);

						enableChatMessageSendingControls();

						_initialRetryTimeStamp = null; // Reset
					}

					// Reset user typing status
					_isUserTyping = false;

					if (result.HasAssignedAgent) {
						if (_enableCoBrowsing) {
							// Enable the co-browsing start button if we're waiting for that
							if (_coBrowsingState == CoBrowsingStates.WaitingForAgent)
							{
								_coBrowsingState = CoBrowsingStates.WaitingForUser;

								$("#ArtviseStartCoBrowsing").prop("disabled", false);

								// "Blink" the button a couple of times to call upon the user's attention
								for (var i = 0; i < 2; i++) {
									$("#ArtviseStartCoBrowsing").fadeTo('fast', 0.25).fadeTo('fast', 1.0);
								}
							}
						}

						// Start chatting if we're waiting for that
						if (_chatState == ChatStates.WaitingForAgent) {
							hideQueuePosition();
							startChat();
						}

						// Resume chatting if we're paused
						if (_chatState == ChatStates.Paused)
							resumeChat();
					}
					else {
						if (_chatState == ChatStates.WaitingForAgent)
							showQueuePosition(result.QueuePosition);
					}

					// If the chat is running, grab any new messages (from the agent) and add them to the log
					if (_chatState == ChatStates.Running) {
						for (var i = 0; i < result.ChatMessages.length; i++) {
							var chatMessage = result.ChatMessages[i];
							_notifications.notifyMe(chatMessage.Message);
							_lastReceivedChatMessageId = chatMessage.MessageId;
							addChatMessageToLog(chatMessage.Message, chatMessage.Name, new Date(), ChatMessageTypes.Incoming);
						}

						// Update the activity time stamp if a message was received
						if (result.ChatMessages.length > 0)
							_lastActivityTimeStamp = new Date();
						else if ((new Date(new Date() - _lastActivityTimeStamp)).getMinutes() >= _idleTimeoutInMinutes) { // End the chat if there's been no activity for a long time
							var message = "Chatten avslutades pga inaktivitet";
							addChatMessageToLog(message, null, new Date(), ChatMessageTypes.Info);
							showStatusMessage(message, false, true);
							endChat(EndChatReasons.Inactivity);
							return;
						}

						// Display the conversation mailer button
						if (result.ChatMessages.length > 0)
							$("#ArtviseSendMailButton").slideDown("fast");

						if (result.IsAgentTyping) {
							_lastActivityTimeStamp = new Date();
							showStatusMessage("Handläggaren skriver", true, true);
						}
						else
							hideStatusMessage();

						// If the agent timed out, end the chat
						if (result.HasAgentSessionTimedOut)
						{
							var message = "Chatten avslutades pga ett tekniskt problem (time-out i kommunikationen)";
							addChatMessageToLog(message, null, new Date(), ChatMessageTypes.Error);
							showStatusMessage(message, false, true);
							endChat(EndChatReasons.AgentTimeout);
							return;
						}

						// If the chat is no longer active (e.g. because the agent ended it), stop it
						if (!result.IsChatActive) {
							endChat(EndChatReasons.Deactivated);
							return;
						}

						if (!result.HasAssignedAgent) { // If the chat is being transferred to another agent, pause the chat and display a message about it
							pauseChat("Väntar på en ledig handläggare");
						}
					}

					// Schedule the next update
					if (_updateFetchTimer != null)
						fetchUpdate();
				},
				function () { // On error
					if (_updateFetchTimer == null)
						return;

					disableChatMessageSendingControls();

					var firstRetry = false;

					if (_initialRetryTimeStamp == null) {
						_initialRetryTimeStamp = new Date();
						firstRetry = true;
					}

					_lastActivityTimeStamp = new Date();

					if ((new Date(new Date() - _initialRetryTimeStamp)).getMinutes() < _retryTimeoutInMinutes)
					{
						if (firstRetry) // One error message is enough
							addChatMessageToLog("Ett fel uppstod i kommunikationen med servern", null, new Date(), ChatMessageTypes.Error);

						showStatusMessage("Försöker återupprätta kontakten med servern", true, true);
						hideQueuePosition();

						// Schedule a retry
						fetchUpdate();
					}
					else {
						var message = "Lyckades inte återupprätta kommunikationen med servern";
						addChatMessageToLog(message, null, new Date(), ChatMessageTypes.Error);
						showStatusMessage(message, false, true);
						hideQueuePosition();

						endChat(EndChatReasons.ReconnectionTimeout);
					}
				});
		}, 2500); 
	}

	
	function setUserFullName(firstName, lastName)
	{
		_userFullName = "";

		if (firstName != "")
			_userFullName = firstName;
		if (lastName != "") {
			if (_userFullName != "")
				_userFullName += " ";
			_userFullName += lastName;
		}

		
		if (_userFullName == "") {
			_userFullName = "Webbanvändare-" + _webSessionId;
			return true;
		}

		return false;
	}

	function getTimeStamp(dateTime) {
		
		if (typeof (dateTime) == "string" && dateTime.indexOf("/Date") == 0) {
			var regexMatches = /(\d+)(?:([\+\-])(\d\d)(\d\d))?/.exec(dateTime);
			var totalTicks = parseInt(regexMatches[1]);
			var timeZoneOffsetSign = regexMatches[2];

			dateTime = new Date(totalTicks);

			
			if (timeZoneOffsetSign == undefined) {
				
				dateTime.setMinutes(dateTime.getMinutes() - dateTime.getTimezoneOffset());
			} else {
				var timeZoneOffsetHours = parseInt(regexMatches[3]);
				var timeZoneOffsetMinutes = parseInt(regexMatches[4]);

				var timeZoneOffsetTotalMinutes = timeZoneOffsetHours * 60 + timeZoneOffsetMinutes;
				if (timeZoneOffsetSign == "-")
					timeZoneOffsetTotalMinutes = -timeZoneOffsetTotalMinutes;

				
				dateTime.setMinutes(dateTime.getMinutes() - timeZoneOffsetTotalMinutes - dateTime.getTimezoneOffset());
			}
		}

		var hours = dateTime.getHours();
		var minutes = dateTime.getMinutes();
		if (hours < 10)
			hours = "0" + hours;
		if (minutes < 10)
			minutes = "0" + minutes;

		return hours + ":" + minutes;
	}

	function showStatusMessage(message, showSpinner, hasElementsAbove) {
		var statusContainer$ = $("#ArtviseDialogStatusContainer");
		$("#ArtviseSpinner").css("display", showSpinner ? "inline-block" : "none");
		$("#ArtviseStatusMessage").html(message);

		// If the status container doesn't have any elements above it, negate its top margin to go "all the way up"
		statusContainer$.css("margin-top", (hasElementsAbove === false ? "-" : "") + "6px");

		statusContainer$.slideDown("fast");
	}
	function hideStatusMessage() {
		$("#ArtviseDialogStatusContainer").slideUp("fast");
	}

	function showQueuePosition(position) {
		$("#ArtviseQueuePosition").text(position);
		$("#ArtviseQueuePositionContainer").slideDown("fast");
	}
	function hideQueuePosition(position) {
		$("#ArtviseQueuePositionContainer").slideUp("fast");
	}

	function openUrlInIframe(url)
	{
		// Get the iframe to open the url in, or add it if it doesn't already exist
		var iframe$ = $("#ArtviseUrlOpeningIframe");
		if (iframe$.length == 0) {
			$(document.body).append(
				"<div id='ArtviseUrlOpeningIframeContainer'>" +
					"<div id='ArtviseUrlOpeningIframeHeaderContainer'>" +
						"<div id='ArtviseUrlOpeningIframeLinkContainer'>Visar länk från chatten: <a id='ArtviseUrlOpeningIframeLink' href='#' target='_blank' title='Klicka på denna länk för att öppna den i en ny flik/fönster'></a></div>" +
						"<button id='ArtviseUrlOpeningIframeCloseButton'>Stäng detta fönster</button>" +
					 "</div>" +
					"<div id='ArtviseUrlOpeningIframeContentContainer'>" +
						"<div id='ArtviseUrlOpeningIframeLoadingMessage'></div>" +
						"<iframe id='ArtviseUrlOpeningIframe'></iframe>" +
					"</div>" +
				"</div>");

			// Clicking on the close button removes entire url opening iframe container
			$("#ArtviseUrlOpeningIframeCloseButton").on("click", function () { $("#ArtviseUrlOpeningIframeContainer").remove(); });

			$("#ArtviseUrlOpeningIframeLink").on("click", function (evt) {
				if (!confirm("OBS! Följande adress kommer att öppnas i en ny flik/fönster:\n\n" + this.href + "\n\nChatten avslutas inte. Kom tillbaka till denna flik/fönster för att fortsätta chatta."))
					evt.preventDefault();
			});

			iframe$ = $("#ArtviseUrlOpeningIframe");

			// When the url has loaded, display a message about any eventual problem with loading the url (which will e.g. happen with www.google.com since it doesn't allow iframing, which the DOM unfortunately doesn't let us know).
			// If the url was successfully loaded, the iframe will cover this message so it won't be visible.
			iframe$.on("load", function () { $("#ArtviseUrlOpeningIframeLoadingMessage").text("Länken kunde inte laddas i detta fönster (vilket kan bero på att den inte tillåts laddas på detta vis). Klicka istället på länken i fönsterrubriken ovan för att öppna den i en ny flik/fönster."); });
		}

		// Display the url in the header and the loading message
		$("#ArtviseUrlOpeningIframeLink").attr("href", url).text(url);
		$("#ArtviseUrlOpeningIframeLoadingMessage").text("Laddar " + url + " ...");

		// Load the url in the iframe
		iframe$.attr("src", url);
	}

	function initialize(reset) {
		reset = (reset === true); // Make sure to be boolean

		if (!reset) {
			// If another jQuery was loaded before we loaded ours, revert to that previous jQuery in the global scope (window) and put our jQuery in our own local scope $ variable.
			// This will also work if there was no jQuery loaded before ours, and also if another jQuery is loaded after ours (since we have ours in our own unaffected local scope).
			$ = window.$.noConflict(true);

			if (debug)
				console.log("Local scope jQuery version: " + $.fn.jquery + "\nGlobal scope jQuery version: " + (window.$ && window.$.fn ? window.$.fn.jquery : "none"));
		}

		// (Re)set the "globals". Important to use undefined, NOT null!
		_webSessionId = undefined;
		_webSessionGuid = undefined;
		_chatDeedObjectGuid = undefined;
		_chatState = undefined;
		_coBrowsingState = undefined;
		_lastReceivedChatMessageId = undefined;
		_userFullName = undefined;
		_isUserTyping = false;
		_extensionId = "QUEUE_MBC_Chat";
		_initialRetryTimeStamp = null;

		if (reset) {
			// Get rid of our ui completely (will also disconnect event handlers etc)
			$("#ArtviseWebHelp").remove();
			$("#ArtviseWebHelpTab").remove();
		}

		var load = function () {
			
			var containerElementIdentifier = "artvise-web-help";
			var containerElement = document.getElementById(containerElementIdentifier);
			if (!containerElement) {
				var elements = document.getElementsByClassName(containerElementIdentifier);
				if (elements.length > 0)
					containerElement = elements[0];
			}
			if (!containerElement)
				containerElement = document.body;

			
			$(containerElement).append(HtmlContentTemplate);

			if (_showPublicRecordAccessNotice)
				$(".ArtvisePublicRecordAccessNotice").html("Texten i chatten sparas och blir en allmän handling som vem som helst kan begära att få läsa.").show();

			$("#ArtviseWebHelp").show();

			var ignition = function() {
				$("#ArtviseWebHelpTab").hide();
				$("#ArtviseWebHelpMain").show();

				$("#ArtviseDialogCollapsableContainer").show("fast");

				loadSystemMessages();

				
				var firstname = _customParams["firstname"];
				var lastname = _customParams["lastname"];
				var ssn = _customParams["ssn"];
				var email = _customParams["email"];
				var phone = _customParams["phone"];
				var message = _customParams["message"];
				if (firstname) {
					$("#ArtviseUserInfoFirstName").val(firstname);
					$("#ArtviseCreateMessageCaseFirstName").val(firstname);
				}
				if (lastname) {
					$("#ArtviseUserInfoLastName").val(lastname);
					$("#ArtviseCreateMessageCaseLastName").val(lastname);
				}
				if (ssn) {
					$("#ArtviseUserInfoSsn").val(ssn);
					$("#ArtviseCreateMessageCaseSsn").val(ssn);
				}
				if (email) {
					$("#ArtviseUserInfoEmail").val(email);
					$("#ArtviseCreateMessageCaseEmail").val(email);
				}
				if (phone) {
					$("#ArtviseUserInfoPhone").val(phone);
					$("#ArtviseCreateMessageCasePhone").val(phone);
				}
				if (message) {
					$("#ArtviseInitialMessage").val(message);
					$("#ArtviseCreateMessageCaseText").val(message);
				}

				
				if (!_extensionId) {
					$("#ArtviseSelectExtensionPanel").show();
					$("#ArtviseDialogHeader").slideDown("fast");
					$("#ArtviseDialogContent").slideDown("fast");

					var extensionId = _extensionData[$("#ArtviseExtension").val()].id;
					getEstimatedWaitingTime(extensionId);
				}
				else
					tryStartWebSession(_extensionId, _shallAutoStartChat);
			};

			$("#ArtviseStartWebHelp")
				.on("click", ignition) 
				.on("keydown", function (evt) { if (evt.keyCode == 13 || evt.keyCode == 32) { evt.preventDefault(); } }) 
				.on("keyup", function (evt) { if (evt.keyCode == 13 || evt.keyCode == 32) { evt.preventDefault(); ignition(); } }); 

			$("#ArtviseDialogExpandButton").on("click", function () {
				$(this).hide();
				$("#ArtviseDialogCollapseButton").show();
				$("#ArtviseWebHelpMain").show();
			});
			$("#ArtviseDialogCollapseButton").on("click", function () {
				$(this).hide();
				$("#ArtviseDialogExpandButton").show();
				$("#ArtviseWebHelpMain").hide();
			});
			$("#ArtviseDialogCancelButton").on("click", function () {
				if (_isWindowed)
					shutdown(false); 
				else
					restart();
			});

			$("#ArtviseExtension").on("change", function () {
				var extensionId = _extensionData[this.value].id;
				getEstimatedWaitingTime(extensionId);
			});
			$("#ArtviseSelectExtensionButton").on("click", function () {
				var extensionId = _extensionData[$("#ArtviseExtension").val()].id;
				if (extensionId == "ERROR") {
					alert("Kan inte starta pga att det inte finns något ärendealternativ att välja");
					return;
				}
				$("#ArtviseSelectExtensionPanel").hide("fast");
				$("#ArtviseDialogHeader").slideUp("fast");
				$("#ArtviseDialogContent").slideUp("fast");
				tryStartWebSession(extensionId, _shallAutoStartChat || !_enableUserInfoPanel); 
			});

			$("#ArtviseCreateMessageCaseButton").on("click", function () {

				if (!_extensionId)
					_extensionId = _extensionData[$("#ArtviseExtension").val()].id;

				var firstName = $("#ArtviseCreateMessageCaseFirstName").val().trim();
				var lastName = $("#ArtviseCreateMessageCaseLastName").val().trim();
				var ssn = $("#ArtviseCreateMessageCaseSsn").val().trim();
				var email = $("#ArtviseCreateMessageCaseEmail").val().trim();
				var phone = $("#ArtviseCreateMessageCasePhone").val().trim();
				var message = $("#ArtviseCreateMessageCaseText").val().trim();
				if (message == "")
				{
					alert("Meddelandet kan inte vara tomt");
					return;
				}
                

				this.disabled = true;

				var htmlEncodedMessage = $("<span/>").text(message).html().replace(/\n/g, "<br/>");

				_customParams["ssn"] = ssn;

				var customParamsDictionary = [];
				for (var key in _customParams)
					customParamsDictionary.push({ Key: key, Value: _customParams[key] }); 

				showStatusMessage("Skickar meddelandet", true);
				callService("CreateMessageCase", { extensionId: _extensionId, firstName: firstName, lastName: lastName, email: email, phone: phone, message: htmlEncodedMessage, culture: "sv-SE", customParams: customParamsDictionary },
					function (result) {
						hideStatusMessage();

						$("#ArtviseCreateMessageCaseIdentifier").text(result);

						$("#ArtviseNoAgentAvailablePanel").slideUp("fast");
						$("#ArtviseCreateMessageCaseReceiptPanel").slideDown("fast");
					},
					function (xhr) {
						hideStatusMessage();
						$("#ArtviseCreateMessageCaseButton").prop("disabled", false);
					});
			});

			$("#ArtviseStartChat").on("click", function () {
				_notifications.init();
				$(this).hide();
				//this.disabled = true;
				_chatState = ChatStates.WaitingForAgent;

				$("#ArtviseActionPanel").slideUp("fast"); // TODO: when co-browsing is enabled, in the future, then this cannot be done because the "start co-browsing" button needs to remain visible
				$("#ArtviseUserInfoPanel").slideUp("fast");

				hideSystemMessages();

				var extensionDataId;
				if (!_extensionId) {
					extensionDataId = $("#ArtviseExtension").val();
					_extensionId = _extensionData[extensionDataId].id;
				}
				else {
					extensionDataId = 0; 
				}

				if (_extensionData != null) {
					var extensionData = _extensionData[extensionDataId];
					if (extensionData) {
						
						if (!_customParams["diaryplanitemguid"]) {
							if (extensionData.diaryplanitemguid) {
								_customParams["diaryplanitemguid"] = extensionData.diaryplanitemguid;
								if (extensionData.casecategoryguid) {
									_customParams["casecategoryguid"] = extensionData.casecategoryguid;
								}
							}
						}
					}
				}

				var firstName = $("#ArtviseUserInfoFirstName").val().trim();
				var lastName = $("#ArtviseUserInfoLastName").val().trim();
				var email = $("#ArtviseUserInfoEmail").val().trim();
				var phone = $("#ArtviseUserInfoPhone").val().trim();
				_customParams["ssn"] = $("#ArtviseUserInfoSsn").val().trim();
				_customParams["message"] = $("#ArtviseInitialMessage").val().trim();

				var isAnonymous = setUserFullName(firstName, lastName);

				var customParamsDictionary = [];
				for (var key in _customParams)
					customParamsDictionary.push({ Key: key, Value: _customParams[key] }); 

				showStatusMessage("Väntar på en ledig handläggare", true, false);
				callService("StartChat",
					{ webSessionGuid: _webSessionGuid, extensionId: _extensionId, firstName: (isAnonymous? _userFullName : firstName), lastName: lastName, email: email, phone: phone, culture: "sv-SE", customParams: customParamsDictionary },
					function (result) {
						_chatDeedObjectGuid = result;

						
						var message = _customParams["message"];
						if (message) {
							var htmlEncodedMessage = $("<span/>").text(message).html().replace(/\n/g, "<br/>");
							addChatMessageToLog(htmlEncodedMessage, "Du", new Date(), ChatMessageTypes.Outgoing);
						}
					});
			});
			$("#ArtviseSendChatMessage").on("click", function () {
				if (_chatState == ChatStates.Ended)
					return;

				// If there's any text then send it, disable the sending button, clear the textbox and focus it (getting ready for the next message to send)
				var text$ = $("#ArtviseChatMessageText");
				if (text$.val().length > 0) {
					_lastActivityTimeStamp = new Date();
					this.disabled = true;

					var message = text$.val();

					var htmlEncodedMessage = $("<span/>").text(message).html().replace(/\n/g, "<br/>");

					callService("SendChatMessage", { webSessionGuid: _webSessionGuid, chatDeedObjectGuid: _chatDeedObjectGuid, message: message, name: _userFullName, culture: "sv-SE" },
						null, // On success, do nothing
						function () { // On error, notify the user
							addChatMessageToLog("Kunde inte skicka följande meddelande pga kommunikationsproblem med servern:<br /><br />" + htmlEncodedMessage, null, new Date(), ChatMessageTypes.Error);
						});

					// For a snappy user experience, immediately add to the log without waiting for the service call
					addChatMessageToLog(htmlEncodedMessage, "Du", new Date(), ChatMessageTypes.Outgoing);
					text$.val("").trigger("focus");

					// Display the conversation mailer button
					$("#ArtviseSendMailButton").slideDown("fast");
				}
			});
			$("#ArtviseChatMessageText")
				.on("keyup", function () {
					if (_chatState == ChatStates.Ended) return;

					_lastActivityTimeStamp = new Date();

					// Enable the sending button if there's any text, else diable it
					$("#ArtviseSendChatMessage").prop("disabled", this.value.length == 0);
				})
				.on("keydown", function (evt) {
					_lastActivityTimeStamp = new Date();

					// Send chat message on enter key press
					if (evt.keyCode == 13) {
						evt.preventDefault(); // We do NOT want to post to the server!
						if (evt.shiftKey) {
							// Appends newline if shift + enter is pressed
							var text = $("#ArtviseChatMessageText").val();
							$("#ArtviseChatMessageText").val(text + "\r\n");
						} else {
							$("#ArtviseSendChatMessage").trigger("click");
						}
						return false;
					}

					// The user is typing
					_isUserTyping = true;
				}
			);
			$("#ArtviseSendMailButton").on("click", function () {
				while (true)
				{
					var recipientEmailAddress = prompt("Ange e-postadress att skicka konversationsloggen till");
					if (recipientEmailAddress == null)
						return;

					if (recipientEmailAddress.match(/^.+?@.+$/g) == null)
						alert("Felaktigt format på e-postadressen");
					else
						break;
				}

				callService("SendChatConversationAsMail",
					{ webSessionGuid: _webSessionGuid, chatDeedObjectGuid: _chatDeedObjectGuid, recipientEmailAddress: recipientEmailAddress, culture: "sv-SE" },
					function (result) {
						if (result == "OK")
							alert("Konversationsloggen har nu skickats till " + recipientEmailAddress);
						else
							alert(result);
					});
			});

			if (!_isWindowed) {
				// Only if NOT in windowed mode: Any link that may later appear in the chat message log shall be opened in the url opening iframe when clicked upon
				$("#ArtviseChatMessageLog").on("click", "a", function (evt) {
					if (!this.href)
						return;
					evt.preventDefault(); // Prevent regular navigation
					openUrlInIframe(this.href);
				});
			}

			if (_enableCoBrowsing) {
				$("#ArtviseStartCoBrowsing").on("click", function () {
					this.disabled = true;
					_coBrowsingState = CoBrowsingStates.Running;
					Surfly.help(window);
				});
			}

			// Get going!
			$("#ArtviseWebHelpTab").fadeIn("fast");

			// In windowed mode, open up right away
			if (_isWindowed)
				$("#ArtviseStartWebHelp").trigger("click");

			// The following code starts the snurkel-animation
			// todo: bör förstås bara göras när snurkeln ska visas, animationen borde inte köras permanent
			if (!reset)
				new imageLoader(cImageSrc, startAnimation);
			else {
				stopAnimation();
				startAnimation();
			}
		};

		if (reset)
			load();
		else
			$(load); // Runs when the document has loaded
	}


	function loadSystemMessages() {
		$("#ArtviseSystemMessagePanel").show();
		callService("GetSystemMessages", { culture: "sv-SE" },
			function (result) {
				var data = JSON.parse(result);
				if (!Array.isArray(data) || data.length == 0)
					return;

				var output = "<b>System- och driftmeddelanden:</b><ol id='ArtviseSystemMessageList'>";

				for (var i = 0; i < data.length; i++) {
					var msg = data[i];
					output +=
						"<li style='color: #" + msg.PriorityColor + "'>" +
							"<div class='ArtviseSystemMessageHeader'>" + msg.Subject + "</div>" +
							"<div class='ArtviseSystemMessageSubheader'>" + msg.PublishedFrom + " - " + msg.CategoryName + "</div>" +
							"<div class='ArtviseSystemMessageText'>" + msg.Message + "</div>" +
							"<div class='ArtviseSystemMessageMoreInfo'><a data-messageId='" + msg.SystemMessageGuid + "' href='#'>Mer information</a></div>" +
						"</li>";
				}

				output += "</ol>";

				$("#ArtviseSystemMessagePanel").html(output);

				$("#ArtviseSystemMessagePanel").find("a").on("click", function () { showSystemMessage(this.getAttribute("data-messageId")); });
			}
		);
	}

	function hideSystemMessages() {
		$("#ArtviseSystemMessagePanel").hide();
	}

	function showSystemMessage(systemMessageGuid) {
		window.open("https://artvise-botkyrka.uc.tele2.se/ContactCenter/SystemMessage.aspx?id=" + systemMessageGuid + "&lang=sv-SE", 'Mer information', 'width=800,height=600,resizable=1');
	}

	function getVerbalTimeString(totalSeconds) {
		var days = Math.floor(totalSeconds / 86400);
		var remainingSeconds = totalSeconds % 86400;

		var hours = Math.floor(remainingSeconds / 3600);
		remainingSeconds = remainingSeconds % 3600;

		var minutes = Math.floor(remainingSeconds / 60);
		remainingSeconds = remainingSeconds % 60;

		var time = "";

		if (days > 0)
			time += days + " " + (days == 1 ? "dag" : "dagar");
		if (hours > 0)
			time += (time.length > 0 ? " " : "") + hours + " " + (hours == 1 ? "timme" : "timmar");
		if (minutes > 0)
			time += (time.length > 0 ? " " : "") + minutes + " " + (minutes == 1 ? "minut" : "minuter");
		if (time.length == 0 || remainingSeconds > 0)
			time += (time.length > 0 ? " " : "") + remainingSeconds + " " + (remainingSeconds == 1 ? "sekund" : "sekunder");

		return time;
	}

	function getEstimatedWaitingTime(extensionId) {
		
		var messageField$ = $(".ArtviseEstimatedWaitingTime");
		messageField$.html("Beräknar uppskattad väntetid ...").show();

		var failureMessage = "Uppskattad väntetid kunde ej beräknas.";

		callService("GetEstimatedWaitingTime", { extensionId: extensionId, culture: "sv-SE" },
			function (result) {
				var seconds = Math.round(result);

				var msg;
				if (seconds >= 0)
					msg = "Uppskattad väntetid: " + getVerbalTimeString(seconds);
				else
					msg = failureMessage;

				messageField$.html(msg);
			},
			function (xhr) {
				messageField$.html(failureMessage);
				if (debug) { console.log("Could not get estimated waiting time for extension " + extensionId); }
			}
		);
		
	}

	function tryStartWebSession(extensionId, shallAutoStart) {
		// Try starting a web session
		showStatusMessage("Startar", true, false);
		var clientUrl = _isWindowed ? decodeURIComponent($("#refUrl").val()) : document.location.href;
		callService("TryStartWebSession", { extensionId: extensionId, clientUrl: clientUrl, clientIpAddress: _enableCoBrowsing ? "" : "anonymous" },
			function (result) {
				hideStatusMessage();

				if (!result.IsOpen) {
					$("#ArtviseChatClosedPanel").html("<p><b>Chatten är för närvarande stängd.</b></p>").show();
					
						$("#ArtviseNoAgentAvailablePanel").show();
						$("#ArtviseCreateMessageCaseFirstName").trigger("focus");
					
				} else {
					if (!result.HasAvailableAgents) {
                        
						    $("#ArtviseNoAgentAvailablePanel").show();
						    $("#ArtviseCreateMessageCaseFirstName").trigger("focus");
                        
					} else {
						_webSessionId = result.WebSessionId;
						_webSessionGuid = result.WebSessionGuid;

						

						if (!shallAutoStart) {
							$("#ArtviseActionPanel").show();
							$("#ArtviseUserInfoFirstName").trigger("focus");

							getEstimatedWaitingTime(extensionId);
						}
						$("#ArtviseStartChat").prop("disabled", false);

						_chatState = ChatStates.WaitingForUser;
						_coBrowsingState = CoBrowsingStates.WaitingForAgent;

						startUpdateFetcher();

						if (shallAutoStart)
							$("#ArtviseStartChat").trigger("click");

						// Register page unload handlers once
						if (!_hasRegisteredUnloadHandlers) {

							// If a chat is running when the user is about to navigate away from this pages, try warning the user that the chat will be ended
							$(window).on("beforeunload", function (evt) {
								if (_chatState != undefined && _chatState != ChatStates.Ended && _chatState != ChatStates.WaitingForUser) {
									var message = "OBS! Chatten kommer att avslutas om du lämnar denna sida.";
									if (debug) { console.log("BeforeUnload: Attempting to display message '" + message + "'"); }
									evt.returnValue = message;
									return message;
								}
							});

							// Leaving the page shall ideally end any ongoing session/chat
							$(window).on("unload", function () {
								if (debug) { console.log("Unload: Shutting down"); }
								shutdown(true); 
								if (debug) { console.log("Unload: Shutdown completed"); }
							});

							_hasRegisteredUnloadHandlers = true;
						}
					}
				}

				$("#ArtviseDialogHeader").slideDown("fast");
				$("#ArtviseDialogContent").slideDown("fast");
			},
			function (xhr) {
				$("#ArtviseDialogHeader").slideDown("fast"); // Allow the user to close/restart
				showStatusMessage("Ett oväntat fel har uppstått");
			}
		);
	}

	function restart() {
		endChat(EndChatReasons.ClientRestart);
		if (_enableCoBrowsing)
			endCoBrowsing();
		stopUpdateFetcher();
		initialize(true);
	}

	function shutdown(isUnloading) {
		
		if (_isShuttingDown || !_isWindowed)
			return;

		_isShuttingDown = true;

			
		if (!isUnloading) {
			$("#ArtviseDialogHeader").slideUp("fast");
			$("#ArtviseDialogContent").slideUp("fast");

			showStatusMessage("Avslutar", true, false);
			hideQueuePosition();
		}

				
		var doAsyncServiceCall = !isUnloading;

		stopUpdateFetcher();

		
		var continuation = function () {
			if (debug) { console.log("Executing continuation, async: " + doAsyncServiceCall); }

			if (_enableCoBrowsing)
				endCoBrowsing();

			
			if (_isWindowed && !isUnloading) {
				if (debug) { console.log("Closing window"); }
				window.close();
			}
		};

		
		if (debug) { console.log("Making end-chat service call"); }
		endChat(EndChatReasons.ClientLeave, doAsyncServiceCall, continuation);
		if (debug) { console.log("Immediately after end-chat service call"); }
	}

	// If NOT in a Surfly session, get started!
	if (!window.__surfly)
	{
		// Do NOT load inside the url-opening-iframe of another page having ArtviseWebHelp loaded. This avoids chat-ception.
		try {
			if (window.frameElement.id == "ArtviseUrlOpeningIframe")
				return;
		} catch (ex) {
			// We'll end up here due to access denial if we're loaded in an iframe in a cross-origin page (i.e. a page in another domain)
		}

		// Load the Surfly base
		if (_enableCoBrowsing)
			loadSurfly();

		// Load our css
		loadCss("//artvise-botkyrka.uc.tele2.se/ContactCenter/Style.css?ver=250117_130614_00");

		
		// Load customer specific css overrides
		loadCss("//artvise-botkyrka.uc.tele2.se/ContactCenter/Style-Customized.css?ver=231017_165255_53");
		

		// In windowed mode, load window mode css overrides
		if (_isWindowed)
			loadCss("//artvise-botkyrka.uc.tele2.se/ContactCenter/StyleWindowed.css?ver=250117_130614_00");

		// Load jQuery and then get started
		loadScript("//artvise-botkyrka.uc.tele2.se/ContactCenter/jquery.min.js?ver=250117_130614_00", initialize);
	}




	// BEGIN spinner bollox - http://preloaders.net/en/circular/broken-circle/

	var cSpeed = 9;
	var cWidth = 16;
	var cHeight = 16;
	var cTotalFrames = 8;
	var cFrameWidth = 16;
	var cImageSrc = "//artvise-botkyrka.uc.tele2.se/ContactCenter/Images/spinner.png?ver=250117_130614_00";
	var cImageTimeout = false;
	var cIndex = 0;
	var cXpos = 0;
	var cPreloaderTimeout = false;
	var SECONDS_BETWEEN_FRAMES = 0;

	function startAnimation() {
		var spinner = document.getElementById("ArtviseSpinner");
		spinner.style.backgroundImage = "url(" + cImageSrc + ")";
		spinner.style.width = cWidth + "px";
		spinner.style.height = cHeight + "px";

		SECONDS_BETWEEN_FRAMES = 1 / Math.round(100 / cSpeed);

		setTimeout(continueAnimation, 0);
	}

	function continueAnimation() {
		cXpos += cFrameWidth;
		cIndex += 1;
		if (cIndex >= cTotalFrames) {
			cXpos = 0;
			cIndex = 0;
		}
		if (document.getElementById("ArtviseSpinner"))
			document.getElementById("ArtviseSpinner").style.backgroundPosition = -cXpos + "px 0";

		cPreloaderTimeout = setTimeout(continueAnimation, SECONDS_BETWEEN_FRAMES * 1000);
	}

	function stopAnimation() {
		clearTimeout(cPreloaderTimeout);
		cPreloaderTimeout = false;
	}

	// Preloads the sprites image
	function imageLoader(s, fun) {
		clearTimeout(cImageTimeout);
		cImageTimeout = 0;
		genImage = new Image();
		genImage.onload = function() { cImageTimeout = setTimeout(fun, 0); };
		genImage.src = s;
	}

	// END spinner bollox
})();
