;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 6
Scriptname QF_Yam_LeftForDead_052D55CA Extends Quest Hidden

;BEGIN ALIAS PROPERTY InnBed
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_InnBed Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY currentHold
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_currentHold Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY InnOrHome
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_InnOrHome Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY MapMarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_MapMarker Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY InnMarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_InnMarker Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY FallbackMarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_FallbackMarker Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Player
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Player Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY OutsideMarkerHold
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_OutsideMarkerHold Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY OutsideMarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_OutsideMarker Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY EdgeMarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_EdgeMarker Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY EdgeMarkerHold
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_EdgeMarkerHold Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY currentLoc
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_currentLoc Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
Actor PlayerRef = Game.GetPlayer()
Game.DisablePlayerControls()

; Imod n stuff
; FadeToBlackImod.Apply()

If(Alias_Follower.GetReference() && Alias_InnBed.GetReference())
  ; We have a Follower that isnt knocked down and found a save loc
  Utility.Wait(1)
  Debug.SendAnimationEvent(PlayerRef, "StaggerStart")
  PlayerRef.MoveTo(Alias_InnBed.GetReference())
  SetStage(5)
else
  ObjectReference toPortTo = none
  If(Alias_EdgeMarker.GetReference())
    toPortTo = Alias_EdgeMarker.GetReference()
  ElseIf(Alias_OutsideMarker.GetReference())
    toPortTo = Alias_OutsideMarker.GetReference()
  ElseIf(Alias_EdgeMarkerHold.GetReference())
    toPortTo = Alias_EdgeMarkerHold.GetReference()
  ElseIf(Alias_OutsideMarkerHold.GetReference())
    toPortTo = Alias_OutsideMarkerHold.GetReference()
  ElseIf(Alias_MapMarker.GetReference())
    toPortTo = Alias_MapMarker.GetReference()
  ElseIf(Alias_FallbackMarker.GetReference())
    toPortTo = Alias_FallbackMarker.GetReference()
  EndIf
  If(toPortTo != none)
    ObjectReference coin = toPortTo.PlaceAtMe(Gold001)
    coin.MoveTo(toPortTo, afZOffset = 50.0)
    Utility.Wait(1)
    Debug.SendAnimationEvent(PlayerRef, "StaggerStart")
    PlayerRef.MoveTo(coin)
    coin.disable()
    coin.delete()
    PlayerRef.StopCombatAlarm()
    SetStage(10)
  else
    Debug.SendAnimationEvent(PlayerRef, "StaggerStart")
    Debug.Notification("Failed to find a Teleport Location")
    FadeToBlackImod.PopTo(FadeToBlackBackImod)
    Game.EnablePlayerControls()
    PlayerRef.StopCombatAlarm()
    Stop()
  EndIf
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
Actor PlayerRef = Game.GetPlayer()
Utility.Wait(2)

Game.EnablePlayerControls()
PlayerRef.StopCombatAlarm()
FadeToBlackImod.PopTo(FadeToBlackBackImod)

Game.EnablePlayerControls()
Stop()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
ScanQ.SetStage(999)

SetStage(1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
Actor PlayerRef = Game.GetPlayer()
Alias_Follower.GetReference().MoveTo(Alias_InnMarker.GetReference())
Utility.Wait(2)

Game.EnablePlayerControls()
PlayerRef.StopCombatAlarm()

FadeToBlackImod.PopTo(Woozy)
Game.GetPLayer().PlayIdle(WoozyIdle)
; FolScene.Start()
Game.EnablePlayerControls()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

ImageSpaceModifier Property FadeToBlackImod  Auto

ImageSpaceModifier Property Woozy  Auto

Idle Property WoozyIdle  Auto

ImageSpaceModifier Property FadeToBlackBackImod  Auto

MiscObject Property Gold001 Auto

Idle Property Wounded  Auto

Idle Property NextClip  Auto

Scene Property FolScene  Auto

Quest Property ScanQ  Auto  

ImageSpaceModifier Property FadeToBlackHoldImod  Auto  
