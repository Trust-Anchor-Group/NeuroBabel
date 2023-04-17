({
	"message": Required(Str(PMessage)),
	"room": Required(Str(PRoom)),
	"language": Required(Str(PLanguage)),
	"nickName": Required(Str(PNickName)),
	"tabId": Required(Str(PTabId))
}:=Posted) ??? BadRequest("Data not in expected format.");

PMessage:="<span class='nickName'>" + MarkdownEncode(PNickName) + "</span>\r\n\r\n" + PMessage.
	Replace("{","\\{").
	Replace("}","\\}").
	Replace("\\\\{","\\{").
	Replace("\\\\}","\\}").
	Replace("<","\\<").
	Replace(">","\\>").
	Replace("\\\\<","\\<").
	Replace("\\\\>","\\>");

Html:=MarkdownToHtml(PMessage);
TabIDs:=GetTabIDs("/Babel/Index.md",{"Room":PRoom});
Key:=null;
Translations:={};
Translations[PLanguage]:=Html;

Background((
	ClientEvents.PushEvent([PTabId],"NewMessage",{"html":Html});

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
			if !Translations.ContainsKey(Language2) then
			(
				if !exists(Key) then
					Key:=GetSetting("NeuroBabel.OpenAI.Key","");

				if empty(Key) then
					Translations[Language2]:=Html
				else
				(
					Resp:=Post("https://api.openai.com/v1/chat/completions",
					{
						"model": "gpt-3.5-turbo",
						"messages":
						[
							{
								"role":"system",
								"content":"You help to translate Markdown text from language code "+PLanguage+" to language code "+Language2+". Input is in raw Markdown. Output must be in raw Markdown, keeping the Markdown formatting of the input. No descriptive text or additional formatting must be included. No examples added. Result must only include the translation."
							},
							{
								"role":"user",
								"content":PMessage
							}
						]
					},
					{
						"Accept":"application/json",
						"Authorization":"Bearer "+Key
					});

					PMessage2:=(Resp.choices[0].message.content ??? PMessage);
					Html2:=MarkdownToHtml(PMessage2);
					Translations[Language2]:=Html2
				)
			);

			PushEvent(TabID,"NewMessage",{"html":Translations[Language2]})
		)
	)
));

Html