Scriptname YamResolution extends Quest  Conditional

; -------------------------------------------- Properties
YamMain Property Main Auto
YamMCM Property MCM Auto
Quest Property Scan Auto

ReferenceAlias Property plVic Auto
{Only filled if the Player is considered a Victim}
YamResVictoire[] Property winners Auto
{All Victoires, excluding Primary}
YamResVictoire Property primWin Auto
{Leading Winner - the one considered Head of the Winning Team}
YamResVictim[] Property victims Auto
{All Defeated, including Primary if not the Player}
YamResVictim Property primVic Auto
{Leading Victim - the Lead Victoires primary Interaction Target, will be the one closest to them if not the Player}
Faction Property victoireFaction Auto
Faction Property friendFac Auto
Spell Property AoEFleeMark Auto
Topic Property nextSceneTopic Auto
Topic Property quitSceneTopic Auto
Keyword Property ActorTypeNPC Auto
Keyword Property bleedoutMarkTmp Auto
; -------------------------------------------- Variables
int Property DisableDialogue Auto Hidden Conditional
int primAction = 0
; -------------------------------------------- Code
; =========================================================================
; ============================================ START UP
; ========================================================================
bool Function GetNearestVictoireMain(Actor victim)
  If(!victim)
    Debug.Trace("[Yamete] GetNearestVictoireMain() -> Victim is none")
    return false
  else
    Actor victoire = none
    float dist = 9999.9
    int slot = 0
    int akt = 0
    int i = 0
    While(i < winners.length)
      Actor that = winners[i].GetReference() as Actor
      Debug.Trace("[Yamete] GetNearestVictoireMain() with " + victim + ", Considering " + winners[i])
      If(that)
        akt = Main.getResolutionAction(that, victim)
        If(akt != 0)
          float d = victim.GetDistance(that)
          If(d < dist)
            dist = d
            slot = i
            victoire = that
          EndIf
        EndIf
      EndIf
      i += 1
    EndWhile
    If(victoire == none)
      return false
    else
      primAction = akt
      primWin.ForceRefTo(victoire)
      primVic.ForceRefTo(victim)
      winners[slot].Clear()
      return true
    EndIf
  EndIf
EndFunction

Event OnStoryScript(Keyword akKeyword, Location akLocation, ObjectReference akRef1, ObjectReference akRef2, int aiValue1, int aiValue2)
  ;/ IDEA get the Algorithm noted in the top post noted and create a switch here /;
  ; complexAlgorithm = false
  ; At this point, the Resolution Quest basically contains 2 Lists: One with unanalyzed Aggressors and one with unanalyzed Victims
  ; Purpose of the following Block is to find a Leading Victim and Victoire including a Consequence for them
  ;/ NOTE /;
  ; A fitting Victoire is considered a Victoire which is of valid Gender and Race and has a valid Action associated with it
  ; ========
  ; Get primary Victim, primary Victoire & Action.. starting with the Player if present
	If(aiValue1 == 0)
		If(!GetNearestVictoireMain(plVic.GetReference() as Actor))
	    int i = 0
	    While(!GetNearestVictoireMain(victims[i].GetReference() as Actor) && (i < victims.length - 1))
	      i += 1
	    EndWhile
	  EndIf
	else
		primAction = aiValue1
	EndIf
  ; ========
  ; Play outcome. If the prim Action isnt 0, set the Stage of the Quest to proceed the Intro Scene..
  If(primAction == 0)
    Debug.Trace("[Yamete] Resoltion: Failed to find a valid Victoire - Victim Combination")
    SetStage(1000)
    return
  Else
		DisableDialogue = aiValue2
    SetStage((10 * primAction) + 20)
  EndIf
EndEvent

Function primaryRobEntry()
  Main.RemoveItemsFromTo(primVic.GetReference(), primWin.GetReference() as Actor)
EndFunction
Function primaryRobDone()
	If(Utility.RandomInt(0, 99) < MCM.iBlackoutChance)
		Main.PlayerConsequence(-1)
		SetStage(1000)
	else
		primVic.setDone()
	EndIf
EndFunction

int rounds
Function chainRapeEntry()
  Actor victim = primVic.GetReference() as Actor
  Actor victoire = primWin.GetReference() as Actor
  If(victim != Game.GetPlayer() && Utility.RandomInt(0, 99) < MCM.iResNPCendless)
    If(Main.CreateEndlessScene(victim, victoire))
      return
    EndIf
  EndIf
  Actor[] partner = new Actor[1]
  partner[0] = victoire
  If(YamAnimationFrame.StartAnimation(MCM, victim, partner, self, 1, "ResolutionMain") > -1)
    RegisterForModEvent("HookAnimationEnd_ResolutionMain", "AfterScene")
    rounds = 1
    Debug.Trace("[Yamete] YamResolution: Started primary Animation..")
  else
    SetStage(1000)
    Debug.Trace("[Yamete] YamResolution: Failed to start primary Animation..")
  EndIf
EndFunction

Event AfterScene(int tid, bool hasPlayer)
  Debug.Trace("[Yamete] SL Scene End registered on YamResolution")
  continueChain()
EndEvent
Event OStimEnd(string eventName, string strArg, float numArg, Form sender)
  Debug.Trace("[Yamete] OStim Scene End Main registered on YamResolution")
  continueChain()
EndEvent
Event OnQuestStop(Quest akQuest)
  Debug.Trace("[Yamete] FG Scene End registered on YamResolution")
  continueChain()
EndEvent
Event OnUpdate()
  Debug.Trace("[Yamete] OStim Scene End Sub registered on YamResolution")
  continueChain()
EndEvent

Function continueChain()
  Actor victim = primVic.GetReference() as Actor
  Main.BleedOutEnter(victim, 0)
  If(playNextScene(rounds))
    rounds += 1
    Debug.Trace("[Yamete] Continue Chain Rape; rounds: " + rounds)
    Actor[] partners = fillSceneArray(primVic)
    If(partners)
      partners[Utility.RandomInt(0, partners.length - 1)].Say(nextSceneTopic)
      Utility.Wait(4)
      If(YamAnimationFrame.StartAnimation(MCM, victim, partners, self, 1, "ResolutionMain") > -1)
        return
      Else
        Debug.Trace("[Yamete] Error at starting Chain Scene at round " + rounds)
      EndIf
    else
      Debug.Trace("[Yamete] Fill Scene Array returned invalid Array")
    EndIf
  EndIf
  Debug.Trace("[Yamete] End Chain Scene after " + rounds + " rounds on YamResolution")
  primVic.setDone()
  ; (primWin.GetReference() as Actor).Say(quitSceneTopic)
  If(victim == Game.GetPlayer())
    If(Utility.RandomInt(0, 99) < MCM.iBlackoutChance)
      Main.PlayerConsequence(-1)
    else
			Utility.Wait(1.5)
      Main.BleedOutExit(victim, true)
    EndIf
  EndIf
  SetStage(1000)
EndFunction

bool Function playNextScene(int repeats)
	bool ltm = MCM.iResMaxRounds > repeats || MCM.iResMaxRounds == 0
	If(MCM.bResReverse)
		return ltm
	else
		return ltm && Utility.RandomInt(0, 99) < MCM.iResNextRoundChance
	EndIf
EndFunction

Actor[] Function fillSceneArray(YamResVictim v)
  Actor victim = v.GetReference() as Actor
  Actor[] act = MiscUtil.ScanCellNPCsByFaction(victoireFaction, victim, 350.0)
	Debug.TraceConditional("[Yamete] Victim include in ScanCellNPC..", act.Find(victim) > -1)
  int numPartners = YamAnimationFrame.calcThreesome(MCM, act.length + 1) - 1
  Actor[] sceneArray = PapyrusUtil.ActorArray(numPartners)
  int i = 0
  int ii = 0
  While(ii < sceneArray.length && i < act.length)
		Debug.Trace("[Yamete] i -> " + i)
    If(Main.isValidGenderCombination(victim, act[i]))
      If(victim.HasKeyword(ActorTypeNPC))
				Debug.Trace("[Yamete] ii -> " + ii)
        sceneArray[ii] = act[i]
        ii += 1
      else
        If(MCM.FrameCreature && Main.isValidCreature(act[i]))
					Debug.Trace("[Yamete] ii -> " + ii)
          sceneArray[ii] = act[i]
          ii += 1
        EndIf
      EndIf
    EndIf
    i += 1
  EndWhile
  sceneArray = PapyrusUtil.RemoveActor(sceneArray, none)
  If(MCM.bResReverse)
    int n = 0
    While(n < ii)
			Debug.Trace("[Yamete] n -> " + n + "; ii -> " + ii)
      If(Utility.RandomInt(0, 99) >= MCM.iResNextRoundChance)
        sceneArray[n].RemoveFromFaction(victoireFaction)
      EndIf
      n += 1
    EndWhile
  EndIf
  return sceneArray
EndFunction

Function handleSceneCancel()
  SetStage(1000)
EndFunction

Function checkResolutionDone()
  If(primVic.isDone)
    int i = 0
    While(i < victims.length)
      If(!victims[i].isDone && victims[i].GetReference())
        return
      EndIf
      i += 1
    EndWhile
    SetStage(1000)
  EndIf
EndFunction

Function Stage1000()
  Actor Player = Game.GetPlayer()
	Main.standUp(Player)
	Utility.Wait(3.3) ; Wait for Getup Animation to be over... zzz
	GotoState("Stage1000")
  AoEFleeMark.Cast(Player)
EndFunction

State Stage1000
	Event OnBeginState()
		RegisterForMenu("ContainerMenu")
		RegisterForSingleUpdate(13)
		RegisterForActorAction(8)
	EndEvent

	Event OnActorAction(int actionType, Actor akActor, Form source, int slot)
		GotoState("")
	EndEvent
	Event OnMenuOpen(string menuName)
		GotoState("")
	EndEvent
	Event OnUpdate()
		GotoState("")
	EndEvent

	Event OnEndState()
		Actor Player = Game.GetPlayer()
		Main.RemoveBleedoutMarks(Player)
		Player.RemoveFromFaction(friendFac)
		Stop()
	EndEvent
EndState

; =========================================================================
; ============================================ UTILITY
; ========================================================================
;/ NOTE Resolutions Algorithm
1) Define the Primary Winner -> Given by the Script Event starting the Quest
2) Get the Primary Winners Victim and claim it -> this.getleadDefeated()
3) Give every other Winner their first Victim -> YamResVictoire.nextVictim()
4.1) Note down every Actor claiming this Victim -> YamResVictim.claimVictim()
4.2) The first claiming Actor chooses an Action -> YamResVictoire.getAction()
5.1) Let every winner path to its claimed Victim -> 5.2 returning true
5.2) jump to 10) -> 5.2 returning false
7) Wait for claiming Actor to be near its victim and keep track of arrived CLaimers -> OnPackageEnd()
* secondary claimers will follow
8) Execute the chosen Action
9) repeat 8) until the Actions ending Condition is fulfilled
10) remove the Victim from the victim pool -> YamResVictoire.clearClaimed()
* its the Actions responsibility to ensure the Victim will find a fitting exit to its predicament
* the Action is allowed to break this Loop for individual winners
11) Get a new nearest Victim -> YamResVictoire.clearClaimed().nextVictim()
12) go to 4)

The algorithm ends when the Player unloads the primary winner or no winners are finding another next Victim
/;

;/ IDEA add Creature Support, currently filtering them out /;
; YamResVictim Function getNearestVic(ReferenceAlias from)
;   ObjectReference me = from.GetReference()
;   YamResVictim sol
;   float minDist = 2500.0
;   If(primVic.status != 2 && primVic.onlyOne == false)
;     float primDist = primVic.GetReference().GetDistance(me)
;     If(primDist < minDist)
;       sol = primVic
;       minDist = primDist
;     EndIf
;   EndIf
;   int i = 0
;   While(i < victims.length)
;     ObjectReference curDef = victims[i].GetReference()
;     If(curDef != none)
;       ; bool tmp = victims[i].onlyOne == false || curDef.HasKeyword(ActorTypeNPC)
;       If(victims[i].onlyOne == false && victims[i].status != 2 && curDef.HasKeyword(ActorTypeNPC))
;         float curDist = curDef.GetDistance(me)
;         If(curDist < minDist)
;           minDist = curDist
;           sol = victims[i]
;         EndIf
;       EndIf
;     EndIf
;     i += 1
;   EndWhile
;   return sol
; EndFunction

; =========================================================================
; ============================================ LEAD VICTOIRE
; ========================================================================
;/ IDEA check if there is an unused Follower here and if so, force them to interact with the Player /;
;/ NOTE if no Action can be found, throw the winner into the generic algorithm and set the victim free if its the Player, otherwise leave them in Bleedout /;
;/ 0 - Robbed, 1 - Raped, 2 - Executed /;
; Function handleVictim()
;   int myAction = getOutcome(primVic.GetReference() as Actor, primWin.GetReference() as Actor)
;   ; Setting a Stage causes the Scene to progress, starting the individual outcomes ..
;   If(myAction < 0)
;     Debug.Trace("[Yamete] Resolution: No Valid Consequence for Lead Victim")
;     primVic.setDone()
;     Main.BleedOutExit(primVic.GetReference() as Actor)
;   ElseIf(myAction == 0)
;     SetStage(30)
;     ; robVictim(primVic.GetReference(), primWin.GetReference())
;   ElseIf(myAction == 1)
;     SetStage(40)
;   ElseIf(myAction == 2)
;     ; Disabled..
;     SetStage(50) ; Silent
;     ; Main.playKillmove(primWin.GetReference() as Actor, primVic.GetReference() as Actor)
;   else
;     Debug.Trace("Failed to find a primary consequence; " + myAction)
;     SetStage(1000)
;   EndIf
; EndFunction


; Function primaryRobDone()
;   Actor vic = primVic.GetReference() as Actor
;   Utility.Wait(1)
;   primVic.setDone()
;   Utility.Wait(0.7)
;   If(Utility.RandomInt(0, 99) < MCM.iBlackoutChance && plVic.GetReference() != none)
;     Debug.Trace("[Yamete] Primary Robe Done - Blacked Out")
;     Main.PlayerConsequence(-1)
;     Main.BleedOutExit(Game.GetPlayer())
;     SetStage(1000)
;   else
;     Debug.Trace("[Yamete] Primary Robe Done - Regular outro")
;     ; Utility.Wait(2)
;     Main.BleedOutExit(vic)
;     Utility.Wait(1)
;     checkCloseCondition()
;   EndIf
; EndFunction

; Function chainRapeEntry()
;   ObjectReference vic = primVic.GetReference()
;   If(vic != Game.GetPlayer())
;     If(Utility.RandomInt(0, 99) < MCM.iResNPCendless)
;       ;/ TODO expand on this, allowing it to survive cell changes /;
;       rounds = -1
;     EndIf
;   EndIf
;   Main.RemoveBleedoutMarks(vic as Actor)
;   If(YamAnimationFrame.startAnimationForm(MCM, self, vic as Actor, PapyrusUtil.ActorArray(1, primWin.GetReference() as Actor), "YamRes", true) == -1)
;     Debug.Trace("[Yamete] YamResolution: Failed to start Animation..")
;     primVic.setDone()
;   else
;     rounds = 1
;     RegisterForModEvent("HookAnimationEnd_YamRes", "AfterScene")
;   EndIf
; EndFunction

; Event AfterScene(int tid, bool hasPlayer)
;   Debug.Trace("[Yamete] SL Scene End registered on YamResolution")
;   nextScene()
; EndEvent
; Event OStimEnd(string eventName, string strArg, float numArg, Form sender)
;   Debug.Trace("[Yamete] OStim Scene End registered on YamResolution")
;   nextScene()
; EndEvent
; Event OnQuestStop(Quest akQuest)
;   Debug.Trace("[Yamete] FG Scene End registered on YamResolution")
;   nextScene()
; EndEvent

; Function nextScene()
;   Utility.Wait(1)
;   Actor victim = primVic.GetReference() as Actor
;   Main.BleedOutEnter(victim, -1)
;   If(playNextScene(rounds) == false)
;     Debug.Trace("[Yamete] End Chain Scene after " + rounds + " rounds on YamResolution")
;     primVic.setDone()
;     Utility.Wait(2)
;     ; (primWin.GetReference() as Actor).Say(quitSceneTopic)
;     If(Utility.RandomInt(0, 99) < MCM.iBlackoutChance)
;       SetStage(1000)
;       Main.PlayerConsequence(-1)
;     else
;       Main.standUp(victim)
;     EndIf
;     return
;   EndIf
;   rounds += 1
;   Debug.Trace("[Yamete] Continue Chain Rape; rounds: " + rounds)
;   Actor[] acR = fillSceneArray(primWin, primVic)
;   ; nextSceneTopic sets startNextScene to true after the Line finished
;   acR[Utility.RandomInt(0, acR.length - 1)].Say(nextSceneTopic)
;   Utility.Wait(4)
;   ; startNextScene = false
;   If(YamAnimationFrame.startAnimationForm(MCM, self, victim, acR, "YamRes", true) == -1)
;     If(victim == Game.GetPlayer())
;       Debug.Notification("There was an Error starting the Scene")
;     EndIf
;     Main.standUp(victim)
;     primVic.setDone()
;   EndIf
; EndFunction

; =========================================================================
; ============================================ GENERIC CONSEQUENCE STUFF
; ========================================================================
;/ 0 - Robbed, 1 - Raped, 2 - Executed /;
; int Function getOutcome(Actor victim, Actor winner)
;     int[] weights = MCM.getAllResActions()
;     ; ------------------ Validate Weights
;     bool isNPCwin = winner.HasKeyword(ActorTypeNPC)
;     bool isNPCvic = victim.HasKeyword(ActorTypeNPC)
;     If(!isNPCwin || !isNPCvic)
;       weights[0] = 0
;       weights[2] = 0
;     ElseIf(MCM.bOnlyBanditsRob)
;       int i = 0
;       bool amI = true
;       While(i < banditFactions.length && amI == true)
;         If(!winner.IsInFaction(banditFactions[i]))
;           amI = false
;         EndIf
;         i += 1
;       EndWhile
;       If(amI == false)
;         weights[0] = 0
;       EndIf
;     EndIf
;     If(!MCM.bSLAllowed)
;       If(!isNPCwin || !isNPCvic)
;         weights[1] = 0
;       ElseIf(!MCM.bFGAllowed && primVic.GetReference() != victim)
;         weights[1] = 0
;       EndIf
;     else
;       If(!isNPCwin)
;         If(Main.isValidCreature(winner) == false)
;           weights[1] = 0
;         EndIf
;       EndIf
;       If(!isNPCvic)
;         If(Main.isValidCreature(victim) == false)
;           weights[1] = 0
;         EndIf
;       EndIf
;     EndIf
;     If(victim != game.GetPlayer())
;       If(Main.isImportant(victim) == true)
;         weights[2] = 0
;       EndIf
;     EndIf
;     ; ----------------------------------------
;     int allCells = 0
;     int i = 0
;     While(i < weights.length)
;       allCells += weights[i]
;       i += 1
;     EndWhile
;     If(allCells < 1)
;       return -1
;     EndIf
;     int solCell = Utility.RandomInt(1, allCells)
;     int counter = 0
;     i = 0
;     While(counter < solCell)
;       counter += weights[i]
;       i += 1
;     EndWhile
;     Debug.Trace("Yamete: Outcome chosen for " + victim.GetActorBase().GetName() + " is " + (i - 1))
;     return i - 1
; EndFunction

; Function robVictim(ObjectReference victim, ObjectReference robber)
;   ; If(victim.GetDistance(robber) > 100)
;   ;   robber.MoveTo(victim, 30 * Math.cos(victim.Z), 50 * Math.sin(victim.Z), 0.0, false)
;   ;   robber.SetAngle(victim.GetAngleX(), victim.GetAngleY(), victim.GetAngleZ() + victim.GetHeadingAngle(robber))
;   ; EndIf
;   (robber as Actor).PlayIdle(stealStuffIdle)
;   Utility.Wait(3)
;   ; 0 - Everything, 1 - by Value, 2 - Random
;   Form[] items = PO3_SKSEFunctions.AddAllItemsToArray(victim, !MCM.bResRWorn, false, !MCM.bResRQstItm)
;   int i = items.length
;   Debug.Trace("[Yamete] Num Items in Inventory: " + i)
;   If(MCM.iResRType == 0)
;     While(i > 0)
;       i -= 1
;       victim.RemoveItem(items[i], victim.GetItemCount(items[i]), true, robber)
;     EndWhile
;   ElseIf(MCM.iResRType == 1)
;     While(i > 0)
;       i -= 1
;       If(items[i].GetGoldValue() < MCM.iResRItmVal)
;         victim.RemoveItem(items[i], victim.GetItemCount(items[i]), true, robber)
;       EndIf
;     EndWhile
;   ElseIf(MCM.iResRType == 2)
;     While(i > 0)
;       i -= 1
;       If(Utility.RandomInt(0, 99) < MCM.iResRStealChance)
;         victim.RemoveItem(items[i], victim.GetItemCount(items[i]), true, robber)
;       EndIf
;     EndWhile
;   EndIf
  ; Form[] qstItems = PO3_SKSEFunctions.GetQuestItems(victim)
  ; If(MCM.iResRType == 0)
  ;   victim.RemoveAllItems(robber)
  ;   If(MCM.bResRQstItm)
  ;     int i = 0
  ;     While(i < qstItems.length)
  ;       victim.RemoveItem(qstItems[i], victim.GetItemCount(qstItems[i]), true, robber)
  ;       i += 1
  ;     EndWhile
  ;   EndIf
  ; ElseIf(MCM.iResRType == 1)
  ;   int index = victim.GetNumItems()
  ;   While(index)
  ;     index -= 1
  ;     Form f = victim.GetNthForm(index)
  ;     If(f.GetGoldValue() < MCM.iResRItmVal)
  ;       If(MCM.bResRQstItm == false)
  ;         If(qstItems.Find(f) == -1)
  ;           victim.RemoveItem(f, victim.GetItemCount(f), true, robber)
  ;         EndIf
  ;       else
  ;         victim.RemoveItem(f, victim.GetItemCount(f), true, robber)
  ;       EndIf
  ;     EndIf
  ;   EndWhile
  ; ElseIf(MCM.iResRType == 2)
  ;   int index = victim.GetNumItems()
  ;   While(index)
  ;     index -= 1
  ;     If(Utility.RandomInt(0, 99) < MCM.iResRStealChance)
  ;       Form f = victim.GetNthForm(index)
  ;       If(MCM.bResRQstItm == false)
  ;         If(qstItems.Find(f) == -1)
  ;           victim.RemoveItem(f, victim.GetItemCount(f), true, robber)
  ;         EndIf
  ;       else
  ;         victim.RemoveItem(f, victim.GetItemCount(f), true, robber)
  ;       EndIf
  ;     EndIf
  ;   EndWhile
  ; EndIf
; EndFunction

; Actor[] Function fillSceneArray(YamResVictoire w, YamResVictim v)
;   int num = YamAnimationFrame.calcThreesome(MCM, v.userNum + 1) - 1
;   Actor victim = v.GetReference() as Actor
;   Actor[] acR = PapyrusUtil.ActorArray(num, w.GetReference() as Actor)
;   ; acR[0] = target
;   ; target.users[0] = self
;   int i = 1
;   int ii = 1
;   While(ii < num && i < v.userNum)
;     Actor tmp = v.users[i].GetReference() as Actor
;     If(tmp.HasKeyword(ActorTypeNPC))
;       acR[i] = tmp
;       ii += 1
;     else
;       If(MCM.bSLAllowed)
;         If(Main.isValidCreature(tmp))
;           If(YamSexLab.ValidateRaceCombinationSingle(victim, tmp) && YamSexLab.ValidateRaceCombinationSingle(acR[0], tmp))
;             acR[i] = tmp
;             ii += 1
;           EndIf
;         EndIf
;       EndIf
;     EndIf
;     i += 1
;   EndWhile
;   return PapyrusUtil.RemoveActor(acR, none)
; EndFunction

; =========================================================================
; ============================================ SHUT DOWN
; ========================================================================
;/ called by Resolutions Lead Scene if that one fails to complete before finishing its Consequence
Reason for that would be that another Combat started somewhere or the game failed to play the Scene for other reasons, idk. Skyrim be janky
return true if combat is ongoing, silently closing Resolution and waiting for Combat to end again, repeating the entire Loop. Yay.
return false if skyrim be janky, and using a fallback to close Resolution and set the Player free instead /;
; bool Function handleSceneCancel()
;   Debug.Trace("[Yamete] Called handleSceneCancel()..")
;   If(Scan.IsRunning() || Scan.IsStarting())
;     OnUpdate()
;   ElseIf(Scan.Start())
;     Main.UnregisterForUpdate()
;     OnUpdate()
;   else
;     Debug.Notification("Yamete: An Unexpected Error occured, resetting Resolution..")
;     SetStage(1000)
;   EndIf
; EndFunction

;/ Control if the Resolution Quest should stop /;
; Function checkCloseCondition()
;   If(primVic.status == 1)
;     return
;   EndIf
;   int i = 0
;   While(i < victims.Length)
;     If(victims[i].GetReference())
;       If(victims[i].status == 1)
;         return
;       EndIf
;     EndIf
;     i += 1
;   EndWhile
;   SetStage(1000)
; EndFunction

; Event OnUpdate()
;   ; If(GetStage() > 999)
;     If(complexAlgorithm)
;       PO3_SKSEFunctions.SetLinkedRef(primWin.GetReference(), none, primWin.resLinked)
;       int i = 0
;       While(i < winners.length)
;         ObjectReference victoire = winners[i].GetReference()
;         If(victoire)
;           PO3_SKSEFunctions.SetLinkedRef(victoire, none, winners[i].resLinked)
;         EndIf
;         i += 1
;       EndWhile
;     EndIf
;     Stop()
;   ; EndIf
; EndEvent
