Scriptname YamFollower extends YamScanReferences

; Set Variables
Event OnInit()
  If(GetReference())
		mySelf = GetReference() as Actor
		mySelf.AddSpell(CacheGear)
  EndIf
  consequenceChance = MCM.iRushedConsequence
  profile = 1
  Aggressor = none
  ; RegisterForModEvent("Yam_CombatStop", "CombatStop")
EndEvent

; Fill this Slot with a new Actor & set Variables
Function ReFill(Actor that)
  Debug.Trace("[Yamete] ReFill() -> Called on a Follower Script..")
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

; Clear this Slot, reset the Actor if necessary
Function CleanUp(bool removeMark = true)
	If(aggressor)
		clearAggressor()
	EndIf
  If(mySelf && removeMark)
    mySelf.RemoveSpell(calmMark)
  EndIf
  GoToState("")
EndFunction



;/ ======================================================================
; ================================== REDUNDANT
; ======================================================================
Event CombatStop(string eventName, string strArg, float numArg, Form sender)
  Debug.Trace("[Yamete] Registered CombatStop Event!")
  CleanUp()
EndEvent

; Return true if this engage is allowed to happen based on MCM RNG Settings
bool Function getValidChance(Actor that)
  return Utility.RandomInt(0, 99) < MCM.iAssNPCFol
EndFunction
; -------------------------- Scenarios
State Basic
  ; =================================================================== ;
  ;                        DEFAULT STATE ACTIONS                        ;
  ; =================================================================== ;
  Event OnBeginState()
    mySelf.SetDontMove()
    Aggressor.SetDontMove()
    ; PrepareState()
    mySelf.AddSpell(CloakSpell)
    Aggressor.AddSpell(CloakSpell, false)
    int scenery = Main.StartSceneSimple(mySelf, Aggressor, myID)
    If(scenery == -1) ; Something failed idk or Scenes deactivated
      PseudoHook()
    else
      RegisterForModEvent("HookAnimationEnding_"+myID, "Aftermath")
    endIf
    mySelf.SetDontMove(false)
    Aggressor.SetDontMove(false)
  EndEvent

  Function Pseudohook()
    Utility.Wait(0.5)
    Aggressor.RemoveSpell(CloakSpell)
    Scan.ClearAggr(myID)
    StateSpecific()
  EndFunction

  Event Aftermath(int tid, bool hasPlayer)
    Main.HealActor(mySelf, MCM.fHealFollower)
    Aggressor.RemoveSpell(CloakSpell)
    Scan.ClearAggr(myID)
    StateSpecific()
    UnregisterForModEvent("HookAnimationEnding_PostUse")
  EndEvent
  ; ================================================================ ;
  ;                      STATE SPECIFIC ACTIONS                      ;
  ; ================================================================ ;
  Function StateSpecific()
    Scan.SceneClose(myID)
    GoToState("")
  endFunction

  ; Event OnUpdate()
  ;
  ; endEvent

  Event OnEndState()
    mySelf.RemoveSpell(CloakSpell)
  EndEvent
  ; ================================================================ ;
  ;                              CLEAN UP                            ;
  ; ================================================================ ;
  Event OnUnload()
    CleanUp()
    Scan.SceneClose(myID)
  EndEvent

  Event OnDeath(Actor akKiller)
    CleanUp()
    Scan.SceneClose(myID)
  EndEvent
EndState

State FleeInstant
  ; ================================================================ ;
  ;                        DEFAULT STATE ACTIONS                     ;
  ; ================================================================ ;
  Event OnBeginState()
    mySelf.SetDontMove()
    Aggressor.SetDontMove()
    ; PrepareState()
    mySelf.AddSpell(CloakSpell)
    Aggressor.AddSpell(CloakSpell, false)
    int scenery = Main.StartSceneSimple(mySelf, Aggressor, myID)
    If(scenery == -1) ; Something failed idk
      PseudoHook()
    else
      RegisterForModEvent("HookAnimationEnding_"+myID, "Aftermath")
    endIf
    mySelf.SetDontMove(false)
    Aggressor.SetDontMove(false)
  EndEvent

  Function Pseudohook()
    Utility.Wait(0.5)
    Aggressor.RemoveSpell(CloakSpell)
    Scan.ClearAggr(myID)
    StateSpecific()
  EndFunction

  Event Aftermath(int tid, bool hasPlayer)
    Main.HealActor(mySelf, MCM.fHealFollower)
    Aggressor.RemoveSpell(CloakSpell)
    Scan.ClearAggr(myID)
    StateSpecific()
    UnregisterForModEvent("HookAnimationEnding_PostUse")
  EndEvent
  ; ================================================================ ;
  ;                      STATE SPECIFIC ACTIONS                      ;
  ; ================================================================ ;
  Function StateSpecific()
    mySelf.AddSpell(Yam_Scan_FleeMark, false)
    mySelf.EvaluatePackage()
    RegisterForSingleUpdate(MCM.iFolFleeDur)
  endFunction

  Event OnUpdate()
    Scan.SceneClose(myID)
    GoToState("")
  endEvent

  Event OnEndState()
    ;State Specific CleanUp:
    mySelf.RemoveSpell(Yam_Scan_FleeMark)
    mySelf.EvaluatePackage()
    mySelf.RemoveSpell(CloakSpell)
  EndEvent
  ; ================================================================ ;
  ;                             CLEAN UP                             ;
  ; ================================================================ ;
  Event OnUnload()
    CleanUp()
    Scan.SceneClose(myID)
  EndEvent

  Event OnDeath(Actor akKiller)
    CleanUp()
    Scan.SceneClose(myID)
  EndEvent
EndState

State BleedoutInstant
  ; ================================================================ ;
  ;                         DEFAULT STATE ACTIONS                    ;
  ; ================================================================ ;
  Event OnBeginState()
    mySelf.SetDontMove()
    Aggressor.SetDontMove()
    ; PrepareState()
    mySelf.AddSpell(CloakSpell)
    Aggressor.AddSpell(CloakSpell, false)
    int scenery = Main.StartSceneSimple(mySelf, Aggressor, myID)
    If(scenery == -1) ; Something failed idk
      PseudoHook()
    else ;Scene started
      RegisterForModEvent("HookAnimationEnding_"+myID, "Aftermath")
    endIf
    mySelf.SetDontMove(false)
    Aggressor.SetDontMove(false)
  EndEvent

  Function Pseudohook()
    Utility.Wait(2)
    Aggressor.RemoveSpell(CloakSpell)
    Scan.ClearAggr(myID)
    StateSpecific()
  EndFunction

  Event Aftermath(int tid, bool hasPlayer)
    Main.HealActor(mySelf, MCM.fHealFollower)
    Aggressor.RemoveSpell(CloakSpell)
    Scan.ClearAggr(myID)
    StateSpecific()
    UnregisterForModEvent("HookAnimationEnding_PostUse")
  EndEvent
  ; ================================================================ ;
  ;                      STATE SPECIFIC ACTIONS                      ;
  ; ================================================================ ;
  Function StateSpecific()
    Utility.Wait(1) ;Waiting to not have SL Close cancel out Bleedout Anim
    Main.BleedOut(mySelf)
    ;How long we stay in Bleedout:
    If(MCM.iFolBleedDur > 0)
      RegisterForSingleUpdate(MCM.iFolBleedDur)
    else
      Scan.SceneClose(myID)
    EndIf
  endFunction

  Event OnUpdate()
    Scan.SceneClose(myID)
    GoToState("")
  endEvent

  Event OnEndState()
    Main.BleedOutExit(mySelf)
    Utility.Wait(5)
    mySelf.RemoveSpell(CloakSpell)
  EndEvent
  ; ================================================================ ;
  ;                              CLEAN UP                            ;
  ; ================================================================ ;
  Event OnUnload()
    CleanUp()
    Scan.SceneClose(myID)
  EndEvent

  Event OnDeath(Actor akKiller)
    CleanUp()
    Scan.SceneClose(myID)
  EndEvent
EndState
; ------------------------------ SexLab
Function StateSpecific()
  ;Each State will execute its Unique Characteristics by calling and overwriting this Function.
endFunction

Event Aftermath(int tid, bool hasPlayer)
  ;SL Hook
  ;A Victim is always located inside a State, so leaving this empty
EndEvent

Function Pseudohook()
  ;Pseudo Hook
  ;Same as Aftermath, used when a Scene doesnt start
EndFunction
/;
