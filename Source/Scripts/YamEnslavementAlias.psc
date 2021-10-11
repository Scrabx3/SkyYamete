Scriptname YamEnslavementAlias extends ReferenceAlias

ObjectReference Property storedOutfit Auto
Outfit Property myCustomOutfit Auto
Spell Property ReaperFlee Auto

Function FreeEnslaved(bool sold = false)
	Actor victim = Self.GetReference() as Actor
	Clear()
	If(!sold)
		victim.IgnoreFriendlyHits(false)
		victim.SetOutfit(StorageUtil.GetFormValue(victim, "YamReaperOutfit") as Outfit)
		Debug.SendAnimationEvent(victim, "staggerStart")
		ReaperFlee.Cast(Game.GetPlayer(), victim)
		StorageUtil.SetFormValue(victim, "YamReaperOutfit", none)
	EndIf
	storedOutfit.RemoveAllItems(victim)
	(myCustomOutfit.GetNthPart(0) as LeveledItem).Revert()
	(GetOwningQuest() as YamEnslavement).availableSlots += 1
EndFunction

; Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
; 	If(!akAggressor || akAggressor == Game.GetPlayer())
; 		return
; 	ElseIf(Utility.RandomFloat(0, 0.99) < 0.075)
; 		FreeEnslaved()
; 	EndIf
; EndEvent
;
; Event OnUnload()
; 	FreeEnslaved()
; EndEvent

Event OnDying(Actor akKiller)
	StorageUtil.SetFormValue(GetReference() as Actor, "YamReaperOutfit", none)
	(GetOwningQuest() as YamEnslavement).availableSlots += 1
	storedOutfit.RemoveAllItems(GetReference())
	(myCustomOutfit.GetNthPart(0) as LeveledItem).Revert()
	Clear()
EndEvent
