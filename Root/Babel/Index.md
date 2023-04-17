Title: Neuro-Babel
Description: Main page the Multi-language Multi-user chat service.
Date: 2023-04-15
Author: Peter Waher
Master: Master.md
Cache-Control: max-age=0, no-cache, no-store
Parameter: Room
Parameter: Language
Parameter: NickName

==================

TAG Neuro-Babel
==================

Welcome to TAG Neuro-Babel[^babel]. This service allows you to create multi-lingual multi-user chat rooms, where each participant
can participate using their own language. The service makes sure to translate each incoming message to the preferred language
of each participant.

**Privacy**: All messages are *public*, and may be forwarded to OpenAI for translation to other languages. (OpenAI may
sometimes be inventive in the translation.)

**Ephemeral**: None of the messages are persisted on the server. You can therefore not see any chat history. It also
means that if you loose connection, you may loose messages being sent during the disconnection. Any images or
documents shared with the group will also be removed from the server after a short while.

<form>

{{if empty(Room) then ]]
<fieldset>
<legend>Select room</legend>

First, you need to select a room. Type in the room identifier below, and press *Continue*.

<label for="Room">Room:</label>  
<input type="text" name="Room" id="Room" required autofocus/>

<button type="button" class="posButton" onclick="SetRoom()">Continue</button>
</fieldset>
[[
else if empty(Language) then
(
	ClientLanguage:=((Request.Header.AcceptLanguage.Records[0].Item) ??? "");
	]]
<fieldset>
<legend>Select language</legend>

Then, you need to select the language you wish to use. Select the language from the list below, and press *Continue*.

<label for="Language">Language:</label>  
<select name="Language" id="Language" required autofocus>
<option((ClientLanguage="af" ? " selected" : "")) value="af">Afrikaans</option>
<option((ClientLanguage="ar" ? " selected" : "")) value="ar">Arabic</option>
<option((ClientLanguage="bn" ? " selected" : "")) value="bn">Bangla</option>
<option((ClientLanguage="bs" ? " selected" : "")) value="bs">Bosnian</option>
<option((ClientLanguage="bg" ? " selected" : "")) value="bg">Bulgarian</option>
<option((ClientLanguage="yue" ? " selected" : "")) value="yue">Cantonese</option>
<option((ClientLanguage="ca" ? " selected" : "")) value="ca">Catalan</option>
<option((ClientLanguage="zh-Hans" ? " selected" : "")) value="zh-Hans">Chinese (Simplified)</option>
<option((ClientLanguage="zh-Hant" ? " selected" : "")) value="zh-Hant">Chinese (Traditional)</option>
<option((ClientLanguage="hr" ? " selected" : "")) value="hr">Croatian</option>
<option((ClientLanguage="cs" ? " selected" : "")) value="cs">Czech</option>
<option((ClientLanguage="da" ? " selected" : "")) value="da">Danish</option>
<option((ClientLanguage="nl" ? " selected" : "")) value="nl">Dutch</option>
<option((ClientLanguage="en" ? " selected" : "")) value="en">English</option>
<option((ClientLanguage="et" ? " selected" : "")) value="et">Estonian</option>
<option((ClientLanguage="fj" ? " selected" : "")) value="fj">Fijian</option>
<option((ClientLanguage="fil" ? " selected" : "")) value="fil">Filipino</option>
<option((ClientLanguage="fi" ? " selected" : "")) value="fi">Finnish</option>
<option((ClientLanguage="fr" ? " selected" : "")) value="fr">French</option>
<option((ClientLanguage="de" ? " selected" : "")) value="de">German</option>
<option((ClientLanguage="el" ? " selected" : "")) value="el">Greek</option>
<option((ClientLanguage="ht" ? " selected" : "")) value="ht">Haitian Creole</option>
<option((ClientLanguage="he" ? " selected" : "")) value="he">Hebrew</option>
<option((ClientLanguage="hi" ? " selected" : "")) value="hi">Hindi</option>
<option((ClientLanguage="mww" ? " selected" : "")) value="mww">Hmong Daw</option>
<option((ClientLanguage="hu" ? " selected" : "")) value="hu">Hungarian</option>
<option((ClientLanguage="is" ? " selected" : "")) value="is">Icelandic</option>
<option((ClientLanguage="id" ? " selected" : "")) value="id">Indonesian</option>
<option((ClientLanguage="ga" ? " selected" : "")) value="ga">Irish</option>
<option((ClientLanguage="it" ? " selected" : "")) value="it">Italian</option>
<option((ClientLanguage="ja" ? " selected" : "")) value="ja">Japanese</option>
<option((ClientLanguage="sw" ? " selected" : "")) value="sw">Kiswahili</option>
<option((ClientLanguage="ko" ? " selected" : "")) value="ko">Korean</option>
<option((ClientLanguage="lv" ? " selected" : "")) value="lv">Latvian</option>
<option((ClientLanguage="lt" ? " selected" : "")) value="lt">Lithuanian</option>
<option((ClientLanguage="mg" ? " selected" : "")) value="mg">Malagasy</option>
<option((ClientLanguage="ms" ? " selected" : "")) value="ms">Malay</option>
<option((ClientLanguage="mt" ? " selected" : "")) value="mt">Maltese</option>
<option((ClientLanguage="nb" ? " selected" : "")) value="nb">Norwegian</option>
<option((ClientLanguage="fa" ? " selected" : "")) value="fa">Persian</option>
<option((ClientLanguage="pl" ? " selected" : "")) value="pl">Polish</option>
<option((ClientLanguage="pt-br" ? " selected" : "")) value="pt-br">Portuguese (Brazil)</option>
<option((ClientLanguage="pt-pt" ? " selected" : "")) value="pt-pt">Portuguese (Portugal)</option>
<option((ClientLanguage="pa" ? " selected" : "")) value="pa">Punjabi</option>
<option((ClientLanguage="ro" ? " selected" : "")) value="ro">Romanian</option>
<option((ClientLanguage="ru" ? " selected" : "")) value="ru">Russian</option>
<option((ClientLanguage="sr-Cyrl" ? " selected" : "")) value="sr-Cyrl">Serbian (Cyrillic)</option>
<option((ClientLanguage="sr-Latn" ? " selected" : "")) value="sr-Latn">Serbian (Latin)</option>
<option((ClientLanguage="sk" ? " selected" : "")) value="sk">Slovak</option>
<option((ClientLanguage="sl" ? " selected" : "")) value="sl">Slovenian</option>
<option((ClientLanguage="es" ? " selected" : "")) value="es">Spanish</option>
<option((ClientLanguage="sv" ? " selected" : "")) value="sv">Swedish</option>
<option((ClientLanguage="ty" ? " selected" : "")) value="ty">Tahitian</option>
<option((ClientLanguage="ta" ? " selected" : "")) value="ta">Tamil</option>
<option((ClientLanguage="te" ? " selected" : "")) value="te">Telugu</option>
<option((ClientLanguage="th" ? " selected" : "")) value="th">Thai</option>
<option((ClientLanguage="to" ? " selected" : "")) value="to">Tongan</option>
<option((ClientLanguage="tr" ? " selected" : "")) value="tr">Turkish</option>
<option((ClientLanguage="uk" ? " selected" : "")) value="uk">Ukrainian</option>
<option((ClientLanguage="ur" ? " selected" : "")) value="ur">Urdu</option>
<option((ClientLanguage="vi" ? " selected" : "")) value="vi">Vietnamese</option>
<option((ClientLanguage="cy" ? " selected" : "")) value="cy">Welsh</option>
<option((ClientLanguage="yua" ? " selected" : "")) value="yua">Yucatec Maya</option>
</select>

<button type="button" class="posButton" onclick="SetLanguage('((Room))')">Continue</button>
</fieldset>
[[
)
else if empty(NickName) then ]]
<fieldset>
<legend>Select language</legend>

Finally, you need to select a Nick-Name you want to use in the chat, then press *Continue*.

<label for="Language">Nick-Name:</label>  
<input type="text" name="NickName" id="NickName" required autofocus/>

<button type="button" class="posButton" onclick="SetNickName('((Room))','((Language))')">Continue</button>
</fieldset>
[[
else
]]
<fieldset>
<legend>Room Chat</legend>
<div id="Chat">
</div>
</fieldset>

<label for="Message">Message: <span class='note'>You can format messages using [Markdown](/Markdown.md), and paste images from clipboard.</span></label>
<textarea id="Message" name="Message" onkeydown="TrapTabCREsc(this,event,'((Room))','((Language))','((NickName))')" 
	onpaste="PasteContent(this,event,'((Room))','((NickName))')" required>
</textarea>

<button type="button" class="posButton" onclick="SendMessage('((Room))','((Language))','((NickName))')">Send</button>
<button type="button" class="negButton" onclick="CancelMessage()">Cancel</button>

<fieldset>
<legend>Preview</legend>
<div id="Preview"/>
</fieldset>

[[
}}

</form>

[^babel]: The name is a tribute to Douglas Adams's [*Babel Fish*](https://en.wikipedia.org/wiki/Babel_Fish_%28website%29).