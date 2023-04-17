AuthenticateSession(Request,"QuickLoginUser");

({
	"message": Required(Str(PMessage)),
	"room": Required(Str(PRoom)),
	"language": Required(Str(PLanguage)),
	"nickName": Required(Str(PNickName)),
	"tabId": Required(Str(PTabId))
}:=Posted) ??? BadRequest("Data not in expected format.");

Prefix:="<span class='nickName'>" + MarkdownEncode(PNickName) + "</span>\r\n\r\n";
PMessage:=PMessage.
	Replace("{","\\{").
	Replace("}","\\}").
	Replace("\\\\{","\\{").
	Replace("\\\\}","\\}").
	Replace("<","\\<").
	Replace(">","\\>").
	Replace("\\\\<","\\<").
	Replace("\\\\>","\\>");

Html:=MarkdownToHtml(Prefix+PMessage);
TabIDs:=GetTabIDs("/Babel/Index.md",{"Room":PRoom});
Key:=null;
TranslationsHtml:={};
TranslationsMarkdown:={};
TranslationsHtml[PLanguage]:=Html;
TranslationsMarkdown[PLanguage]:=PMessage;

Background(
(
	ClientEvents.PushEvent([PTabId],"NewMessage",{"html":Html});

	Translate([From],[To],[Message]):=
	(
		Resp:=Post("https://api.openai.com/v1/chat/completions",
		{
			"model": "gpt-3.5-turbo",
			"messages":
			[
				{
					"role":"system",
					"content":"You help to translate Markdown text from language code "+From+" to language code "+To+". Input is in raw Markdown. Output must be in raw Markdown, keeping the Markdown formatting of the input. No descriptive text or additional formatting must be included. No examples added. Result must only include the translation. If the message is a question, don't answer the question, only translate the question."
				},
				{
					"role":"user",
					"content":Message
				}
			]
		},
		{
			"Accept":"application/json",
			"Authorization":"Bearer "+Key
		});

		Resp.choices[0].message.content ??? Message;
	);

	FindMucRoom([Room],[Domain],[JID]):=
	(
		RoomObj:=select top 1 
			* 
		from 
			Waher.Service.IoTBroker.MultiUserChat.MucRoom 
		where 
			Room=PRoom;

		if !exists(RoomObj) then
		(
			RoomObj:=Create(Waher.Service.IoTBroker.MultiUserChat.MucRoom);
			RoomObj.Room := Room;
			RoomObj.Domain := Domain;
			RoomObj.Creator := JID;
			RoomObj.Admins := [JID];
			RoomObj.Owners := [JID];
			RoomObj.Persistent := true;
			RoomObj.Archive := false;
			
			SaveNewObject(RoomObj);

			LogInformational("Room created", 
			{
				"Object": Room,
				"Actor": JID,
				"Room": Room,
				"Domain": Domain,
				"Creator": JID
			});
		);

		RoomObj
	);

	FindOccupant(RoomObj,[JID],[NickName],[FirstName],[LastName]):=
	(
		Occupant:=select top 1 
			* 
		from 
			Waher.Service.IoTBroker.MultiUserChat.MucOccupant 
		where 
			Room=RoomObj.Room and
			Domain=RoomObj.Domain and
			BareJid=JID;

		if !exists(Occupant) then
		(
			Occupant:=Create(Waher.Service.IoTBroker.MultiUserChat.MucOccupant);

			Occupant.Room:=RoomObj.Room;
			Occupant.Domain:=RoomObj.Domain;
			Occupant.BareJid:=JID;
			Occupant.NickName:=PNickName;
			Occupant.FirstName:=FirstName;
			Occupant.LastName:=LastName;

			SaveNewObject(Occupant);
		)
		else if Occupant.NickName!=PNickName or Occupant.FirstName!=FirstName or Occupant.LastName!=LastName then
		(
			Occupant.NickName:=PNickName;
			Occupant.FirstName:=FirstName;
			Occupant.LastName:=LastName;

			UpdateObject(Occupant);
		);

		Occupant
	);

	SaveMessage(RoomObj,OccupantObj,[Language],[Text],[Html],[Markdown]):=
	(
		Message:=Create(Waher.Service.IoTBroker.MultiUserChat.MucMessage);
		Message.ContentXml:=Waher.IoTGateway.Gateway.GetMultiFormatChatMessageXml(Text,Html,Markdown);
		Message.Language:=Language;
		Message.Room:=RoomObj.Room;
		Message.Domain:=RoomObj.Domain;
		Message.NickName:=OccupantObj.NickName;
		Message.FullJid:=OccupantObj.BareJid;
		Message.Timestamp:=NowUtc;
		Message.ArchiveDays:=RoomObj.Archive ? RoomObj.ArchiveDays : 0;

		SaveNewObject(Message);
	);

	foreach TabID in TabIDs do
	(
		TabInfo:=GetTabInformation(TabID);
		Language2:=TabInfo.Query.Language;
		if Language2=PLanguage then
		(
			if TabID != PTabId then
				ClientEvents.PushEvent([TabID],"NewMessage",{"html":Html});
		)
		else
		(
			if !TranslationsHtml.ContainsKey(Language2) then
			(
				if !exists(Key) then
					Key:=GetSetting("NeuroBabel.OpenAI.Key","");

				if empty(Key) then
				(
					TranslationsHtml[Language2]:=Html;
					TranslationsMarkdown[Language2]:=PMessage;
				)
				else
				(
					PMessage2:=Translate(PLanguage,Language2,PMessage);
					Html2:=MarkdownToHtml(Prefix+PMessage2);
					TranslationsHtml[Language2]:=Html2;
					TranslationsMarkdown[Language2]:=PMessage2;
				)
			);

			PushEvent(TabID,"NewMessage",{"html":TranslationsHtml[Language2]})
		)
	);

	JID:=QuickLoginUser.Properties.JID ??? null;

	if exists(XmppServerModule.Muc) and exists(JID) then
	(
		ParsedMarkdown:=ParseMarkdown(Markdown);
		Text:=ParsedMarkdown.GeneratePlainText();

		MainRoom:=FindMucRoom(PRoom,Waher.IoTGateway.Gateway.Domain,JID);
		MainOccupant:=FindOccupant(MainRoom,JID,PNickName,QuickLoginUser.Properties.FIRST,QuickLoginUser.Properties.LAST);
		SaveMessage(MainRoom,MainOccupant,"",Text,Html,PMessage);
		
		foreach Language in TranslationsHtml.Keys do
		(
			Markdown2:=TranslationsMarkdown[Language];
			ParsedMarkdown2:=ParseMarkdown(Markdown2);
			Text2:=ParsedMarkdown2.GeneratePlainText();

			Room:=FindMucRoom(PRoom+"."+Language,Waher.IoTGateway.Gateway.Domain,JID);
			Occupant:=FindOccupant(Room,JID,PNickName,QuickLoginUser.Properties.FIRST,QuickLoginUser.Properties.LAST);
			SaveMessage(Room,Occupant,Language,Text2,TranslationsHtml[Language],Markdown2);
		);

		SubRooms:=select 
			* 
		from 
			Waher.Service.IoTBroker.MultiUserChat.MucRoom 
		where 
			Room like (PRoom+".%") and 
			Domain=Waher.IoTGateway.Gateway.Domain;

		foreach SubRoom in SubRooms do
		(
			i:=LastIndexOf(SubRoom.Room,".");
			Language:=SubRoom.Substring(i+1);
			if !TranslationsHtml.ContainsKey(Language) then
			(
				Occupant:=FindOccupant(SubRoom,JID,PNickName,QuickLoginUser.Properties.FIRST,QuickLoginUser.Properties.LAST);

				if !exists(Key) then
					Key:=GetSetting("NeuroBabel.OpenAI.Key","");

				if empty(Key) then
					SaveMessage(SubRoom,Occupant,Language,Text,Html,PMessage)
				else
				(
					Markdown2:=Translate(PLanguage,Language,PMessage);
					Html2:=MarkdownToHtml(Prefix+Markdown2);
					ParsedMarkdown2:=ParseMarkdown(Markdown2);
					Text2:=ParsedMarkdown2.GeneratePlainText();
					SaveMessage(SubRoom,Occupant,Language,Text2,Html2,Markdown2);
				)
			)
		);
	)
));

Html