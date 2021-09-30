Scriptname YamAddPackageOnEffectStart extends ActiveMagicEffect

Package Property packageToAdd Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
  ActorUtil.AddPackageOverride(akCaster, packageToAdd)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
  ActorUtil.RemovePackageOverride(akCaster, packageToAdd)
EndEvent
