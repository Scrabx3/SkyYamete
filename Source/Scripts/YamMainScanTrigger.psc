Scriptname YamMainScanTrigger extends ActiveMagicEffect

YamScan Property Yam_Scan Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
  ; Debug.Notification("Yam Scan Trigger; Combat Detected..")
	If(Yam_Scan.GetStage() == 999)
		Yam_Scan.GotoState("")
	else
		Yam_Scan.Start()
	EndIf
EndEvent
