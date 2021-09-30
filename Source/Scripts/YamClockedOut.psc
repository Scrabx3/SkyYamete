Scriptname YamClockedOut extends ActiveMagicEffect

; -------------------------- Properties
YamMCM Property mcm Auto
Spell Property ClockOut Auto

; -------------------------- Code
; Event OnEffectStart(Actor akTarget, Actor akCaster)
;   RegisterForSingleUpdate(MCM.iClockOutDur + 1)
; EndEvent
;
; Event OnUpdate()
;   GetTargetActor().RemoveSpell(ClockOut)
; EndEvent
;
; Event OnDeath(Actor akKiller)
;   UnregisterForUpdate()
;   GetTargetActor().RemoveSpell(ClockOut)
; EndEvent
