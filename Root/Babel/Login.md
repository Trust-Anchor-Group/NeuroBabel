Title: Neuro-Babel Login
Description: This page allows you to login using your TAG ID.
Date: 2023-04-17
Author: Peter Waher
Master: Master.md
JavaScript: Login.js
JavaScript: /Events.js
CSS: /QuickLogin.css
Neuron: {{GW:=Waher.IoTGateway.Gateway;Domain:=empty(GW.Domain) ? (x:=Before(After(GW.GetUrl("/"),"://"),"/");if contains(x,":") and exists(number(after(x,":"))) then "localhost:"+after(x,":") else "localhost") : GW.Domain}}
Parameter: from

=====================================================================================

Neuro-Babel Login
======================

In order to use the multi-language chat rooms provided by Neuro-Babel, you are required to login. You do this using the 
*TAG Digital ID*[^tagid]. You login by either scanning the code presented below, or, if viewing from the phone with the app,
clicking on the code directly.

<div id="quickLoginCode" data-mode="image" data-serviceId="{{QuickLoginServiceId(Request) ??? (
UserName:="Dev"+floor(Uniform(1,1000000));
TokenStr:=CreateJwt({
	"jti":Base64Encode(Gateway.NextBytes(32)),
	"sub":UserName,
	"iat":floor(NowUtc.Subtract(Waher.Content.JSON.UnixEpoch).TotalSeconds),
	"exp":floor(NowUtc.AddHours(1).Subtract(Waher.Content.JSON.UnixEpoch).TotalSeconds)
});
Token:=Create(Waher.Security.JWT.JwtToken,TokenStr);
QuickLoginUser:=Create(Waher.Security.JWT.ExternalUser,UserName,Token);
SeeOther(from))}}" 
data-purpose="To perform a quick login on {{Domain}}, to access Neuro-Babel. This login request is valid for one (1) minute."></div>

Do you need to create an account on this server? Install the app, and when you get the option to choose server, select the
*Invitation Code* option, and scan the code generated by clicking this link: 
<a href="/Babel/Invitation.md" target="_blank">Get invitation code</a>.

[^tagid]:	The *TAG Digital ID* is a smart phone app that can be downloaded for 
[Android](https://play.google.com/store/apps/details?id=com.tag.IdApp) or 
[iOS](https://apps.apple.com/tr/app/trust-anchor-id/id1580610247). You can also use
the more light-weight *Neuro-Access App*, also downloadable for
[Android](https://play.google.com/store/apps/details?id=com.tag.NeuroAccess) or
[iOS](https://apps.apple.com/app/neuro-access/id6446863270).
By using any of these apps, or any app derived from these, to login, you avoid 
having to create credentials on each site you visit. This helps you protect your 
credentials and make sure external entities never process your sensitive information 
without your consent.