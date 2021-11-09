ScriptName Yamete Hidden

; Knockdown a Victim into Yametes System
; --- Parameters
; @victim     - The Victim to Knockdown
; @overwrite  - The Bleedout Type the Victim should be using. -1 to let Yamete Decide. See Forum Documentation for IDs
Function Knockdown(Actor victim, int overwrite) global
  Debug.Trace("[Yamete] <Yamete> Knockdown(); overwrite: " + overwrite)
  YamMain Main = Quest.GetQuest("Yam_Main") as YamMain
  Main.npcBleedout(victim, overwrite)
EndFunction

; Call one of Yametes Consequences
; --- Paremeters
; @overwrite   - The ID of the Consequence. Set -1 to use Yametes owned Algorithm. See Forum Documentation for IDs
; @victoire    - The Actor considered the Winner of the Encounter. Used by the Algorithm to pick a suited Outcome. Can be none
Function StartPlayerConsequence(int overwrite, Actor victoire) global
  Debug.Trace("[Yamete] <Yamete> StartPlayerConsequence(); overwrite: " + overwrite)
  YamMain Main = Quest.GetQuest("Yam_Main") as YamMain
  Main.PlayerConsequence(overwrite)
EndFunction

; Manually start Yametes Resolution
; --- Parameters
; @victim							- An Array of Victims (Actors that lost the Fight)
; @victoire						- An Array of Victoires (Actors that won the fight)
; @SknockdownVictims	- Should all Victims be forced into Bleedout? Resolution expects Victims to be Bleeding out
; @consequence				- The Resolution Scenario. Set 0 to let Yamete decide; See Forum for Documentation for IDs. Invalid IDs break Resolution
; @disableDIalogue		- Disable Dialogue in Resolution; If this call is not made after a Combat Defeat this might be useful to avoid unfitting Dialogue
; --- Return
; Wheter or not Resolution managed started.
bool Function StartResolution(Actor[] victim, Actor[] victoire, bool knockdownVictims, int consequence, int disableDialogue) global
  Debug.Trace("[Yamete] <Yamete> StartResolution(); consequence: " + consequence)
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
