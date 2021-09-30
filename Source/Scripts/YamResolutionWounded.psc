Scriptname YamResolutionWounded extends ActiveMagicEffect

YamResolution Property resu Auto
Keyword Property MagicRestoreHealth Auto

; REDUNDANT

; Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
;   If(akSource)
;     If(akSource.HasKeyword(MagicRestoreHealth))
;       resu.swapWounded(GetCasterActor())
;     EndIf
;   EndIf
; EndEvent
