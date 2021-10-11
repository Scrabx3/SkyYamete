Scriptname YamReapersMercy extends Quest


YamMCM Property MCM Auto
Actor Property PlayerRef Auto
GlobalVariable Property ShowMenu Auto
GlobalVariable Property LevelUp Auto
GlobalVariable Property Level Auto
GlobalVariable Property Perks Auto
GlobalVariable Property Experience Auto
{Currently stored Experience}
GlobalVariable Property xpReqLv Auto
{Required XP to gain a new Level}
GlobalVariable Property xpReqPerk Auto
{Required Xp to gain a new Perk}
Perk[] Property ReapersMercy Auto ; 1 - Unlock Claim; 2 - Unlock Enslave
Perk[] Property Anculo Auto ; Claim a Victim upon Bleedout; 10/15/20% Chance
Perk Property Gnade Auto ; Heal a Victim from Bleedout without using a Potion; 12h Cooldown
Perk Property PiercingStrike Auto ; Reapers Mercy ignores Blocks
Perk[] Property Ravage Auto ; Increase efficiency of Weakened by 10/15/20/25/30%
Perk[] Property LurkingThreat Auto ; Stealthattacks Claim a Victim at 5/7,5/10% Chance
Perk Property ShadowsCaptive Auto ; Stealthkill set the Target essential for 2 Seconds
Perk[] Property ReapersResilience Auto ; Ignore Knockdown Triggers per fight; 1/2
Perk Property ReapersGaze Auto ; Gain an Ability to instantly knockdown a Target without Combat (non hostile)
Message[] Property SkillDescriptions Auto ; Skill Docs for non Skilltree Users
; --------------------------- Variables
int Property ReapersMercyRank Auto Hidden
int Property AnculoRank Auto Hidden
int Property LurkingThreatRank Auto Hidden
int Property RavageRank Auto Hidden
int Property ReapersResilienceRank Auto Hidden
int gainedPerks = 1 ; Total Perks Gained

; ======================================================================
; ================================== SETUP
; ======================================================================
Event OnInit()
	xpReqPerk.Value = 3 * gainedPerks + 1
	SetLvXp()
	UpdateCurrentInstanceGlobal(xpReqPerk)
	UpdateCurrentInstanceGlobal(xpReqLv)
EndEvent

; ======================================================================
; ================================== REAPERS MERCY PROGRESSION
; ======================================================================
Function OpenMenu()
	If(MCM.bNoSkilltree)
		UIListMenu Menu = UIExtensions.GetMenu("UIListMenu") as UIListMenu
		int ps = PlayerRef.HasPerk(PiercingStrike) as int
		int gn = PlayerRef.HasPerk(Gnade) as int
		int sc = PlayerRef.HasPerk(ShadowsCaptive) as int
		int rg = PlayerRef.HasPerk(ReapersGaze) as int
		If(Level.Value >= 20 || ReapersMercyRank == 0)
			Menu.AddEntryItem("Prison of Flesh and Blood (" + ReapersMercyRank + "/2)")
		EndIf
		If(ReapersMercyRank > 0)
			If(Level.Value >= (20 + AnculoRank * 20) || AnculoRank == 3)
				Menu.AddEntryItem("Anculo (" + AnculoRank + "/3)")
			EndIf
			If(Level.Value >= 45)
				Menu.AddEntryItem("Gnade (" + gn + "/1)")
			EndIf
			If(Level.Value >= 30)
				Menu.AddEntryItem("Piercing Strike (" + ps + "/1)")
			EndIf
			If(ps > 0 && Level.Value >= (40 + RavageRank * 10))
				Menu.AddEntryItem("Ravage (" + RavageRank + "/5)")
			EndIf
			If(Level.Value >= (20 + LurkingThreatRank * 15))
				Menu.AddEntryItem("Lurking Threat (" + LurkingThreatRank + "/3)")
			EndIf
			If(LurkingThreatRank > 0 && Level.Value >= 75)
				Menu.AddEntryItem("Shadow's Captive (" + sc + "/1)")
			EndIf
			If(LurkingThreatRank > 0 || ps > 0)
				If(Level.Value >= (90 + ReapersResilienceRank * 10))
					Menu.AddEntryItem("Reaper's Resilience (" + ReapersResilienceRank + "/2)")
				EndIf
				If(ReapersResilienceRank > 0 && Level.Value >= 100)
					Menu.AddEntryItem("Reaper's Gaze (" + rg + "/1)")
				EndIf
			EndIf
		EndIf
		Menu.AddEntryItem("Cancel")
		Menu.OpenMenu()
		string sol = Menu.GetResultString()
		If(sol == ("Reapers Mercy (" + ReapersMercyRank + "/2)") && ReapersMercyRank < 2 && SkillDescriptions[0].Show() == 0)
			PlayerRef.AddPerk(ReapersMercy[ReapersMercyRank])
			ReapersMercyRank += 1
		ElseIf(sol == ("Anculo (" + AnculoRank + "/3)") && AnculoRank < 3 && SkillDescriptions[1].Show() == 0)
			PlayerRef.AddPerk(Anculo[AnculoRank])
			AnculoRank += 1
		ElseIf(sol == ("Gnade (" + gn + "/1)") && gn < 1 && SkillDescriptions[2].Show() == 0)
			PlayerRef.AddPerk(Gnade)
		ElseIf(sol == ("Piercing Strike (" + ps + "/1)") && ps < 1 && SkillDescriptions[3].Show() == 0)
			PlayerRef.AddPerk(PiercingStrike)
		ElseIf(sol == ("Ravage (" + RavageRank + "/5)") && RavageRank < 5 && SkillDescriptions[4].Show() == 0)
			PlayerRef.AddPerk(Ravage[RavageRank])
			RavageRank += 1
		ElseIf(sol == ("Lurking Threat (" + LurkingThreatRank + "/3)") && LurkingThreatRank < 3 && SkillDescriptions[5].Show() == 0)
			PlayerRef.AddPerk(LurkingThreat[LurkingThreatRank])
			LurkingThreatRank += 1
		ElseIf(sol == ("Shadow's Captive (" + sc + "/1)") && sc < 1 && SkillDescriptions[6].Show() == 0)
			PlayerRef.AddPerk(ShadowsCaptive)
		ElseIf(sol == ("Reaper's Resilience (" + ReapersResilienceRank + "/2)") && ReapersResilienceRank < 2 && SkillDescriptions[7].Show() == 0)
			PlayerRef.AddPerk(ReapersResilience[ReapersResilienceRank])
			ReapersResilienceRank += 1
		ElseIf(sol == ("Reaper's Gaze (" + rg + "/1)") && rg < 1 && SkillDescriptions[8].Show() == 0)
			PlayerRef.AddPerk(ReapersGaze)
		EndIf
	else
		ShowMenu.Value = 1
		Utility.Wait(1)
		ReapersMercyRank = GetPerkRank(ReapersMercy)
		AnculoRank = GetPerkRank(Anculo)
		LurkingThreatRank = GetPerkRank(LurkingThreat)
		RavageRank = GetPerkRank(Ravage)
		ReapersResilienceRank = GetPerkRank(ReapersResilience)
	EndIf
EndFunction
int Function GetPerkRank(Perk[] p)
	int sol = 0
	int i = 0
	While(i < p.length)
		sol += PlayerRef.HasPerk(p[i]) as int
		i += 1
	EndWhile
	return sol
EndFunction

; Gain 2 Xp for a Knockdown
; Gain 3 Xp for each sold Victim
; Gain 7 Xp for completed Quests
; New Perk = 3 * gainedPerks + 1
; New Level = Math.pow((0.09 * Level.Value), 1.4) + 5.0
Function AddXp(float e)
	Experience.Value += e * 4.7
	If(Level.Value < 100)
		xpReqLv.Value -= e
		If(xpReqLv.Value <= 0)
			Level.Value += 1
			LevelUp.Value = Level.Value
			float leftover = Math.abs(xpReqLv.Value)
			SetLvXp()
			xpReqLv.value -= leftover
		EndIf
	EndIf
	UpdateCurrentInstanceGlobal(Experience)
	UpdateCurrentInstanceGlobal(xpReqLv)
EndFunction

Function AddPerk()
	If(Experience.Value < xpReqPerk.Value)
		XpMissPerk()
		return
	EndIf
	gainedPerks += 1
	Perks.Value += 1
	Experience.Value -= xpReqPerk.Value
	xpReqPerk.Value = 3 * gainedPerks + 1
	UpdateCurrentInstanceGlobal(Experience)
	UpdateCurrentInstanceGlobal(xpReqPerk)
EndFunction
Function XpMissPerk()
	Debug.Notification("You don't have enough Experience to obtain a new Perk Point.")
EndFunction

Function LevelUp()
	If(Experience.Value < xpReqLv.Value)
		XpMissLevel()
		return
	EndIf
	Level.Value += 1
	LevelUp.Value = Level.Value
	Experience.Value -= xpReqLv.Value
	SetLvXp()
	UpdateCurrentInstanceGlobal(Experience)
	UpdateCurrentInstanceGlobal(xpReqLv)
EndFunction
Function XpMissLevel()
	Debug.Notification("You don't have enough Experience to level up.")
EndFunction

Function SetLvXp()
	xpReqLv.Value = Math.floor(Math.pow(0.2 * Level.Value, 1.7) + 4.7)
EndFunction
