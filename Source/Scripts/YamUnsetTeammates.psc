Scriptname YamUnsetTeammates extends ActiveMagicEffect

Faction Property tmpTeammates Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
  akTarget.AddToFaction(tmpTeammates)
  akTarget.SetPlayerTeammate(false, false)
EndEvent
