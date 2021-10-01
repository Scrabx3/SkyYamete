Scriptname YamBlackMarket extends Quest

ReferenceAlias Property Captured Auto
Idle Property OffsetBoundStandingStart Auto
Spell Property BlackMarketLeash Auto
Spell Property FleeMark Auto

Function CaptureNPC(Actor victim, Actor slaver)
	Captured.ForceRefTo(victim)
	If(victim.GetLeveledActorBase().IsUnique())
		victim.SetRelationshipRank(Game.GetPlayer(), -1)
	EndIf
	(Quest.GetQuest("Yam_Main") as YamMain).BleedoutExit(victim)
	Utility.Wait(1.7)
	victim.PlayIdle(OffsetBoundStandingStart)
	BlackMarketLeash.Cast(slaver, victim)
EndFunction

Function CutLoose()
	FleeMark.Cast(Captured.GetReference())
	Captured.Clear()
EndFunction
