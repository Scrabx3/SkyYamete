Scriptname YamBlackMarket00Captured extends ReferenceAlias
{Simulation of the Leash Effect on a Captured Victim}

ReferenceAlias Property BMMAINcap0 Auto
Idle Property OffsetBoundStandingStart Auto
Spell Property CalmMark Auto
Spell Property FleeMark Auto
bool break

Function CaptureNPC(Actor victim)
	; victim.AddSpell(CalmMark)
	BMMAINcap0.ForceRefTo(victim)
	ForceRefTo(victim)
	If(victim.GetLeveledActorBase().IsUnique())
		victim.SetRelationshipRank(Game.GetPlayer(), -1)
	EndIf
	(Quest.GetQuest("Yam_Main") as YamMain).BleedoutExit(victim)
	Utility.Wait(1.7)
	victim.PlayIdle(OffsetBoundStandingStart)
	RegisterForSingleUpdate(5)
EndFunction

Event OnUpdate()
	break = false
	Actor player = Game.GetPlayer()
	ObjectReference me = GetReference()
	While(!break)
		If(me.GetDistance(player) > 800 && me.GetWorldSpace() == player.GetWorldSpace())
			Clear()
		EndIf
		Utility.Wait(0.2)
	EndWhile
	CutLoose()
EndEvent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
	Spell yep = akSource as Spell
	Enchantment yip = akSource as Enchantment
	If(yep && !yep.IsHostile() || yip && !yip.IsHostile())
		return
	ElseIf(Utility.RandomInt(0, 99) < 20)
		Clear()
	EndIf
EndEvent

Function CutLoose()
	If(GetOwningQuest().GetStage() < 90)
		Debug.Trace("[Yametet] BM00 -> CutLoose()")
		FleeMark.Cast(GetReference())
		BMMAINcap0.Clear()
		Clear()
		Debug.MessageBox("Your target managed to free itself and runs away.\nMake sure to always stay close to it and avoid Combat!")
	EndIf
EndFunction

; Give control of the Captured NPC over to Charon
Function Clear()
	break = true
	Parent.Clear()
EndFunction
