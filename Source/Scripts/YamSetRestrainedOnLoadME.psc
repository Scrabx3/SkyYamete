Scriptname YamSetRestrainedOnLoadME extends ActiveMagicEffect  

Event OnLoad()
	GetTargetActor().SetRestrained(true)
EndEvent