Scriptname YamReapersMercy extends Quest

; --------------------------- Property
YamMCM Property MCM Auto
Actor Property PlayerRef Auto
Perk[] Property pReapersMercy Auto
{KdHpThresh -> 30 35 40 45 50}
Perk[] Property pLurkingThreat Auto
{KdHpUnseen -> 10 15 20}
Perk Property pPiercingStrike Auto
{KdPierceBlock -> Bool}
Perk[] Property pExposedStrike Auto
{KdArmorThresh -> 1 2 3}
Perk[] Property pAnculo Auto
{KdCommandedThresh -> 20 30 40}
GlobalVariable Property ShowMenu Auto
GlobalVariable Property LevelUp Auto
GlobalVariable Property Level Auto
GlobalVariable Property Perks Auto
; --------------------------- Variables
int XP = 0
float Property KdCommandedThresh = 0.0 Auto Hidden
float Property KdHpThresh = 0.2 Auto Hidden
float Property KdHpUnseen = 0.0 Auto Hidden
int Property KdArmorThresh = 0 Auto Hidden
bool Property KdPierceBlock = false Auto Hidden
; ======================================================================
; ================================== REAPERS MERCY PROGRESSION
; ======================================================================
Function OpenMenu()
	; Debug.MessageBox("Open menu..")
	If(MCM.bNoSkilltree)
		
	else
		ShowMenu.Value = 1
		Utility.Wait(1)
	EndIf
	; Debug.MessageBox("Waiting over..")
	SetKdCommandedThresh()
	SetKdHpThresh()
	SetKdHpUnseen()
	SetKdArmorThresh()
	SetKdPierceBlock()
EndFunction
Function SetKdCommandedThresh()
	int i = pAnculo.length
	While(i > 0)
		i -= 1
		If(PlayerRef.HasPerk(pAnculo[i]))
			KdCommandedThresh = 0.2 + i * 0.1
			return
		EndIf
	EndWhile
	KdCommandedThresh = 0.0
EndFunction
Function SetKdHpThresh()
	int i = pReapersMercy.length
	While(i > 0)
		i -= 1
		If(PlayerRef.HasPerk(pReapersMercy[i]))
			KdHpThresh = 0.3 + i * 0.05
			return
		EndIf
	EndWhile
	KdHpThresh = 0.2
EndFunction
Function SetKdHpUnseen()
	int i = pLurkingThreat.length
	While(i > 0)
		i -= 1
		If(PlayerRef.HasPerk(pLurkingThreat[i]))
			KdHpUnseen = 0.1 + i * 0.05
			return
		EndIf
	EndWhile
	KdHpUnseen = 0.0
EndFunction
Function SetKdArmorThresh()
	int i = pLurkingThreat.length
	While(i > 0)
		i -= 1
		If(PlayerRef.HasPerk(pLurkingThreat[i]))
			KdArmorThresh = 1 + i
			return
		EndIf
	EndWhile
	KdArmorThresh = 0
EndFunction
Function SetKdPierceBlock()
	KdPierceBlock =	PlayerRef.HasPerk(pPiercingStrike)
EndFunction

; NextLvXp = 5 * ThisLv - 2
; Gain 1 for Claiming, 3 for Missions
Function AddXP(int gain)
	XP += gain
	If(XP >= 5 * Level.Value - 2)
		Level.Value += 1
		Perks.Value += 1
		LevelUp.Value = Level.Value
	EndIf
EndFunction
