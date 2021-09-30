ScriptName Yamete Hidden

; Start one of Yametes owned Consequences
; See Forum for IDs, set -1 for random
Function StartPlayerConsequence(int overwrite) global
	Debug.Trace("[Yamete] StartPlayerConsequence() called; overwrite: " + overwrite)
	YamMain Main = Quest.GetQuest("Yam_Main") as YamMain
	Main.PlayerConsequence(overwrite)
EndFunction

; Manually start Resolution
; See Forum for IDs, set 0 for random. Invalid IDs break Resolution
bool Function StartResolution(Actor[] victim, Actor[] victoire, bool knockdownVictims, int consequence, int disableDialogue) global
	Debug.Trace("[Yamete] StartResolution() called; consequence: " + consequence)
	Spell victimMark = Game.GetFormFromFile(0x6F26B2, "Yamete.esp") as Spell
	Spell victoireMark = Game.GetFormFromFile(0x6F26B0, "Yamete.esp") as Spell
	YamMain Main = Quest.GetQuest("Yam_Main") as YamMain
	int i = 0
	While(i < victim.length)
		victimMark.Cast(victim[i], victim[i])
		If(knockdownVictims)
			Main.BleedOutEnter(victim[i], 1)
		EndIf
		i += 1
	EndWhile
	int n = 0
	While(n < victoire.length)
		victoireMark.Cast(victoire[i], victoire[i])
		n += 1
	EndWhile
	return Keyword.GetKeyword("Yam_ResolutionSE").SendStoryEventAndWait(none, victoire[0], aiValue1 = consequence, aiValue2 = disableDialogue)
EndFunction
