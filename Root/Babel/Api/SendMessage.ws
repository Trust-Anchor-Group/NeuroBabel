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
LogDebug(Html);
TabIDs:=GetTabIDs("/Babel/Index.md",{"Room":PRoom});
LogDebug(TabIDs);

PushEvent("/Babel/Index.md",{"Room":PRoom},"NewMessage",{"html":Html});

Html