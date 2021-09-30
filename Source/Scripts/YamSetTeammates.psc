Scriptname YamSetTeammates extends ActiveMagicEffect

Faction Property tmpTeammates Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
;	If(akTarget != Game.GetPlayer())
		akTarget.SetPlayerTeammate(true, true)
		akTarget.RemoveFromFaction(tmpTeammates)
;	EndIf
EndEvent
