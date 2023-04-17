({
	"message": Required(Str(PMessage)),
	"room": Required(Str(PRoom)),
	"language": Required(Str(PLanguage)),
	"nickName": Required(Str(PNickName))
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
Translations[Language]:=Html;

Background((
	foreach TabID in TabIDs do
	(
		TabInfo:=GetTabInformation(TabID);
		Language2:=TabInfo.Query.Language;
		if Language2=Language then
			ClientEvents.PushEvent([TabID],"NewMessage",{"html":Html})
		else
		(
			if !Translations.ContainsKey(Language2) then
			(
				if !exists(Key) then
					Key:=GetSetting("NeuroBabel.MsTranslator.Key","");

				if empty(Key) then
					Translations[Language2]:=Html
				else
				(
					Resp:=Post("https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&from="+Language+
						"&to="+Language2,[{"Text":PMessage}],{"Ocp-Apim-Subscription-Key":Key});

					PMessage2:=Resp[0].translations[0].text;
					Html2:=MarkdownToHtml(PMessage2);
					Translations[Language2]:=Html2;
				);
			);

			PushEvent(TabID,"NewMessage",{"html":Translations[Language2]})
		)
	)
));

Html