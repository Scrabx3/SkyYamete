Scriptname YamVictimMonitor extends Quest

; -------------------------- Properties
YamMCM Property MCM Auto
YamMain Property Main Auto
;/ 
Actor Property PlayerRef Auto

ReferenceAlias[] Property victims Auto
; -------------------------- Variables
int victimCounter = 0

; -------------------------- Code
Function addVictim(actor newVic)
  ; If there is an Actor in our current Slot, remove it first
  Actor victimRef = Victims[victimCounter].GetReference() as Actor
  If(victimRef)
    Victims[victimCounter].TryToClear()
    Core.BleedOutExit(victimRef)
  EndIf
  victims[victimCounter].ForceRefTo(newVic)
  Core.BleedOut(newVic)
  newVic.StopCombat()
  newVic.SetNoBleedoutRecovery(true)
  ; (victims[victimCounter] as YamVictim).Entry()
  victimCounter += 1
  If(victimCounter >= victims.Length)
    victimCounter = 0
  EndIf
  ; Notify (Dev only)
  If(MCM.bShowNotifyKD && !MCM.bSLScenes)
    If(MCM.bShowNotifyColorKD)
      Core.UILib.ShowNotification(newVic.GetLeveledActorBase().GetName() + "got knocked out by " + PlayerRef.GetLeveledActorBase().GetName(), "#302FCF")
    Else
      Debug.Notification(newVic.GetLeveledActorBase().GetName() + "got knocked out by " + PlayerRef.GetLeveledActorBase().GetName())
    EndIf
  EndIf
endFunction

Function removeVictim(actor vic)
  int count = victims.Length
  While(count)
    count -= 1
    If(victims[Count].GetReference() as Actor == vic)
      ; (victims[count] as YamVictim).Exit()
      victims[Count].TryToClear()
      ;If Actor is still in Bleedout, we throw them out of it
      Core.BleedOutExit(vic)
      return
    EndIf
  EndWhile
  vic.SetNoBleedoutRecovery(false)
endFunction


; Called when Player tries to interact with an bleeding out Actor
; Function InteractVictim(Actor victim, int choice)
;   ; Assault - Kill - Setfree - Cancel
;   If(choice == 0)
;     If(!MCM.bSLScenes)
;       Debug.Notification("Imagine a Scene to start here")
;       ; Notification if enabled
;       If(MCM.bShowNotify)
;         If(MCM.bShowNotifyColorKD)
;           Core.UILib.ShowNotification(PlayerRef.GetLeveledActorBase().GetName() + " assaults " + victim.GetLeveledActorBase().GetName(), "#FF164f")
;         Else
;           Debug.Notification(PlayerRef.GetLeveledActorBase().GetName() + " assaults " + victim.GetLeveledActorBase().GetName())
;         EndIf
;       EndIf
;     else
;       Actor[] Acteurs = new Actor[2]
;       If(MCM.bFemaleFirst && GetActorType(PlayerRef) == 1)
;         Acteurs[0] = PlayerRef
;         Acteurs[1] = victim
;       else
;         Acteurs[0] = victim
;         Acteurs[1] = PlayerRef
;       EndIf
;       sslBaseAnimation[] Anims
;       If(MCM.bUseAggressive)
;         Anims = Core.SL.GetAnimationsByTags(2, "Aggressive")
;       else
;         Anims = Core.SL.PickAnimationsByActors(acteurs)
;       EndIf
;       If(MCM.bTreatAsVictim)
;         Core.SL.StartSex(Acteurs, Anims, victim)
;       else
;         Core.SL.StartSex(Acteurs, Anims)
;       EndIf
;     EndIf
;   ElseIf(choice == 1)
;     If(victim.GetLeveledActorBase().IsEssential())
;       Debug.Notification("This Actor is essential and can't be killed")
;       return
;     Else
;       victim.Kill(PlayerRef)
;     EndIf
;   ElseIf(choice == 2)
;     removeVictim(victim)
;   EndIf
; EndFunction

int Function GetActorType(Actor me)
  int mySLGender = Core.SL.GetGender(me)
  If(mySLGender == 3) ;Female Creature
    return 4
  ElseIf(mySLGender == 2) ;Male Creature
    return 3
  Else ;Humanoid
    int myVanillaGender = me.GetLeveledActorBase().GetSex()
    If(myVanillaGender == mySLGender) ;Either male or female
      return myVanillaGender
    Else ;Futa
      return 2
    EndIf
  EndIf
endFunction
/;
