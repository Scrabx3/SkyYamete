;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 5
Scriptname QF_Yam_Scan_07005900 Extends Quest Hidden

;BEGIN ALIAS PROPERTY Follower4
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower4 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower3000
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower3000 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower4000
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower4000 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower0000
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower0000 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower1
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower1 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Combatant12
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Combatant12 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower1000
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower1000 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Combatant7
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Combatant7 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Combatant10
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Combatant10 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Combatant15
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Combatant15 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Combatant3
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Combatant3 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Combatant5
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Combatant5 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Player
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Player Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Combatant1
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Combatant1 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Combatant6
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Combatant6 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower2000
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower2000 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower2
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower2 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower3
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower3 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Combatant8
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Combatant8 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Combatant2
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Combatant2 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY playerEssential
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_playerEssential Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Combatant9
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Combatant9 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Combatant14
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Combatant14 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Combatant0
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Combatant0 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Combatant11
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Combatant11 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Combatant4
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Combatant4 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower0
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower0 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Combatant13
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Combatant13 Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
SendModEvent("Yam_CombatStop")
Utility.Wait(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN AUTOCAST TYPE YamScan
Quest __temp = self as Quest
YamScan kmyQuest = __temp as YamScan
;END AUTOCAST
;BEGIN CODE
kmyQuest.Stage1000()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN AUTOCAST TYPE YamScan
Quest __temp = self as Quest
YamScan kmyQuest = __temp as YamScan
;END AUTOCAST
;BEGIN CODE
;Quest ends here, going back to default cycle
kmyQuest.Stage999()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN AUTOCAST TYPE YamScan
Quest __temp = self as Quest
YamScan kmyQuest = __temp as YamScan
;END AUTOCAST
;BEGIN CODE
; kmyQuest.Stage1050()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
