Scriptname YamAgentsRobes extends ActiveMagicEffect

Spell Property AgentsRobes Auto

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
	AgentsRobes.Cast(GetTargetActor(), akAggressor)
EndEvent
