;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname PRKF_Yam_EnslavementInteract_059F9EB9 Extends Perk Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akTargetRef, Actor akActor)
;BEGIN CODE
OpenMenu(akTargetRef as Actor)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Function OpenMenu(Actor target)
  bool isNPC = target.HasKeyword(ActorTypeNPC)
  bool doesFavor = target.IsDoingFavor()
  float isWaiting = target.GetActorValue("WaitingForPlayer")
  int color = 0xad0909 ; dark red
  String[] options = new String[8]
  If(isWaiting == 1)
    options[0] = "Follow"
  Else
    options[0] = "Wait"
  EndIf
  options[1] = "Trade"
  options[2] = "Outfit"
  options[3] = "Restrain"
  options[4] = "Set Free"
  options[5] = "Assault"
  If(doesFavor)
    options[6] = "End Command"
  Else
    options[6] = "Command"
  EndIf
  options[7] = "Cancel"
  bool[] allow = new bool[8]
  allow[0] = true
  allow[1] = true
  allow[2] = true
  allow[3] = false ;isNPC
  allow[4] = true
  allow[5] = isNPC || MCM.FrameCreature
  allow[6] = true
  allow[7] = true
  UIWheelMenu Menu = UIExtensions.GetMenu("UIWheelMenu") as UIWheelMenu
  int i = 0
  While(i < options.length)
		Menu.SetPropertyIndexString("optionLabelText", i, options[i])
		If(allow[i])
			Menu.SetPropertyIndexBool("optionEnabled", i, true)
		else
			Menu.SetPropertyIndexInt("optionTextColor", i, color)
		EndIf
		i += 1
	EndWhile

  int choice = Menu.OpenMenu(target)
  If(choice == 0) ; Wait/Follow
		target.SetActorValue("WaitingForPlayer", Math.abs(isWaiting - 1))
	ElseIf(choice == 1) ; Trade
		target.OpenInventory(true)
	ElseIf(choice == 2) ; Outfit
		Enslavement.SetOutfit(target)
	ElseIf(choice == 3) ; Restrain
		; TODO: implement me
	ElseIf(choice == 4) ; Set Free
    Enslavement.ReleaseVictim(target)
	ElseIf(choice == 5) ; Assault
		YamAnimationFrame.StartAnimationWithPlayer((Quest.GetQuest("Yam_Main") as YamMCM), target, 2)
	ElseIf(choice == 6) ; Do Favor
    target.SetDoingFavor(!doesFavor)
	EndIf
EndFunction

YamMCM Property MCM Auto

YamEnslavement Property Enslavement  Auto  

Keyword Property ActorTypeNPC Auto