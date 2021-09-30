Scriptname YamResVictim extends ReferenceAlias

bool Property isDone Auto Hidden

Event OnInit()
  isDone = false
EndEvent

Function setDone()
  isDone = true
  (GetOwningQuest() as YamResolution).checkResolutionDone()
EndFunction

; YamResolution Property res Auto Hidden
; int userIndex
; YamResVictoire[] Property users Auto Hidden
; {Every Victoire claiming this Victim}
; int Property userNum Auto Hidden
; {The Number of Victoires having this Victim as Target & being near them}
; bool Property onlyOne Auto Hidden
; {This Victim can only be claimed by a single Victoire}
; int Property status Auto Hidden
; {0 - Unused, 1 - Claimed, 2 - Done}
;
; Event OnInit()
;   userNum = 0
;   userIndex = 0
;   onlyOne = false
;   status = 0
;   users = new YamResVictoire[15]
; EndEvent
;
; ;/ Assign that ReferenceAlias to be an aggressor for this Victim
; Returns true if that is the first aggressor, otherwise false /;
; bool Function claimVictim(YamResVictoire that)
;   users[userNum] = that
;   userIndex += 1
;   status = 1
;   If(userIndex == 1)
;     Debug.Trace("[Yamete] " + GetName() + " claimed by " + that.GetName())
;     return true
;   EndIf
;   Debug.Trace("[Yamete] " + GetName() + " failed to be claimed by " + that.GetName())
;   return false
; EndFunction
;
; Function setDone()
;   status = 2
;   (GetOwningQuest() as YamResolution).checkCloseCondition()
;   ;/ TODO if expanding this, reenable & refit into the new System /;
;   ; int i = 0
;   ; While(i < users.length)
;   ;   If(users[i])
;   ;     PO3_SKSEFunctions.SetLinkedRef(users[i].GetReference(), none, users[i].resLinked)
;   ;     users[i].findNextVictim()
;   ;   EndIf
;   ;   i += 1
;   ; EndWhile
; EndFunction
;
; Event OnDying(Actor akKiller)
;   setDone()
; EndEvent
