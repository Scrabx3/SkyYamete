Scriptname YamVictim extends ReferenceAlias

; -------------------------- Properties
; -------------------------- Variables
Actor mySelf
float myAggression
; -------------------------- Code
; "AV Aggression cannot be modified in Scripts" zzz
Function Entry()
  mySelf = GetActorReference()
  Utility.Wait(0.1)
  myAggression = mySelf.GetBaseActorValue("Aggression")
  mySelf.ForceActorValue("Aggression", 0)
EndFunction

Function Exit()
  mySelf.SetActorValue("Aggression", myAggression)
EndFunction
