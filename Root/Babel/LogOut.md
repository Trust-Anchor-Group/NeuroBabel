Title: Neuro-Babel Logout
Description: This page logs you out from Neuro-Babel.
Date: 2023-04-17
Author: Peter Waher
Master: Master.md

=====================================================================================

Neuro-Babel Logout
======================

{{If exists(QuickLoginUser) then
(
	Destroy(QuickLoginUser);
	]]You have successfully logged out of the system.[[
)
else
	]]You're not logged into the system.[[
}}

[Click here to go back to the main page.](Index.md)

