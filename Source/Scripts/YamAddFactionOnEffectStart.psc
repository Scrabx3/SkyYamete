Scriptname YamAddFactionOnEffectStart extends ActiveMagicEffect  

Faction Property FactionToAdd Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
  akCaster.AddToFaction(FactionToAdd)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
  akCaster.RemoveFromFaction(FactionToAdd)
EndEvent