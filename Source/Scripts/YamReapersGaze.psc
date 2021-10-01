Scriptname YamReapersGaze extends ActiveMagicEffect

YamReapersMercyQst Property RM Auto
Keyword Property Protecc Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If(akTarget.GetLevel() < akCaster.GetLevel() && !akTarget.HasKeyword(Protecc) && !akTarget.IsChild())
		RM.ClaimVictim(akTarget)
	else
		Debug.Notification(akTarget.GetLeveledActorBase().GetName() + " resisted Reaper's Gaze")
	EndIf
EndEvent
