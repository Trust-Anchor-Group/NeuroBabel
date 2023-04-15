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

foreach TabID in TabIDs do
(
	TabInfo:=GetTabInformation(TabID);
	if TabInfo.Query.Language=Language then
		ClientEvents.PushEvent([TabID],"NewMessage",{"html":Html});
);

Html