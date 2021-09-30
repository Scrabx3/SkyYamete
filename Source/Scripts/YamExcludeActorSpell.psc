Scriptname YamExcludeActorSpell extends ActiveMagicEffect  

YamMCM Property MCM Auto
Message Property excludeMsg  Auto  

Event OnEffectStart(Actor akTarget, Actor akCaster)
  int choice = excludeMsg.Show()
  If(choice == 0) ;Exclude Aggressor
	MCM.excludeActorAggr(akTarget)
  ElseIf(choice == 1) ;Exclude Victim
	MCM.excludeActorVic(akTarget)
  ElseIf(choice == 2) ;Both
	MCM.excludeActorAggr(akTarget)
	MCM.excludeActorVic(akTarget)
  EndIf
EndEvent