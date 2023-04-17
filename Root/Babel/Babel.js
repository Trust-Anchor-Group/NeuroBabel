function SetRoom()
{
	var Room = document.getElementById("Room").value;
	window.location.href = "Index.md?Room=" + encodeURIComponent(Room);
}

function SetLanguage(Room)
{
	var Language = document.getElementById("Language").value;
	window.location.href = "Index.md?Room=" + encodeURIComponent(Room) + "&Language=" + Language;
}

function SetNickName(Room,Language)
{
	var NickName = document.getElementById("NickName").value;
	window.location.href = "Index.md?Room=" + encodeURIComponent(Room) + "&Language=" + Language + "&NickName=" + NickName;
}

function TrapTabCREsc(Control, Event, Room, Language, NickName)
{
	if (Event.keyCode === 9)
	{
		Event.preventDefault();

		var Value = Control.value;
		var Start = Control.selectionStart;
		var End = Control.selectionEnd;
		Control.value = Value.substring(0, Start) + '\t' + Value.substring(End);
		Control.selectionStart = Control.selectionEnd = Start + 1;
	}
	else if (Event.keyCode === 13)
	{
		Event.preventDefault();
		SendMessage(Room, Language, NickName);
		return;
	}
	else if (Event.keyCode === 27)
	{
		CancelMessage();
		return;
	}

	InvalidatePreview();

	window.setTimeout(function () { AdaptSize(Control); }, 0);
}

function AdaptSize(Control)
{
	if (Control.tagName === "TEXTAREA")
	{
		var maxheight = Math.floor((("innerHeight" in window ? window.innerHeight : document.documentElement.offsetHeight) * 2) / 3);
		var h = Control.scrollHeight;
		if (h > maxheight)
			h = maxheight;

		if (h > Control.clientHeight)
			Control.style.height = h + "px";
	}
}

function InvalidatePreview()
{
	if (PreviewTimer !== null)
		window.clearTimeout(PreviewTimer);

	PreviewTimer = window.setTimeout(function ()
	{
		DoPreview();
	}, 250);
}

var PreviewTimer = null;

function DoPreview()
{
	var Text = document.getElementById("Message").value;
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function ()
	{
		if (xhttp.readyState === 4)
		{
			if (xhttp.status === 200)
			{
				var Preview = document.getElementById("Preview");
				Preview.innerHTML = xhttp.responseText;
			}
			else
				window.alert(xhttp.responseText);
		}
	};

	xhttp.open("POST", "/Babel/Api/PreviewMessage.ws", true);
	xhttp.setRequestHeader("Content-Type", "text/plain");
	xhttp.setRequestHeader("Accept", "text/html");
	xhttp.send(Text);
}

function CancelMessage()
{
	var Message = document.getElementById("Message");
	Message.value = "";
	Message.focus();

	InvalidatePreview();
}

function SendMessage(Room,Language,NickName)
{
	var Message = document.getElementById("Message").value;
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function ()
	{
		if (xhttp.readyState === 4)
		{
			if (xhttp.status === 200)
				CancelMessage();
			else
				window.alert(xhttp.responseText);
		}
	};

	xhttp.open("POST", "/Babel/Api/SendMessage.ws", true);
	xhttp.setRequestHeader("Content-Type", "application/json");
	xhttp.setRequestHeader("Accept", "text/plain");
	xhttp.send(JSON.stringify(
		{
			"message": Message,
			"room": Room,
			"language": Language,
			"nickName": NickName
		}));
}

function NewMessage(Data)
{
	var Chat = document.getElementById("Chat");
	var Div = document.createElement("DIV");
	Chat.appendChild(Div);
	Div.innerHTML = Data.html;
	window.scrollTo(0, document.body.scrollHeight);
}

function PasteContent(Control, Event, Room, NickName)
{
	var Items = Event.clipboardData.items;
	var i, c = Items.length;

	for (i = 0; i < c; i++)
	{
		var Item = Items[i];

		if (Item.type.indexOf("image") >= 0)
		{
			Event.preventDefault();

			var Image = Item.getAsFile();
			var FileName = window.prompt("File Name:", Image.name);

			if (FileName)
			{
				var Form = new FormData();

				Form.append("Room", Room);
				Form.append("NickName", NickName);
				Form.append("Image", Image, FileName);

				var xhttp = new XMLHttpRequest();
				xhttp.onreadystatechange = function ()
				{
					if (xhttp.readyState == 4)
					{
						var MarkdownImageReference = xhttp.responseText;

						var Value = Control.value;
						var Start = Control.selectionStart;
						var End = Control.selectionEnd;
						Control.value = Value.substring(0, Start) + MarkdownImageReference + Value.substring(End);
						Control.selectionStart = Start;
						Control.selectionEnd = Start + MarkdownImageReference.length;
						Control.focus();

						AdaptSize(Control);
						InvalidatePreview();
					}
				};

				xhttp.open("POST", "/Babel/Api/Upload.ws", true);
				xhttp.setRequestHeader("Accept", "text/plain");
				xhttp.send(Form);
			}
			break;
		}
	}
}
