Scriptname YamClaimMark extends ActiveMagicEffect

Spell Property claimed Auto
Keyword Property MagicRestoreHealth Auto

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
  If(akSource && akSource.HasKeyword(MagicRestoreHealth))
    GetTargetActor().RemoveSpell(claimed)
  EndIf
EndEvent
