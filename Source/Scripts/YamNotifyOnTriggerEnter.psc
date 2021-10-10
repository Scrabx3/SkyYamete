Scriptname YamNotifyOnTriggerEnter extends ObjectReference

string Property notify Auto
{The Message to display}
int Property cooldown = 10 Auto
{How long until the Message can be displayed again. Default: 10}
bool Property onlyOnce = false Auto
{If the Message should only be displayed once. Default: false}

Auto State Ready
	Event OnTriggerEnter(ObjectReference akActionRef)
		Debug.Notification(notify)
		If(!onlyOnce)
			GotoState("Wait")
		else
			GotoState("Done")
		EndIf
	EndEvent
EndState

State Wait
	Event OnBeginState()
		RegisterForSingleUpdate(cooldown)
	EndEvent

	Event OnUpdate()
		GotoState("Ready")
	EndEvent
EndState

State Done
	;
EndState
