Scriptname YamEndlessAlias extends ReferenceAlias

Event OnUnload()
  (GetOwningQuest() as YamEndless).startTimer()
EndEvent

Event OnCellAttach()
  (GetOwningQuest() as YamEndless).startAnimation()
EndEvent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
  Spell source = akSource as Spell
  Enchantment enchant = akSource as Enchantment
  If(source && !source.IsHostile())
    return
  ElseIf(enchant && !enchant.IsHostile())
    return
  EndIf
  YamEndless e = GetOwningQuest() as YamEndless
  If(e.mcm.bSLAllowed)
    YamSexLab.stopAnimation(GetReference() as Actor)
  EndIf
  e.StopQst()
EndEvent
