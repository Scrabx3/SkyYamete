Scriptname YamLurkingThreat extends ActiveMagicEffect

YamEnslavement Property RMQ Auto
YamReapersMercy Property RM Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If(Utility.RandomInt(0, 99) < (2.5 + RM.LurkingThreatRank * 2.5))
		RMQ.claimVictim(akTarget)
	EndIf
EndEvent
