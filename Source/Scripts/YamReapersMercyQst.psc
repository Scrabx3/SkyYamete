Scriptname YamReapersMercyQst extends Quest Conditional

; --------------- Property
YamMain Property Main Auto
YamMCM Property MCM Auto
YamReapersVictim[] Property Victims Auto
Keyword Property BleedoutMark Auto
Outfit Property nudeOutfit Auto
Spell Property claimed Auto
Idle Property OffsetBoundStandingStart Auto
Idle Property BleedoutEnter Auto
; --------------- Variables
int Property availableSlots Auto Hidden Conditional

Event OnInit()
	availableSlots = Victims.length
EndEvent
; ======================================================================
; ================================== SLOT MANAGEMENT
; ======================================================================
;/ A claimed Victim is defined by its Claim Mark. An Enslaved Victim is defined by its Keyword
Both should always hold the Friend Faction /;
Function ClaimVictim(Actor victim, bool enslave = false)
	If(victim.IsBleedingOut())
		victim.SetNoBleedoutRecovery(true)
	ElseIf(!victim.HasMagicEffectWithKeyword(BleedoutMark))
		Main.BleedOutEnter(victim, -1)
	EndIf
	victim.AddSpell(claimed, false)
	Utility.Wait(2.7)
	If(enslave)
		EnslaveVictim(victim)
	ElseIf(victim.GetNoBleedoutRecovery())
		victim.PlayIdle(BleedoutEnter)
	EndIf
EndFunction

;/ NOTE This is expected to always be called on a claimed Victim /;
Function EnslaveVictim(Actor victim)
	int i = findVictim(none)
	If(i != -1)
		If(victim.IsBleedingOut())
			victim.SetNoBleedoutRecovery(false)
			victim.RestoreAV("Health", 50.0)
		else
			Debug.SendAnimationEvent(victim, "staggerStart")
		EndIf
		Utility.Wait(2)
		; victim.PlayIdle(OffsetBoundStandingStart)
		victims[i].ForceRefTo(victim)
		ActorBase base = victim.GetLeveledActorBase()
		StorageUtil.SetFormValue(victim, "YamReaperOutfit", base.GetOutfit())
		If(base.IsUnique())
			victim.SetRelationshipRank(Game.GetPlayer(), -2)
		EndIf
		victim.RemoveSpell(claimed)
		victim.UnequipAll()
		Utility.Wait(0.3)
		victim.SetOutfit(nudeOutfit)
		victim.QueueNiNodeUpdate()
		victim.IgnoreFriendlyHits(true)
		availableSlots -= 1
	else
		Debug.Notification("[Yamete] There was an Error enslaving this Target; no Valid Slots found")
	EndIf
EndFunction


bool Function ReleaseVictim(Actor that)
	int slot = findVictim(that)
	If(slot < 0)
		return false
	else
		Victims[slot].FreeEnslaved()
		availableSlots += 1
		return true
	EndIf
EndFunction


; ======================================================================
; ================================== INTERACTION
; ======================================================================
Function StartAnimationVictim(Actor that)
	YamAnimationFrame.StartAnimationWithPlayer(MCM, that, 2)
EndFunction

Function SetOutfit(Actor that)
	int slot = findVictim(that)
	If(slot < 0)
		return
	else
		that.UnequipAll()
		Utility.Wait(0.3)
		that.SetOutfit(nudeOutfit)
		ObjectReference outfitChest = Victims[slot].storedOutfit
		outfitChest.Activate(Game.GetPlayer())
		; Wait for Menu to close..
		Utility.Wait(0.3)
		; Set Outfit
		LeveledItem lvOutfit = Victims[slot].myCustomOutfit.GetNthPart(0) as LeveledItem
		lvOutfit.Revert()
		Utility.Wait(0.1)
		int parts = outfitChest.GetNumItems()
		If(parts > 0)
			int i = 0
			While(i < parts)
				lvOutfit.AddForm(outfitChest.GetNthForm(i), 0, 1)
				i += 1
			EndWhile
		EndIf
		Utility.Wait(0.1)
		that.SetOutfit(Victims[slot].myCustomOutfit)
		that.QueueNiNodeUpdate()
	EndIf
EndFunction

; ======================================================================
; ================================== UTILITY
; ======================================================================
int Function findVictim(ObjectReference that)
	int i = 0
	While(i < Victims.length)
		ObjectReference tmp = Victims[i].GetReference()
		If(tmp == that)
			return i
		EndIf
		i += 1
	EndWhile
	return -1
EndFunction
