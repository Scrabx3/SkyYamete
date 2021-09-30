Scriptname YamGatherActors extends ActiveMagicEffect
{This Script is called with an AoE Spell attaching itself to any that..
- is not the Player
- is not affected by Death Sentence
- is not dead

This is called at the Beginning of Resolution}

; REDUNDANT

YamResolution Property resu Auto
; Keyword Property BleedoutPerma Auto
Keyword Property YamMarks Auto

; Event OnEffectStart(Actor akTarget, Actor akCaster)
;   Debug.Trace("Yamete: Gather Actors affected " + akTarget.GetLeveledActorBase().GetName())
;   resu.AddActor(akTarget)
; EndEvent
