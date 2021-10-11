Scriptname YamBlackMarketTransfer extends ActiveMagicEffect
{Script resting on the Transfer Spell for Selling Victims to Charon}

ObjectReference Property OutofBound Auto ; Apparently NPC can headtrack disabled Actors which is kinda awkard

Event OnCellDetach()
	Actor me = GetTargetActor()
	me.MoveTo(OutofBound)
	me.KillEssential()
	me.Disable()
EndEvent
