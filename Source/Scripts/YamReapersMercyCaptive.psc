Scriptname YamReapersMercyCaptive extends ActiveMagicEffect
{If the Player has the "Reapers Captive" perk, this Effect will be applied to an Actor the Player is attacking with physical Weaponry
The target will be set essential for 2 seconds}

Event OnEffectStart(Actor akTarget, Actor akCaster)
  If(akTarget.GetLeveledActorBase().IsEssential())
    GotoState("IsEssential")
  else
    akTarget.GetLeveledActorBase().SetEssential(true)
  EndIf
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
  akTarget.GetLeveledActorBase().SetEssential(false)
EndEvent

State IsEssential
	Event OnEffectFinish(Actor akTarget, Actor akCaster)
	EndEvent
EndState
