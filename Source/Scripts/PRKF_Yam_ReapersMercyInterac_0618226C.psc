;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 5
Scriptname PRKF_Yam_ReapersMercyInterac_0618226C Extends Perk Hidden

;BEGIN FRAGMENT Fragment_4
Function Fragment_4(ObjectReference akTargetRef, Actor akActor)
;BEGIN CODE
victim = akTargetRef as Actor
OpenMenu()
; SetInterfaceOptions()
; BleedoutInterface()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3(ObjectReference akTargetRef, Actor akActor)
;BEGIN CODE
victim = akTargetRef as Actor
OpenMenu()
; SetInterfaceOptions()
; BleedoutInterface()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

;/ NOTE Menu goes
0 Move on
1 Claim
2 Enslave
4 Open Inventory
5 Give Potion
6 Assault
7 Kill
/;
Actor victim = none
float days = 0.0

Function OpenMenu()
	Actor Player = Game.GetPlayer()
	bool hasType0 = victim.HasMagicEffectWithKeyword(Type0)
	bool isClaimed = victim.HasSpell(Claimed)
	bool isEnslaved = victim.HasKeyword(Enslaved)
	; Create Menu
	UIWheelMenu Menu = UIExtensions.GetMenu("UIWheelMenu") as UIWheelMenu
	; Option 0
	If(BlackMarket00.IsCompleted())
		Menu.SetPropertyIndexString("optionLabelText", 0, "Claim")
		If(hasType0 || isClaimed || isEnslaved)
			Menu.SetPropertyIndexInt("optionTextColor", 0, 0xad0909) ; dark red
		else
			Menu.SetPropertyIndexBool("optionEnabled", 0, true)
		EndIf
	EndIf
	; Option 1
	Menu.SetPropertyIndexString("optionLabelText", 1, "Open Inventory")
	Menu.SetPropertyIndexBool("optionEnabled", 1, true)
	; Option 2
	Menu.SetPropertyIndexString("optionLabelText", 2, "Give Potion")
	If(Player.GetItemCount(HealingPotions) == 0)
		Menu.SetPropertyIndexInt("optionTextColor", 2, 0xad0909) ; dark red
	else
		Menu.SetPropertyIndexBool("optionEnabled", 2, true)
	EndIf
	; Option 3
	If(BlackMarket00.IsCompleted())
		Menu.SetPropertyIndexString("optionLabelText", 3, "Gnade")
		If(!Player.HasPerk(Gnade) || days > gGameDaysPassed.Value)
			Menu.SetPropertyIndexInt("optionTextColor", 3, 0xad0909) ; dark red
		else
			Menu.SetPropertyIndexBool("optionEnabled", 3, true)
			days = gGameDaysPassed.Value + 0.5
		EndIf
	EndIf
	; Option 4
	bool base4 = hasType0 || isEnslaved
	If(BlackMarket00.IsCompleted())
		Menu.SetPropertyIndexString("optionLabelText", 4, " Enslave")
		If(base4 || ReapersMercy.availableSlots == 0)
			Menu.SetPropertyIndexInt("optionTextColor", 4, 0xad0909) ; dark red
		else
			Menu.SetPropertyIndexBool("optionEnabled", 4, true)
		EndIf
	Else ; If(BlackMarket00.GetStage() > 50)
		Menu.SetPropertyIndexString("optionLabelText", 4, " Capture")
		If(base4 || (BlackMarket00.GetAlias(0) as ReferenceAlias).GetReference() != none)
			Menu.SetPropertyIndexInt("optionTextColor", 4, 0xad0909) ; dark red
		else
			Menu.SetPropertyIndexBool("optionEnabled", 4, true)
		EndIf
	EndIf
	; Option 5
	Menu.SetPropertyIndexString("optionLabelText", 5, "Assault")
	If(hasType0 || !victim.HasKeyword(ActorTypeNPC) && !MCM.FrameCreature)
		Menu.SetPropertyIndexInt("optionTextColor", 5, 0xad0909) ; dark red
	else
		Menu.SetPropertyIndexBool("optionEnabled", 5, true)
	EndIf
	; Option 6
	Menu.SetPropertyIndexString("optionLabelText", 6, "Kill")
	Menu.SetPropertyIndexBool("optionEnabled", 6, true)
	; Option 7
	Menu.SetPropertyIndexString("optionLabelText", 7, "Cancel")
	Menu.SetPropertyIndexBool("optionEnabled", 7, true)

	int choice = Menu.OpenMenu(victim)
	If(choice == 0) ; Claim
		ReapersMercy.ClaimVictim(victim)
	ElseIf(choice == 1) ; Rob
		victim.OpenInventory(true)
	ElseIf(choice == 2) ; Rescue (Potion)
		GivePotion()
	ElseIf(choice == 3) ; Gnade (Rescue without Potion)
		healSpell.Cast(Player, victim)
	ElseIf(choice == 4) ; Enslave/Capture
		If(BlackMarket00.IsCompleted())
			If(!isClaimed)
				ReapersMercy.ClaimVictim(victim, true)
			else
				ReapersMercy.EnslaveVictim(victim)
			EndIf
		else
			(BlackMarket00 as YamBlackMarket).CaptureNPC(victim, Player)
		EndIf
	ElseIf(choice == 5) ; Assault
		If(YamAnimationFrame.StartAnimation(MCM, victim, PapyrusUtil.ActorArray(1, Game.GetPlayer()), self, 1, "YamReaperClaimed") > -1)
			RegisterForModEvent("HookAnimationEnd_YamReaperClaimed", "AfterScene")
		EndIf
	ElseIf(choice == 6) ; Kill
		If(MCM.Main.isImportant(victim))
			If(KillConformoation.Show() == 0)
				return
			Else
				ActorBase vb = victim.GetLeveledActorBase()
				If(vb.IsEssential())
					vb.SetEssential(false)
				EndIf
			EndIf
		EndIf
		; ReapersMercy.Main.playKillmove(Game.GetPlayer(), Victim)
		victim.Kill(Game.GetPlayer())
	; Else ; Cancel
		;
	EndIf
EndFunction

Function GivePotion()
	; This can only be selected if the Player has at least 1 Potion
	Actor PlayerRef = Game.GetPlayer()
	int[] itemCount = Utility.CreateIntArray(HealingPotions.GetSize())
	int i = 0
		While(i < HealingPotions.GetSize())
		itemCount[i] = PlayerRef.GetItemCount(HealingPotions.GetAt(i))
		i += 1
	EndWhile
	int potionSlot = 0
	i = 0
	If(MCM.iPotionUsage == 2) ; Most available
		While(i < HealingPotions.GetSize())
			If(itemCount[i] > potionSlot)
				potionSlot = itemCount[i]
			EndIf
			i += 1
		EndWhile
	ElseIf(MCM.iPotionUsage == 1) ; Strongest
		While(potionSlot == 0 && i < HealingPotions.GetSize())
			potionSlot = itemCount[i]
			i += 1
		EndWhile
	else ; Weakest
		i = HealingPotions.GetSize()
		While(potionSlot == 0 && i > 0)
				i -= 1
			potionSlot = itemCount[i]
		EndWhile
	EndIf
	PlayerRef.RemoveItem(HealingPotions.GetAt(potionSlot))
	healSpell.Cast(PlayerRef, victim)
EndFunction

Event AfterScene(int tid, bool hasPlayer)
	PostScene()
	UnregisterForModEvent("HookAnimationEnd_YamReaperClaimed")
EndEvent
Event OStimEnd(string eventName, string strArg, float numArg, Form sender)
	PostScene()
	UnregisterForModEvent("ostim_end")
EndEvent
Event OnQuestStop(Quest akQuest)
	PostScene()
	PO3_Events_Form.UnregisterForAllQuests(self)
EndEvent
Event OnUpdate()
	PostScene()
EndEvent

Function PostScene()
	Utility.Wait(0.3)
	MCM.Main.BleedOutEnter(victim, -1)
EndFunction

YamMCM Property MCM Auto

YamReapersMercyQst Property ReapersMercy Auto

; Message Property BleedoutInterfaceMsg Auto

Message Property KillConformoation Auto

FormList Property HealingPotions Auto

Spell Property healSpell Auto

Spell Property Claimed Auto

Perk Property Gnade Auto

Keyword Property Enslaved Auto

Keyword Property ActorTypeNPC Auto

Keyword Property Type0 Auto

GlobalVariable Property gGameDaysPassed Auto

Quest Property BlackMarket00 Auto

; GlobalVariable Property AllowClaim Auto
;
; GlobalVariable Property AllowEnslave Auto
;
; GlobalVariable Property AllowAssault Auto
;
; GlobalVariable Property AllowKill Auto
