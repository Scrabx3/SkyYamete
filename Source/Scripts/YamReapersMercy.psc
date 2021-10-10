Scriptname YamReapersMercy extends Quest

; --------------------------- Property
YamMCM Property MCM Auto
Actor Property PlayerRef Auto
; ======================================================================
; ================================== SETUP
; ======================================================================
Event OnInit()
	NextPerkReq.Value = 3 * gainedPerks + 1
	SetLvXp()
	UpdateCurrentInstanceGlobal(NextPerkReq)
	UpdateCurrentInstanceGlobal(lvProgress)
EndEvent

; ======================================================================
; ================================== REAPERS MERCY PROGRESSION
; ======================================================================
GlobalVariable Property ShowMenu Auto
Perk[] Property ReapersMercy Auto
{1 - Unlock Claim; 2 - Unlock Enslave}
Perk[] Property Anculo Auto
{Claim a Victim upon Knockdown; 10/15/20% Chance}
Perk Property Gnade Auto
{Heal a Victim from Knockdown without using a Potion; 12h Cooldown}
Perk Property PiercingStrike Auto
{Reapers Mercy ignores Blocks}
Perk[] Property Ravage Auto
{Increase efficiency of Weakened by 10/15/20/25/30%}
Perk[] Property LurkingThreat Auto
{Stealthattacks Claim a Victim at 5/7,5/10% Chance}
Perk Property ShadowsCaptive Auto
{Stealthkill set the Target essential for 2 Seconds}
Perk[] Property ReapersResilience Auto
{Ignore 1/2 Knockdown Triggers per fight}
Perk Property ReapersGaze Auto
{Gain an ABility to instantly knockdown a Target without Combat (non hostile)}
Message[] Property SkillDescriptions Auto
; -------------------------
int Property ReapersMercyRank Auto Hidden
int Property AnculoRank Auto Hidden
int Property LurkingThreatRank Auto Hidden
int Property RavageRank Auto Hidden
int ReapersResilienceRank

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
		ReapersMercyRank = (PlayerRef.HasPerk(ReapersMercy[0]) as int) + (PlayerRef.HasPerk(ReapersMercy[1]) as int)
		AnculoRank = (PlayerRef.HasPerk(Anculo[0]) as int) + (PlayerRef.HasPerk(Anculo[1]) as int) + (PlayerRef.HasPerk(Anculo[2]) as int)
		LurkingThreatRank = (PlayerRef.HasPerk(LurkingThreat[0]) as int) + (PlayerRef.HasPerk(LurkingThreat[1]) as int) + (PlayerRef.HasPerk(LurkingThreat[2]) as int)
		RavageRank = (PlayerRef.HasPerk(Ravage[0]) as int) + (PlayerRef.HasPerk(Ravage[1]) as int) + (PlayerRef.HasPerk(Ravage[2]) as int) + (PlayerRef.HasPerk(Ravage[3]) as int) + (PlayerRef.HasPerk(Ravage[4]) as int)
		ReapersResilienceRank =  (PlayerRef.HasPerk(ReapersResilience[0]) as int) + (PlayerRef.HasPerk(ReapersResilience[1]) as int)
	EndIf
EndFunction

; ======================================================================
; ================================== XP SYSTEM
; ======================================================================
GlobalVariable Property LevelUp Auto
GlobalVariable Property Level Auto
GlobalVariable Property Perks Auto
GlobalVariable Property Experience Auto
{Currently stored Experience}
GlobalVariable Property NextPerkReq Auto
{Required Xp to gain a new Perk}
int gainedPerks = 1
; Total Perks Gained
GlobalVariable Property lvProgress Auto
{Required Xp for a new Level}
; Gain 2 Xp for a Knockdown
; Gain 3 Xp for each sold Victim
; Gain 5 Xp for completed Quests

; New Perk = 3 * gainedPerks + 1
; New Level = Math.pow((0.09 * Level.Value), 1.4) + 5.0
Function AddXp(float e)
	Experience.Value += e * 4.7
	If(Level.Value < 100)
		lvProgress.Value -= e
		If(lvProgress.Value <= 0)
			Level.Value += 1
			LevelUp.Value = Level.Value
			float leftover = Math.abs(lvProgress.Value)
			SetLvXp()
			lvProgress.value -= leftover
		EndIf
	EndIf
	UpdateCurrentInstanceGlobal(Experience)
	UpdateCurrentInstanceGlobal(lvProgress)
EndFunction


Function AddPerk()
	If(Experience.Value < NextPerkReq.Value)
		Debug.Notification("You don't have enough Experience to obtain a new Perk Point.")
		return
	EndIf
	gainedPerks += 1
	Perks.Value += 1
	Experience.Value -= NextPerkReq.Value
	NextPerkReq.Value = 3 * gainedPerks + 1
	UpdateCurrentInstanceGlobal(Experience)
	UpdateCurrentInstanceGlobal(NextPerkReq)
EndFunction

; Expect this to only be called when Experience >= NextLevelReq
Function LevelUp()
	If(Experience.Value < lvProgress.Value)
		Debug.Notification("You don't have enough Experience to level up.")
		return
	EndIf
	Level.Value += 1
	LevelUp.Value = Level.Value
	Experience.Value -= lvProgress.Value
	SetLvXp()
	UpdateCurrentInstanceGlobal(Experience)
	UpdateCurrentInstanceGlobal(lvProgress)
EndFunction

Function SetLvXp()
	lvProgress.Value = Math.floor(Math.pow(0.2 * Level.Value, 1.7) + 4.7)
EndFunction
