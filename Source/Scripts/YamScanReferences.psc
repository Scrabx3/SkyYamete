ScriptName YamScanReferences Extends ReferenceAlias Hidden
{Main Script for handling Knockdowns in Yamete. This here is treated as an "Abstract Class" of sorts
See YamPlayerMonitor, YamFollower or YamActor for actual implementation}

YamScan Property Scan Auto
YamMain Property Main Auto
YamMCM Property MCM Auto
YamReapersMercy Property RM Auto
YamEnslavement Property RMQ Auto
Actor Property PlayerRef Auto
Spell Property calmMark Auto
Spell Property CacheGear Auto
Spell Property ReapersMercy Auto
Perk Property pPiercingStrike Auto
Keyword Property DaedricArtifact Auto
Keyword Property bleedoutMarkKW Auto
; -------------------------- Variables
Actor Property mySelf Auto Hidden
Actor Property aggressor Auto Hidden
bool Property myValidRace Auto Hidden
int Property consequenceChance Auto Hidden
int Property profile Auto Hidden
int Property repeats Auto Hidden

; ======================================================================
; ================================== Active
; ======================================================================
State Busy
  Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    ;
  EndEvent
EndState

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
  GoToState("Busy")
  Actor myAggr = akAggressor as Actor
  If(!myAggr || StorageUtil.FormListHas(Scan, "YamProcessing", akAggressor) || StorageUtil.FormListHas(Scan, "YamProcessing", akAggressor))
    GoToState("")
    return
  EndIf
  If(!StorageUtil.FormListAdd(Scan, "YamProcessing", akAggressor, false))
    GoToState("")
    return
  ElseIf(!StorageUtil.FormListAdd(Scan, "YamProcessing", mySelf, false))
    StorageUtil.FormListRemove(Scan, "YamProcessing", akAggressor)
    GoToState("")
    return
  EndIf
  Spell source = akSource as Spell
  Enchantment enchant = akSource as Enchantment
  If((!source || source.IsHostile()) && (!enchant || enchant.IsHostile()))
    Form[] myItems = Main.getWornItems(mySelf)
    If(!MCM.bKdStripBlock[profile] || !abHitBlocked)
      CheckStrip(myItems)
    EndIf
    float myHp = Math.abs(mySelf.GetActorValue("Health"))
    If(mySelf.IsBleedingOut() && MCM.bKdEssentialNPC[profile] && myHp < 0)
      Utility.Wait(1.8)
      mySelf.AddSpell(calmMark, false)
      mySelf.ResetHealthAndLimbs()
      Utility.Wait(3.8)
      If(myAggr != PlayerRef && ValidInteraction(myAggr, true))
        Aggressor = myAggr
        EnterKnockdown()
        return
      ElseIf(ReaperKnockdown())
        GotoState("Reaper")
        return
      EndIf
      consequenceChance += MCM.iRushedConsequenceAdd
      mySelf.RemoveSpell(calmMark)
    Else
      If(myAggr != PlayerRef)
        ; Chance Setting & Knockdown Condition
        If(Utility.RandomFloat(0, 99.5) < MCM.fKDChance[profile])
          bool blocked = MCM.bKdBlock[profile] && abHitBlocked
          bool ranged = MCM.bKdMelee[profile] && (akProjectile != none)
          If(!blocked && !ranged && ValidInteraction(myAggr))
            If(GetWeakened() || GetExhausted() || GetVulnerable(myItems))
              Aggressor = myAggr
              EnterKnockdown()
              return
            EndIf
          EndIf
        EndIf
      Else ; Player Aggressor
        bool bashed = !MCM.bRBashOnly || abBashAttack
        bool blocked = MCM.bKdBlock[profile] && abHitBlocked && !PlayerRef.HasPerk(pPiercingStrike)
        ; Debug.Trace("[YAMETE] - CHECKING PLAYER HIT;; bashed = " + bashed + ";; blocked = " + blocked + ";; abBashAttack = " + abBashAttack + ";; bashOnly = " + MCM.bRBashOnly)
        If(bashed && !blocked && ReaperKnockdown())
          bool weak = GetWeakenedReaper()
          bool exhausted = GetExhausted()
          bool vulnerable = GetVulnerable(myItems)
          ; Debug.Trace("[YAMETE] - CHECKING PLAYER HIT;; weak = " + weak + ";; exhausted = " + Exhausted + ";; vulnerable = " + vulnerable)
          If(weak || exhausted || vulnerable)
            GotoState("Reaper")
            return
          EndIf
        EndIf
      EndIf
    EndIf
  EndIf
  Utility.Wait(0.1)
  StorageUtil.FormListRemove(Scan, "YamProcessing", akAggressor)
  StorageUtil.FormListRemove(Scan, "YamProcessing", mySelf)
  GoToState("")
EndEvent

bool Function ValidInteraction(Actor akAggressor, bool fromBleedout = false)
  ; I hate doing "exists" checks here but I still get some Errors about
  ; stuff not existing ... zzz. Apparently things that dont exist get hits
  ; registerd by Objects that dont exist but arent none
  ; Someone, explain me this game
  ; Base Checks
  If(akAggressor == none || mySelf == none || akAggressor == mySelf)
    Debug.Trace("[Yamete] isValidBase received invalid Argument")
    return false
  ElseIf(JsonUtil.FormListHas("../Yamete/excluded.json", "actorsAggr", akAggressor.GetLeveledActorBase()) || mySelf.HasMagicEffectWithKeyword(bleedoutMarkKW) || akAggressor.IsDead() || mySelf.IsDead() || (akAggressor.IsCommandedActor() && !MCM.bSummonAggr) || (akAggressor.GetRace() == Main.ElderRace && !MCM.bElderAggr))
    return false
  ElseIf(Main.baboDia != none) ; TODO: Remove this
    If(akAggressor.IsInFaction(Main.baboDia) || mySelf.IsInFaction(Main.baboDia))
      return false
    EndIf
  EndIf
  ; Distance
  If(MCM.iMaxDistance)
    If(akAggressor.GetDistance(mySelf) > MCM.iMaxDistance * 70)
      return false
    EndIf
  EndIf
  ; Hostility
  If(MCM.bCheckHostility && !fromBleedout)
    If(!akAggressor.IsHostileToActor(mySelf))
			Debug.Trace("[Yamete] Actor isnt hostile towards me")
      return false
    EndIf
  EndIf
  ; Gender
  If(MCM.iFilterType == 1)
		bool aroused = true
		If(MCM.bSLAllowed)
			bool isFol = akAggressor.IsInFaction(Main.PlayerFollowerFaction) || akAggressor.IsPlayerTeammate()
			int ar = YamSexLab.GetArousal(akAggressor)
			aroused = ar >= MCM.iSLArousalThresh && (!isFol || MCM.iSLArousalFollower == 0) || isFol && ar >= MCM.iSLArousalFollower
		EndIf
    return myValidRace && aroused && Main.isValidGenderCombination(mySelf, akAggressor) && Main.isValidCreature(akAggressor)
  else
    return true
  EndIf
endFunction

; "ValidInteraction()" equivalent for Player Aggressor
bool Function ReaperKnockdown()
	If(!mySelf || mySelf == PlayerRef || !PlayerRef.HasSpell(ReapersMercy))
    ; Debug.Trace("[YAMETE] - PLAYER GOT NO SPELL")
		return false
	ElseIf(mySelf.HasMagicEffectWithKeyword(bleedoutMarkKW) || mySelf.IsDead())
    ; Debug.Trace("[YAMETE] - VICTIM BLEEDOUT")
		return false
	ElseIf(Main.baboDia != none) ; TODO: Remove this
		If(PlayerRef.IsInFaction(Main.baboDia) || mySelf.IsInFaction(Main.baboDia))
      ; Debug.Trace("[YAMETE] - BABO PROTECCT")
			return false
		EndIf
  ElseIf(!mySelf.HasKeyword(Main.ActorTypeNPC) && (MCM.lReapersCreature == 0 || MCM.lReapersCreature == 2 && !myValidRace))
    ; Debug.Trace("[YAMETE] - INVALID CREATURE FILTER BLEEDOUT")
    return false
  ; ElseIf(MCM.lReapersCreature == 0 || MCM.lReapersCreature == 2 && !Main.isValidCreature(akAggressor))
  ;   return false
	EndIf
	return true
EndFunction

bool Function GetWeakened()
  float healthPer = mySelf.GetActorValuePercentage("Health")
  return healthPer < MCM.fKdHpThreshUpper[profile] && healthPer >= MCM.fKdHpThreshLower[profile]
EndFunction

bool Function GetWeakenedReaper()
	float healthPer = mySelf.GetActorValuePercentage("Health")
	float hpUpper = MCM.fKdHpThreshUpper[profile] * (1 + ((5 + RM.RavageRank * 5)/100))
  return healthPer <= hpUpper && healthPer >= MCM.fKdHpThreshLower[profile]
EndFunction

bool Function GetVulnerable(Form[] wornItems)
  return mySelf.HasKeyword(Main.ActorTypeNPC) && wornItems.length < MCM.iKdVulnerable[profile]
EndFunction

bool Function GetExhausted()
  return mySelf.GetActorValuePercentage("Stamina") < MCM.fStaminaThresh[profile] || mySelf.GetActorValuePercentage("Magicka") < MCM.fMagickaThresh[profile]
EndFunction

Function CheckStrip(Form[] wornItems)
  If(Utility.RandomInt(0, 99) < MCM.iKdStrip[profile] && wornItems)
		Form item = wornItems[Utility.RandomInt(0, (wornItems.Length - 1))]
    bool canDestroy = !(MCM.iKdStripProtect && (item.HasKeyword(DaedricArtifact) || JsonUtil.FormListHas("../Yamete/excluded.json", "items", item)))
    If(Utility.RandomInt(0, 99) < MCM.iKdStripDstry[profile] && canDestroy)
      mySelf.RemoveItem(item, abSilent = true)
      If(mySelf == PlayerRef && MCM.bShowNotifyStrip)
        string tmp = item.GetName()
        If(MCM.bShowNotifyColor)
          Debug.Notification("<font color='" + MCM.sNotifyColor + "'>" + tmp + " got teared off and destroyed")
        Else
          Debug.Notification(tmp + " got teared off and destroyed")
        EndIf
      EndIf
    Else
      If(MCM.bKdStripDrop[profile])
				mySelf.DropObject(item)
      Else
        mySelf.UnequipItem(item, abSilent = true)
      EndIf
    EndIf
  EndIf
EndFunction

Function EnterKnockdown()
  If(MCM.bShowNotifyKD)
		string myName = mySelf.GetLeveledActorBase().GetName()
		string otherName = Aggressor.GetLeveledActorBase().GetName()
		If(MCM.bShowNotifyColor)
			Debug.Notification("<font color='" + MCM.sNotifyColor + "'>" + myName + " got knocked out by " + otherName + "</font>")
		Else
			Debug.Notification(myName + " got knocked out by" + otherName)
		EndIf
	EndIf
	If(MCM.iCombatScenario == 1)
		GoToState("Traditional")
	else
		GoToState("Rushed")
	EndIf
EndFunction

; ======================================================================
; ================================== REAPER
; ======================================================================
State Reaper
	Event OnBeginState()
    StorageUtil.FormListRemove(Scan, "YamProcessing", aggressor)
		Debug.Trace("[Yamete] Enter Reaper on " + GetName())
		RM.AddXp(2)
		If(RM.AnculoRank > 0 && Utility.RandomInt(0, 99) < (5 + RM.AnculoRank * 5))
			RMQ.ClaimVictim(mySelf)
		else
			Main.npcBleedout(mySelf, -1)
		EndIf
    CleanUp()
	EndEvent
EndState

; ======================================================================
; ================================== RUSHED
; ======================================================================
Event AfterScene(int tid, bool hasPlayer)
EndEvent
Event OStimEnd(string eventName, string strArg, float numArg, Form sender)
EndEvent
Event OnQuestStop(Quest akQuest)
EndEvent

State Rushed
  ;/ "Knockdown" -> "Adult Scene" -> "Bleedout" -> (Chance)[Combat End | Blackout] -> "Combat End" /;
  ;/ Handle Adult Scene and wait or Enter Bleedout in case of Failure /;
  Event OnBeginState()
		Debug.Trace("[Yamete] Enter Rushed on " + GetName())
    Main.BleedOutEnter(mySelf, 0)
    mySelf.AddSpell(calmMark, false)
    int a = Main.getResolutionAction(aggressor, mySelf)
		Debug.Trace("[Yamete] Rushed Resolution Choice for " + GetName() + ": " + a)
    If(aggressor.GetActorValue("Aggression") < 4 && a > 0)
      aggressor.AddSpell(calmMark, false)
      aggressor.SetRestrained(true)
      Utility.Wait(3.4) ; Some time to allow this Actor to be rescued
      If(!mySelf.HasMagicEffectWithKeyword(bleedoutMarkKW) || mySelf.IsDead() || aggressor.IsDead())
        clearAggressor()
        ResetGroup(true)
        return
      EndIf
      If(a == 1)
        Main.RemoveItemsFromTo(mySelf, aggressor)
        Utility.Wait(1.7)
      ElseIf(a == 2)
        If(Utility.RandomInt(0, 99) < MCM.iResNPCendless && mySelf != PlayerRef)
          If(Main.CreateEndlessScene(mySelf, aggressor))
            clearAggressor()
            CleanUp(removeMark = false)
            return
          EndIf
        EndIf
        Actor[] partners = PapyrusUtil.ActorArray(1, aggressor)
        If(YamAnimationFrame.StartSceneRushed(MCM, self, partners) > -1)
          repeats = 1
          RegisterForModEvent("HookAnimationEnd_" + GetName(), "AfterScene")
          return
        EndIf
      EndIf
    EndIf
    EnterBleedout(false)
  EndEvent

  Event AfterScene(int tid, bool hasPlayer)
    EnterBleedout(true)
    UnregisterForModEvent("HookAnimationEnding_" + GetName())
  EndEvent
  Event OStimEnd(string eventName, string strArg, float numArg, Form sender)
    If(numArg > -2)
      If(YamOStim.FindActor(mySelf, numArg as int) == false)
        return
      EndIf
    EndIf
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

;/ If Consequence applies, put this Actor into Bleedout & cleanup his Slot in the Quest
Otherwise stack Consequence and reset the Actor to default /;
Function EnterBleedout(bool fromScene)
  Debug.Trace("[Yamete] Rushed: YamScanReferences.EnterBleed() on " + GetName() + " -> fromScene: " + fromScene)
  If(!mySelf.Is3DLoaded())
    ResetGroup(!fromScene)
    clearAggressor()
    return
  EndIf
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
		Debug.Trace("[Yamete] " + GetName() + " entered Consequence State")
    consequenceChance = MCM.iRushedConsequence
    Main.npcBleedout(mySelf, -1)
    CleanUp()
    ; If in Mixed, is combat over now?
    If(MCM.iCombatScenario == 2)
      Scan.startResolutionfast()
    EndIf
  else
		Debug.Trace("[Yamete] Resetting Group for " + GetName() + "; Consequence Chance: " + consequenceChance)
    consequenceChance += MCM.iRushedConsequenceAdd
		Debug.Trace("[Yamete] New Consequence Chance for " + GetName() + " is " + consequenceChance)
    ResetGroup(!fromScene)
  EndIf
EndFunction

; ======================================================================
; ================================== TRADITIONAL
; ======================================================================
State Traditional
  ;/ "Knockdown" -> "Bleedout" -> "Combat End" -> "Resolution" /;
  Event OnBeginState()
    Debug.Trace("[Yamete] Enter Traditional on " + GetName())
    Main.npcBleedout(mySelf, -1)
    CleanUp()
    Scan.startResolutionfast()
  EndEvent

  Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    ;
  EndEvent
EndState

; ======================================================================
; ================================== MISC
; ======================================================================
Event OnCellDetach()
  Debug.SendAnimationEvent(mySelf, "staggerStart")
  CleanUp()
EndEvent

Event OnDying(Actor akKiller)
  If(aggressor)
    clearAggressor()
  EndIf
  If(GetName() != "Combatant0")
    Clear()
  Else
    ResetGroup(false)
    GoToState("Busy")
    return
  EndIf
  GoToState("")
EndEvent

Function clearAggressor()
  aggressor.SetRestrained(false)
  aggressor.RemoveSpell(calmMark)
  If(aggressor.IsInFaction(Main.PlayerFollowerFaction))
    aggressor.SetPlayerTeammate(true, true)
  EndIf
  StorageUtil.FormListRemove(Scan, "YamProcessing", Aggressor)
  aggressor = none
EndFunction

; ======================================================================
; ================================== PSEUDO ABSTRACT
; ======================================================================
; Set Variables
Event OnInit()
  Debug.Trace("[Yamete] OnInit() -> Where are abstract classes when you need them")
EndEvent
; Fill this Slot with a new Actor & set Variables
Function ReFill(Actor that)
  Debug.Trace("[Yamete] ReFill() -> Where are abstract classes when you need them")
EndFunction
; Rushed: Reset this Actor back into Idle State
Function ResetGroup(bool expectBleedout)
  Debug.Trace("[Yamete] ResetGroup() -> Where are abstract classes when you need them")
EndFunction
; Clear this Slot, reset the Actor is necessary
Function CleanUp(bool removeMark = true)
  Debug.Trace("[Yamete] CleanUp() -> Where are abstract classes when you need them")
EndFunction
