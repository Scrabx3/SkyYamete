Scriptname YamShadowsCaptive extends ActiveMagicEffect
{Set the Target essential for 2 seconds if the Player has the Shadows Captive Perk & this attack is a Stealth Attack}

YamEnslavement Property RMQ Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Debug.MessageBox("Shadows Captive applied")
	ActorBase b = akTarget.GetLeveledActorBase()
  If(b.IsEssential())
		Debug.MessageBox("Target is essential")
    GotoState("IsEssential")
  else
		Debug.MessageBox("Setting target essential")
    b.SetEssential(true)
  EndIf
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	Debug.MessageBox("Unsetting target essential")
  akTarget.GetLeveledActorBase().SetEssential(false)
EndEvent

State IsEssential
	Event OnEffectFinish(Actor akTarget, Actor akCaster)
		Debug.MessageBox("Effect finish target non-essential")
	EndEvent
EndState

Event OnEnterBleedout()
	RMQ.ClaimVictim(GetTargetActor())
EndEvent
