Scriptname YamScanClose extends ActiveMagicEffect
{Script acts as a Clock, when the Cloak this Scirpt rests on ends, the associated Quest Stops}

YamScan Property Scan Auto

Event OnEffectFinish(Actor akTarget, Actor akCaster)
  Scan.Stop()
  ; Scan.MCM.Main.RemoveBleedoutMarks(akCaster)
EndEvent
