Scriptname YamActor extends YamScanReferences

; Set Variables
Event OnInit()
  If(GetReference())
    mySelf = GetReference() as Actor
		mySelf.AddSpell(CacheGear)
  EndIf
  consequenceChance = MCM.iRushedConsequence
  profile = 2
  Aggressor = none
	GoToState("")
  ; RegisterForModEvent("Yam_CombatStop", "CombatStop")
EndEvent

; Fill this Slot with a new Actor & set Variables
Function ReFill(Actor that)
  Debug.Trace("[Yamete] YamActor: ReFill() on " + GetName())
  ForceRefTo(that)
  mySelf = that
	mySelf.AddSpell(CacheGear)
  consequenceChance = MCM.iRushedConsequence
  Aggressor = none
  GoToState("")
EndFunction

; Rushed: Reset this Actor back into Idle State
Function ResetGroup(bool expectBleedout)
  If(expectBleedout)
    Main.standUp(mySelf)
  EndIf
  Utility.Wait(MCM.iRushedBuffer/2)
  mySelf.RemoveSpell(calmMark)
  GoToState("")
EndFunction

; Clear this Slot, reset the Actor is necessary
Function CleanUp(bool removeMark = true)
  If(aggressor)
    clearAggressor()
  EndIf
  If(removeMark)
    mySelf.RemoveSpell(calmMark)
  EndIf
  If(GetName() != "Combatant0")
    Clear()
  EndIf
  GoToState("")
EndFunction


;/ ======================================================================
; ================================== REDUNDANT
; ======================================================================
Event CombatStop(string eventName, string strArg, float numArg, Form sender)
  CleanUp()
EndEvent

; Return true if this engage is allowed to happen based on MCM RNG Settings
bool Function getValidChance(Actor that)
  int chance = Utility.RandomInt(0, 99)
  bool isFol = that.IsInFaction(Main.PlayerFollowerFaction)
  bool folValid = isFol && (chance < MCM.iAssFolNPC)
  bool npcValid = !isFol && (chance < MCM.iAssNPCNPC)
  return folValid || npcValid
EndFunction
;/ -------------------------- Code
Event OnInit()
  consequenceChance = MCM.iRushedConsequence
  bLock = false
  Aggressor = none
  profile = MCM.iNPCKDProfile
  RegisterForModEvent("Yam_CombatStop", "CombatStop")
EndEvent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
  Actor myAggr = akAggressor as Actor
  If(myAggr == none || myAggr == PlayerRef || bLock)
    return
  EndIf
  bLock = true
  ; Chance Settings
  int chance = Utility.RandomInt(0, 99)
  bool isFol = myAggr.IsInFaction(Main.PlayerFollowerFaction)
  bool folValid = isFol && chance < MCM.iAssFolNPC
  bool npcValid = !isFol && chance < MCM.iAssNPCNPC
  If(folValid || npcValid)
    ; General Conditions
    If(isValidInteraction(myAggr))
      Form[] myItems = Main.getWornItems(mySelf)
      If(!MCM.bKDStrpBlock[MCM.iNPCKDProfile] || !abHitBlocked)
        CheckStrip(myItems)
      EndIf
      ; Knockdown Conditions
      If(GetWeakened(abHitBlocked, akProjectile) || GetStripped(myItems, abHitBlocked))
        ; Debug.Trace("[Yamete] Knockdown Valid: " + GetName())
        Aggressor = myAggr
        If(MCM.iCombatScenario == 1)
          GoToState("Traditional")
        else
          GoToState("Rushed")
        EndIf
        If(MCM.bShowNotifyKD)
          string myName = mySelf.GetLeveledActorBase().GetName()
          string otherName = myAggr.GetLeveledActorBase().GetName()
          If(MCM.bShowNotifyColor)
            Main.UILib.ShowNotification(myName + " got knocked out by " + otherName, MCM.sNotifyColor)
          Else
            Debug.Notification(myName + " got knocked out by" + otherName)
          EndIf
        EndIf
      EndIf
    EndIf
  EndIf
  Utility.Wait(0.1)
  bLock = false
EndEvent

bool Function isValidInteraction(Actor me)
  ; I hate doing "exists" checks here but I still get some Errors about
  ; stuff not existing ... zzz. Apparently things that dont exist get hits
  ; registerd by Objects that dont exist but arent none
  ; Someone, explain me this game
  If(mySelf == none)
    mySelf = GetReference() as Actor
  EndIf
  ; Base Checks
  If(Main.isValidBase(mySelf, me) == false)
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

Event OnEnterBleedout()
  If(MCM.bKDNPCEssential == false)
    return
  EndIf
  Utility.Wait(3.1) ; For the regular OnHit Event to complete..
  String st = GetState()
  If(st != "")
    return
  Else
    mySelf.SetDontMove(true)
    mySelf.SetRestrained(true)
    mySelf.AddSpell(calmMark, false)
    Main.HealActor(mySelf)
    If(MCM.iCombatScenario == 1) ; Traditional
      Utility.Wait(1.1)
      Main.npcBleedout(mySelf, -1)
    else
      Utility.Wait(MCM.iRushedBuffer/4)
      consequenceChance += MCM.iRushedConsequenceAdd
    EndIf
    mySelf.SetDontMove(false)
    mySelf.SetRestrained(false)
    mySelf.RemoveSpell(calmMark)
  EndIf
EndEvent
; ==============================================================
; ====================================== SCENARIOS
; ==============================================================
State Rushed
  ;/ "Knockdown" -> "Adult Scene" -> "Bleedout" -> (Chance)[Combat End | Blackout] -> "Combat End" /;
  ;/ Handle Adult Scene and wait or Enter Bleedout in case of Failure ;
  Event OnBeginState()
    bool startScene = true
    Main.Bleedout0(mySelf)
    mySelf.AddSpell(calmMark, false)
    If(PO3_SKSEFunctions.HasMagicEffectWithArchetype(Aggressor, "Frenzy") || MCM.FrameAllowedAny == false)
      startScene = false
    else
      aggressor.AddSpell(calmMark, false)
      aggressor.SetDontMove(true)
    EndIf
    Utility.Wait(3.5) ; Some time to allow this Actor to be rescued
    If(mySelf.HasMagicEffectWithKeyword(bleedoutMarkKW) == false)
      ; Someone helped me!
      ResetGroup()
      return
    EndIf
    ; Final check for Scene Start & Scene Start
    If(MCM.iFilterType == 0 && startScene)
      startScene = Main.isValidGenderCombination(mySelf, Aggressor)
    EndIf
    If(startScene)
      Actor[] partners = PapyrusUtil.ActorArray(1, Aggressor)
      If(YamAnimationFrame.startAnimationAlias(MCM, self, partners) > -1)
        RegisterForModEvent("HookAnimationEnd_" + GetName(), "AfterScene")
        return
      EndIf
    EndIf
    ; If we dont start a Scene, check for Bleedout; otherwise wait for Scene to end
    EnterBleedout(false)
  EndEvent

  ;/ Event Triggers, fires after Scene finished ;
  Event AfterScene(int tid, bool hasPlayer)
    EnterBleedout(true)
    UnregisterForModEvent("HookAnimationEnding_" + GetName())
  EndEvent
  Event OStimEnd(string eventName, string strArg, float numArg, Form sender)
    EnterBleedout(true)
    UnregisterForModEvent("ostim_end")
  EndEvent
  Event OnQuestStop(Quest akQuest)
    EnterBleedout(true)
    PO3_Events_Alias.UnregisterForAllQuests(self)
  EndEvent

  ;/ Disable OnHit Event while in here ;
  Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    ;
  EndEvent
EndState

State Traditional
  ;/ "Knockdown" -> "Bleedout" -> "Combat End" -> "Resolution" ;
  Event OnBeginState()
    Main.npcBleedout(mySelf, -1)
    CleanUp()
    Scan.startResolutionfast()
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
Event CombatStop(string eventName, string strArg, float numArg, Form sender)
  If(GetState() != "")
    Utility.Wait(MCM.iRushedBuffer/3)
  EndIf
  CleanUp()
EndEvent

;/ Remove Calm Spell & go back into Empty State
Basically this is CleanUp() with a buffer ;
Function ResetGroup()
  If(aggressor.HasSpell(calmMark))
    aggressor.SetDontMove(false)
    aggressor.RemoveSpell(calmMark)
  EndIf
  Utility.Wait(MCM.iRushedBuffer/3)
  mySelf.RemoveSpell(calmMark)
  GoToState("")
EndFunction

Function CleanUp()
  GoToState("")
  bLock = false
  If(mySelf)
    mySelf.RemoveSpell(calmMark)
    If(GetName() != "Combatant0")
      TryToClear()
    EndIf
  EndIf
  If(aggressor)
    aggressor.RemoveSpell(calmMark)
    aggressor.SetDontMove(false)
    aggressor = none
  EndIf
endFunction

Event OnDying(Actor akKiller)
  CleanUp()
  If(GetName() != "Combatant0")
    Clear()
    bLock = false
  EndIf
EndEvent

Event OnUnload()
  CleanUp()
  If(GetName() != "Combatant0")
    Clear()
    bLock = false
  EndIf
EndEvent
; =====================================================================
Event AfterScene(int tid, bool hasPlayer)
EndEvent
Event OStimEnd(string eventName, string strArg, float numArg, Form sender)
EndEvent
Event OnQuestStop(Quest akQuest)
EndEvent
Function EnterBleedout(bool fromScene)
EndFunction
; ===================== REDUNDANT
; ; Scenarios
; State Basic
;   ; ================================================================ ;
;   ;                       DEFAULT STATE ACTIONS                      ;
;   ; ================================================================ ;
;   Event OnBeginState()
;     mySelf.SetDontMove()
;     Aggressor.SetDontMove()
;     mySelf.AddSpell(CloakSpell)
;     aggressor.AddSpell(CloakSpell, false)
;     int scenery = Main.StartSceneSimple(mySelf, Aggressor, myID)
;     If(scenery == -1) ; Something failed idk
;       PseudoHook()
;     else
;       RegisterForModEvent("HookAnimationEnding_"+myID, "Aftermath")
;     endIf
;     mySelf.SetDontMove(false)
;     Aggressor.SetDontMove(false)
;   EndEvent
;
;   Function Pseudohook()
;     Utility.Wait(0.5)
;     Aggressor.RemoveSpell(CloakSpell)
;     Scan.ClearAggr(myID)
;     StateSpecific()
;   EndFunction
;
;   Event Aftermath(int tid, bool hasPlayer)
;     Main.HealActor(mySelf, MCM.fHealNPC)
;     Aggressor.RemoveSpell(CloakSpell)
;     Scan.ClearAggr(myID)
;     StateSpecific()
;     UnregisterForModEvent("HookAnimationEnding_PostUse")
;   EndEvent
;   ; ================================================================ ;
;   ;                      STATE SPECIFIC ACTIONS                      ;
;   ; ================================================================ ;
;   Function StateSpecific()
;     Scan.SceneClose(myID)
;     GoToState("")
;   endFunction
;
;   ; Event OnUpdate()
;   ;
;   ; endEvent
;
;   Event OnEndState()
;     mySelf.RemoveSpell(CloakSpell)
;   EndEvent
;   ; ================================================================ ;
;   ;                             CLEAN UP                             ;
;   ; ================================================================ ;
;   Event OnUnload()
;     CleanUp()
;     Scan.SceneClose(myID)
;   EndEvent
;
;   Event OnDeath(Actor akKiller)
;     CleanUp()
;     Scan.SceneClose(myID)
;   EndEvent
; EndState
;
;
; State FleeInstant
;   ; ================================================================ ;
;   ;                       DEFAULT STATE ACTIONS                      ;
;   ; ================================================================ ;
;   Event OnBeginState()
;     mySelf.SetDontMove()
;     Aggressor.SetDontMove()
;     ; PrepareState()
;     mySelf.AddSpell(CloakSpell)
;     aggressor.AddSpell(CloakSpell, false)
;     int scenery = Main.StartSceneSimple(mySelf, Aggressor, myID)
;     If(scenery == -1) ; Something failed idk
;       PseudoHook()
;     else
;       RegisterForModEvent("HookAnimationEnding_"+myID, "Aftermath")
;     endIf
;     mySelf.SetDontMove(false)
;     Aggressor.SetDontMove(false)
;   EndEvent
;
;   Function Pseudohook()
;     Utility.Wait(0.5)
;     Aggressor.RemoveSpell(CloakSpell)
;     Scan.ClearAggr(myID)
;     StateSpecific()
;   EndFunction
;
;   Event Aftermath(int tid, bool hasPlayer)
;     Main.HealActor(mySelf, MCM.fHealNPC)
;     Aggressor.RemoveSpell(CloakSpell)
;     Scan.ClearAggr(myID)
;     StateSpecific()
;     UnregisterForModEvent("HookAnimationEnding_PostUse")
;   EndEvent
;   ; ================================================================ ;
;   ;                      STATE SPECIFIC ACTIONS                      ;
;   ; ================================================================ ;
;   Function StateSpecific()
;     mySelf.AddSpell(Yam_Scan_FleeMark, false)
;     mySelf.EvaluatePackage()
;     RegisterForSingleUpdate(MCM.iFolFleeDur)
;   endFunction
;
;   Event OnUpdate()
;     Scan.SceneClose(myID)
;     GoToState("")
;   endEvent
;
;   Event OnEndState()
;     mySelf.RemoveSpell(Yam_Scan_FleeMark)
;     mySelf.EvaluatePackage()
;     mySelf.RemoveSpell(CloakSpell)
;   EndEvent
;   ; ================================================================ ;
;   ;                             CLEAN UP                             ;
;   ; ================================================================ ;
;   Event OnUnload()
;     CleanUp()
;     Scan.SceneClose(myID)
;   EndEvent
;
;   Event OnDeath(Actor akKiller)
;     CleanUp()
;     Scan.SceneClose(myID)
;   EndEvent
; EndState
;
;
; State BleedoutInstant
;   ; ================================================================ ;
;   ;                       DEFAULT STATE ACTIONS                      ;
;   ; ================================================================ ;
;   Event OnBeginState()
;     mySelf.SetDontMove()
;     Aggressor.SetDontMove()
;     mySelf.AddSpell(CloakSpell)
;     aggressor.AddSpell(CloakSpell, false)
;     int scenery = Main.StartSceneSimple(mySelf, Aggressor, myID)
;     If(scenery == -1) ; Something failed idk
;       PseudoHook()
;     else
;       RegisterForModEvent("HookAnimationEnding_"+myID, "Aftermath")
;     endIf
;     mySelf.SetDontMove(false)
;     Aggressor.SetDontMove(false)
;   EndEvent
;
;   Function Pseudohook()
;     Utility.Wait(0.5)
;     Aggressor.RemoveSpell(CloakSpell)
;     Scan.ClearAggr(myID)
;     StateSpecific()
;   EndFunction
;
;   Event Aftermath(int tid, bool hasPlayer)
;     Main.HealActor(mySelf, MCM.fHealNPC)
;     Aggressor.RemoveSpell(CloakSpell)
;     Scan.ClearAggr(myID)
;     StateSpecific()
;     UnregisterForModEvent("HookAnimationEnding_PostUse")
;   EndEvent
;   ; ================================================================ ;
;   ;                      STATE SPECIFIC ACTIONS                      ;
;   ; ================================================================ ;
;   Function StateSpecific()
;     Utility.Wait(1) ;Waiting to not have SL Close cancel out Bleedout Anim
;     Main.BleedOut(mySelf)
;     ;How long we stay in Bleedout:
;     If(MCM.iNPCBleedoutDur > 0)
;       RegisterForSingleUpdate(MCM.iNPCBleedoutDur)
;     else
;       Scan.SceneClose(myID)
;     EndIf
;   endFunction
;
;   Event OnUpdate()
;     Scan.SceneClose(myID)
;     GoToState("")
;   endEvent
;
;   Event OnEndState()
;     Main.BleedOutExit(mySelf)
;     Utility.Wait(5)
;     mySelf.RemoveSpell(CloakSpell)
;   EndEvent
;   ; ================================================================ ;
;   ;                             CLEAN UP                             ;
;   ; ================================================================ ;
;   Event OnUnload()
;     CleanUp()
;     Scan.SceneClose(myID)
;   EndEvent
;
;   Event OnDeath(Actor akKiller)
;     CleanUp()
;     Scan.SceneClose(myID)
;   EndEvent
; EndState
; ; ------------------------------ SexLab
; Function StateSpecific()
;   ;Each State will execute its Unique Characteristics by calling and overwriting this Function.
; endFunction
;
; Event Aftermath(int tid, bool hasPlayer)
;   ;SL Hook
;   ;A Victim is always located inside a State, so leaving this empty
; EndEvent
;
; Function Pseudohook()
;   ;Pseudo Hook
;   ;Same as Aftermath, used when a Scene doesnt start
; EndFunction
/;
