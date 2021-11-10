Scriptname YamShadowsCaptive extends ActiveMagicEffect
{Set the Target essential for 2 seconds if the Player has the Shadows Captive Perk & this attack is a Stealth Attack}

YamEnslavement Property RMQ Auto
bool essential

Event OnEffectStart(Actor akTarget, Actor akCaster)
	akTarget.SetNoBleedoutRecovery(true)
	ActorBase b = akTarget.GetLeveledActorBase()
	essential = b.IsEssential()
	If(!essential)
		b.SetEssential(true)
	EndIf
EndEvent

Event OnEnterBleedout()
	GoToState("Claimed")
	Actor target = GetTargetActor()
	Debug.Trace("[Yamete] <Shadows Captive> " + target + " Entered Bleedout")
	RMQ.ClaimVictim(target)
	If(!essential)
		target.RestoreActorValue("Health", Math.abs(target.GetActorValue("Health")) + 20)
		target.GetLeveledActorBase().SetEssential(false)
	EndIf
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	If(!essential)
		akTarget.GetLeveledActorBase().SetEssential(false)
	EndIf
	akTarget.SetNoBleedoutRecovery(false)
EndEvent

State Claimed
	Event OnEffectFinish(Actor akTarget, Actor akCaster)
	EndEvent
EndState