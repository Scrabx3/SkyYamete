Scriptname YamBleedoutExitOnEffectFinish extends ActiveMagicEffect
{Pulls this Actor out of (a Yamete owned) Bleedout when the Effect ends}

YamMain Property Main Auto

Event OnEffectFinish(Actor akTarget, Actor akCaster)
  Main.BleedOutExit(akTarget)
EndEvent
