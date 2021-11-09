Scriptname YamPlayerMonitor extends YamScanReferences

Perk[] Property RR Auto
ImageSpaceModifier Property RRcracked Auto
int resiliance

Event OnInit()
  mySelf = PlayerRef
  myValidRace = true
  consequenceChance = MCM.iRushedConsequence
  profile = 0
  Aggressor = none
	DefineResiliance()
  ; RegisterForModEvent("Yam_CombatStop", "CombatStop")
EndEvent

; Fill this Slot with a new Actor & set Variables
Function ReFill(Actor that)
  Debug.Trace("[Yamete] ReFill() -> Called on the Player Script")
EndFunction

; Rushed: Reset this Actor back into Idle State
Function ResetGroup(bool expectBleedout)
	GotoState("Exhausted")
  If(expectBleedout) ; Bleedout here should be Type 0
    Main.standUp(mySelf)
  EndIf
  StorageUtil.FormListRemove(Scan, "YamProcessing", mySelf)
EndFunction

; Clear this Slot, reset the Actor if necessary
Function CleanUp(bool removeMark = true)
  If(aggressor)
    clearAggressor()
  EndIf
  If(removeMark)
    mySelf.RemoveSpell(calmMark)
  EndIf
  StorageUtil.FormListRemove(Scan, "YamProcessing", mySelf)
  GoToState("")
EndFunction

State Exhausted
	Event OnBeginState()
		RegisterForActorAction(8)
		RegisterForMenu("ContainerMenu")
		RegisterForSingleUpdate(MCM.iRushedBuffer)
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
		UnregisterForActorAction(8)
		UnregisterForAllMenus()
		mySelf.RemoveSpell(calmMark)
	EndEvent
EndState

Event OnDying(Actor akKiller)
  ;
EndEvent

Function EnterKnockdown()
	Debug.Trace("[Yamete] EnterKnockdown on Player, Resiliance: " + resiliance)
	If(ReapersResiliance())
		GotoState("")
		return
	EndIf
	Parent.EnterKnockdown()
EndFunction

; ======================================================================
; ================================== RUSHED
; ======================================================================
Function EnterBleedout(bool fromScene)
  Debug.Trace("[Yamete] Rushed: YamPlayerMonitor.EnterBleed() on " + GetName() + " -> fromScene: " + fromScene)
  If(fromScene && Utility.RandomInt(0, 99) < MCM.iResNextRoundChance && (MCM.iResMaxRounds > repeats || MCM.iResMaxRounds == 0))
    Main.BleedOutEnter(mySelf, 0)
    Actor[] partners = PapyrusUtil.ActorArray(1, aggressor)
    If(YamAnimationFrame.StartSceneRushed(MCM, self, partners) > -1)
      repeats += 1
      return
    EndIf
  EndIf
  clearAggressor()
  If(Utility.RandomInt(0, 99) < consequenceChance)
    consequenceChance = MCM.iRushedConsequence
    ; ..Blackout?
    If(Utility.RandomInt(0, 99) < MCM.iBlackoutChance)
      Main.PlayerConsequence(-1)
      CleanUp()
      return
    EndIf
    Main.playerBleedout(-1)
    CleanUp()
    If(MCM.iCombatScenario == 2)
      scan.startResolutionfast()
    EndIf
  else
    consequenceChance += MCM.iRushedConsequenceAdd
    ResetGroup(!fromScene)
  EndIf
EndFunction

; ======================================================================
; ================================== TRADITIONAL
; ======================================================================
State Traditional
  Event OnBeginState()
    Debug.Trace("[Yamete] Enter Traditional on Player")
    Main.playerBleedout(-1)
    CleanUp()
    Scan.startResolutionfast()
  EndEvent

  Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    ;
  EndEvent
EndState

; ======================================================================
; ================================== REAPERS MERCY
; ======================================================================
Function DefineResiliance()
	resiliance = 0
	While(resiliance < RR.length)
		If(!mySelf.HasPerk(RR[resiliance]))
			return
		EndIf
		resiliance += 1
	EndWhile
EndFunction

bool Function ReapersResiliance()
	If(resiliance == 0)
		return false
	EndIf
	resiliance -= 1
	RRcracked.Apply()
	Utility.Wait(0.3)
	RRcracked.Remove()
	return true
EndFunction


;/ ======================================================================
; ================================== REDUNDANT
; ======================================================================
Event CombatStop(string eventName, string strArg, float numArg, Form sender)
  Debug.Trace("[Yamete] Registered CombatStop Event!")
  CleanUp()
EndEvent

; Return true if this engage is allowed to happen based on MCM RNG Settings
; bool Function getValidChance(Actor that)
;   int chance = Utility.RandomInt(0, 99)
;   bool isFol = that.IsInFaction(Main.PlayerFollowerFaction)
;   bool folValid = isFol && (chance < MCM.iAssFolPl)
;   bool npcValid = !isFol && (chance < MCM.iAssNpcPl)
;   return folValid || npcValid
; EndFunction

Event OnInit()
  consequenceChance = MCM.iRushedConsequence
  bLock = false
  aggressor = none
  mySelf = PlayerRef
  profile = iPlayerKDProfile
EndEvent

Auto State Active
  Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    Actor myAggr = akAggressor as Actor
    If(myAggr == none || bLock)
      return
    EndIf
    bLock = true
    ; Chcne Settings
    int chance = Utility.RandomInt(0, 99)
    bool isFol = myAggr.IsInFaction(Main.PlayerFollowerFaction)
    bool folValid = isFol && (chance < MCM.iAssFolPl)
    bool npcValid = !isFol && (chance < MCM.iAssNpcPl)
    If(folValid || npcValid)
      ; General Conditions
      If(ValidInteraction(myAggr))
        Form[] myItems = Main.getWornItems(PlayerRef)
        If(!MCM.bKDStrpBlock[MCM.iPlayerKDProfile] || !abHitBlocked)
          CheckStrip(myItems)
        EndIf
        ; Knockdown Conditions
        If(GetWeakened(abHitBlocked, akProjectile) || GetStripped(myItems, abHitBlocked))
          Aggressor = myAggr
          If(MCM.iCombatScenario == 1)
            GoToState("Traditional")
          else
            GoToState("Rushed")
          EndIf
        EndIf
      EndIf
    EndIf
    Utility.Wait(0.1)
    bLock = false
  EndEvent

  Event OnEnterBleedout()
    If(MCM.bKDPlayerEssential == false)
      return
    EndIf
    Utility.Wait(3.1) ; For the regular OnHit Event to complete..
    String st = GetState()
    If(st != "")
      return
    Else
      Game.SetPlayerAIDriven(true)
      PlayerRef.AddSpell(calmMark, false)
      Main.HealActor(PlayerRef)
      If(MCM.iCombatScenario == 1) ; Traditional
        Utility.Wait(1.1)
        Main.playerBleedout(-1)
      else
        Utility.Wait(MCM.iRushedBuffer/2)
        consequenceChance += MCM.iRushedConsequenceAdd
      EndIf
      Game.SetPlayerAIDriven(false)
      PlayerRef.RemoveSpell(calmMark)
    EndIf
  EndEvent
EndState

bool Function ValidInteraction(Actor me)
  ; Base Checks
  If(Main.isValidBase(PlayerRef, me) == false)
    return false
  EndIf
  ; Gender
  If(MCM.iFilterType == 1)
    If(Main.isValidCreature(me))
      return Main.isValidGenderCombination(mySelf, me)
    else
      return false
    EndIf
  else
    return true
  EndIf
endFunction

; ==============================================================
; ====================================== GROUPS
; ==============================================================
State Rushed
  ;/ "Knockdown" -> "Adult Scene" -> "Bleedout" -> (Chance)[Consequence / Combat End] /;
  ;/ Handle Adult Scene and wait or Enter Bleedout in case of Failure ;
  Event OnBeginState()
    bool startScene = true
    Main.Bleedout0(PlayerRef)
    PlayerRef.AddSpell(calmMark, false)
    If(PO3_SKSEFunctions.HasMagicEffectWithArchetype(Aggressor, "Frenzy") || MCM.FrameAllowedAny == false)
      startScene = false
    else
      aggressor.AddSpell(calmMark, false)
      aggressor.SetDontMove(true)
    EndIf
    Utility.Wait(3.5) ; Some time to allow this Actor to be rescued
    If(PlayerRef.HasMagicEffectWithKeyword(bleedoutMarkKW) == false)
      ; Someone helped me!
      PlayerRef.RemoveSpell(calmMark)
      ResetGroup()
      return
    EndIf
    ; Final check for Scene Start & Scene Start
    If(MCM.iFilterType == 0 && startScene)
      startScene = Main.isValidGenderCombination(PlayerRef, Aggressor)
    EndIf
    If(startScene)
      Actor[] partners = PapyrusUtil.ActorArray(1, Aggressor)
      If(YamAnimationFrame.startAnimationAlias(MCM, self, partners) > -1)
        RegisterForModEvent("HookAnimationEnd_Player", "AfterScene")
        Debug.Trace("[Yamete] PlayerMonitor, successfully started Scene..")
        return
      EndIf
    EndIf
    Debug.Trace("[Yamete] PlayerMonitor, failed to start Scene")
    EnterBleedout(false)
  EndEvent

  Event AfterScene(int tid, bool hasPlayer)
    EnterBleedout(true)
    UnregisterForModEvent("HookAnimationEnd_Player")
  EndEvent
  Event OStimEnd(string eventName, string strArg, float numArg, Form sender)
    EnterBleedout(true)
    UnregisterForModEvent("ostim_end")
  EndEvent
  Event OnQuestStop(Quest akQuest)
    EnterBleedout(true)
    PO3_Events_Alias.UnregisterForAllQuests(self)
  EndEvent

  Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    ;
  EndEvent
EndState

State Traditional
  ;/ "Knockdown" -> "Bleedout" -> "Combat End" -> "Resolution" ;
  Event OnBeginState()
    Main.playerBleedout(-1)
    CleanUp()
    scan.plAggr = aggressor
    scan.startResolutionfast()
  EndEvent

  ;/ Disable OnHit Event while in here ;
  Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    ;
  EndEvent
EndState

; ==============================================================
; ====================================== MISC
; ==============================================================
State Busy
  Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    ; Shut it
  EndEvent
EndState

; ===================== COMBAT STOP
Function CleanUp()
  GoToState("")
  PlayerRef.RemoveSpell(calmMark)
  ; PlayerRef.SetDontMove(false)
  If(Aggressor)
    aggressor.RemoveSpell(calmMark)
    Aggressor.SetDontMove(false)
  EndIf
endFunction

Function ResetGroup()
  Utility.Wait(MCM.iRushedBuffer)
  CleanUp()
EndFunction

; =====================================================================
Event AfterScene(int tid, bool hasPlayer)
EndEvent
Event OStimEnd(string eventName, string strArg, float numArg, Form sender)
EndEvent
Event OnQuestStop(Quest akQuest)
EndEvent
;/ RUSHED
Set this Actor into Bleedout ;
Function EnterBleedout(bool fromScene)
  Debug.Trace("[Yamete] Rushed: YamPlayerMonitor.EnterBleed() on " + GetName() + " -> fromScene: " + fromScene)
  If(aggressor.HasSpell(calmMark))
    aggressor.SetDontMove(false)
    aggressor.RemoveSpell(calmMark)
  EndIf
  ; Should this Actor be Bleeding out?
  If(Utility.RandomInt(0, 99) < consequenceChance)
    consequenceChance = MCM.iRushedConsequence
    ; ..Blackout?
    If(Utility.RandomInt(0, 99) < MCM.iBlackoutChance)
      Main.PlayerConsequence(-1)
      CleanUp()
      return
    EndIf
    Main.playerBleedout(-1)
    CleanUp()
    If(MCM.iCombatScenario == 2)
      scan.plAggr = Aggressor
      scan.startResolutionfast()
    EndIf
  else
    ; ..otherwise get them out of Bleedout, back into fight & stack chance
    consequenceChance += MCM.iRushedConsequenceAdd
    If(fromScene == false || PlayerRef.IsBleedingOut())
      Main.BleedOutExit(PlayerRef)
    EndIf
    Utility.Wait(MCM.iRushedBuffer)
    ResetGroup()
  EndIf
EndFunction
;/ ============================ REDUNDANT
; -------------------------- Scenarios
; ================================================================ ;
;                               BASIC                              ;
; ================================================================ ;
State Basic
  ; ------------------- DEFAULT STATE ACTIONS -------------------
  Event OnBeginState()
    PlayerRef.SetDontMove()
    Aggressor.SetDontMove()
    PlayerRef.AddSpell(CloakSpell, false)
    Aggressor.AddSpell(CloakSpell)
    int scenery = Main.StartSceneSimple(PlayerRef, Aggressor, "Player")
    If(scenery == -1)
      PseudoHook()
    else
      RegisterForModEvent("HookAnimationEnding_Player", "Aftermath")
    EndIf
    PlayerRef.SetDontMove(false)
    Aggressor.SetDontMove(false)
  EndEvent

  Function PseudoHook()
    Utility.Wait(0.5)
    Aggressor.RemoveSpell(CloakSpell)
    If(Utility.RandomInt(1, 100) <= MCM.iClockOutChance)
      Aggressor.AddSpell(ClockedOut)
    EndIf
    StateSpecific()
  EndFunction

  Event Aftermath(int tid, bool hasPlayer)
    Main.HealActor(PlayerRef, MCM.fHealPlayer)
    Aggressor.RemoveSpell(CloakSpell)
    If(Utility.RandomInt(1, 100) <= MCM.iClockOutChance)
      Aggressor.AddSpell(ClockedOut)
    EndIf
    StateSpecific()
    UnregisterForModEvent("HookAnimationEnding_Player")
  EndEvent

  ; ------------------- STATE SPECIFIC ACTIONS -------------------
  Function StateSpecific()
    CombatQuestRunning = false
    GoToState("PostScene")
  endFunction

  ; Event OnUpdate()
  ;
  ; EndEvent

  ; Event OnEndState()
  ;
  ; EndEvent
EndState

; ================================================================ ;
;                         BLEEDOUT INSTANT                         ;
; ================================================================ ;
State BleedoutInstant
  ; ------------------- DEFAULT STATE ACTIONS -------------------
  Event OnBeginState()
    PlayerRef.SetDontMove()
    Aggressor.SetDontMove()
    ; PrepareState()
    PlayerRef.AddSpell(CloakSpell, false)
    Aggressor.AddSpell(CloakSpell)
    int scenery = Main.StartSceneSimple(PlayerRef, Aggressor, "Player")
    If(scenery == -1)
      PseudoHook()
    else
      RegisterForModEvent("HookAnimationEnding_Player", "Aftermath")
    EndIf
    PlayerRef.SetDontMove(false)
    Aggressor.SetDontMove(false)
  EndEvent

  Function Pseudohook()
    Utility.Wait(0.5)
    Aggressor.RemoveSpell(CloakSpell)
    If(Utility.RandomInt(1, 100) <= MCM.iClockOutChance)
      Aggressor.AddSpell(ClockedOut)
    EndIf
    StateSpecific()
  EndFunction

  Event Aftermath(int tid, bool hasPlayer)
    Main.HealActor(PlayerRef, MCM.fHealPlayer)
    Aggressor.RemoveSpell(CloakSpell)
    If(Utility.RandomInt(1, 100) <= MCM.iClockOutChance)
      Aggressor.AddSpell(ClockedOut)
    EndIf
    StateSpecific()
    UnregisterForModEvent("HookAnimationEnding_Player")
  EndEvent

  ; ------------------- STATE SPECIFIC ACTIONS -------------------
  Function StateSpecific()
    Utility.Wait(1) ;Waiting to not have SL Close cancel out Bleedout Anim
    Main.BleedOut(PlayerRef)
    ; How long we stay in Bleedout:
    If(MCM.iPlBleedDur > 0) ; Fixed Duration
      RegisterForSingleUpdate(MCM.iPlBleedDur)
    elseIf(!Scan.IsRunning()) ; Duration is 0 but Combat Quest isnt running
      RegisterForSingleUpdate(20)
    else ; Duration is 0 and Combat Quest is running, waiting for its close Call
      CombatQuestRunning = false
    EndIf
  endFunction

  Function CombatEnd()
    GoToState("PostScene")
  EndFunction

  Event OnUpdate()
    CombatQuestRunning = false
    GoToState("PostScene")
  EndEvent

  Event OnEndState()
    Main.BleedOutExit(PlayerRef)
  EndEvent
EndState

; ================================================================ ;
;                            POST SCENE                            ;
; ================================================================ ;
State PostScene
  Event OnBeginState()
    RegisterForSingleUpdate(MCM.fPlayerRecoverTime)
  EndEvent

  Event OnUpdate()
    ; If(!hadGhost)
    ;   PlayerRef.SetGhost(false)
    ; EndIf
    PlayerRef.RemoveSpell(CloakSpell)
    GoToState("")
  EndEvent
EndState

; ------------------------------ State Utility
Function StateSpecific()
  ; Each State will execute its Unique Characteristics by calling and overwriting this Function.
EndFunction

Event Aftermath(int tid, bool hasPlayer)
  ; SL Hook
  ; A Victim is always located inside a State, so leaving this empty
EndEvent

Function Pseudohook()
  ; Pseudo Hook
  ; Same as Aftermath, used when a Scene doesnt start
EndFunction

Function CombatEnd()
  ; Function is called on Combat End from Scan Quest. Some States follow up on this to properly react to Combat End
EndFunction
/;
