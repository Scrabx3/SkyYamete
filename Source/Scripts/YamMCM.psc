Scriptname YamMCM extends SKI_ConfigBase Conditional Hidden

import JsonUtil
import PapyrusUtil
import Utility
; -------------------------- Properties
YamMain Property Main Auto
YamArmorExclusion Property armorExclude Auto
Actor Property PlayerRef Auto
Quest Property Yam_Scan Auto
Spell Property ReapersMercySpell Auto
Spell Property ExclusionSpell Auto
Faction Property exclusionFac Auto
; -------------------------- Variables
String[] classColors
bool firstCall = true
string filePathNull = "../Yamete/Default.json"
string filePath00 = "../Yamete/MCM.json"
; --- General
; Combat Quest
int Property iClockOutChance = 100 Auto Hidden
bool Property bCheckHostility = true Auto Hidden
int Property iMaxDistance = 60 Auto Hidden
GlobalVariable Property SummonVicGl Auto
GlobalVariable Property EnderVicGl Auto 
bool Property bSummonAggr = false Auto Hidden
bool Property bElderAggr = false Auto Hidden
; Importance
string[] importanceOptions
int Property iImportance = 2 Auto Hidden
bool Property bImportantFollowers = true Auto Hidden
; Surrender
int Property iSurrenderKey = -1 Auto Hidden
; Miscellaneous
bool Property bCustomBleed = false Auto Hidden
bool Property bShowNotifyKD = false Auto Hidden
bool Property bShowNotifySteal = false Auto Hidden
bool Property bShowNotifyStrip = false Auto Hidden
bool Property bShowNotifyColor = false Auto Hidden
string Property sNotifyColor = "#0000FF" Auto Hidden
int iShowNotifyColor = 0x0000FF

; --- Reapers Mercy
string[] ReaperTargetTreat
; Reapers Mercy Ability
int Property iPlAggrKey = -1 Auto Hidden
bool Property bRBashOnly = false Auto Hidden
; Filter
int Property lReapersCreature = 0 Auto Hidden
int Property lReaperFollower = 0 Auto Hidden
;
bool Property bOnlyWithReaper = true Auto Hidden
; Perks
bool Property bNoSkilltree = false Auto Hidden


; Valid Targets
bool[] Property bReaperTargets Auto Hidden

; --- Defeat
; Scenario
string[] combatScenarios
int Property iCombatScenario = 0 Auto Hidden
int Property iBlackoutChance = 15 Auto Hidden
; Bleedout
string[] potionUsageList
int Property iPotionUsage = 1 Auto Hidden
; bool Property bleedoutMarkImmunity = true Auto Hidden Conditional
; Rushed
int Property iRushedConsequence = 25 Auto Hidden
int Property iRushedConsequenceAdd = 10 Auto Hidden
float Property frushedHeal = 0.3 Auto Hidden
int Property iRushedBuffer = 7 Auto Hidden
; Bleedout Types
int iBleedRegularPl = 85
int iBleedWitheredPl = 0
int iBleedDeathSentencePl = 5
int iBleedRegular = 90
int iBleedWithered = 15
int iBleedDeathSentence = 40
; Resoltion
int Property iResIgnore = 70 Auto Hidden
int iResRobbed = 50
int iResRaped = 50
int iResExecuted = 50
bool Property bOnlyBanditsRob = true Auto Hidden
; Robbed
string[] resRobbedList
int Property iResRType = 0 Auto Hidden
bool Property bResRWorn = false Auto Hidden
bool Property bResRQstItm = false Auto Hidden
int Property iResRItmVal = 200 Auto Hidden
int Property iResRStealChance = 65 Auto Hidden
; Raped
bool Property bResReverse = true Auto Hidden
int Property iResMaxRounds = 6 Auto Hidden
int Property iResNextRoundChance = 15 Auto Hidden
int Property iResNPCendless = 0 Auto Hidden

; --- Condition
string[] KnockdownProfile
int Property iKDProfile = 0 Auto Hidden
; Generic
float[] Property fKDChance Auto Hidden
bool[] Property bKdBlock Auto Hidden
bool[] Property bKdMelee Auto Hidden
; Weakened
float[] Property fKdHpThreshUpper Auto Hidden
float[] Property fKdHpThreshLower Auto Hidden
; Exhausted
float[] Property fStaminaThresh Auto Hidden
float[] Property fMagickaThresh Auto Hidden
; Vulnerable
int[] Property iKdVulnerable Auto Hidden
; Essential
bool Property bKdEssentialPlayer = false Auto Hidden Conditional
bool[] Property bKdEssentialNPC Auto Hidden
; Stripping
int[] Property iKdStrip Auto Hidden
bool[] Property bKdStripBlock Auto Hidden
bool[] Property bKdStripDrop Auto Hidden
int[] Property iKdStripDstry Auto Hidden
bool Property iKdStripProtect = true Auto Hidden ; Profile Independent

; --- Stripping
bool[] Property bValidStrips Auto Hidden

; --- Animation Frames
int afHideSL = 1
int afHideOStim = 1
bool Property bSLAllowed = true Auto Hidden Conditional
bool Property bFGAllowed = true Auto Hidden Conditional
bool Property bOStimAllowed = true Auto Hidden Conditional
int iSLweight = 50
int iFGweight = 50
int iOStimweight = 50
bool Property bNotifyAF = false Auto Hidden
bool Property bNotifyColorAF = false Auto Hidden
int iNotifyColorAF = 0xFF0000
string Property sNotifyColorAF = "#FF0000" Auto Hidden
; SexLab
bool Property bSLAsVictim = true Auto Hidden
int Property iSLArousalThresh = 0 Auto Hidden
int Property iSLArousalFollower = 0 Auto Hidden
bool bSupportFilter = false
string[] Property SLTags Auto Hidden
; OStim
float Property fOtMinD = 30.0 Auto Hidden
float Property fOtMaxD = 45.0 Auto Hidden
; 3p+ Weights
int Property iAF2some = 70 Auto Hidden
int Property iAF3some = 50 Auto Hidden
int Property iAF4some = 40 Auto Hidden
int Property iAF5Some = 30 Auto Hidden
; Utility
bool Property FrameCreature
	bool Function Get()
		return bSLAllowed
	EndFunction
EndProperty
bool Property FrameAny
	bool Function Get()
		return bSLAllowed || bFGAllowed || bOStimAllowed
	EndFunction
EndProperty

; --- Filter
string[] FilterTypeList
string[] FollowerAttac
string[] NPCAttac
int Property iFilterType = 1 Auto Hidden
int Property iFolAttac = 1 Auto Hidden
int Property iNPCAttac = 1 Auto Hidden
bool[] Property bAssaultPl Auto
bool[] Property bAssaultNPC Auto
bool[] Property bAssaultFol Auto

; --- Creature Filter
string[] crtFilterMethodList
int Property iCrtFilterMethod = 1 Auto Hidden
bool[] Property bValidRace Auto Hidden ; Initialize: All True

; --- Consequences
int cLeftForDead = 100
int Property cSimpleSlavery = 40 Auto Hidden
; --- Debug
; System
int Property iPauseKey = -1 Auto Hidden
bool Property bSLScenes = true Auto Hidden
bool Property bModPaused = true Auto Hidden Conditional
bool bKillScanQuest = false ; Used in OnConfigClose()
bool AutoSaveMCM = false

; -------------------------- Code
; ===============================================================
; =============================	STARTUP // UTILITY
; ===============================================================
int Function GetVersion()
	return 2
endFunction

; ===================================== BLEEDOUTS
int[] Function getBleedoutsNPC(bool important)
	int[] toRet
	If(!important)
		toRet = new int[3]
		toRet[2] = iBleedDeathSentence
	else
		toRet = new int[2]
	EndIf
	toRet[0] = iBleedRegular
	toRet[1] = iBleedWithered
	return toRet
EndFunction

int[] Function getBleedoutsPl(bool important)
	int[] toRet
	If(!important)
		toRet = new int[3]
		toRet[2] = iBleedDeathSentencePl
	else
		toRet = new int[2]
	EndIf
	toRet[0] = iBleedRegularPl
	toRet[1] = iBleedWitheredPl
	return toRet
EndFunction

; ===================================== CONSEQUENCES
int[] Function getAllConsequencesPl()
	int[] toRet = new int[2]
	toRet[0] = cLeftForDead
	toRet[1] = cSimpleSlavery
	return toRet
EndFunction

; ===================================== RESOLUTION
int[] Function getAllResActions()
	int[] sol = new int[2]
	sol[0] = iResRobbed
	sol[1] = iResRaped
	; sol[2] = iResExecuted
	return sol
EndFunction

; ===================================== ANIMATION FRAME
int[] Function getXsomeWeight()
	int[] sol
	If(bSLAllowed)
		sol = new int[4]
		sol[2] = iAF4some
		sol[3] = iAF5Some
	else
		sol = new int[2]
	EndIf
	sol[0] = iAF2some
	sol[1] = iAF3some
	return sol
EndFunction

int[] Function getFrameWeights()
	int[] sol = new int[3]
	sol[0] = iOStimweight * (bOStimAllowed as int)
	sol[1] = iFGweight * (bFGAllowed as int)
	sol[2] = iSLweight * (bSLAllowed as int)
	return sol
EndFunction

; ===============================================================
; =============================	MENU (RE)INITIALISATION
; ===============================================================
Event OnVersionUpdate(int newVers)
	If(firstCall == false)
		Initialize()
	EndIf
endEvent

Function Initialize()
	Pages = new string[10]
	Pages[0] = "$Yam_pGeneral"
	Pages[1] = "$Yam_pReaper"
	Pages[2] = "$Yam_pDefeat"
	Pages[3] = "$Yam_pConditions"
	Pages[4] = "$Yam_pStripping"
	Pages[5] = "$Yam_pAdultFrames"
	Pages[6] = "$Yam_pFilter"
	Pages[7] = "$Yam_pCreatureFilter"
	Pages[8] = "$Yam_pConsequences"
	Pages[9] = "$Yam_pDebug"

	; Colors
	classColors = new String[3]
	classColors[0] = "<font color = '#ffff00'>" ; Player - Yellow
	classColors[1] = "<font color = '#00c707'>" ; Follower - Green
	classColors[2] = "<font color = '#f536ff'>"	; NPC - Magnetta

	; General
	importanceOptions = new string[3]
	importanceOptions[0] = "$Yam_cNPCImportanceOptions_0" ; Essential only
	importanceOptions[1] = "$Yam_cNPCImportanceOptions_1" ; Protected
	importanceOptions[2] = "$Yam_cNPCImportanceOptions_2" ; Unique

	; Defeat
	combatScenarios = new string[3]
	combatScenarios[0] = "$Yam_dScenario_0" ; Default
	combatScenarios[1] = "$Yam_dScenario_1" ; Traditional
	combatScenarios[2] = "$Yam_dScenario_2" ; Mixed

	potionUsageList = new string[3]
	potionUsageList[0] = "$Yam_dBleedPotion_0" ; Use Weakest
	potionUsageList[1] = "$Yam_dBleedPotion_1" ; Use Strongest
	potionUsageList[2] = "$Yam_dBleedPotion_2" ; Use most present

	; Resolution
	resRobbedList = new string[3]
	resRobbedList[0] = "$Yam_robbedList_0" ; Everything
	resRobbedList[1] = "$Yam_robbedList_1" ; By Value
	resRobbedList[2] = "$Yam_robbedList_2" ; By Chance

	; Reapers Mercy
	ReaperTargetTreat = new string[3]
	ReaperTargetTreat[0] = "$Yam_reaperTarget_0" ; ignore
	ReaperTargetTreat[1] = "$Yam_reaperTarget_1" ; never
	ReaperTargetTreat[2] = "$Yam_reaperTarget_2" ; use settings

	; Knockdown Profile
	KnockdownProfile = new string[3]
	KnockdownProfile[0] = "$Yam_KdProfilePlayer" ; Player
	KnockdownProfile[1] = "$Yam_KdProfileFollower" ; Follower
	KnockdownProfile[2] = "$Yam_KdProfileNPC" ; NPC/Creature

	; --- Filter
	FilterTypeList = new string[2]
	FilterTypeList[0] = "$Yam_filterType_0" ; Selective
	FilterTypeList[1] = "$Yam_filterType_1" ; Restrictive

	FollowerAttac = new String[3]
	FollowerAttac[0] = "$Yam_folAttac_0" ; Nobody
	FollowerAttac[1] = "$Yam_folAttac_1" ; Anyone
	FollowerAttac[2] = "$Yam_folAttac_2" ; Only NPC

	NPCAttac = new String[6]
	NPCAttac[0] = "$Yam_npcAttac_0" ; Nobody
	NPCAttac[1] = "$Yam_NPCAttac_1" ; Anyone
	NPCAttac[2] = "$Yam_npcAttac_2" ; Only NPC
	NPCAttac[3] = "$Yam_npcAttac_3" ; Only Follower
	NPCAttac[4] = "$Yam_npcAttac_4" ; Only Player
	NPCAttac[5] = "$Yam_npcAttac_5" ; Only Player Team

	; --- Creature Filter
	crtFilterMethodList = new string[4]
	crtFilterMethodList[0] = "$Yam_scrFilterMethod_0" ; All Creatures
	crtFilterMethodList[1] = "$Yam_scrFilterMethod_1" ; No Creatures
	crtFilterMethodList[2] = "$Yam_scrFilterMethod_2" ; Use List
	crtFilterMethodList[3] = "$Yam_scrFilterMethod_3" ; Use List Reverse
endFunction

Function startMod(bool loadMCM)
	firstCall = false
	Initialize()
	WaitMenuMode(0.15)
	bReaperTargets = CreateBoolArray(10, true)
	bValidRace = CreateBoolArray(52, true)
	fKDChance = CreateFloatArray(KnockdownProfile.length, 75.0)
	bKdBlock = CreateBoolArray(KnockdownProfile.length, false)
	bKdMelee = CreateBoolArray(KnockdownProfile.length, false)
	fKdHpThreshUpper = CreateFloatArray(KnockdownProfile.length, 0.5)
	fKdHpThreshLower = CreateFloatArray(KnockdownProfile.length, 0.0)
	fStaminaThresh = CreateFloatArray(KnockdownProfile.length, 0.4)
	fMagickaThresh = CreateFloatArray(KnockdownProfile.length, 0.2)
	iKdVulnerable = CreateIntArray(KnockdownProfile.length, 2)
	bKdEssentialNPC = CreateBoolArray(KnockdownProfile.length, false)
	iKdStrip = CreateIntArray(KnockdownProfile.length, 25)
	bKdStripBlock = CreateBoolArray(KnockdownProfile.length, true)
	bKdStripDrop = CreateBoolArray(KnockdownProfile.length, false)
	iKdStripDstry = CreateIntArray(KnockdownProfile.length, 20)
	bValidStrips = CreateBoolArray(32)
	SLTags = CreateStringArray(11)
	strippingRestoreDefaults()
	SLTags[1] = "ff"
	SLTags[2] = "femdom"
	SLTags[3] = "mm"
	WaitMenuMode(0.2)
	If(loadMCM)
		LoadingMCM(filePath00)
	EndIf
	bModPaused = false
EndFunction

Event OnConfigClose()
	If(AutoSaveMCM)
		SavingMCM(filePath00)
	EndIf
	; Force Shutdown the Combat Quest
	If(bKillScanQuest)
		Yam_Scan.SetStage(999)
		bKillScanQuest = false
	EndIf
EndEvent

Function strippingRestoreDefaults()
	int i = 0
	While(i < 32)
		If(i == 1 || i == 5 || i == 6 || i == 11 || i == 20 || i == 21 || i == 22 || i > 29)
			bValidStrips[i] = false
		else
			bValidStrips[i] = true
		EndIf
		i += 1
	EndWhile
EndFunction
; ===============================================================
; =============================	MENU
; ===============================================================
Event OnPageReset(String Page)
	SetCursorFillMode(TOP_TO_BOTTOM)
	If(firstCall)
		AddTextOption("$Yam_sDisabled", none, OPTION_FLAG_DISABLED)
		AddEmptyOption()
		AddTextOption("$Yam_sINFO_0", none, OPTION_FLAG_DISABLED)
		AddTextOption("$Yam_sINFO_1", none, OPTION_FLAG_DISABLED)
		AddTextOption("$Yam_sINFO_2", none, OPTION_FLAG_DISABLED)
		AddEmptyOption()
		AddTextOptionST("EnableMod", "$Yam_sEnable", none)
		AddTextOptionST("EnableModExtra", "$Yam_sEnableLoad", none)
		return
	ElseIf(Page == "")
		Page = "$Yam_pGeneral"
	EndIf


	If(Page == "$Yam_pGeneral")
		SetCursorFillMode(TOP_TO_BOTTOM)
		AddHeaderOption("$Yam_genCombatQ")
		; AddSliderOptionST("clockChance", "(C)lockout Chance", iClockOutChance, "{0}%")
		AddToggleOptionST("checkHostility", "$Yam_genCombatQHostility", bCheckHostility)
		AddSliderOptionST("checkDistance", "$Yam_genCombatQDistance", iMaxDistance, "{0}m")
		AddToggleOptionST("summonedVic", "$Yam_genSummonVic", SummonVicGl.Value as bool)
		AddToggleOptionST("summonedAgg", "$Yam_genSummonAgg", bSummonAggr)
		AddToggleOptionST("elderVic", "$Yam_genElderVic", EnderVicGl.Value as bool)
		AddToggleOptionST("elderAgg", "$Yam_genElderAgg", bElderAggr)
		AddHeaderOption("$Yam_cImportance")
		AddMenuOptionST("cNPCimportance", "$Yam_cNPCImportance", importanceOptions[iImportance])
		AddToggleOptionST("cNPCimportanceFol", "$Yam_cNPCFollowerImportance", bImportantFollowers)
		AddHeaderOption("$Yam_genMisc")
		AddToggleOptionST("CustomBleed", "$Yam_genBleedoutAnim", bCustomBleed)
		SetCursorPosition(1)
		AddHeaderOption("$Yam_genStatus")
		AddTextOption(GetStatus(), none)
		AddEmptyOption()
		AddEmptyOption()
		AddHeaderOption("$Yam_genSurrender")
		AddKeyMapOptionST("SurrenderKey", "$Yam_SurrenderKey", iSurrenderKey)
		AddHeaderOption("$Yam_genNotify")
		AddToggleOptionST("notifyKd", "$Yam_genNotifyKd", bShowNotifyKD)
		AddToggleOptionST("notifySteal", "$Yam_genNotifySteal", bShowNotifySteal)
		AddToggleOptionST("notifyStrip", "$Yam_genNotifyStrip", bShowNotifyStrip)
		AddToggleOptionST("ColoredKnockdownNotify", "$Yam_genNotifyColor", bShowNotifyColor, ColorNotify())
		AddColorOptionST("KnockdownNotifyColor", "$Yam_genNotifyColorChoice", iShowNotifyColor, ColorNotifyChoice())

	ElseIf(Page == "$Yam_pReaper")
		AddHeaderOption("$Yam_reaperAbility")
		AddKeyMapOptionST("PlAggrKey", "$Yam_reaperAbilityHotkey", iPlAggrKey)
		AddTextOptionST("ReapersMercyPowerAdd", "$Yam_reaperAbilityAddRemove", none)
		AddToggleOptionST("ReaperBashOnly", "$Yam_reaperBashOnly", bRBashOnly)
		AddHeaderOption("$Yam_reaperConsideration")
		AddMenuOptionST("ReaperCrtTreatment", "$Yam_ReaperCreature", ReaperTargetTreat[lReapersCreature])
		SetCursorPosition(1)
		AddHeaderOption("$Yam_reaperPerks")
		AddToggleOptionST("ReaperSkilltree", "$Yam_reaperSkilltree", bNoSkilltree)
		; AddMenuOptionST("reaperFolTreatment", "$Yam_ReaperFollower", ReaperTargetTreat[lReaperFollower])
		; int i = 0
		; While(i < 5)
		; 	AddToggleOptionST("reaperNPCValid_" + i, "$Yam_reaperTarget_" + i, bReaperTargets[i])
		; 	i += 1
		; EndWhile

	ElseIf(Page == "$Yam_pDefeat")
		AddHeaderOption("$Yam_dScenario")
		AddMenuOptionST("combatScenario", "$Yam_dCombatScenario", combatScenarios[iCombatScenario])
		AddSliderOptionST("blackoutChance", "$Yam_dBlackout", iBlackoutChance, "{0}%")
		AddHeaderOption("$Yam_dBleedout")
		; AddToggleOptionST("dBleedImmunity", "$Yam_dBleedImmunity", bleedoutMarkImmunity)
		AddMenuOptionST("dBleedPotionMenu", "$Yam_dBleedPotionUse", potionUsageList[iPotionUsage])
		AddHeaderOption("$Yam_dRushed")
		AddSliderOptionST("dRushedChance", "$Yam_dRushedChance", iRushedConsequence, "{0}%", getFlag(iCombatScenario != 1))
		AddSliderOptionST("dRushedChanceAdd", "$Yam_dRushedChanceAdd", iRushedConsequenceAdd, "+{0}%", getFlag(iCombatScenario != 1))
		AddSliderOptionST("dRushedHeal", "$Yam_dRushedHeal", fRushedHeal * 100, "{0}%", getFlag(iCombatScenario != 1))
		AddSliderOptionST("dRushedBuffer", "$Yam_dRushedBuffer", iRushedBuffer, "{0}s", getFlag(iCombatScenario != 1))
		AddHeaderOption("$Yam_dBleedTypes")
		AddSliderOptionST("dBleedRegularPl", "$Yam_dBleedRegPl", iBleedRegularPl)
		; AddSliderOptionST("dBleedWitherPl", "$Yam_dBleedWitherPl", iBleedWitheredPl)
		AddSliderOptionST("dBleedDeathSentPl", "$Yam_dBleedDeathSentPl", iBleedDeathSentencePl)
		AddEmptyOption()
		AddSliderOptionST("dBleedRegular", "$Yam_dBleedRegNPC", iBleedRegular)
		AddSliderOptionST("dBleedWither", "$Yam_dBleedWitherNPC", iBleedWithered)
		AddSliderOptionST("dBleedDeathSent", "$Yam_dBleedDeathSentNPC", iBleedDeathSentence)
		SetCursorPosition(1)
		AddTextOptionST("dReadMe", "$Yam_rReadMe", "")
		AddHeaderOption("$Yam_dResolution")
		; AddSliderOptionST("resIgnoreVic", "$Yam_resIgnore", iResIgnore, "{0}%")
		AddSliderOptionST("resRobVic", "$Yam_resRobbed", iResRobbed, "{0}")
		AddToggleOptionST("resOnlyBanditsRob", "$Yam_resRobbedBandits", bOnlyBanditsRob)
		AddSliderOptionST("resRapeVic", "$Yam_resRaped", iResRaped, "{0}")
		; AddSliderOptionST("resExecuteVic", "$Yam_resExecute", iResExecuted, "{0}")
		AddHeaderOption("$Yam_resRobbed")
		AddMenuOptionST("resRobbedOptions", "$Yam_resRobbedOptions", resRobbedList[iResRType])
		AddToggleOptionST("resRobbedWorn", "$Yam_resRobbedWorn", bResRWorn)
		AddToggleOptionST("resRobbedQstItm", "$Yam_resRobbedQstItm", bResRQstItm)
		AddSliderOptionST("resRobVal", "$Yam_resRobVal", iResRItmVal, "{0}g", getFlag(iResRType == 1))
		AddSliderOptionST("resRobChance", "$Yam_resRobChance", iResRStealChance, "{0}%", getFlag(iResRType == 2))
		AddHeaderOption("$Yam_resRaped")
		AddToggleOptionST("resRapeReverse", "$Yam_resRapeReverse", bResReverse)
		AddSliderOptionST("resRapeMax", "$Yam_resRapeRounds", iResMaxRounds, "{0}")
		AddSliderOptionST("resRapeChance", "$Yam_resRapeChance", iResNextRoundChance, "{0}%")
		AddSliderOptionST("resRapeEndless", "$Yam_resRapeEndless", iResNPCendless, "{0}%")

	ElseIf(Page == "$Yam_pConditions")
		AddMenuOptionST("KDProfileViewer", "$Yam_KdProfileCurrent", KnockdownProfile[iKDProfile])
		SetCursorPosition(1)
		AddTextOptionST("KDreadMe", "$Yam_rReadMe", none)
		SetCursorPosition(2)
		int i = iKDProfile
		; ================= Default
		AddHeaderOption(classColors[i] + "$Yam_KdProfileHeader4")
		AddSliderOptionST("KdChance_" + i, "$Yam_KdProfileChance", fKDChance[i], "{1}%")
		AddToggleOptionST("KdBlock_" + i, "$Yam_KdProfileUnblocked", bKdBlock[i])
		AddToggleOptionST("KdMelee_" + i, "$Yam_KdProfileMelee", bKdMelee[i])
		; ================= Weakened
		AddHeaderOption(classColors[i] + "$Yam_KdProfileHeader0")
		AddSliderOptionST("KdHpThreshUp_" + i, "$Yam_KdProfileHPThreshUpper", fKdHpThreshUpper[i] * 100, "{0}%")
		AddSliderOptionST("KdHpThreshLow_" + i, "$Yam_KdProfileHPThreshLower", fKdHpThreshLower[i] * 100, "{0}%")
		; ================= Exhausted
		AddHeaderOption(classColors[i] + "$Yam_KdProfileHeader5")
		AddSliderOptionST("KdStaminaThresh_" + i, "$Yam_KdProfileStaminaThresh", fStaminaThresh[i] * 100, "{0}%")
		AddSliderOptionST("KdMagickaThresh_" + i, "$Yam_KdProfileMagickaThresh", fMagickaThresh[i] * 100, "{0}%")
		; ================= Vulnerable
		AddHeaderOption(classColors[i] + "$Yam_KdProfileHeader1")
		AddSliderOptionST("KdVulnerable_" + i, "$Yam_KdProfileVulnerable", iKdVulnerable[i], "{0}")
		SetCursorPosition(3)
		; ================= Essential
		AddHeaderOption(classColors[i] + "$Yam_KdProfileHeader3")
		AddToggleOptionST("KdEssentialPlayer", "$Yam_KdEssentialPl", bKdEssentialPlayer)
		AddToggleOptionST("KdEssentialNPC_" + i, "$Yam_KdEssentialNPC", bKdEssentialNPC[i])
		; ================= Stripping
		AddHeaderOption(classColors[i] + "$Yam_KdProfileHeader2")
		AddSliderOptionST("KdStripOdds_" + i, "$Yam_KdStripOdds", iKdStrip[i], "{0}%")
		AddToggleOptionST("KdStripBlock_" + i, "$Yam_KdStripBlock", bKdStripBlock[i], getFlag(iKdStrip[i] > 0))
		AddToggleOptionST("KdStripDrop_" + i, "$Yam_KdStripDrop", bKdStripDrop[i], getFlag(iKdStrip[i] > 0))
		AddSliderOptionST("KdStripDestroy_" + i, "$Yam_KdStripDestroy", iKdStripDstry[i], "{0}%", getFlag(iKdStrip[i] > 0))
		AddToggleOptionST("KdStripProtect", "$Yam_KdStripProtect", iKdStripProtect, getFlag(iKdStripDstry[i] > 0 && iKdStrip[i] > 0))
		AddTextOptionST("KdStripExclude", "$Yam_KdStripExclude", none)

	ElseIf(Page == "$Yam_pStripping")
		SetCursorFillMode(LEFT_TO_RIGHT)
		AddHeaderOption("Default Slots")
		AddHeaderOption("")
		int i = 0
		While(i < 32)
			If(i != 20 && i != 21 && i != 31)
				AddToggleOptionST("Strp_" + i, "$Yam_strpList" + i, bValidStrips[i])
				If(i == 13)
					AddHeaderOption("$Yam_miscSlots")
					AddHeaderOption("")
				EndIf
			EndIf
			i += 1
		EndWhile

	ElseIf(Page == "$Yam_pAdultFrames")
		bool SLThere = Game.GetModByName("SexLab.esm") != 255
		bool OStimThere = Game.GetModByName("OStim.esp") != 255
		AddHeaderOption("$Yam_afFramesLoaded")
		AddTextOptionST("frameUsage", "$Yam_rReadMe", "")
		AddToggleOptionST("SLAllowed", "$Yam_afFrameSexLab", bSLAllowed, getFlag(SLThere))
		AddToggleOptionST("FGAllowed", "$Yam_afFrameFlowergirls", bFGAllowed, getFlag(Game.GetModByName("FlowerGirls SE.esm") != 255))
		AddToggleOptionST("OStimAllowed", "$Yam_afFrameOStim", bOStimAllowed, getFlag(OStimThere))
		AddEmptyOption()
		AddSliderOptionST("SLAllowedweight", "$Yam_afFrameSexLabWeight", iSLweight, "{0}", getFlag(SLThere))
		AddSliderOptionST("FGAllowedweight", "$Yam_afFrameFlowergirlsWeight", iFGweight, "{0}", getFlag(Game.GetModByName("FlowerGirls SE.esm") != 255))
		AddSliderOptionST("OStimAllowedweight", "$Yam_afFrameOStimWeight", iOStimweight, "{0}", getFlag(OStimThere))
		AddHeaderOption("$Yam_afThreads")
		AddToggleOptionST("afNotify", "$Yam_afAssaultNotify", bNotifyAF)
		AddToggleOptionST("afNotifyColor", "$Yam_afAssaultNotifyColor", bNotifyColorAF, GetFlag(bNotifyAF))
		AddColorOptionST("afNotifyColorChoice", "$Yam_afAssaultNofityColorChoice", iNotifyColorAF, GetFlag(bNotifyAF && bNotifyColorAF))
		; ===============================================
		SetCursorPosition(1)
		AddHeaderOption("$Yam_afFrameSexLab")
		AddTextOptionST("hideSL", "$Yam_SLHide_" + afHideSL, "")
		If(afHideSL == 0)
			AddToggleOptionST("SLTreatVictim", "$Yam_SLTreatVictim", bSLAsVictim, getFlag(SLThere))
			AddSliderOptionST("SLArousal", "$Yam_SLArousal", iSLArousalThresh, "{0}")
			AddSlideroptionST("SLArousalFol", "$Yam_SLArousalFol", iSLArousalFollower)
			AddToggleOptionST("SLSupportFilter", "$Yam_SLFilterOption", bSupportFilter, getFlag(SLThere))
			AddEmptyOption()
			AddTextOptionST("SLTaggingReadMe", "$Yam_rReadMe", "", getFlag(SLThere))
			int i = 0
			While(i < SLTags.length)
				AddInputOptionST("SLTag_" + i, "$Yam_SLTags_" + i, SLTags[i], getFlag(SLThere))
				i += 1
			EndWhile
		EndIf
		AddHeaderOption("$Yam_afFrameOStim")
		AddTextOptionST("hideOstim", "$Yam_OStimHide_" + afHideOStim, "")
		If(afHideOStim == 0)
			AddSliderOptionST("ostimMinD", "$Yam_afOStimMinDur", fOtMinD, "{0}s", getFlag(OStimThere))
			AddSliderOptionST("ostimMaxD", "$Yam_afOStimMaxDur", fOtMaxD, "{0}s", getFlag(OStimThere))
		EndIf
		AddHeaderOption("")
		AddSliderOptionST("af2pWeight", "$Yam_af2pWeight", iAF2some, "{0}")
		AddSliderOptionST("af3pWeight", "$Yam_af3pWeight", iAF3some, "{0}")
		AddSliderOptionST("af4pWeight", "$Yam_af4pWeight", iAF4some, "{0}", getFlag(SLThere))
		AddSliderOptionST("af5pWeight", "$Yam_af5pWeight", iAF5Some, "{0}", getFlag(SLThere))

	ElseIf(Page == "$Yam_pFilter")
		;/ Male > Female (> Futa) > Creature (> Fem. Creature) /;
		AddMenuOptionST("filterType", "$Yam_filterType", FilterTypeList[iFilterType])
		AddEmptyOption()
		AddMenuOptionST("filterFol", "$Yam_folAttac", FollowerAttac[iFolAttac])
		AddMenuOptionST("filterNPC", "$Yam_npcAttac", NPCAttac[iNPCAttac])
		If(bSupportFilter == true)
			AddEmptyOption()
			AddEmptyOption()
		EndIf
		int i = 0
		While(i < 5)
			If((i != 2 && i != 4) || bSupportFilter == true)
				AddHeaderOption(classColors[2] + "$Yam_filterClasses_" + i)
				int n = 0
				While(n < 5)
					If((n != 2 && n != 4) || bSupportFilter == true)
						int j = i * 5 + n
						AddToggleOptionST("filterGender_" + j, "$Yam_filterGenders_" + n, bAssaultNPC[j])
					EndIf
					n += 1
				EndWhile
			EndIf
			i += 1
		EndWhile
		SetCursorPosition(1)
		AddHeaderOption(classColors[0] + "$Yam_filterClassesPlayer")
		i = 0
		While(i < 5)
			If(i != 2 && i != 4 || bSupportFilter == true)
				AddToggleOptionST("filterPlayer_" + i, "$Yam_filterGenders_" + i, bAssaultPl[i])
			EndIf
			i += 1
		EndWhile
		i = 0
		While(i < 5)
			If((i != 2 && i != 4) || bSupportFilter == true)
				AddHeaderOption(classColors[1] + "$Yam_filterClassesFol_" + i)
				int n = 0
				While(n < 5)
					If((n != 2 && n != 4) || bSupportFilter == true)
						int j = i * 5 + n
						AddToggleOptionST("filterGenderFol_" + j, "$Yam_filterGenders_" + n, bAssaultFol[j])
					EndIf
					n += 1
				EndWhile
			EndIf
			i += 1
		EndWhile

	ElseIf(Page == "$Yam_pCreatureFilter")
		SetCursorFillMode(LEFT_TO_RIGHT)
		AddTextOptionST("crtFilterReadMe", "$Yam_rReadMe", "")
		AddMenuOptionST("crtFilterMethod", "$Yam_scrFilterMethod", crtFilterMethodList[iCrtFilterMethod])
		AddHeaderOption("")
		AddHeaderOption("")
		int i = 0
		While(i < 52)
			AddToggleOptionST("creatureFilter_" + i, "$Yam_crtFilter_Creature_" + i, bValidRace[i])
			i += 1
		EndWhile

	ElseIf(Page == "$Yam_pConsequences")
		AddTextOptionST("consequenceReadMe", "$Yam_rReadMe", "")
		AddSliderOptionST("conLfD", "$Yam_cLeftForDead", cLeftForDead)
		SetCursorPosition(1)
		AddHeaderOption("")
		AddSliderOptionST("conSS", "$Yam_cSimpleSlavery", cSimpleSlavery, "{0}", getFlag(Game.GetModByName("SimpleSlavery.esp") != 255))

	ElseIf(Page == "$Yam_pDebug")
		AddHeaderOption("System")
		AddToggleOptionST("PauseMod", "$Yam_debugPause", bModPaused)
		AddKeyMapOptionST("DebugPauseKey", "$Yam_debugPauseHotkey", iPauseKey)
		AddTextOptionST("KillScanQuest", "$Yam_debugKillCombatQ", none)
		AddToggleOptionST("SLScenery", "$Yam_debugDevMode", !bSLScenes)
		SetCursorPosition(1)
		AddHeaderOption("$Yam_debugPreset")
		AddToggleOptionST("AutoSaveMCM", "$Yam_debugAutoSaveMCM", AutoSaveMCM)
		AddTextOptionST("LoadMCMNull", "$Yam_debugPresetLoadNull", none)
		AddTextOptionST("LoadMCM", "$Yam_debugPresetLoad", none)
		AddTextOptionST("SaveMCM", "$Yam_debugPresetSave", none)
		AddEmptyOption()
		AddHeaderOption("$Yam_debugExclusion")
		AddTextOptionST("ExcludeSpell", "$Yam_debugExclusionSpell", none)
		AddTextOptionST("ExcludeAggressor", "$Yam_debugExclusionAggr", none)
		AddTextOptionST("ExcludeVictim", "$Yam_debugExclusionVic", none)
		AddTextOptionST("excludeValidation", "$Yam_debugExclusionValidate", none)
	EndIf
EndEvent

; ===============================================================
; =============================	EMPTY STATE
; ===============================================================

; ========================= TOGGLE // TEXT OPTION
Event OnSelectST()
	string[] option = StringSplit(GetState(), "_")
	If(option[0] == "CustomBleed") ; General
		bCustomBleed = !bCustomBleed
		SetToggleOptionValueST(bCustomBleed)
	ElseIf(option[0] == "cNPCimportanceFol")
		bImportantFollowers = !bImportantFollowers
		SetToggleOptionValueST(bImportantFollowers)
	ElseIf(option[0] == "summonedVic")
		bool tmp = SummonVicGl.Value as float
		tmp = !tmp
		SummonVicGl.Value = tmp as float
		SetToggleOptionValueST(tmp)
	ElseIf(option[0] == "summonedAgg")
		bSummonAggr = !bSummonAggr
		SetToggleOptionValueST(bSummonAggr)
	ElseIf(option[0] == "elderVic")
		bool tmp = EnderVicGl.Value as float
		tmp = !tmp
		EnderVicGl.Value = tmp as float
		SetToggleOptionValueST(tmp)
	ElseIf(option[0] == "elderAgg")
		bElderAggr = !bElderAggr
		SetToggleOptionValueST(bElderAggr)		

	ElseIf(option[0] == "ReaperSkilltree") ; Reaper
		bNoSkilltree = !bNoSkilltree
		SetToggleOptionValueST(bNoSkilltree)
	ElseIf(option[0] == "reaperNPCValid")
		int i = option[1] as int
		bReaperTargets[i] = !bReaperTargets[i]
		SetToggleOptionValueST(bReaperTargets[i])
	ElseIf(option[0] == "ReaperBashOnly")
		bRBashOnly = !bRBashOnly
		SetToggleOptionValueST(bRBashOnly)

	; ElseIf(option[0] == "dBleedImmunity") ; Defeat
	; 	bleedoutMarkImmunity = !bleedoutMarkImmunity
	; 	SetToggleOptionValueST(bleedoutMarkImmunity)

	ElseIf(option[0] == "resOnlyBanditsRob") ; Resolution
		bOnlyBanditsRob = !bOnlyBanditsRob
		SetToggleOptionValueST(bOnlyBanditsRob)
	ElseIf(option[0] == "resRobbedWorn")
		bResRWorn = !bResRWorn
		SetToggleOptionValueST(bResRWorn)
	ElseIf(option[0] == "resRobbedQstItm")
		bResRQstItm = !bResRQstItm
		SetToggleOptionValueST(bResRQstItm)
	ElseIf(option[0] == "resRapeReverse")
		bResReverse = !bResReverse
		SetToggleOptionValueST(bResReverse)
		If(!bResReverse && iResMaxRounds == 0)
			iResMaxRounds = 1
			SetSliderOptionValueST(iResMaxRounds, "{0}", false, "resRapeMax")
		EndIf

	ElseIf(option[0] == "filterPlayer") ; Filter
		int i = option[1] as int
		bAssaultPl[i] = !bAssaultPl[i]
		SetToggleOptionValueST(bAssaultPl[i])
	ElseIf(option[0] == "filterGender")
		int i = option[1] as int
		bAssaultNPC[i] = !bAssaultNPC[i]
		SetToggleOptionValueST(bAssaultNPC[i])
	ElseIf(option[0] == "filterGenderFol")
		int i = option[1] as int
		bAssaultFol[i] = !bAssaultFol[i]
		SetToggleOptionValueST(bAssaultFol[i])


	ElseIf(option[0] == "creatureFilter") ; Creature Filter
		int i = option[1] as int
		bValidRace[i] = !bValidRace[i]
		SetToggleOptionValueST(bValidRace[i])

	ElseIf(option[0] == "Strp") ; Stripping
		int i = option[1] as int
		bValidStrips[i] = !bValidStrips[i]
		SetToggleOptionValueST(bValidStrips[i])

	ElseIf(option[0] == "KdBlock") ; Knockdown Condition
		int i = option[1] as int
		bKdBlock[i] = !bKdBlock[i]
		SetToggleOptionValueST(bKdBlock[i])
	ElseIf(option[0] == "KdMelee")
		int i = option[1] as int
		bKdMelee[i] = !bKdMelee[i]
		SetToggleOptionValueST(bKdMelee[i])
	ElseIf(option[0] == "KdStripBlock")
		int i = option[1] as int
		bKdStripBlock[i] = !bKdStripBlock[i]
		SetToggleOptionValueST(bKdStripBlock[i])
	ElseIf(option[0] == "KdStripDrop")
		int i = option[1] as int
		bKdStripDrop[i] = !bKdStripDrop[i]
		SetToggleOptionValueST(bKdStripDrop[i])
	ElseIf(option[0] == "KdEssentialPlayer")
		bKdEssentialPlayer = !bKdEssentialPlayer
		SetToggleOptionValueST(bKdEssentialPlayer)
	ElseIf(option[0] == "KdEssentialNPC")
		int i = option[1] as int
		bKdEssentialNPC[i] = !bKdEssentialNPC[i]
		SetToggleOptionValueST(bKdEssentialNPC[i])
	ElseIf(option[0] == "KdStripProtect")
		iKdStripProtect = !iKdStripProtect
		SetToggleOptionValueST(iKdStripProtect)

	ElseIf(option[0] == "afNotifyColor") ; Adult Frames
		bNotifyColorAF = !bNotifyColorAF
		SetToggleOptionValueST(bNotifyColorAF)
		If(bNotifyColorAF)
			SetOptionFlagsST(OPTION_FLAG_NONE, false, "afNotifyColorChoice")
		else
			SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "afNotifyColorChoice")
		EndIf
	ElseIf(option[0] == "SLTreatVictim")
		bSLAsVictim = !bSLAsVictim
		SetToggleOptionValueST(bSLAsVictim)
	ElseIf(option[0] == "SLSupportFilter")
		bSupportFilter = !bSupportFilter
		SetToggleOptionValueST(bSupportFilter)
	ElseIf(option[0] == "SLAllowed")
		bSLAllowed = !bSLAllowed
		SetToggleOptionValueST(bSLAllowed)
	ElseIf(option[0] == "FGAllowed")
		bFGAllowed = !bFGAllowed
		SetToggleOptionValueST(bFGAllowed)
	ElseIf(option[0] == "OStimAllowed")
		bOStimAllowed = !bOStimAllowed
		SetToggleOptionValueST(bOStimAllowed)

	ElseIf(option[0] == "EnableMod")
		SetOptionFlagsST(OPTION_FLAG_DISABLED, true)
		SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "EnableModExtra")
		SetTextOptionValueST("$Yam_working")
		startMod(false)
		SetTextOptionValueST("$Yam_sEnableReload")
	ElseIf(option[0] == "EnableModExtra")
		SetOptionFlagsST(OPTION_FLAG_DISABLED, true)
		SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "EnableMod")
		SetTextOptionValueST("$Yam_working")
		startMod(true)
		SetTextOptionValueST("$Yam_sEnableReload")

	ElseIf(option[0] == "crtFilterReadMe") ; Read Mes
		ShowMessage("$Yam_crtFilterReadMe", false, "$Yam_OK")
	ElseIf(option[0] == "strippingReadMe")
		ShowMessage("$Yam_strpReadMe", false, "$Yam_OK")
	ElseIf(option[0] == "frameUsage")
		ShowMessage("$Yam_afFrameUsageReadMe", false, "$Yam_OK")
	ElseIf(option[0] == "SLTaggingReadMe")
		ShowMessage("$Yam_SLTagsReadMe", false, "$Yam_OK")
	ElseIf(option[0] == "dReadMe")
		ShowMessage("$Yam_dReadMe", false, "$Yam_OK")
	ElseIf(option[0] == "consequenceReadMe")
		ShowMessage("$Yam_consequenceReadMe", false, "$Yam_OK")
	ElseIf(option[0] == "KDreadMe")
		ShowMessage("$Yam_kdReadMe", false, "$Yam_OK")
	EndIf
EndEvent

; ========================= SLIDER
Event OnSliderOpenST()
	string[] option = StringSplit(GetState(), "_")
	If(option[0] == "dRushedHeal") ; Defeat
		SetSliderDialogStartValue(frushedHeal * 100)
		SetSliderDialogDefaultValue(30)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "dRushedChance")
		SetSliderDialogStartValue(iRushedConsequence)
		SetSliderDialogDefaultValue(25)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "dRushedChanceAdd")
		SetSliderDialogStartValue(iRushedConsequenceAdd)
		SetSliderDialogDefaultValue(10)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "dRushedBuffer")
		SetSliderDialogStartValue(iRushedBuffer)
		SetSliderDialogDefaultValue(7)
		SetSliderDialogRange(0, 30)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "blackoutChance")
		SetSliderDialogStartValue(iBlackoutChance)
		SetSliderDialogDefaultValue(15)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "dBleedRegular")
		SetSliderDialogStartValue(iBleedRegular)
		SetSliderDialogDefaultValue(30)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "dBleedWither")
		SetSliderDialogStartValue(iBleedWithered)
		SetSliderDialogDefaultValue(30)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "dBleedDeathSent")
		SetSliderDialogStartValue(iBleedDeathSentence)
		SetSliderDialogDefaultValue(30)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "dBleedRegularPl")
		SetSliderDialogStartValue(iBleedRegularPl)
		SetSliderDialogDefaultValue(30)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "dBleedWitherPl")
		SetSliderDialogStartValue(iBleedWitheredPl)
		SetSliderDialogDefaultValue(30)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "dBleedDeathSentPl")
		SetSliderDialogStartValue(iBleedDeathSentencePl)
		SetSliderDialogDefaultValue(30)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "resIgnoreVic")
		SetSliderDialogStartValue(iResIgnore)
		SetSliderDialogDefaultValue(70)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "resRobVic")
		SetSliderDialogStartValue(iResRobbed)
		SetSliderDialogDefaultValue(50)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "resRapeVic")
		SetSliderDialogStartValue(iResRaped)
		SetSliderDialogDefaultValue(50)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "resExecuteVic")
		SetSliderDialogStartValue(iResExecuted)
		SetSliderDialogDefaultValue(50)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "resRobVal")
		SetSliderDialogStartValue(iResRItmVal)
		SetSliderDialogDefaultValue(2000)
		SetSliderDialogRange(0, 50000)
		SetSliderDialogInterval(100)
	ElseIf(option[0] == "resRobChance")
		SetSliderDialogStartValue(iResRStealChance)
		SetSliderDialogDefaultValue(65)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "resRapeMax")
		SetSliderDialogStartValue(iResMaxRounds)
		SetSliderDialogDefaultValue(6)
		SetSliderDialogRange(0, 30)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "resRapeChance")
		SetSliderDialogStartValue(iResNextRoundChance)
		SetSliderDialogDefaultValue(15)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "resRapeEndless")
		SetSliderDialogStartValue(iResNPCendless)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)

	ElseIf(option[0] == "KdChance") ; Knockdown Condition
		int i = option[1] as int
		SetSliderDialogStartValue(fKDChance[i])
		SetSliderDialogDefaultValue(75)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(0.5)
	ElseIf(option[0] == "KdHpThreshUp")
		int i = option[1] as int
		SetSliderDialogStartValue(fKdHpThreshUpper[i] * 100)
		SetSliderDialogDefaultValue(50)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "KdHpThreshLow")
		int i = option[1] as int
		SetSliderDialogStartValue(fKdHpThreshLower[i] * 100)
		SetSliderDialogDefaultValue(5)
		SetSliderDialogRange(0, (fKdHpThreshUpper[i] * 100))
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "KdStaminaThresh")
		int i = option[1] as int
		SetSliderDialogStartValue(fStaminaThresh[i] * 100)
		SetSliderDialogDefaultValue(40)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "KdMagickaThresh")
		int i = option[1] as int
		SetSliderDialogStartValue(fMagickaThresh[i] * 100)
		SetSliderDialogDefaultValue(40)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "KdVulnerable")
		int i = option[1] as int
		SetSliderDialogStartValue(iKdVulnerable[i])
		SetSliderDialogDefaultValue(1)
		SetSliderDialogRange(0, 20)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "KdStripOdds")
		int i = option[1] as int
		SetSliderDialogStartValue(iKdStrip[i])
		SetSliderDialogDefaultValue(25)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "KdStripDestroy")
		int i = option[1] as int
		SetSliderDialogStartValue(iKdStripDstry[i])
		SetSliderDialogDefaultValue(20)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)

	ElseIf(option[0] == "SLAllowedweight")  ; Animation Frame
		SetSliderDialogStartValue(iSLweight)
		SetSliderDialogDefaultValue(50)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "FGAllowedweight")
		SetSliderDialogStartValue(iFGweight)
		SetSliderDialogDefaultValue(50)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "OStimAllowedweight")
		SetSliderDialogStartValue(iOStimweight)
		SetSliderDialogDefaultValue(50)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "af2pWeight")
		SetSliderDialogStartValue(iAF2some)
		SetSliderDialogDefaultValue(70)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "af3pWeight")
		SetSliderDialogStartValue(iAF3some)
		SetSliderDialogDefaultValue(50)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "af4pWeight")
		SetSliderDialogStartValue(iAF4some)
		SetSliderDialogDefaultValue(40)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "af5pWeight")
		SetSliderDialogStartValue(iAF5Some)
		SetSliderDialogDefaultValue(30)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "SLArousal")
		SetSliderDialogStartValue(iSLArousalThresh)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "SLArousalFol")
		SetSliderDialogStartValue(iSLArousalFollower)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "ostimMinD")
		SetSliderDialogStartValue(fOtMinD)
		SetSliderDialogDefaultValue(30)
		SetSliderDialogRange(10, fOtMaxD)
		SetSliderDialogInterval(5)
	ElseIf(option[0] == "ostimMaxD")
		SetSliderDialogStartValue(fOtMaxD)
		SetSliderDialogDefaultValue(45)
		SetSliderDialogRange(fOtMinD, 180)
		SetSliderDialogInterval(5)

	ElseIf(option[0] == "conLfD") ; Consequences
		SetSliderDialogStartValue(cLeftForDead)
		SetSliderDialogDefaultValue(100)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "conSS")
		SetSliderDialogStartValue(cSimpleSlavery)
		SetSliderDialogDefaultValue(100)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndIf
EndEvent

Event OnSliderAcceptST(float value)
	string[] option = StringSplit(GetState(), "_")
	If(option[0] == "dRushedHeal") ; Defeat
		frushedHeal = value / 100
		SetSliderOptionValueST(frushedHeal * 100, "{0}%")
	ElseIf(option[0] == "dRushedChance")
		iRushedConsequence = value as int
		SetSliderOptionValueST(iRushedConsequence, "{0}%")
	ElseIf(option[0] == "dRushedChanceAdd")
		iRushedConsequenceAdd = value as int
		SetSliderOptionValueST(iRushedConsequenceAdd, "+{0}%")
	ElseIf(option[0] == "dRushedBuffer")
		iRushedBuffer = value as int
		SetSliderOptionValueST(iRushedBuffer, "{0}s")
	ElseIf(option[0] == "blackoutChance")
		iBlackoutChance = value as int
		SetSliderOptionValueST(iBlackoutChance, "{0}")
	ElseIf(option[0] == "dBleedRegular")
		iBleedRegular = value as int
		SetSliderOptionValueST(iBleedRegular, "{0}")
	ElseIf(option[0] == "dBleedWither")
		iBleedWithered = value as int
		SetSliderOptionValueST(iBleedWithered, "{0}")
	ElseIf(option[0] == "dBleedDeathSent")
		iBleedDeathSentence = value as int
		SetSliderOptionValueST(iBleedDeathSentence, "{0}")
	ElseIf(option[0] == "dBleedRegularPl")
		iBleedRegularPl = value as int
		SetSliderOptionValueST(iBleedRegularPl, "{0}")
	ElseIf(option[0] == "dBleedWitherPl")
		iBleedWitheredPl = value as int
		SetSliderOptionValueST(iBleedWitheredPl, "{0}")
	ElseIf(option[0] == "dBleedDeathSentPl")
		iBleedDeathSentencePl = value as int
		SetSliderOptionValueST(iBleedDeathSentencePl, "{0}")
	ElseIf(option[0] == "resIgnoreVic")
		iResIgnore = value as int
		SetSliderOptionValueST(iResIgnore, "{0}%")
	ElseIf(option[0] == "resRobVic")
		iResRobbed = value as int
		SetSliderOptionValueST(iResRobbed, "{0}")
	ElseIf(option[0] == "resRapeVic")
		iResRaped = value as int
		SetSliderOptionValueST(iResRaped, "{0}")
	ElseIf(option[0] == "resExecuteVic")
		iResExecuted = value as int
		SetSliderOptionValueST(iResExecuted, "{0}")
	ElseIf(option[0] == "resRobVal")
		iResRItmVal = value as int
		SetSliderOptionValueST(iResRItmVal, "{0}g")
	ElseIf(option[0] == "resRobChance")
		iResRStealChance = value as int
		SetSliderOptionValueST(iResRStealChance, "{0}%")
	ElseIf(option[0] == "resRapeMax")
		iResMaxRounds = value as int
		SetSliderOptionValueST(iResMaxRounds, "{0}")
	ElseIf(option[0] == "resRapeChance")
		iResNextRoundChance = value as int
		SetSliderOptionValueST(iResNextRoundChance, "{0}%")
	ElseIf(option[0] == "resRapeEndless")
		iResNPCendless = value as int
		SetSliderOptionValueST(iResNPCendless, "{0}%")

	ElseIf(option[0] == "KdChance") ; Knockdown Condition
		int i = option[1] as int
		fKDChance[i] = value
		SetSliderOptionValueST(fKDChance[i], "{1}%")
	ElseIf(option[0] == "KdHpThreshUp")
		int i = option[1] as int
		fKdHpThreshUpper[i] = value/100
		SetSliderOptionValueST(fKdHpThreshUpper[i] * 100, "{0}%")
	ElseIf(option[0] == "KdHpThreshLow")
		int i = option[1] as int
		fKdHpThreshLower[i] = value/100
		SetSliderOptionValueST(fKdHpThreshLower[i] * 100, "{0}%")
	ElseIf(option[0] == "KdStaminaThresh")
		int i = option[1] as int
		fStaminaThresh[i] = value/100
		SetSliderOptionValueST(fStaminaThresh[i] * 100, "{0}%")
	ElseIf(option[0] == "KdMagickaThresh")
		int i = option[1] as int
		fMagickaThresh[i] = value/100
		SetSliderOptionValueST(fMagickaThresh[i] * 100, "{0}%")
	ElseIf(option[0] == "KdVulnerable")
		int i = option[1] as int
		iKdVulnerable[i] = value as int
		SetSliderOptionValueST(iKdVulnerable[i], "{0}")
	ElseIf(option[0] == "KdStripOdds")
		int i = option[1] as int
		iKdStrip[i] = value as int
		SetSliderOptionValueST(iKdStrip[i], "{0}%")
		If(iKdStrip[i] == 0)
			SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "KdStripBlock_" + i)
			SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "KdStripDrop_" + i)
			SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "KdStripDestroy_" + i)
			SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "KdStripProtect")
		else
			SetOptionFlagsST(OPTION_FLAG_NONE, true, "KdStripBlock_" + i)
			SetOptionFlagsST(OPTION_FLAG_NONE, true, "KdStripDrop_" + i)
			SetOptionFlagsST(OPTION_FLAG_NONE, true, "KdStripDestroy_" + i)
			SetOptionFlagsST(OPTION_FLAG_NONE, false, "KdStripProtect")
		EndIf
	ElseIf(option[0] == "KdStripDestroy")
		int i = option[1] as int
		iKdStripDstry[i] = value as int
		SetSliderOptionValueST(iKdStripDstry[i], "{0}%")

	ElseIf(option[0] == "SLAllowedweight") ; Animation Frame
		iSLweight = value as int
		SetSliderOptionValueST(iSLweight)
	ElseIf(option[0] == "FGAllowedweight")
		iFGweight = value as int
		SetSliderOptionValueST(iFGweight)
	ElseIf(option[0] == "OStimAllowedweight")
		iOStimweight = value as int
		SetSliderOptionValueST(iOStimweight)
	ElseIf(option[0] == "af2pWeight")
		iAF2some = value as int
		SetSliderOptionValueST(iAF2some)
	ElseIf(option[0] == "af3pWeight")
		iAF3some = value as int
		SetSliderOptionValueST(iAF3some)
	ElseIf(option[0] == "af4pWeight")
		iAF4some = value as int
		SetSliderOptionValueST(iAF4some)
	ElseIf(option[0] == "af5pWeight")
		iAF5Some = value as int
		SetSliderOptionValueST(iAF5Some)
	ElseIf(option[0] == "SLArousal")
		iSLArousalThresh = value as int
		SetSliderOptionValueST(iSLArousalThresh)
	ElseIf(option[0] == "SLArousalFol")
		iSLArousalFollower = value as int
		SetSliderOptionValueST(iSLArousalFollower)
	ElseIf(option[0] == "ostimMinD")
		fOtMinD = value
		SetSliderOptionValueST(fOtMinD)
	ElseIf(option[0] == "ostimMaxD")
		fOtMaxD = value
		SetSliderOptionValueST(fOtMaxD)

	ElseIf(option[0] == "conLfD") ; Consequence
		cLeftForDead = value as int
		SetSliderOptionValueST(cLeftForDead)
	ElseIf(option[0] == "conSS")
		cSimpleSlavery = value as int
		SetSliderOptionValueST(cSimpleSlavery)
	EndIf
EndEvent

; ========================= MENU
Event OnMenuOpenST()
	string[] option = StringSplit(GetState(), "_")
	If(option[0] == "cNPCimportance") ; General
		SetMenuDialogStartIndex(iImportance)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(importanceOptions)

	ElseIf(option[0] == "combatScenario") ; Defeat
		SetMenuDialogStartIndex(iCombatScenario)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(combatScenarios)

	ElseIf(option[0] == "resRobbedOptions") ; Resolution
		SetMenuDialogStartIndex(iResRType)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(resRobbedList)

	ElseIf(option[0] == "reaperFolTreatment") ; Reaper
		SetMenuDialogStartIndex(lReaperFollower)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(ReaperTargetTreat)
		ElseIf(option[0] == "ReaperCrtTreatment")
		SetMenuDialogStartIndex(lReapersCreature)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(ReaperTargetTreat)

	ElseIf(option[0] == "dBleedPotionMenu") ; Knockdown
		SetMenuDialogStartIndex(iPotionUsage)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(potionUsageList)

	ElseIf(option[0] == "filterType") ; Filter
		SetMenuDialogStartIndex(iFilterType)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(FilterTypeList)
	ElseIf(option[0] == "filterFol")
		SetMenuDialogStartIndex(iFolAttac)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(FollowerAttac)
	ElseIf(option[0] == "filterNPC")
		SetMenuDialogStartIndex(iNPCAttac)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(NPCAttac)

	ElseIf(option[0] == "crtFilterMethod") ; Creature Filter
		SetMenuDialogStartIndex(iCrtFilterMethod)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(crtFilterMethodList)
	EndIf
EndEvent

Event OnMenuAcceptST(int index)
	string[] option = StringSplit(GetState(), "_")
	If(option[0] == "cNPCimportance") ; General
		iImportance = index
		SetMenuOptionValueST(importanceOptions[iImportance])

	ElseIf(option[0] == "combatScenario") ; Defeat
		iCombatScenario = index
		SetMenuOptionValueST(combatScenarios[index])
		If(iCombatScenario == 1)
			SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "dRushedChance")
			SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "dRushedChanceAdd")
			SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "dRushedHeal")
			SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "dRushedBuffer")
		else
			SetOptionFlagsST(OPTION_FLAG_NONE, true, "dRushedChance")
			SetOptionFlagsST(OPTION_FLAG_NONE, true, "dRushedChanceAdd")
			SetOptionFlagsST(OPTION_FLAG_NONE, true, "dRushedHeal")
			SetOptionFlagsST(OPTION_FLAG_NONE, false, "dRushedBuffer")
		EndIf

	ElseIf(option[0] == "resRobbedOptions") ; Resolution
		iResRType = index
		SetMenuOptionValueST(resRobbedList[index])
		SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "resRobVal")
		SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "resRobChance")
		If(index == 1)
			SetOptionFlagsST(OPTION_FLAG_NONE, false, "resRobVal")
		ElseIf(index == 2)
			SetOptionFlagsST(OPTION_FLAG_NONE, false, "resRobChance")
		EndIf

	ElseIf(option[0] == "reaperFolTreatment") ; Reaper
		lReaperFollower = index
		SetMenuOptionValueST(ReaperTargetTreat[index])
	ElseIf(option[0] == "ReaperCrtTreatment") ; Reaper
		lReapersCreature = index
		SetMenuOptionValueST(ReaperTargetTreat[index])

	ElseIf(option[0] == "dBleedPotionMenu") ; Knockdown
		iPotionUsage = index
		SetMenuOptionValueST(potionUsageList[index])

	ElseIf(option[0] == "filterType") ; Filter
		iFilterType = index
		SetMenuOptionValueST(FilterTypeList[index])
	ElseIf(option[0] == "filterFol")
		iFolAttac = index
		SetMenuOptionValueST(FollowerAttac[index])
	ElseIf(option[0] == "filterNPC")
		iNPCAttac = index
		SetMenuOptionValueST(NPCAttac[index])

	ElseIf(option[0] == "crtFilterMethod") ; Creature Filter
		iCrtFilterMethod = index
		SetMenuOptionValueST(crtFilterMethodList[index])
	EndIf
EndEvent

; ========================= INPUT
Event OnInputOpenST()
	string[] option = StringSplit(GetState(), "_")
	If(option[0] == "SLTag")
		int i = option[1] as int
		SetInputDialogStartText(SLTags[i])
	EndIf
EndEvent

Event OnInputAcceptST(string a_input)
	string[] option = StringSplit(GetState(), "_")
	If(option[0] == "SLTag")
		int i = option[1] as int
		SLTags[i] = a_input
		SetInputOptionValueST(SLTags[i])
	EndIf
EndEvent

; ========================= HIGHLIGHT
Event OnHighlightST()
	string[] option = StringSplit(GetState(), "_")
	If(option[0] == "summonedVic") ; General
		SetInfoText("$Yam_genSummonVicHighlight")
	ElseIf(option[0] == "summonedAgg")
		SetInfoText("$Yam_genSummonAggHighlight")
	ElseIf(option[0] == "elderVic")
		SetInfoText("$Yam_genElderVicHighlight")
	ElseIf(option[0] == "elderAgg")
		SetInfoText("$Yam_genElderAggHighlight")
	ElseIf(option[0] == "CustomBleed")
		SetInfoText("$Yam_genBleedoutAnimHighlight")
	ElseIf(option[0] == "cNPCimportance")
		SetInfoText("$Yam_cNPCImportanceHighlight")
	ElseIf(option[0] == "cNPCimportanceFol")
		SetInfoText("$Yam_cNPCFollowerImportanceHighlight")

	ElseIf(option[0] == "ReaperSkilltree")
		SetInfoText("$Yam_reaperSkilltreeHighlight")

	ElseIf(option[0] == "combatScenario") ; Defeat
		SetInfoText("$Yam_dCombatScenarioHighlight")
	ElseIf(option[0] == "dBleedImmunity")
		SetInfoText("$Yam_dBleedImmunityHighlight")
	ElseIf(option[0] == "dBleedPotionMenu")
		SetInfoText("$Yam_dBleedPotionUseHighlight")
	ElseIf(option[0] == "blackoutChance")
		SetInfoText("$Yam_dBlackoutHighlight")
	ElseIf(option[0] == "dBleedRegular" || option[0] == "dBleedRegularPl")
		SetInfoText("$Yam_dBleedRegHighlight")
	ElseIf(option[0] == "dBleedWither" || option[0] == "dBleedWitherPl")
		SetInfoText("$Yam_dBleedWitherHighlight")
	ElseIf(option[0] == "dBleedDeathSent" || option[0] == "dBleedDeathSentPl")
		SetInfoText("$Yam_dBleedDeathSentence")

	ElseIf(option[0] == "dRushedChance")
		SetInfoText("$Yam_dRushedChanceHighlight")
	ElseIf(option[0] == "dRushedChanceAdd")
		SetInfoText("$Yam_dRushedChanceAddHighlight")
	ElseIf(option[0] == "dRushedHeal")
		SetInfoText("$Yam_dRushedHealHighlight")
	ElseIf(option[0] == "dRushedBuffer")
		SetInfoText("$Yam_dRushedBufferHighlight")

	ElseIf(option[0] == "resIgnoreVic") ; Resolution
		SetInfoText("$Yam_resIgnoreHighlight")
	ElseIf(option[0] == "resRobVic")
		SetInfoText("$Yam_resRobbedHighlight")
	ElseIf(option[0] == "resOnlyBanditsRob")
		SetInfoText("$Yam_resRobbedBanditsHighlight")
	ElseIf(option[0] == "resRapeVic")
		SetInfoText("$Yam_resRapedHighlight")
	ElseIf(option[0] == "resExecuteVic")
		SetInfoText("$Yam_resExecuteHighlight")
	ElseIf(option[0] == "resRobbedOptions")
		SetInfoText("$Yam_resRobbedOptionsHighlight")
	ElseIf(option[0] == "resRobbedWorn")
		SetInfoText("$Yam_resRobbedWornHighlight")
	ElseIf(option[0] == "resRobbedQstItm")
		SetInfoText("$Yam_resRobbedQstItmHighlight")
	ElseIf(option[0] == "resRobVal")
		SetInfoText("$Yam_resRobValHighlight")
	ElseIf(option[0] == "resRobChance")
		SetInfoText("$Yam_resRobChanceHighlight")
	ElseIf(option[0] == "resRapeReverse")
		SetInfoText("$Yam_resRapeReverseHighlight")
	ElseIf(option[0] == "resRapeMax")
		SetInfoText("$Yam_resRapeRoundsHighlight")
	ElseIf(option[0] == "resRapeChance")
		SetInfoText("$Yam_resRapeChanceHighlight")
	ElseIf(option[0] == "resRapeEndless")
		SetInfoText("$Yam_resRapeEndlessHighlight")

	ElseIf(option[0] == "reaperFolTreatment") ; Reaper
		SetInfoText("$Yam_reaperFollowerHighlight")
	ElseIf(option[0] == "ReaperCrtTreatment")
		SetInfoText("$Yam_ReaperCreatureHighlight")
	ElseIf(option[0] == "ReaperBashOnly")
		SetInfoText("$Yam_reaperBashOnlyHighlight")

	ElseIf(option[0] == "filterType") ; Filter
		SetInfoText("$Yam_filterTypeHighlight")

	ElseIf(option[0] == "crtFilterMethod") ; Creature Filter
		SetInfoText("$Yam_scrFilterMethodHighlight")

	ElseIf(option[0] == "KdChance") ; Knockdown Condition
		SetInfoText("$Yam_KdProfileChanceHighlight")
	ElseIf(option[0] == "KdBlock")
		SetInfoText("$Yam_KdProfileUnblockedHighlight")
	ElseIf(option[0] == "KdMelee")
		SetInfoText("$Yam_KdProfileMeleeHighlight")
	ElseIf(option[0] == "KDHpThreshUp")
		SetInfoText("$Yam_KdProfileHpThreshUpperHighlight")
	ElseIf(option[0] == "KDHpThreshLow")
		SetInfoText("$Yam_KdProfileHpThreshLowerHighlight")
	ElseIf(option[0] == "KdStaminaThresh")
		SetInfoText("$Yam_KdProfileStaminaThreshHighlight")
	ElseIf(option[0] == "KdMagickaThresh")
		SetInfoText("$Yam_KdProfileMagickaThreshHighlight")
	ElseIf(option[0] == "KdVulnerable")
		SetInfoText("$Yam_KdProfileVulnerableHighlight")
	ElseIf(option[0] == "KdStripOdds")
		SetInfoText("$Yam_KdStripOddsHighlight")
	ElseIf(option[0] == "KdStripDrop")
		SetInfoText("$Yam_KdStripDropHighlight")
	ElseIf(option[0] == "KdStripDestroy")
		SetInfoText("$Yam_KdStripDestroyHighlight")
	ElseIf(option[0] == "KdStripProtect")
		SetInfoText("$Yam_KdStripProtectHighlight")
	ElseIf(option[0] == "KdStripBlock")
		SetInfoText("$Yam_KdStripBlockHighlight")
	ElseIf(option[0] == "KdEssentialPlayer")
		SetInfoText("$Yam_KdEssentialPlHighlight")
	ElseIf(option[0] == "KdEssentialNPC")
		SetInfoText("$Yam_KdEssentialNPCHighlight")

	ElseIf(option[0] == "SLAllowed")  ; Anim Frames
		SetInfoText("$Yam_afFrameSexLabHighlight")
	ElseIf(option[0] == "SLAllowedweight")
		SetInfoText("$Yam_afFrameSexLabWeightHighlight")
	ElseIf(option[0] == "FGAllowed")
		SetInfoText("$Yam_afFrameFlowergirlsHighlight")
	ElseIf(option[0] == "FGAllowedweight")
		SetInfoText("$Yam_afFrameFlowergirlsWeightHighlight")
	ElseIf(option[0] == "OStimAllowed")
		SetInfoText("$Yam_afFrameOStimHighlight")
	ElseIf(option[0] == "OStimAllowedweight")
		SetInfoText("$Yam_afFrameOStimWeightHighlight")
	ElseIf(option[0] == "afNotifyColor")
		SetInfoText("$Yam_afAssaultNofifyColorHighlight")
	ElseIf(option[0] == "SLTreatVictim")
		SetInfoText("$Yam_SLTreatVictimHighlight")
	ElseIf(option[0] == "SLArousal")
		SetInfoText("$Yam_SLArousalHighlight")
	ElseIf(option[0] == "SLArousalFol")
		SetInfoText("$Yam_SLArousalFolHighlight")
	ElseIf(option[0] == "SLSupportFilter")
		SetInfoText("$Yam_SLFilterOptionHighlight")
	ElseIf(option[0] == "ostimMinD" || option[0] == "ostimMaxD")
		SetInfoText("$Yam_afOStimMinMaxDurHighlight")

	ElseIf(option[0] == "EnableMod")
		SetInfoText("$Yam_sEnableHighlight")
	ElseIf(option[0] == "EnableModExtra")
		SetInfoText("$Yam_sEnableLoadHighlight")
	EndIf
EndEvent

; ===============================================================
; =============================	GENERAL
; ===============================================================
State checkHostility
	Event OnSelectST()
		bCheckHostility = !bCheckHostility
		SetToggleOptionValueST(bCheckHostility)
	EndEvent
	Event OnHighlightST()
		SetInfoText("$Yam_genCombatQHostilityHighlight")
	EndEvent
EndState

State checkDistance
	Event OnSliderOpenST()
		SetSliderDialogStartValue(iMaxDistance)
		SetSliderDialogDefaultValue(60)
		SetSliderDialogRange(0, 300)
		SetSliderDialogInterval(5)
	EndEvent
	Event OnSliderAcceptST(float value)
		iMaxDistance = value as int
		SetSliderOptionValueST(iMaxDistance, "{0}m")
	EndEvent
	Event OnHighlightST()
		SetInfoText("$Yam_genCombatQDistanceHighlight")
	EndEvent
EndState

State notifyKd
	Event OnSelectST()
		bShowNotifyKD = !bShowNotifyKD
		SetToggleOptionValueST(bShowNotifyKD)
		SetNotifyFlags()
	EndEvent
	Event OnHighlightST()
		SetInfoText("$Yam_genNotifyKdHighlight")
	EndEvent
EndState

State notifySteal
	Event OnSelectST()
		bShowNotifySteal = !bShowNotifySteal
		SetToggleOptionValueST(bShowNotifySteal)
		SetNotifyFlags()
	EndEvent
	Event OnHighlightST()
		SetInfoText("$Yam_genNotifyStealHighlight")
	EndEvent
EndState

State notifyStrip
	Event OnSelectST()
		bShowNotifyStrip = !bShowNotifyStrip
		SetToggleOptionValueST(bShowNotifyStrip)
		SetNotifyFlags()
	EndEvent
	Event OnHighlightST()
		SetInfoText("$Yam_genNotifyStripHighlight")
	EndEvent
EndState

State ColoredKnockdownNotify
	Event OnSelectST()
		bShowNotifyColor = !bShowNotifyColor
		SetToggleOptionValueST(bShowNotifyColor)
		SetNotifyFlags()
	EndEvent
EndState

State KnockdownNotifyColor
	Event OnColorOpenST()
		SetColorDialogStartColor(iShowNotifyColor)
		SetColorDialogDefaultColor(0x0000FF)
	EndEvent
	Event OnColorAcceptST(int color)
		iShowNotifyColor = color
		SetColorOptionValueST(iShowNotifyColor)
		sNotifyColor = IntToString(iShowNotifyColor)
	EndEvent
EndState

Function SetNotifyFlags()
	SetOptionFlagsST(ColorNotify(), true, "ColoredKnockdownNotify")
	SetOptionFlagsST(ColorNotifyChoice(), false, "KnockdownNotifyColor")
EndFunction

int Function ColorNotify()
	return getFlag(bShowNotifyKD || bShowNotifySteal || bShowNotifyStrip)
EndFunction

int Function ColorNotifyChoice()
	return getFlag((bShowNotifyKD || bShowNotifySteal || bShowNotifyStrip) && bShowNotifyColor)
EndFunction

; ===============================================================
; =============================	SURRENDER
; ===============================================================
State SurrenderKey
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		If(newKeyCode == 1)
			Main.UnregisterForKey(iPlAggrKey)
			iSurrenderKey = -1
			SetKeyMapOptionValueST(iPlAggrKey)
			return
		EndIf
		bool continue = true
		if(conflictControl != "")
			string msg
			if(conflictName != "")
				msg = "This key is already mapped to:\n\"" + conflictControl + "\"\n(" + conflictName + ")\n\nAre you sure you want to continue?"
			else
				msg = "This key is already mapped to:\n\"" + conflictControl + "\"\n\nAre you sure you want to continue?"
			endIf
			continue = ShowMessage(msg, true, "$Yes", "$No")
		endIf
			if (continue)
				Main.UnregisterForKey(iSurrenderKey)
				iSurrenderKey = newKeyCode
				SetKeyMapOptionValueST(iSurrenderKey)
				Main.RegisterForKey(iSurrenderKey)
			endIf
		endEvent
	event OnDefaultST()
		Main.UnregisterForKey(iSurrenderKey)
		iSurrenderKey = -1
		SetKeyMapOptionValueST(iSurrenderKey)
	endEvent
	event OnHighlightST()
		SetInfoText("$Yam_SurrenderKeyHighlight")
	endEvent
EndState

; ===============================================================
; =============================	REAPERS MERCY
; ===============================================================
State PlAggrKey
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		If(newKeyCode == 1)
			Main.UnregisterForKey(iPlAggrKey)
			iPlAggrKey = -1
			SetKeyMapOptionValueST(iPlAggrKey)
			return
		EndIf
		bool continue = true
		if(conflictControl != "")
			string msg
			if(conflictName != "")
				msg = "This key is already mapped to:\n\"" + conflictControl + "\"\n(" + conflictName + ")\n\nAre you sure you want to continue?"
			else
				msg = "This key is already mapped to:\n\"" + conflictControl + "\"\n\nAre you sure you want to continue?"
			endIf
			continue = ShowMessage(msg, true, "$Yes", "$No")
		endIf
			if (continue)
				Main.UnregisterForKey(iPlAggrKey)
				iPlAggrKey = newKeyCode
				SetKeyMapOptionValueST(iPlAggrKey)
				Main.RegisterForKey(iPlAggrKey)
			endIf
		endEvent
	event OnDefaultST()
		Main.UnregisterForKey(iPlAggrKey)
		iPlAggrKey = -1
		SetKeyMapOptionValueST(iPlAggrKey)
	endEvent
	event OnHighlightST()
		SetInfoText("$Yam_reaperAbilityHotkeyHighlight")
	endEvent
EndState

State ReapersMercyPowerAdd
	Event OnSelectST()
		If(PlayerRef.HasSpell(ReapersMercySpell))
			If(ShowMessage("$Yam_reaperAbilityAddRemove_0"))
				PlayerRef.RemoveSpell(ReapersMercySpell)
				Debug.Notification("Reapers Mercy removed")
			EndIf
		else
			If(ShowMessage("$Yam_reaperAbilityAddRemove_1"))
				PlayerRef.AddSpell(ReapersMercySpell)
			EndIf
		EndIf
	EndEvent
endState

; ===============================================================
; =============================	KNOCKDOWN CONDITION
; ===============================================================
State KDProfileViewer
	Event OnMenuOpenST()
		SetMenuDialogStartIndex(iKDProfile)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(KnockdownProfile)
	EndEvent
	Event OnMenuAcceptST(int index)
		iKDProfile = index
		SetMenuOptionValueST(KnockdownProfile[iKDProfile])
		ForcePageReset()
	EndEvent
	Event OnDefaultST()
		iKDProfile = 1
		SetMenuOptionValueST(KnockdownProfile[iKDProfile])
		ForcePageReset()
	EndEvent
	Event OnHighlightST()
		SetInfoText("$Yam_KdProfileCurrentHighlight")
	endEvent
EndState

State KdStripExclude
	Event OnSelectST()
		If(ShowMessage("$Yam_KdStripExcludeMsg"))
			Wait(0.5)
			armorExclude.triggered()
		EndIf
	EndEvent
	Event OnHighlightST()
		SetInfoText("$Yam_KdStripExcludeHighlight")
	EndEvent
EndState

; ==================================
; ================ SEXLAB
; ==================================
State hideSL
	Event OnSelectST()
		If(afHideSL == 0)
			afHideSL = 1
		else
			afHideSL = 0
		EndIf
		ForcePageReset()
	EndEvent
EndState

State hideOstim
	Event OnSelectST()
		If(afHideOStim == 0)
			afHideOStim = 1
		else
			afHideOStim = 0
		EndIf
		ForcePageReset()
	EndEvent
EndState

State afNotify
	Event OnSelectST()
		bNotifyAF = !bNotifyAF
		SetToggleOptionValueST(bNotifyAF)
		If(bNotifyAF)
			If(bNotifyColorAF)
				SetOptionFlagsST(OPTION_FLAG_NONE, true, "afNotifyColorChoice")
			EndIf
			SetOptionFlagsST(OPTION_FLAG_NONE, false, "afNotifyColor")
		else
			If(bNotifyColorAF)
				SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "afNotifyColorChoice")
			EndIf
			SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "afNotifyColor")
		EndIf
	EndEvent
	Event OnHighlightST()
		SetInfoText("$Yam_afAssaultNotifyHighlight")
	EndEvent
EndState

State afNotifyColorChoice
	Event OnColorOpenST()
		SetColorDialogStartColor(iNotifyColorAF)
		SetColorDialogDefaultColor(0x0000FF)
	EndEvent
	Event OnColorAcceptST(int color)
		iNotifyColorAF = color
		SetColorOptionValueST(iNotifyColorAF)
		sNotifyColorAF = IntToString(iNotifyColorAF)
	EndEvent
EndState

; ==================================
; ================ DEBUG
; ==================================

; System
State PauseMod
	Event OnSelectST()
		bModPaused = !bModPaused
		SetToggleOptionValueST(bModPaused)
	EndEvent
	Event OnHighlightST()
		SetInfoText("$Yam_debugPauseHighlight")
	EndEvent
EndState

State DebugPauseKey
	Event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		If(newKeyCode == 1)
			Main.UnregisterForKey(iPauseKey)
			iPauseKey = -1
			SetKeyMapOptionValueST(iPauseKey)
			return
		EndIf
		bool continue = true
		if(conflictControl != "")
			string msg
			if(conflictName != "")
				msg = "This key is already mapped to:\n\"" + conflictControl + "\"\n(" + conflictName + ")\n\nAre you sure you want to continue?"
			else
				msg = "This key is already mapped to:\n\"" + conflictControl + "\"\n\nAre you sure you want to continue?"
			endIf
			continue = ShowMessage(msg, true, "$Yes", "$No")
		endIf
			if (continue)
				Main.UnregisterForKey(iPauseKey)
				iPauseKey = newKeyCode
				SetKeyMapOptionValueST(iPauseKey)
				Main.RegisterForKey(iPauseKey)
			endIf
		endEvent
	event OnDefaultST()
		Main.UnregisterForKey(iPauseKey)
		iPauseKey = 47
		SetKeyMapOptionValueST(iPauseKey)
		Main.RegisterForKey(iPauseKey)
	endEvent
	event OnHighlightST()
		SetInfoText("$Yam_debugPauseHotkeyHighlight")
	endEvent
EndState

State KillScanQuest
	Event OnSelectST()
		If(Yam_Scan.IsRunning())
			bKillScanQuest = true
			ShowMessage("$Yam_UponExit", false, "$Yam_OK")
		else
			ShowMessage("$Yam_debugKillCombatQError", false, "$Yam_OK")
		EndIf
	EndEvent
	Event OnHighlightST()
		SetInfoText("$Yam_debugKillCombatQHighlight")
	EndEvent
EndState

State SLScenery
		Event OnSelectST()
			bSLScenes = !bSLScenes
			SetToggleOptionValueST(!bSLScenes)
		endEvent
		Event OnHighlightST()
			SetInfoText("$Yam_debugDevModeHighlight")
		EndEvent
EndState
; Presets
State LoadMCMNull
	Event OnSelectST()
		If(ShowMessage("$Yam_debugPresetLoadNullSure"))
			SetTextOptionValueST("$Yam_working")
			LoadingMCM(filePathNull)
			WaitMenuMode(1)
			SetTextOptionValueST("$Yam_done")
		EndIf
	EndEvent
EndState

State LoadMCM
	Event OnSelectST()
		If(ShowMessage("$Yam_debugPresetLoadSure"))
			SetTextOptionValueST("$Yam_working")
			LoadingMCM(filePath00)
			WaitMenuMode(1)
			SetTextOptionValueST("$Yam_done")
		EndIf
	EndEvent
EndState

State SaveMCM
	Event OnSelectST()
		If(ShowMessage("$Yam_debugPresetSaveSure"))
			SetTextOptionValueST("$Yam_working")
			SavingMCM(filePath00)
			WaitMenuMode(1)
			SetTextOptionValueST("$Yam_done")
		EndIf
	EndEvent
EndState

State AutoSaveMCM
	Event OnSelectST()
		AutoSaveMCM = !AutoSaveMCM
		SetToggleOptionValueST(AutoSaveMCM)
	EndEvent
EndState
; Exclusion
State ExcludeSpell
	Event OnSelectST()
		If(PlayerRef.HasSpell(ExclusionSpell))
			If(ShowMessage("$Yam_debugExclusionSpellSure_0"))
				PlayerRef.RemoveSpell(ExclusionSpell)
				Debug.Notification("Yamete: Exclude Actor removed")
			EndIf
		else
			If(ShowMessage("$Yam_debugExclusionSpellSure_1"))
				PlayerRef.AddSpell(ExclusionSpell)
			EndIf
		EndIf
	EndEvent
endState

State ExcludeAggressor
	Event OnSelectST()
		Actor ref = Game.GetCurrentCrosshairRef() as Actor
		If(ref)
			If(ShowMessage("Exclude " + ref.GetLeveledActorBase().GetName() + " from becomming an Aggressor?"))
				excludeActorVic(ref)
			EndIf
		else
			Debug.Notification("No Actor found")
		EndIf
	EndEvent
	Event OnHighlightST()
		SetInfoText("$Yam_debugExclusionAggrHighlight")
	EndEvent
EndState

State ExcludeVictim
	Event OnSelectST()
		Actor ref = Game.GetCurrentCrosshairRef() as Actor
		If(ref)
			If(ShowMessage("Exclude " + ref.GetLeveledActorBase().GetName() + " from becomming a Victim?"))
				excludeActorVic(ref)
			EndIf
		else
			Debug.Notification("No Actor found")
		EndIf
	EndEvent
	Event OnHighlightST()
		SetInfoText("$Yam_debugExclusionVicHighlight")
	EndEvent
EndState

State excludeValidation
	Event OnSelectST()
		int sol = validateExcludedVictims()
		If(sol == 0)
			ShowMessage("$Yam_debugExclusionValidateError_0", false, "$Yam_OK")
		ElseIf(sol == 1)
			ShowMessage("$Yam_debugExclusionValidateError_1", false, "$Yam_OK")
		ElseIf(sol == 2)
			ShowMessage("$Yam_debugExclusionValidateError_2", false, "$Yam_OK")
		Else
			ShowMessage("$Yam_debugExclusionValidateSuccess", false, "$Yam_OK")
		EndIf
	EndEvent
	Event OnHighlightST()
		SetInfoText("$Yam_debugExclusionValidateHighlight")
	EndEvent
endState

; ==================================
; 				States // General
; ==================================
; State clockChance
; 	Event OnSliderOpenST()
; 		SetSliderDialogStartValue(iClockOutChance)
; 		SetSliderDialogDefaultValue(12)
; 		SetSliderDialogRange(0, 120)
; 		SetSliderDialogInterval(1)
; 	EndEvent
; 	Event OnSliderAcceptST(float value)
; 		iClockOutChance = value as int
; 		SetSliderOptionValueST(iClockOutChance, "{0}%")
; 	EndEvent
; 	Event OnHighlightST()
; 		SetInfoText("An Actor that has recently assaulted someone will be clocked. While clocked out, Actors arent allowed to assault anyone. This Setting controls how likely it is that an Actor will be clocked out.\nYes Im funny, shut it.")
; 	EndEvent
; EndState

; ===============================================================
; =============================	UTILITY
; ===============================================================
string Function GetStatus()
	If(Yam_Scan.IsRunning())
		return "<font color = '#00ffdd'>$Yam_genStatusActive" ; Blue Green
	ElseIf(!bModPaused)
		return "<font color = '#00ff00'>$Yam_genStatusInactive" ; Green
	Else
		return "<font color = '#ff1f0a'>$Yam_genStatusPaused" ; Red
	EndIf
EndFunction

int Function getFlag(bool option)
	If(option)
		return OPTION_FLAG_NONE
	else
		return OPTION_FLAG_DISABLED
	EndIf
endFunction

; ===============================================================
; =============================	LOAD SAVE EXCLUDE
; ===============================================================
int Function validateExcludedVictims()
	If(!JsonExists("../Yamete/excluded.json"))
		return 0
	ElseIf(!IsGood("../Yamete/excluded.json"))
		return 1
	EndIf
	Form[] excluded = FormListToArray("../Yamete/excluded.json", "actorVic")
	If(!excluded)
		return 2
	EndIf
	int count = excluded.Length
	If(!count)
		return 2
	Else
		While(Count)
			count -= 1
			(excluded[count] as Actor).AddToFaction(exclusionFac)
		EndWhile
	EndIf
	return 3
EndFunction

Function SavingMCM(String filepath)
	; --- General
	SetIntValue(filePath, "ClockOutChance", iClockOutChance)
	SetIntValue(filePath, "bCheckHostility", bCheckHostility as int)
	SetIntValue(filePath, "iMaxDistance", iMaxDistance)
	SetFloatValue(filePath, "SummonVicGl", SummonVicGl.Value)
	SetIntValue(filePath, "bSummonAggr", bSummonAggr as int)
	SetIntValue(filePath, "iImportance", iImportance)
	SetIntValue(filePath, "bImportantFollowers", bImportantFollowers as int)
	SetIntValue(filePath, "bCustomBleed", bCustomBleed as int)
	SetIntValue(filePath, "bShowNotifyKD", bShowNotifyKD as int)
	SetIntValue(filePath, "bShowNotifySteal", bShowNotifySteal as int)
	SetIntValue(filePath, "bShowNotifyStrip", bShowNotifyStrip as int)
	SetIntValue(filePath, "bShowNotifyColor", bShowNotifyColor as int)
	SetIntValue(filePath, "iShowNotifyColor", iShowNotifyColor)
	SetStringValue(filePath, "sNotifyColor", sNotifyColor)

	; --- Reapers Mercy
	SetIntValue(filePath, "iPlAggrKey", iPlAggrKey)

	; --- Defeat
	SetIntValue(filePath, "iCombatScenario", iCombatScenario)
	SetIntValue(filePath, "iBlackoutChance", iBlackoutChance)
	SetIntValue(filePath, "iPotionUsage", iPotionUsage)
	; SetIntValue(filePath, "bleedoutMarkImmunity", bleedoutMarkImmunity as int)
	SetIntValue(filePath, "iRushedConsequence", iRushedConsequence)
	SetIntValue(filePath, "iRushedConsequenceAdd", iRushedConsequenceAdd)
	SetFloatValue(filePath, "frushedHeal", frushedHeal)
	SetIntValue(filePath, "iRushedBuffer", iRushedBuffer)
	SetIntValue(filePath, "iBleedRegularPl", iBleedRegularPl)
	SetIntValue(filePath, "iBleedWitheredPl", iBleedWitheredPl)
	SetIntValue(filePath, "iBleedDeathSentencePl", iBleedDeathSentencePl)
	SetIntValue(filePath, "iBleedRegular", iBleedRegular)
	SetIntValue(filePath, "iBleedWithered", iBleedWithered)
	SetIntValue(filePath, "iBleedDeathSentence", iBleedDeathSentence)
	SetIntValue(filePath, "iResIgnore", iResIgnore)
	SetIntValue(filePath, "iResRobbed", iResRobbed)
	SetIntValue(filePath, "iResRaped", iResRaped)
	SetIntValue(filePath, "iResExecuted", iResExecuted)
	SetIntValue(filePath, "bOnlyBanditsRob", bOnlyBanditsRob as int)
	SetIntValue(filePath, "iResRType", iResRType)
	SetIntValue(filePath, "bResRWorn", bResRWorn as int)
	SetIntValue(filePath, "bResRQstItm", bResRQstItm as int)
	SetIntValue(filePath, "iResRItmVal", iResRItmVal)
	SetIntValue(filePath, "iResRStealChance", iResRStealChance)
	SetIntValue(filePath, "bResReverse", bResReverse as int)
	SetIntValue(filePath, "iResMaxRounds", iResMaxRounds)
	SetIntValue(filePath, "iResNextRoundChance", iResNextRoundChance)
	SetIntValue(filePath, "iResNPCendless", iResNPCendless)

	; --- Knockdown Condition
	FloatListCopy(filePath, "fKDChance", fKDChance)
	IntListCopy(filePath, "bKdBlock", boolToIntArray(bKdBlock))
	IntListCopy(filePath, "bKdMelee", boolToIntArray(bKdMelee))
	FloatListCopy(filePath, "fKdHpThreshUpper", fKdHpThreshUpper)
	FloatListCopy(filePath, "fKdHpThreshLower", fKdHpThreshLower)
	FloatListCopy(filePath, "fStaminaThresh", fStaminaThresh)
	FloatListCopy(filePath, "fMagickaThresh", fMagickaThresh)
	IntListCopy(filePath, "iKdVulnerable", iKdVulnerable)
	SetIntValue(filePath, "bKdEssentialPlayer", bKdEssentialPlayer as int)
	IntListCopy(filePath, "bKdEssentialNPC", boolToIntArray(bKdEssentialNPC))
	IntListCopy(filePath, "iKdStrip", iKdStrip)
	IntListCopy(filePath, "bKdStripBlock", boolToIntArray(bKdStripBlock))
	IntListCopy(filePath, "bKdStripDrop", boolToIntArray(bKdStripDrop))
	IntListCopy(filePath, "iKdStripDstry", iKdStripDstry)
	SetIntValue(filePath, "iKdStripProtect", iKdStripProtect as int)

	; --- Stripping
	IntListCopy(filePath, "bValidStrips", boolToIntArray(bValidStrips))

	; --- Animation Frames
	SetIntValue(filePath, "bSLAllowed", bSLAllowed as int)
	SetIntValue(filePath, "bFGAllowed", bFGAllowed as int)
	SetIntValue(filePath, "bOStimAllowed", bOStimAllowed as int)
	SetIntValue(filePath, "iSLweight", iSLweight)
	SetIntValue(filePath, "iFGweight", iFGweight)
	SetIntValue(filePath, "iOStimweight", iOStimweight)
	SetIntValue(filePath, "bNotifyAF", bNotifyAF as int)
	SetIntValue(filePath, "bNotifyColorAF", bNotifyColorAF as int)
	SetIntValue(filePath, "iNotifyColorAF", iNotifyColorAF)
	SetStringValue(filePath, "sNotifyColorAF", sNotifyColorAF)
	SetIntValue(filePath, "bSLAsVictim", bSLAsVictim as int)
	SetIntValue(filePath, "iSLArousalThresh", iSLArousalThresh)
	SetIntValue(filePath, "iSLArousalFollower", iSLArousalFollower)
	SetIntValue(filePath, "bSupportFilter", bSupportFilter as int)
	StringListCopy(filePath, "SLTags", SLTags)
	SetFloatValue(filePath, "fOtMinD", fOtMinD)
	SetFloatValue(filePath, "fOtMaxD", fOtMaxD)
	SetIntValue(filePath, "iAF2some", iAF2some)
	SetIntValue(filePath, "iAF3some", iAF3some)
	SetIntValue(filePath, "iAF4some", iAF4some)
	SetIntValue(filePath, "iAF5Some", iAF5Some)

	; --- Filter
	SetIntValue(filePath, "iFilterType", iFilterType)
	SetIntValue(filePath, "iFolAttac", iFolAttac)
	SetIntValue(filePath, "iNPCAttac", iNPCAttac)
	IntListCopy(filePath, "bAssaultPl", boolToIntArray(bAssaultPl))
	IntListCopy(filePath, "bAssaultNPC", boolToIntArray(bAssaultNPC))
	IntListCopy(filePath, "bAssaultFol", boolToIntArray(bAssaultFol))

	; --- Creature Filter
	SetIntValue(filePath, "iCrtFilterMethod", iCrtFilterMethod)
	IntListCopy(filePath, "bValidRace", boolToIntArray(bValidRace))

	; --- Consequences
	SetIntValue(filePath, "cLeftForDead", cLeftForDead)
	SetIntValue(filePath, "cSimpleSlavery", cSimpleSlavery)

	; --- Debug
	SetIntValue(filePath, "iPauseKey", iPauseKey)

	Save(filepath)
EndFunction

Function LoadingMCM(String filepath)
	If(IsGood(filePath) == false || JsonExists(filePath) == false)
		Debug.Messagebox("[Error] MCM Preset has errors or doesn't exist")
		return
	EndIf
	; --- General
	iClockOutChance = GetIntValue(filePath, "iClockOutChance")
	bCheckHostility = GetIntValue(filePath, "bCheckHostility") as bool
	iMaxDistance = GetIntValue(filePath, "iMaxDistance")
	SummonVicGl.Value = GetFloatValue(filePath, "SummonVicGl")
	bSummonAggr = GetIntValue(filePath, "bSummonAggr") as bool
	iImportance = GetIntValue(filePath, "iImportance")
	bImportantFollowers = GetIntValue(filePath, "bImportantFollowers") as bool
	bCustomBleed = GetIntValue(filePath, "bCustomBleed") as bool
	bShowNotifyKD = GetIntValue(filePath, "bShowNotifyKD") as bool
	bShowNotifySteal = GetIntValue(filePath, "bShowNotifySteal") as bool
	bShowNotifyStrip = GetIntValue(filePath, "bShowNotifyStrip") as bool
	bShowNotifyColor = GetIntValue(filePath, "bShowNotifyColor") as bool
	iShowNotifyColor = GetIntValue(filePath, "iShowNotifyColor")
	sNotifyColor = GetStringValue(filePath, "sNotifyColor")
	; --- Reapers Mercy
	iPlAggrKey = GetIntValue(filePath, "iPlAggrKey")

	; --- Defeat
	iCombatScenario = GetIntValue(filePath, "iCombatScenario")
	iBlackoutChance = GetIntValue(filePath, "iBlackoutChance")
	iPotionUsage = GetIntValue(filePath, "iPotionUsage")
	; bleedoutMarkImmunity = GetIntValue(filePath, "bleedoutMarkImmunity") as bool
	iRushedConsequence = GetIntValue(filePath, "iRushedConsequence")
	iRushedConsequenceAdd = GetIntValue(filePath, "iRushedConsequenceAdd")
	frushedHeal = GetFloatValue(filePath, "frushedHeal")
	iRushedBuffer = GetIntValue(filePath, "iRushedBuffer")
	iBleedRegularPl = GetIntValue(filePath, "iBleedRegularPl")
	iBleedWitheredPl = GetIntValue(filePath, "iBleedWitheredPl")
	iBleedDeathSentencePl = GetIntValue(filePath, "iBleedDeathSentencePl")
	iBleedRegular = GetIntValue(filePath, "iBleedRegular")
	iBleedWithered = GetIntValue(filePath, "iBleedWithered")
	iBleedDeathSentence = GetIntValue(filePath, "iBleedDeathSentence")
	iResIgnore = GetIntValue(filePath, "iResIgnore")
	iResRobbed = GetIntValue(filePath, "iResRobbed")
	iResRaped = GetIntValue(filePath, "iResRaped")
	iResExecuted = GetIntValue(filePath, "iResExecuted")
	bOnlyBanditsRob = GetIntValue(filePath, "bOnlyBanditsRob") as bool
	iResRType = GetIntValue(filePath, "iResRType")
	bResRWorn = GetIntValue(filePath, "bResRWorn") as bool
	bResRQstItm = GetIntValue(filePath, "bResRQstItm") as bool
	iResRItmVal = GetIntValue(filePath, "iResRItmVal")
	iResRStealChance = GetIntValue(filePath, "iResRStealChance")
	bResReverse = GetIntValue(filePath, "bResReverse") as bool
	iResMaxRounds = GetIntValue(filePath, "iResMaxRounds")
	iResNextRoundChance = GetIntValue(filePath, "iResNextRoundChance")
	iResNPCendless = GetIntValue(filePath, "iResNPCendless")

	; --- Knockdown Condition
	fKDChance = FloatListToArray(filePath, "fKDChance")
	bKdBlock = intToBoolArray(IntListToArray(filePath, "bKdBlock"))
	bKdMelee = intToBoolArray(IntListToArray(filePath, "bKdMelee"))
	fKdHpThreshUpper = FloatListToArray(filePath, "fKdHpThreshUpper")
	fKdHpThreshLower = FloatListToArray(filePath, "fKdHpThreshLower")
	fStaminaThresh = FloatListToArray(filePath, "fStaminaThresh")
	fMagickaThresh = FloatListToArray(filePath, "fMagickaThresh")
	iKdVulnerable = IntListToArray(filePath, "iKdVulnerable")
	bKdEssentialPlayer = GetIntValue(filePath, "bKdEssentialPlayer") as bool
	bKdEssentialNPC = intToBoolArray(IntListToArray(filePath, "bKdEssentialNPC"))
	iKdStrip = IntListToArray(filePath, "iKdStrip")
	bKdStripBlock = intToBoolArray(IntListToArray(filePath, "bKdStripBlock"))
	bKdStripDrop = intToBoolArray(IntListToArray(filePath, "bKdStripDrop"))
	iKdStripDstry = IntListToArray(filePath, "iKdStripDstry")
	iKdStripProtect = GetIntValue(filePath, "iKdStripProtect") as bool

	; --- Stripping
	bValidStrips = intToBoolArray(IntListToArray(filePath, "bValidStrips"))

	; --- Animation Frames
	bSLAllowed = GetIntValue(filePath, "bSLAllowed") as bool
	bFGAllowed = GetIntValue(filePath, "bFGAllowed") as bool
	bOStimAllowed = GetIntValue(filePath, "bOStimAllowed") as bool
	iSLweight = GetIntValue(filePath, "iSLweight")
	iFGweight = GetIntValue(filePath, "iFGweight")
	iOStimweight = GetIntValue(filePath, "iOStimweight")
	bNotifyAF = GetIntValue(filePath, "bNotifyAF") as bool
	bNotifyColorAF = GetIntValue(filePath, "bNotifyColorAF") as bool
	iNotifyColorAF = GetIntValue(filePath, "iNotifyColorAF")
	sNotifyColorAF = GetStringValue(filePath, "sNotifyColorAF")
	bSLAsVictim = GetIntValue(filePath, "bSLAsVictim") as bool
	iSLArousalThresh = GetIntValue(filePath, "iSLArousalThresh")
	iSLArousalFollower = GetIntValue(filePath, "iSLArousalFollower")
	bSupportFilter = GetIntValue(filePath, "bSupportFilter") as bool
	SLTags = StringListToArray(filePath, "SLTags")
	fOtMinD = GetFloatValue(filePath, "fOtMinD")
	fOtMaxD = GetFloatValue(filePath, "fOtMaxD")
	iAF2some = GetIntValue(filePath, "iAF2some")
	iAF3some = GetIntValue(filePath, "iAF3some")
	iAF4some = GetIntValue(filePath, "iAF4some")
	iAF5Some = GetIntValue(filePath, "iAF5Some")

	; --- Filter
	iFilterType = GetIntValue(filePath, "iFilterType")
	iFolAttac = GetIntValue(filePath, "iFolAttac")
	iNPCAttac = GetIntValue(filePath, "iNPCAttac")
	bAssaultPl = intToBoolArray(IntListToArray(filePath, "bAssaultPl"))
	bAssaultNPC = intToBoolArray(IntListToArray(filePath, "bAssaultNPC"))
	bAssaultFol = intToBoolArray(IntListToArray(filePath, "bAssaultFol"))

	; --- Creature Filter
	iCrtFilterMethod = GetIntValue(filePath, "iCrtFilterMethod")
	bValidRace = intToBoolArray(IntListToArray(filePath, "bValidRace"))

	; --- Consequences
	cLeftForDead = GetIntValue(filePath, "cLeftForDead")
	cSimpleSlavery = GetIntValue(filePath, "cSimpleSlavery")

	; --- Debug
	iPauseKey = GetIntValue(filePath, "iPauseKey")
EndFunction

Function excludeActorAggr(Form toExclude)
  FormListAdd("../Yamete/excluded.json", "actorsAggr", toExclude, false)
  Debug.Notification((toExclude as Actor).GetLeveledActorBase().GetName() + " is no longer allowed to knock down.")
EndFunction

Function excludeActorVic(Form toExclude)
  FormListAdd("../Yamete/excluded.json", "actorsVic", toExclude, false)
  (toExclude as Actor).AddToFaction(exclusionFac)
  Debug.Notification((toExclude as Actor).GetLeveledActorBase().GetName() + " is no longer allowed to be knocked down.")
EndFunction

bool[] Function intToBoolArray(int[] myArr)
	int i = myArr.Length
	bool[] toRet = CreateBoolArray(i)
	While(i)
		i -= 1
		toRet[i] = myArr[i] as bool
	EndWhile
	return toRet
EndFunction

int[] Function boolToIntArray(bool[] myArr)
	int i = myArr.Length
	int[] toRet = CreateIntArray(i)
	While(i)
		i -= 1
		toRet[i] = myArr[i] as int
	EndWhile
	return toRet
EndFunction

String Function IntToString(int x)
	String hex = ""
  While(x != 0)
		int c = x % 16
		If(c < 10)
			hex += c
		Else
			hex += StringUtil.AsChar(55 + c)
		EndIf
	EndWhile
  While(StringUtil.GetLength(hex) < 6)
    hex = "0" + hex
  EndWhile
  return "#" + hex
EndFunction
