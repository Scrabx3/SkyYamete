Scriptname YamBleedoutMark extends ActiveMagicEffect
{Cancels Bleedout on being healed with Restoration Spell
Stops others from attacking this Target if the Calm Mark fails to do so
Applies a Spell if enabled in the MCM}

YamMain Property Main Auto
Keyword Property MagicRestoreHealth Auto
Spell Property abToAdd Auto

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
  If(akSource && akSource.HasKeyword(MagicRestoreHealth))
    Main.BleedOutExit(GetTargetActor())
  EndIf
EndEvent

Event OnEffectStart(Actor akTarget, Actor akCaster)
  If(Main.MCM.bleedoutMarkImmunity && abToAdd != none && !akTarget.IsBleedingOut())
	   akTarget.AddSpell(abToAdd)
  EndIf
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
  If(abToAdd != none)
    akTarget.RemoveSpell(abToAdd)
  EndIf
EndEvent
