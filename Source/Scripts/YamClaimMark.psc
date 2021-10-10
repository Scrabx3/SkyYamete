Scriptname YamClaimMark extends ActiveMagicEffect

Spell Property claimed Auto
Spell Property abToAdd Auto
Keyword Property MagicRestoreHealth Auto

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
	If(akAggressor == Game.GetPlayer() && akSource && akSource.HasKeyword(MagicRestoreHealth))
		GetTargetActor().RemoveSpell(claimed)
	EndIf
EndEvent

Event OnEffectStart(Actor akTarget, Actor akCaster)
  If(abToAdd != none && !akTarget.IsBleedingOut())
	   akTarget.AddSpell(abToAdd)
  EndIf
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
  If(abToAdd != none)
    akTarget.RemoveSpell(abToAdd)
  EndIf
EndEvent
