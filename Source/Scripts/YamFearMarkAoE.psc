Scriptname YamFearMarkAoE extends ActiveMagicEffect
{Affects all Actors that are not affected by a non-permanent Bleedout and are not part of an endless Rape}

YamMain Property Main Auto
SPELL Property FearMark  Auto
Keyword Property bleedoutMarkTemporary Auto
Faction Property PlayerFollowerFaction Auto
Faction Property friendFac Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If(akTarget != Game.GetPlayer())
		If(akTarget.HasMagicEffectWithKeyword(bleedoutMarkTemporary))
			Main.BleedoutExit(akTarget)
			If(!akTarget.IsInFaction(PlayerFollowerFaction) && !akTarget.IsPlayerTeammate())
	      FearMark.Cast(akTarget)
	    else
	      akTarget.SetPlayerTeammate(true, true)
	    EndIf
		EndIf
		akTarget.RemoveFromFaction(friendFac)
		akTarget.EvaluatePackage()
	EndIf
EndEvent
