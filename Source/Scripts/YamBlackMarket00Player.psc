Scriptname YamBlackMarket00Player extends ReferenceAlias

Location Property BlackMarket Auto
Faction Property Slave Auto
Quest Property MQ104 Auto

Auto State Waiting
	Event OnLocationChange(Location akOldLoc, Location akNewLoc)
		Quest q = GetOwningQuest()
		If(q.GetStage() > 20)
			GotoState("Done")
			return
		EndIf
		Actor player = Game.GetPlayer()
		int lv = player.GetLevel()
		If(!player.IsInFaction(Slave) && ((MQ104.IsCompleted() && lv >= 7) || lv >= 15) && akOldLoc != BlackMarket && akNewLoc != BlackMarket)
			Debug.Trace("[Yamete] BlackMarket00 -> Enabling Letter")
			If(q.GetStageDone(20))
				q.SetStage(6)
			else
				q.SetStage(5)
			EndIf
			GotoState("Done")
		EndIf
	EndEvent
EndState

State Done
	;
EndState
