Scriptname YamReapersMercyInventory extends ActiveMagicEffect  
{Lesser Power to add or remove Reapers Mercy via Shout Key}

Spell Property ReapersMercy Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Actor Player = Game.GetPlayer()
	If(Player.HasSpell(ReapersMercy))
		Player.RemoveSpell(ReapersMercy)
		Debug.Notification("Reapers Mercy removed")
	else
		Player.AddSpell(ReapersMercy)
	Endif
EndEvent
