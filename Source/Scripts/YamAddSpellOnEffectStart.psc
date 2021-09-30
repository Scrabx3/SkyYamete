Scriptname YamAddSpellOnEffectStart extends ActiveMagicEffect
{Add a Spell to this Actor while this Effect is active}

Spell Property spellToAdd Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
  akCaster.AddSpell(spellToAdd)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
  akCaster.RemoveSpell(spellToAdd)
EndEvent
