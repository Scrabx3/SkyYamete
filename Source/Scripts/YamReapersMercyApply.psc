Scriptname YamReapersMercyApply extends ActiveMagicEffect
{The Cloak Spell applying Reapers Mercy to everyone in the Area. This is essentially the Mainscript for the Ability itself}

; ----------------------- Property
YamReapersMercy Property RM Auto
YamReapersMercyQst Property SQ Auto
YamMain Property Main Auto
Actor Property PlayerRef Auto
; ----------------------- Code
State Busy
	Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
		;
	EndEvent
EndState

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
	GotoState("Busy")
	If(akAggressor == PlayerRef)
		Spell source = akSource as Spell
	  Enchantment enchant = akSource as Enchantment
	  If(source && !source.IsHostile() || enchant && !enchant.IsHostile() || abHitBlocked && !RM.KdPierceBlock)
	    GotoState("")
	    return
	  EndIf
		Actor me = GetTargetActor()
		float healthP = me.GetActorValuePercentage("Health")
		float healthT = RM.KdHpThresh
		If(PlayerRef.IsDetectedBy(me))
			healthT += RM.KdHpUnseen
		EndIf
		If(healthP <= healthT && healthP > 0 || Main.getWornItems(me).length < RM.KdArmorThresh)
			SQ.ClaimVictim(me)
			RM.AddXp(1)
		EndIf
	Else
		Actor this = akAggressor as Actor
		If(this && this.IsCommandedActor() && this.IsHostileToActor(PlayerRef) == false)
			Actor me = GetTargetActor()
			float healthP = me.GetActorValuePercentage("Health")
			If(healthP <= RM.KdCommandedThresh && healthP > 0)
				SQ.ClaimVictim(me)
				RM.AddXp(1)
			Endif
		EndIf
	EndIf
	Utility.Wait(0.1)
	GotoState("")
EndEvent
