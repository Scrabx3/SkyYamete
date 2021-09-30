ScriptName YamScanReferences Extends ReferenceAlias Hidden
{Main Script for handling Knockdowns in Yamete. This here is treated as an "Abstract Class" of sorts
See YamPlayerMonitor, YamFollower or YamActor for actual implementation}

YamScan Property Scan Auto
YamMain Property Main Auto
YamMCM Property MCM Auto
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
  Spell source = akSource as Spell
  Enchantment enchant = akSource as Enchantment
  If(source && !source.IsHostile() || enchant && !enchant.IsHostile())
    GotoState("")
    return
  EndIf
  Form[] myItems = Main.getWornItems(mySelf)
  If(!MCM.bKdStripBlock[profile] || !abHitBlocked)
    CheckStrip(myItems)
  EndIf
  Actor myAggr = akAggressor as Actor
  If(mySelf.IsBleedingOut())
    If(MCM.bKdEssentialNPC[profile] || (mySelf == PlayerRef && MCM.bKdEssentialPlayer))
      Utility.Wait(1.8)
      mySelf.AddSpell(calmMark, false)
      mySelf.RestoreActorValue("Health", Math.abs(mySelf.GetActorValue("Health")) + 20)
      Utility.Wait(3.6)
      If(myAggr != PlayerRef)
				Aggressor = myAggr
        EnterKnockdown()
				return
			ElseIf(ReaperKnockdown())
				GotoState("Reaper")
				return
      EndIf
      consequenceChance += MCM.iRushedConsequenceAdd
      mySelf.RemoveSpell(calmMark)
    EndIf
  ElseIf(myAggr)
		If(myAggr != PlayerRef)
	    ; Chance Setting & Knockdown Condition
	    ;If(GetValidChance(myAggr))
			If(Utility.RandomFloat(0, 99.5) < MCM.fKDChance[profile])
				bool blocked = MCM.bKdBlock[profile] && abHitBlocked
			  bool ranged = MCM.bKdMelee[profile] && (akProjectile != none)
	      If(!blocked && !ranged && ValidInteraction(myAggr))
	        If(GetWeakened() || GetVulnerable(myItems))
	          Aggressor = myAggr
	          EnterKnockdown()
	          return
	        EndIf
				EndIf
			EndIf
		Else ; Player Aggressor
			bool blocked = MCM.bKdBlock[profile] && abHitBlocked && !PlayerRef.HasPerk(pPiercingStrike)
			If(!blocked && ReaperKnockdown())
				If(GetWeakened() || GetVulnerable(myItems))
					GotoState("Reaper")
					return
					return
				EndIf
			EndIf
    EndIf
  EndIf
  Utility.Wait(0.1)
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
  ElseIf(JsonUtil.FormListHas("../Yamete/excluded.json", "actorsAggr", akAggressor) || mySelf.HasMagicEffectWithKeyword(bleedoutMarkKW) || (akAggressor.IsCommandedActor() && !MCM.bSummonAggr))
    return false
  ElseIf(Main.baboDia != none) ;/ TODO remove this /;
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
    return Main.isValidGenderCombination(mySelf, akAggressor) && Main.isValidCreature(akAggressor) && aroused
  else
    return true
  EndIf
endFunction

; "ValidInteraction()" equivalent for Player Aggressor
bool Function ReaperKnockdown()
	If(!mySelf || mySelf == PlayerRef || MCM.bOnlyWithReaper && !PlayerRef.HasSpell(ReapersMercy))
		return false
	ElseIf(mySelf.HasMagicEffectWithKeyword(bleedoutMarkKW))
		return false
	ElseIf(Main.baboDia != none) ;/ TODO remove this /;
		If(PlayerRef.IsInFaction(Main.baboDia) || mySelf.IsInFaction(Main.baboDia))
			return false
		EndIf
	EndIf
	return true
EndFunction

bool Function GetWeakened()
  float healthPer = mySelf.GetActorValuePercentage("Health")
  return healthPer <= MCM.fKdHpThreshUpper[profile] && healthPer >= MCM.fKdHpThreshLower[profile]
EndFunction

bool Function GetVulnerable(Form[] wornItems)
  return wornItems.length < MCM.iKdVulnerable[profile]
EndFunction

Function CheckStrip(Form[] wornItems)
  If(Utility.RandomInt(0, 99) < MCM.iKdStrip[profile] && wornItems)
		Form item = wornItems[Utility.RandomInt(0, (wornItems.Length - 1))]
    If(Utility.RandomInt(0, 99) < MCM.iKdStripDstry[profile] && canDestroy(item))
      mySelf.RemoveItem(item, abSilent = true)
      If(mySelf == PlayerRef && MCM.bShowNotifyStrip)
        string tmp = item.GetName()
        If(MCM.bShowNotifyColor)
          Debug.Notification("<font color='" + MCM.sNotifyColor + "'>" + tmp + " got teared off and destroyed")
        else
          Debug.Notification(tmp + " got teared off and destroyed")
        EndIf
      EndIf
    else
      If(MCM.bKdStripDrop[profile])
				mySelf.DropObject(item)
      else
        mySelf.UnequipItem(item, abSilent = true)
      EndIf
    EndIf
  EndIf
EndFunction

bool Function canDestroy(Form item)
  return !(MCM.iKdStripProtect && (item.HasKeyword(DaedricArtifact) || JsonUtil.FormListHas("../Yamete/excluded.json", "items", item)))
EndFunction

Function EnterKnockdown()
	If(MCM.iCombatScenario == 1)
		GoToState("Traditional")
	else
		GoToState("Rushed")
	EndIf
	If(MCM.bShowNotifyKD)
		string myName = mySelf.GetLeveledActorBase().GetName()
		string otherName = Aggressor.GetLeveledActorBase().GetName()
		If(MCM.bShowNotifyColor)
			Debug.Notification("<font color='" + MCM.sNotifyColor + "'>" + myName + " got knocked out by " + otherName + "</font>")
		Else
			Debug.Notification(myName + " got knocked out by" + otherName)
		EndIf
	EndIf
EndFunction

; ======================================================================
; ================================== REAPER
; ======================================================================
State Reaper
	Event OnBeginState()
		Debug.Trace("[Yamete] Enter Reaper on " + GetName())
    Main.npcBleedout(mySelf, -1)
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
    If(!PO3_SKSEFunctions.HasMagicEffectWithArchetype(aggressor, "Frenzy") && a > 0)
      aggressor.AddSpell(calmMark, false)
      aggressor.SetRestrained(true)
      aggressor.KeepOffsetFromActor(mySelf, 0.0, 0.0, 20.0, afCatchUpRadius = 300.0, afFollowRadius = 150.0)
      Utility.Wait(3.4) ; Some time to allow this Actor to be rescued
      If(!mySelf.HasMagicEffectWithKeyword(bleedoutMarkKW) || mySelf.IsDead())
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
    EnterBleedout(true)
    UnregisterForModEvent("ostim_end")
  EndEvent
  Event OnQuestStop(Quest akQuest)
    EnterBleedout(true)
    PO3_Events_Alias.UnregisterForAllQuests(self)
  EndEvent
  Event OnUpdate()
    ; Debug.MessageBox("[Yamete] OnUpdate() on " + (GetReference() as Actor).GetLeveledActorBase().GetName())
    EnterBleedout(true)
  EndEvent

  Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    ;
  EndEvent
EndState

;/ If Consequence applies, put this Actor into Bleedout & cleanup his Slot in the Quest
Otherwise stack Consequence and reset the Actor to default /;
Function EnterBleedout(bool fromScene)
  Debug.Trace("[Yamete] Rushed: YamScanReferences.EnterBleed() on " + GetName() + " -> fromScene: " + fromScene)
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
Event OnDying(Actor akKiller)
  If(aggressor)
    clearAggressor()
  EndIf
  If(GetName() != "Combatant0")
    Clear()
  EndIf
  GoToState("")
EndEvent

Function clearAggressor()
	aggressor.ClearKeepOffsetFromActor()
	aggressor.SetRestrained(false)
	aggressor.RemoveSpell(calmMark)
	If(aggressor.IsInFaction(Main.PlayerFollowerFaction))
		aggressor.SetPlayerTeammate(true, true)
	EndIf
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
