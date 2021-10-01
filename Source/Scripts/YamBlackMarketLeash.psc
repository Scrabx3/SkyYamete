Scriptname YamBlackMarketLeash extends ActiveMagicEffect

YamBlackMarket Property BM  Auto
bool active

Event OnEffectStart(Actor akTarget, Actor akCaster)
	active = true
	While(active)
		If(akTarget.GetDistance(akCaster) > 500 && akTarget.IsInInterior() == akCaster.IsInInterior())
			Dispel()
		EndIf
		Utility.Wait(0.2)
	EndWhile
EndEvent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
	Spell yep = akSource as Spell
	If(yep && !yep.IsHostile())
		return
	ElseIf(Utility.RandomInt(0, 99) < 30)
		Dispel()
	EndIf
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	active = false
	BM.CutLoose()
	Debug.MessageBox("Your target managed to free itself and runs away.\nMake sure to always stay close to it and avoid Combat!")
EndEvent
