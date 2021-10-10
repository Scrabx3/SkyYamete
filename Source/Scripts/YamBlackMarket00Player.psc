Scriptname YamBlackMarket00Player extends ReferenceAlias

Location Property BlackMarket Auto

Auto State Waiting
	Event OnLocationChange(Location akOldLoc, Location akNewLoc)
		Quest q = GetOwningQuest()
		If(q.GetStage() > 20)
			GotoState("Done")
			return
		EndIf
		int lv = Game.GetPlayer().GetLevel()
		If(((Quest.GetQuest("MQ104").IsCompleted() && lv >= 7) || lv >= 15) && akOldLoc != BlackMarket && akNewLoc != BlackMarket)
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
	Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	EndEvent
EndState
