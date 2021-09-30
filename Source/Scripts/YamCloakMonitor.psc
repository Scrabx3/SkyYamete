Scriptname YamCloakMonitor extends ActiveMagicEffect

; -------------------------- Property
Faction Property FriendFaction Auto

; -------------------------- Code
Event OnEffectStart(Actor akTarget, Actor akCaster)
  akTarget.AddToFaction(FriendFaction)
  akTarget.StopCombat()
  akCaster.StopCombatAlarm()
EndEvent


Event OnEffectFinish(Actor akTarget, Actor akCaster)
  akCaster.RemoveFromFaction(FriendFaction)
EndEvent