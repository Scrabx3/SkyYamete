;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 10
Scriptname QF_Yam_Resolution_05446F08 Extends Quest Hidden

;BEGIN ALIAS PROPERTY Victoire00000001001
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire00000001001 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire00000000
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire00000000 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY PlayerVic
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_PlayerVic Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victim00
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victim00 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY LeadDefeated
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_LeadDefeated Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Player
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Player Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire00000001000
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire00000001000 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victim00000000
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victim00000000 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victim00000
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victim00000 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY playerEssential
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_playerEssential Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire00000
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire00000 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire00000001
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire00000001 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Victoire00
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Victoire00 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY LeadVictoire
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_LeadVictoire Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN AUTOCAST TYPE YamResolution
Quest __temp = self as Quest
YamResolution kmyQuest = __temp as YamResolution
;END AUTOCAST
;BEGIN CODE
; Everyone will be ignored, move temporary bleeding out Actors out of Bleedout & let them run
; Only set the Player and their Followers free, no running

kmyQuest.Stage1000()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
; Get the Victoires Alliance Faction
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN CODE
; the StartUp Stage effectively acts as an OnInit Event which disallows most of the SetUp to execute properly.. so yay.
; RegisterForSingleUpdate(2)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_7
Function Fragment_7()
;BEGIN CODE
; chainREntryScene.Start()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
; start robbed Scene
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_9
Function Fragment_9()
;BEGIN CODE
SendModEvent("Yam_ResolutionStop")
Utility.Wait(1.0)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

SPELL Property AoEFleeMark  Auto
