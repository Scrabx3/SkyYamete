Scriptname YamBlackMarketLeash extends ActiveMagicEffect

;/ Code here got moved into "YamBlackMarket00Captured"

YamBlackMarket00 Property BM  Auto
bool active

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Debug.Trace("[YAMETE]: Leash Applied")
	active = true
	While(active)
		If(akTarget.GetDistance(akCaster) > 600)
			Debug.Trace("[Yamete] BlackMarket Leash -> Distance too great")
			If(akTarget.GetWorldSpace() == akCaster.GetWorldSpace())
				Debug.Trace("[Yamete] BlackMarket Leash -> Different Worldspace")
				Dispel()
			EndIf
		EndIf
		Utility.Wait(0.2)
	EndWhile
EndEvent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
	Spell yep = akSource as Spell
	If(yep && !yep.IsHostile())
		return
	ElseIf(Utility.RandomInt(0, 99) < 20)
		Dispel()
	EndIf
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	Debug.Trace("[YAMETE]: Leash Removed")
	active = false
	BM.CutLoose()
	Debug.MessageBox("Your target managed to free itself and runs away.\nMake sure to always stay close to it and avoid Combat!")
EndEvent

/;
