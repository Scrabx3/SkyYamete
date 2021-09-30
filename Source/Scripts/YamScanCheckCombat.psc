Scriptname YamScanCheckCombat extends ActiveMagicEffect

YamScan Property Scan  Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
  If(akTarget.GetCombatTarget() != none)
    Scan.inCombat = true
  EndIf
EndEvent
