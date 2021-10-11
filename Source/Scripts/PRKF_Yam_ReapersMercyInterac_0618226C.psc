;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 5
Scriptname PRKF_Yam_ReapersMercyInterac_0618226C Extends Perk Hidden

;BEGIN FRAGMENT Fragment_4
Function Fragment_4(ObjectReference akTargetRef, Actor akActor)
;BEGIN CODE
victim = akTargetRef as Actor
OpenMenu()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3(ObjectReference akTargetRef, Actor akActor)
;BEGIN CODE
victim = akTargetRef as Actor
OpenMenu()
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
	int color = 0xad0909 ; dark red
	bool hasType0 = victim.HasMagicEffectWithKeyword(Type0)
	bool isClaimed = victim.HasSpell(Claimed)
	bool isEnslaved = victim.HasKeyword(Enslaved)
	bool isProtecc = victim.HasKeyword(Protecc)
	bool isHunter = BlackMarket00.GetStageDone(100)
	String[] label = new String[8]
	If(isHunter)
		label[0] = "Claim"
	else
		label[0] = ""
	EndIf
	label[1] = "Open Inventory"
	label[2] = "Give Potion"
	label[3] = "Gnade"
	If(isHunter)
		label[4] = " Enslave"
	ElseIf(BlackMarket00.GetStageDone(50))
		label[4] = " Capture"
	else
		label[4] = ""
	EndIf
	label[5] = "Assault"
	label[6] = "Kill"
	label[7] = "Cancel"
	bool[] allow = new bool[8]
	allow[0] = !hasType0 && !isClaimed && !isEnslaved && !isProtecc && Player.HasPerk(Reaper[0])
	allow[1] = true
	allow[2] = Player.GetItemCount(HealingPotions) > 0
	allow[3] = Player.HasPerk(Gnade) && days <= gGameDaysPassed.Value
	allow[4] = (!hasType0 && !isEnslaved && !isProtecc) && ((label[4] == " Enslave" && ReapersMercy.availableSlots > 0 && Player.HasPerk(Reaper[1])) || (label[4] == " Capture" && BMCap.GetReference() == none))
	allow[5] = !hasType0 && (victim.HasKeyword(ActorTypeNPC) || MCM.FrameCreature)
	allow[6] = !isProtecc
	allow[7] = true
	UIWheelMenu Menu = UIExtensions.GetMenu("UIWheelMenu") as UIWheelMenu
	int i = 0
	While(i < label.length)
		Menu.SetPropertyIndexString("optionLabelText", i, label[i])
		If(allow[i])
			Menu.SetPropertyIndexBool("optionEnabled", i, true)
		else
			Menu.SetPropertyIndexInt("optionTextColor", i, color)
		EndIf
		i += 1
	EndWhile

	int choice = Menu.OpenMenu(victim)
	If(choice == 0) ; Claim
		ReapersMercy.ClaimVictim(victim)
	ElseIf(choice == 1) ; Rob
		victim.OpenInventory(true)
	ElseIf(choice == 2) ; Rescue (Potion)
		GivePotion()
	ElseIf(choice == 3) ; Gnade (Rescue without Potion)
		healSpell.Cast(Player, victim)
		days = gGameDaysPassed.Value + 0.5
	ElseIf(choice == 4) ; Enslave/Capture
		If(BlackMarket00.IsCompleted())
			If(!isClaimed)
				ReapersMercy.ClaimVictim(victim, true)
			else
				ReapersMercy.EnslaveVictim(victim)
			EndIf
		else
			BMCap.CaptureNPC(victim)
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

YamEnslavement Property ReapersMercy Auto

Message Property KillConformoation Auto

FormList Property HealingPotions Auto

Spell Property healSpell Auto

Spell Property Claimed Auto

Perk Property Gnade Auto

Perk[] Property Reaper Auto

Keyword Property Enslaved Auto

Keyword Property Protecc Auto

Keyword Property ActorTypeNPC Auto

Keyword Property Type0 Auto

GlobalVariable Property gGameDaysPassed Auto

Quest Property BlackMarket00 Auto

YamBlackMarket00Captured Property BMCap Auto
