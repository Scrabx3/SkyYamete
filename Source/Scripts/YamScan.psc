Scriptname YamScan extends Quest
{Script to Monitor in-Combat behavior}

; -------------------------- Properties
YamMCM Property MCM Auto
YamMain Property Main Auto
Actor Property PlayerRef Auto
; Spell Property ClockedOut Auto
Quest Property Yam_Reload Auto
Quest Property ResolutionQ Auto
Faction property exclusionFac Auto ; Cant filter that out in the Scan Quest directly as that one also needs to check if Combat is going on
Faction Property friendFac Auto
Faction Property resoFriendFac Auto
Faction[] Property alliances Auto
Spell[] Property gatherers Auto
YamActor[] Property myActors Auto
{Combatants}
YamScanReferences[] Property myAliases Auto
{All the Scans Aliases.  I know and I dont care about the SKSE Function cause slower; shut it
0 - Player, 1~10 - Followers, after - Combatants}
ReferenceAlias[] Property myBullets Auto
{Actors that joined the fight after this Quest already started}
; --- Post Combat
Spell Property calmMark Auto
Spell Property scanCloseSpell Auto
Spell Property AoEFleeMark Auto
Spell Property checkCombat Auto
Keyword Property markKW Auto
Keyword Property bleedoutMarkKW Auto
Keyword Property bleedTemporaryKW Auto
Keyword Property resolutionKW Auto
Keyword Property Yam_Scan_InUse Auto
; -------------------------- Variables
; --- Resolution Quick
bool Property inCombat Auto Hidden
; -------------------------- Code
;/ ==========================
; Yamete V4+
; ==========================
With V4+, the Combat Quest only monitors an Actor until Knockdown; It no longer regulates the Consequence or caches the Actor
As such, it will throw out any Actor that entered Bleedout or Blackout and most of the content in this Script became redundant
The Quest itself will no longer recognize Actors inside a Consequence and instead onyl differentiate between Actors "that are being knocked down" and Actors that "are not knocked down", Actors that "are" knockdowned are no longer part of this Quest. The Scan Quest is considered completed when there are no more Actors that are in the process of getting knocked down and the Reload Quest cannot identify Combat anymore
/;

Event OnInit()
  If(!IsRunning())
    return
  EndIf
  If(!MCM.bSLScenes)
    Debug.Notification("Combat Quest started..")
  EndIf
  RegisterForSingleUpdate(2)
EndEvent
; ================================================================ ;
;                   Reload System & Combat End                     ;
; ================================================================ ;
Event OnUpdate()
  If(Yam_Reload.Start())
		Actor b = myBullets[0].GetReference() as Actor
    int i = (b.HasKeyword(Yam_Scan_InUse) || b.IsInFaction(exclusionFac)) as int
    While(i < myBullets.length)
      b = myBullets[i].GetReference() as Actor
      If(b != none && ((b.GetRace() == Main.ElderRace) as int <= MCM.EnderVicGl.Value) && (b.IsCommandedActor() as int <= MCM.SummonVicGl.Value))
        int freeSlot = GetFreeSlot()
        If(freeSlot > -1)
          myActors[freeSlot].ReFill(b)
        EndIf
      EndIf
      i += 1
    EndWhile
    Utility.Wait(0.1)
    Yam_Reload.Stop()
  else
    ;/ No Combat anymore
    Close the Quest if nobody is currently playing through Scenario..
    If Rushed ->
      Get everyone out of Bleedout that isnt supposed to stay in it
    If Traditional or Mixed ->
      Close the Quest silently, handing over to Resolution after analyzing the battle field for Victoires & Victims
    /;
    Debug.Trace("[Yamete] Scan: No Combat found")
    If(IsEveryoneIdling() == true)
      Debug.Trace("[Yamete] Scan: Everyone idling, stopping Quest..")
      If(MCM.iCombatScenario == 0)
        SetStage(999)
      else
        SetStage(1000)
      EndIf
      return
    EndIf
  EndIf
  Debug.Trace("[Yamete] Polling Scan Quest..")
  RegisterForSingleUpdate(5)
EndEvent

;/ Check if Combat ends without adding new Actors in the Area to the Quest
This is significantly faster than the regular OnUpdate() check /;
Function startResolutionfast()
  inCombat = false
  Utility.Wait(0.7)
  checkCombat.Cast(PlayerRef)
  Utility.Wait(0.3)
  If(inCombat == true)
    ; Debug.Trace("[Yamete] startResolutionfast() -> isCombat == true")
    return
  ElseIf(IsEveryoneIdling() == false)
    return
  EndIf
  SetStage(1000)
EndFunction

;/ Get a currently empty Actor Slot from this Quest /;
int Function GetFreeSlot()
  int i = myActors.Length
  While(i > 1)
    i -= 1
    If(!myActors[i].GetReference())
      return i
    EndIf
  EndWhile
  return -1
endFunction

bool Function IsEveryoneIdling()
  int i = 0
  While(i < myAliases.length)
    String thisState = myAliases[i].GetState()
    If(thisState != "" && myAliases[i].GetReference() != none)
      Debug.Trace("[Yamete] IsEveryoneIdling() -> " + myAliases[i].GetName() + " is in State: " + thisState)
      return false
    EndIf
    i += 1
  EndWhile
  return true
EndFunction

;/ NOTE Quest can close in 2 ways; With or Without starting Resolution
-> Without Resolution:
Close the Quest after the Buffer run out, pull Followers out of Combat alongside the Player, all other Actors follow after the Buffer ends
• Player Lost
Pull them out of Bleedout (if not permanent)
-> With Resolution:
• Player Lost
Define a leading Victoire and split the Field into Victoires (Actors with same Alliance as the leading Victoire) and Victims (everyone else that is bleeding out)
Start Resolution & end the Quest silently
• Player won
Grant the Player a Cloak that closes this Quest silently after 3 Minutes and pulls every Actor out of a (non permanent) Bleedout if the Player goes too far away or the 3 Minutes are over
/;
Function Stage999()
	GotoState("Stage999")
  Debug.Trace("[Yamete] Scan: SetStage 999")
  If(PlayerRef.HasMagicEffectWithKeyword(bleedoutMarkKW))
    PlayerRef.AddSpell(calmMark, false)
    If(!Main.SurrenderQ.IsRunning())
      myAliases[0].GotoState("Exhausted")
    EndIf
    Main.BleedOutExit(PlayerRef, true)
  EndIf
  int i = 1
  int cap = myAliases.length - myActors.length
  While(i < cap)
    Actor that = myAliases[i].GetReference() as Actor
    If(that)
      ; upon exiting Bleedout, they will be teammates again and thus inherit the players Calm Mark
      If(that.HasMagicEffectWithKeyword(bleedoutMarkKW))
        Main.BleedOutExit(that, true)
      EndIf
      that.SetPlayerTeammate(true, true)
      that.RemoveFromFaction(friendFac)
    EndIf
    i += 1
  EndWhile
  If(Main.SurrenderQ.IsRunning())
    Stop()
  Else
    RegisterForSingleUpdate(MCM.iRushedBuffer + 4)
  EndIf
EndFunction

State Stage999
	Event OnUpdate()
		AoEFleeMark.Cast(PlayerRef)
		PlayerRef.RemoveFromFaction(friendFac)
		Stop()
	EndEvent
EndState

Function Stage1000()
  Debug.Trace("[Yamete] Scan: SetStage 1000")
  ; If Resoolution didnt stop itself (is still running) this combat has nothing to do with the ongoing Resolution, so dont interrupt it and close the Quest silently..
  If(!ResolutionQ.IsRunning())
    Actor victoire = none
    int i = 0
    While(i < myActors.length && victoire == none)
      Actor tmp = myActors[i].GetReference() as Actor
      If(tmp)
        If(!tmp.HasMagicEffectWithKeyword(markKW))
          victoire = tmp
        EndIf
      EndIf
      i += 1
    EndWhile
    If(victoire != none)
      If(victoire.IsInFaction(alliances[0])) ; Rootsider
        Debug.Trace("[Yamete] Scan: Casting Gathering Spell Nr. 0 (Rootsider)")
        gatherers[0].Cast(victoire, victoire)
      ElseIf(victoire.IsInFaction(alliances[1])) ; Bystander
        Debug.Trace("[Yamete] Scan: Casting Gathering Spell Nr. 1 (Bystander)")
        gatherers[1].Cast(victoire, victoire)
      ElseIf(victoire.IsInFaction(alliances[2])) ; Playersider
        Debug.Trace("[Yamete] Scan: Casting Gathering Spell Nr. 2 (Playersider)")
        gatherers[2].Cast(victoire, victoire)
      Else
        Debug.Trace("[Yamete] Scan: Target was not part of any Alliance")
      EndIf
      Utility.Wait(0.5)
      gatherers[3].Cast(PlayerRef)
      Utility.Wait(0.3)
      If(victoire != none)
        If(resolutionKW.SendStoryEventAndWait(none, victoire) == true)
          Debug.Trace("[Yamete] Started Resolution..")
          Stop()
          return
        EndIf
      EndIf
    EndIf
  else
    Debug.Trace("[Yamete] Resolution already running")
  EndIf
  Debug.Trace("[Yamete] Failed to start Resolution..")
  If(!PlayerRef.IsInFaction(resoFriendFac))
    If(PlayerRef.HasMagicEffectWithKeyword(bleedoutMarkKW))
      Debug.Trace("[Yamete] Player is bleeding out. Falling back to Stage999")
      Stage999()
    else
      Debug.Trace("[Yamete] Assuming the Player to be Victoire. Closing Quest through Cloak Spell")
      scanCloseSpell.Cast(PlayerRef)
    EndIf
  else
    Debug.Trace("[Yamete] Player is currently part of Resolution, assuming this to be a random Encounter off road. Silently stopping Quest")
    Stop()
  EndIf
EndFunction

;/ ========================= REDUNDANT
; Function CloseQuest()
;   ;Go through all Actors in the Combat Quest, if the Alias isnt empty & the Alias is finished with their Scenario, let their Script Instance know its time to clean up State Specific Stuff
;   ; If(!plMonitor.CombatQuestRunning)
;   ;   plMonitor.CombatEnd()
;   ; EndIf
;   int Count = myActors.Length
;   While(Count)
;     Count -= 1
;     If(myActors[Count].GetReference() && !activVic[Count])
;       (myActors[Count] as YamActor).GoToState("")
;     EndIf
;   EndWhile
;   Count = myFollowers.Length
;   While(Count)
;     Count -= 1
;     If(myFollowers[Count].GetReference() && !activVic[16 + Count])
;       (myFollowers[Count] as YamFollower).GoToState("")
;     EndIf
;   EndWhile
; endFunction
;
; Function StopQuest()
;   ; Before we can completely shut down the Quest, we need to make sure that all Actors in the Quest arent affected by any Combat Quest applied effects, this is especially important for Force-Shutdowns
;   If(!IsRunning())
;     return
;   EndIf
;   If(plMonitor.GetState() != "PostScene")
;     plMonitor.CleanUp()
;   EndIf
;   int Count = myActors.Length
;   While(Count)
;     Count -= 1
;     If(myActors[Count].GetReference())
;       (myActors[Count] as YamActor).CleanUp()
;     EndIf
;   EndWhile
;   Count = myFollowers.Length
;   While(Count)
;     Count -= 1
;     If(myFollowers[Count].GetReference())
;       (myFollowers[Count] as YamFollower).CleanUp()
;     EndIf
;   EndWhile
;   Stop()
;   If(!MCM.bSLScenes)
;     Debug.Notification("Combat Quest stopped..")
;   EndIf
; endFunction

; ================================================================ ;
;                         Knockout System                          ;
; ================================================================ ;
bool Function IsReservedAggr(Actor me)
  If(me == none || aggrList.Find(me) >= 0)
    return true
  ElseIf(me.HasSpell(ClockedOut))
    return true
  EndIf
  return false
endFunction

Function SceneEntry(string ID, Actor myAggr)
  ; Let the System know were currently playing through a Scenario..
  activeScenes += 1
  ; Cache Aggressor for Clocking & set Victim as active
  ; If(ID == "Player")
  ;   aggrList[21] = myAggr
  ;   activVic[21] = true
  If(GetNthChar(ID, 0) == "F") ;"F"ollower
    int IDv = (GetNthChar(ID, 8)) as int
    aggrList[16 + IDv] = myAggr
    activVic[16 + IDv] = true
  else
    int IDv = (GetNthChar(ID, 9) + GetNthChar(ID, 10)) as int
    aggrList[IDv] = myAggr
    activVic[IDv] = true
  EndIf
EndFunction

Function ClearAggr(string ID)
  ; Clear Aggressor from Cache & Clock them
  ; If(ID == "Player")
  ;   If(Utility.RandomInt(1, 100) <= MCM.iClockOutChance)
  ;     aggrList[21].AddSpell(ClockedOut)
  ;     Utility.Wait(0.3)
  ;   EndIf
  ;   aggrList[21] = none
  If(GetNthChar(ID, 0) == "F") ;Follower
    int IDv = (GetNthChar(ID, 8)) as int
    If(Utility.RandomInt(1, 100) <= MCM.iClockOutChance)
      aggrList[16 + IDv].AddSpell(ClockedOut)
      Utility.Wait(0.3)
    EndIf
    aggrList[16 + IDv] = none
  else
    int IDv = (GetNthChar(ID, 9) + GetNthChar(ID, 10)) as int
    If(Utility.RandomInt(1, 100) <= MCM.iClockOutChance)
      aggrList[IDv].AddSpell(ClockedOut)
      Utility.Wait(0.3)
    EndIf
    aggrList[IDv] = none
  EndIf
endFunction

Function SceneClose(string ID)
  ; Clear Victim
  activeScenes -= 1
  ; If(ID == "Player")
  ;   activVic[21] = false
  If(GetNthChar(ID, 0) == "F") ;Follower
    int IDv = (GetNthChar(ID, 8)) as int
    activVic[16 + IDv] = false
  else
    int IDv = (GetNthChar(ID, 9) + GetNthChar(ID, 10)) as int
    activVic[IDv] = false
  EndIf
endFunction/;
