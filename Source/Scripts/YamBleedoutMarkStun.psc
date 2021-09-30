Scriptname YamBleedoutMarkStun extends ActiveMagicEffect

Faction Property PlayerFollowerFaction Auto
Package Property Yam_DoNothingPackage Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
  If(akTarget == Game.GetPlayer())
    Game.SetPlayerAIDriven(true)
  else
		ActorUtil.AddPackageOverride(akTarget, Yam_DoNothingPackage, 100)
    ; akTarget.SetDontMove(true)
    akTarget.SetRestrained(true)
    If(akTarget.IsInFaction(PlayerFollowerFaction))
      akTarget.SetAV("WaitingForPlayer", 1)
    EndIf
		akTarget.EvaluatePackage()
  EndIf
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
  If(akTarget == Game.GetPlayer())
    Game.SetPlayerAIDriven(false)
  else
		ActorUtil.RemovePackageOverride(akTarget, Yam_DoNothingPackage)
    ; akTarget.SetDontMove(false)
    akTarget.SetRestrained(false)
    If(akTarget.IsInFaction(PlayerFollowerFaction))
      akTarget.SetAV("WaitingForPlayer", 0)
    EndIf
		akTarget.EvaluatePackage()
  EndIf
EndEvent
