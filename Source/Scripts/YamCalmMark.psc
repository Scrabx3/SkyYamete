Scriptname YamCalmMark extends ActiveMagicEffect
{Script to turn Actors non-hostile towards the Caster}

Actor Property PlayerRef Auto
Faction Property Yam_FriendFaction Auto
{Faction which is befriended with most? all? hostile Enemy Factions in the Game, used to make any Actor non-hostile towards this one}
Faction Property Yam_CalmMark_TmpTeammates Auto
{A Faction for Player Teammates that currently have their Flag removed. Actors in this Faction would still be allied with the Player but dont inherit their Combat Behavior}
Spell Property Yam_CalmMark_UnsetTeammates Auto
{Collects all Player Teammates and temporarily puts them into the tmpTeammate Faction}
Spell Property Yam_CalmMark_SetTeammates Auto
{Collects everyone inside the tmpTeammate Faction and makes them a proper Teammate again}
Keyword Property Yam_CalmMarkKW Auto
{Keyword for every Calm Mark owning Effect used in Yamete}

; ================================== CODE
Event OnEffectStart(Actor akTarget, Actor akCaster)
  ; Teammates inherit their Combat Behavior from the Player, meaning they consider friend and ally whatever is friend or ally to the PC..
  If(akCaster == PlayerRef)
    ; Thus, if the Mark affects the Player, its mandatory to disable any Teammates Teammate-Statue while affected by this mark. Otherwise all of the players teammates would also be affected by it
    Yam_CalmMark_UnsetTeammates.Cast(PlayerRef)
  ElseIf(akCaster.IsPlayerTeammate())
    ; or if they are currently a Player Teammate, their flag has to be temporarily removed
    akCaster.SetPlayerTeammate(false, false)
    akCaster.AddToFaction(Yam_CalmMark_TmpTeammates)
  EndIf
  ; Friend Faction so they arent considered Hostile towards anyone and take them out of Combat
  akCaster.AddToFaction(Yam_FriendFaction)
  Utility.Wait(0.3)
  akCaster.StopCombat()
	akCaster.StopCombatAlarm()
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
  ; Dont do a thing if another Effect still applies the Mark
  If(akCaster.HasMagicEffectWithKeyword(Yam_CalmMarkKW))
    return
  EndIf
  ; Reset Teammate Flags
  If(akCaster == PlayerRef)
    ; Get all tmpTeammates that arent currently marked themselves and turn them into proper teammates again
    ; (Marked Teammates will be readded when they lose their mark)
    Yam_CalmMark_SetTeammates.Cast(PlayerRef)
  ElseIf(akCaster.IsInFaction(Yam_CalmMark_TmpTeammates) && !PlayerRef.HasMagicEffectWithKeyword(Yam_CalmMarkKW))
    ; If we are a teammate and the Player isnt currently marked, make us a Teammate again. Otherwise we wait for the setTeamate Spell Cast
    akCaster.SetPlayerTeammate(true, true)
		akCaster.RemoveFromFaction(Yam_CalmMark_TmpTeammates)
  EndIf
  akCaster.RemoveFromFaction(Yam_FriendFaction)
EndEvent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
  Spell source = akSource as Spell
  Enchantment enchant = akSource as Enchantment
  If(source)
    If(!source.IsHostile())
      return
    EndIf
  ElseIf(enchant)
    If(!enchant.IsHostile())
      return
    EndIf
  EndIf
  Actor caster = GetCasterActor()
  caster.AddToFaction(Yam_FriendFaction)
  caster.StopCombat()
  caster.StopCombatAlarm()
EndEvent
