Scriptname YamMain extends Quest
{Main  Script, handles most basic utility functionality and is responsible for starting the Combat Quest}

YamMCM Property MCM Auto
Actor Property PlayerRef Auto
FormList Property Yam_FriendList Auto
Quest Property ScanQ Auto
Quest Property ResoQ Auto
Spell Property ReapersMercy Auto
Spell[] Property bleedoutMarks Auto
Faction Property Yam_FriendFaction Auto
Faction Property PlayerFollowerFaction Auto
Faction[] Property BanditFactions Auto
Race[] Property raceList Auto
Keyword Property ActorTypeNPC Auto
Keyword Property EndlessSceneKW Auto
Keyword Property bleedoutMarkTemporary Auto
ImageSpaceModifier Property FadeToBlack Auto
ImageSpaceModifier Property FadeToBlackHold Auto
ImageSpaceModifier Property FadeToBlackBack Auto
Idle Property StealingIdle Auto
Idle[] Property killMoves Auto
Weapon Property SteelDagger Auto
; --- Consequences
Quest Property leftForDead Auto
; -------------------------- Variables
bool Property ModPaused = true Auto Hidden
string filePath = "../Yamete/excluded.json"
int ignoredSlots = 0x8070862
Faction Property baboDia Auto Hidden

; -------------------------- Globals
bool Function EquipCachedOutfit(Actor target) global
	Debug.Trace("[Yamete] EquipCachedOutfit called for " + target)
	string storageID = "YamOutfit" + target.GetFormID()
	int numItems = StorageUtil.FormListCount(target, storageID)
	bool ret = false
	If(numItems > 0)
		While(numItems > 0)
			numItems -= 1
			Form item = StorageUtil.FormListPop(target, storageID)
			If(target.GetItemCount(item) > 0)
				target.EquipItem(item)
			EndIf
		EndWhile
		ret = true
	EndIf
	StorageUtil.FileFormListClear(storageID)
	return ret
EndFunction

; ======================================================================
; ================================== STARTUP
; ======================================================================
Function Maintenance()
  RegisterForKey(MCM.iPlAggrKey)
  RegisterForKey(MCM.iPauseKey)
  RegisterForModEvent("Yam_ConsequencePlayer", "Yam_ConsequencePlayer")
  RegisterForModEvent("Yam_BleedoutPlayer", "Yam_BleedoutPlayer")
  RegisterForModEvent("Yam_BleedoutNPC", "Yam_BleedoutNPC")
  RegisterForModEvent("Yam_Pause", "Yam_Pause")
  RegisterForModEvent("Yam_Resume", "Yam_Resume")
  ; Adult Frames
  bool slhere = Game.GetModByName("SexLab.esm") != 255
  If(!slhere)
    MCM.bSLAllowed = false
  EndIf
  bool fghere = Game.GetModByName("FlowerGirls SE.esm") != 255
  If(!fghere)
    MCM.bFGAllowed = false
  EndIf
  bool ostimhere = Game.GetModByName("OStim.esp") != 255
  If(!ostimhere)
    MCM.bOStimAllowed = false
  EndIf
  ; Other Soft Integrations
  If(Game.GetModByName("SimpleSlavery.esp") == 255)
    MCM.cSimpleSlavery = 0
  EndIf
  ; Hostile Faction
  int i = Yam_FriendList.GetSize()
  While(i)
    i -= 1
    Faction tmpFac = Yam_FriendList.GetAt(i) as Faction
    tmpFac.SetAlly(Yam_FriendFaction, true, true)
  EndWhile
	;/ TODO Remove this /;
  If(Game.GetModByName("BaboInteractiveDia.esp") != 255)
    baboDia = (Game.GetFormFromFile(0xD58522, "BaboInteractiveDia.esp") as Faction)
  else
    baboDia = none
  EndIf
EndFunction


; ======================================================================
; ================================== CONSEQUENCES
; ======================================================================

; ================================= PLAYER
; ----------------- Aftermath
;/ TODO this is not setup to handle multiple outcomes /;
Function PlayerConsequence(int consequence)
  Debug.Trace("[Yamete] <Main> Received Event for Player; consequence: " + consequence)
  FadeToBlack.Apply()
  Utility.Wait(1.7)
  If(consequence < 0)
    ; Draw Event
    int[] weights = MCM.getAllConsequencesPl()
    int allCells = 0
    int i = 0
    While(i < weights.length - 1)
      allCells += weights[i]
      i += 1
    EndWhile
    If(allCells == 0)
      consequence = 1
    else
      int r = Utility.RandomInt(1, allCells)
      int w = 0
      i = 0
      While(w < r)
        w += weights[i]
        i += 1
      EndWhile
      consequence = i
      Debug.Trace("[Yamete] <Main> Draw consequence: " + consequence)
    EndIf
  EndIf
  ; Start Consequence
  If(consequence == 1)
    Utility.Wait(2)
    FadeToBlack.PopTo(FadeToBlackHold)
    leftForDead.Start()
  ElseIf(consequence == 2)
    SendModEvent("SSLV Entry")
  EndIf
EndFunction

; ----------------- Bleedout
int Function playerBleedout(int consequence)
  If(consequence < 0)
    ; Draw Event
    int[] weights = MCM.getBleedoutsPl(isImportant(PlayerRef))
    int allCells = 0
    int i = 0
    While(i < weights.length - 1)
      allCells += weights[i]
      i += 1
    EndWhile
    If(allCells == 0)
      consequence = 1
    else
      int r = Utility.RandomInt(1, allCells)
      int w = 0
      i = 0
      While(w < r)
        w += weights[i]
        i += 1
      EndWhile
      consequence = i
    EndIf
  EndIf
  ; Start Consequence
  Debug.Trace("[Yamete] <Main> Entering Player Bleedout - Type " + consequence)
  BleedOutEnter(PlayerRef, consequence)
  return consequence
EndFunction

; ================================== NPC
;/ Force this NPC into a Bleedout. Return the Bleedout Type:
1 - Regular, 2 - Withered, 3 - Death Sentence /;
int Function npcBleedout(Actor akVictim, int consequence)
  If(consequence < 0)
    bool important = isImportant(akVictim)
    ; Draw Event
    int[] weights = MCM.getBleedoutsNPC(important)
    int allCells = 0
    int i = 0
    While(i < weights.length)
      allCells += weights[i]
      i += 1
    EndWhile
    If(allCells == 0)
      consequence = 1
    else
      int c = Utility.RandomInt(1, allCells)
      int thatCell = 0
      i = 0
      While(thatCell < c)
        thatCell += weights[i]
        i += 1
      EndWhile
      consequence = i
    EndIf
  EndIf
  ; Start Consequence
  Debug.Trace("[Yamete] <Main> " + akVictim + " Entering Bleedout Type " + consequence)
  BleedOutEnter(akVictim, consequence)
  return consequence
EndFunction

; ======================================================================
; ================================== ANIMATIONS
; ======================================================================
Function BleedOutEnter(Actor me, int type)
  If(type == 0)
    bleedoutMarks[0].Cast(me, me)
    ; Debug.SendAnimationEvent(me, "BleedoutStart")
    ; return
  ElseIf(type > 0)
    me.AddSpell(bleedoutMarks[type])
    me.EvaluatePackage()
  EndIf
  Form device59 = me.GetWornForm(0x20000000)
  If(device59 != none)
    If(device59.HasKeyWordString("zbfAnimHandsArmbinder"))
      Debug.SendAnimationEvent(me, "ZapArmbBleedoutIdle")
    ElseIf(device59.HasKeyWordString("zbfAnimHandsYoke"))
      Debug.SendAnimationEvent(me, "ZapYokeBleedoutIdle")
    ElseIf(device59.HasKeyWordString("zbfAnimHandsWrists"))
      Debug.SendAnimationEvent(me, "ZapWriBleedoutIdle")
    else
      If(MCM.bCustomBleed)
        Debug.SendAnimationEvent(me, "YamBleedout"+Utility.RandomInt(0, 5))
      else
        Debug.SendAnimationEvent(me, "BleedoutStart")
      EndIf
    EndIf
  else
    If(MCM.bCustomBleed)
      Debug.SendAnimationEvent(me, "YamBleedout"+Utility.RandomInt(0, 5))
    else
      Debug.SendAnimationEvent(me, "BleedoutStart")
    EndIf
  EndIf
endFunction

Function BleedOutExit(Actor me, bool simple = false)
  If(simple && !me.HasMagicEffectWithKeyword(bleedoutMarkTemporary))
    return
  ElseIf(me.Is3DLoaded() || me == PlayerRef)
    Form device59 = me.GetWornForm(0x20000000)
    If(device59 != none)
      If(device59.HasKeyWordString("zbfAnimHandsArmbinder"))
        Debug.SendAnimationEvent(me, "ZazAPOA005")
      ElseIf(device59.HasKeyWordString("zbfAnimHandsYoke"))
        Debug.SendAnimationEvent(me, "ZazAPOA007")
      ElseIf(device59.HasKeyWordString("zbfAnimHandsWrists"))
        Debug.SendAnimationEvent(me, "ZazAPOA001")
      else
        If(MCM.bCustomBleed || !me.IsBleedingOut())
          Debug.SendAnimationEvent(me, "staggerStart")
        else
          Debug.SendAnimationEvent(me, "BleedoutStop")
        EndIf
      endIf
    else
      If(MCM.bCustomBleed || !me.IsBleedingOut())
        Debug.SendAnimationEvent(me, "staggerStart")
      else
        Debug.SendAnimationEvent(me, "BleedoutStop")
      EndIf
    EndIf
  EndIf
  int i = 0
  While(i < bleedoutMarks.length)
    me.RemoveSpell(bleedoutMarks[i])
    me.DispelSpell(bleedoutMarks[i])
    i += 1
  EndWhile
	If(!ScanQ.IsRunning() && !ResoQ.IsRunning())
		EquipCachedOutfit(me)
	EndIf
  me.EvaluatePackage()
endFunction

Function standUp(Actor me)
  If(me.Is3DLoaded() || me == PlayerRef)
    Form device59 = me.GetWornForm(0x20000000)
    If(device59 != none)
      If(device59.HasKeyWordString("zbfAnimHandsArmbinder"))
        Debug.SendAnimationEvent(me, "ZazAPOA005")
      ElseIf(device59.HasKeyWordString("zbfAnimHandsYoke"))
        Debug.SendAnimationEvent(me, "ZazAPOA007")
      ElseIf(device59.HasKeyWordString("zbfAnimHandsWrists"))
        Debug.SendAnimationEvent(me, "ZazAPOA001")
      else
        If(MCM.bCustomBleed || !me.IsBleedingOut())
          Debug.SendAnimationEvent(me, "staggerStart")
        else
          Debug.SendAnimationEvent(me, "BleedoutStop")
        EndIf
      endIf
    else
      If(MCM.bCustomBleed || !me.IsBleedingOut())
        Debug.SendAnimationEvent(me, "staggerStart")
      else
        Debug.SendAnimationEvent(me, "BleedoutStop")
      EndIf
    EndIf
    If(me == PlayerRef)
      Game.SetPlayerAIDriven(false)
    else
      me.SetRestrained(false)
    EndIf
    me.SetDontMove(false)
  EndIf
EndFunction

Function RemoveBleedoutMarks(Actor me)
  int i = 0
  While(i < bleedoutMarks.length)
    me.RemoveSpell(bleedoutMarks[i])
    me.DispelSpell(bleedoutMarks[i])
    i += 1
  EndWhile
  me.EvaluatePackage()
EndFunction

; ======================================================================
; ================================== UTILITY
; ======================================================================
;30 x00000001 ; HEAD
;31 x00000002 ; Hair
;32 x00000004 ; BODY
;33 x00000008 ; Hands
;34 x00000010 ; Forearms
;35 x00000020 ; Amulet
;36 x00000040 ; Ring
;37 x00000080 ; Feet
;38 x00000100 ; Calves
;39 x00000200 ; SHIELD
;40 x00000400 ; TAIL
;41 x00000800 ; LongHair
;42 x00001000 ; Circlet
;43 x00002000 ; Ears
;  /// Misc Slots ///
;44 x00004000 ; Unnamed (Face/Mouth)
;45 x00008000 ; Unnamed (Neck)
;46 x00010000 ; Unnamed (Chest)
;47 x00020000 ; Unnamed (Back)
;48 x00040000 ; Unnamed (Misc)
;49 x00080000 ; Unnamed (Pelvis)
;50 x00100000 ; DecapitateHead /// Reserved by Game
;51 x00200000 ; Decapitate     /// Reserved by Game
;52 x00400000 ; SOS*           /// Reserved by SOS
;53 x00800000 ; Unnamed (Legs, Right)
;54 x01000000 ; Unnamed (Legs, Left)
;55 x02000000 ; Unnamed (Face, Jewelry)
;56 x04000000 ; Unnamed (Chest / Under)
;57 x08000000 ; Unnamed (Shoulders)
;58 x10000000 ; Unnamed (Arms, Right / Under)
;59 x20000000 ; Unnamed (Arms, Left / Outer)
;60 x40000000 ; 3BA Bodies*
;61 x80000000 ; FX01*          /// Reserved by Game
Form[] Function getWornItems(Actor me)
  If(me.HasKeyword(ActorTypeNPC) == false)
    return PapyrusUtil.FormArray(0)
  EndIf
  Keyword DD = Keyword.GetKeyword("zad_lockable")
  Keyword Toys = Keyword.GetKeyword("ToysToy")
  int thisSlot = 0x01
  int i = 0
  While(i < MCM.bValidStrips.length)
    If(MCM.bValidStrips[i])
      Form wornForm = me.GetWornForm(thisSlot)
      If(wornForm && !wornForm.HasKeyword(DD) && !wornForm.HasKeyword(Toys))
        StorageUtil.FormListAdd(me, "YamWornForms", wornForm, false)
      EndIf
    EndIf
    thisSlot *= 2
    i += 1
  EndWhile
  Form[] ret = StorageUtil.FormListToArray(me, "YamWornForms")
  StorageUtil.FormListClear(me, "YamWornForms")
  return ret
EndFunction

;0 - Male, 1 - Female, 2 - Futa, 3 - Male Creature, 4 - Female Creature
int Function GetActorType(Actor me)
  If(MCM.bSLAllowed)
    return YamSexLab.getActorType(me)
  else
    If(me.HasKeyword(ActorTypeNPC))
      return me.GetLeveledActorBase().GetSex()
    else
      return 3
    EndIf
  EndIf
endFunction

; ollowerAttac[0] = "$Yam_folAttac_0" ; Nobody
; FollowerAttac[1] = "$Yam_folAttac_1" ; Anyone
; FollowerAttac[2] = "$Yam_folAttac_2" ; Only NPC

;	NPCAttac[0] = "$Yam_npcAttac_0" ; Nobody
;	NPCAttac[1] = "$Yam_NPCAttac_1" ; Anyone
;	NPCAttac[2] = "$Yam_npcAttac_2" ; Only NPC
;	NPCAttac[3] = "$Yam_npcAttac_3" ; Only Follower
;	NPCAttac[4] = "$Yam_npcAttac_4" ; Only Player
;	NPCAttac[5] = "$Yam_npcAttac_5" ; Only Player Team


bool Function isValidGenderCombination(Actor akVictim, Actor akAggressor)
  bool isFolA = akAggressor.IsInFaction(PlayerFollowerFaction) || akAggressor.IsPlayerTeammate()
  bool isFolV = akVictim.IsInFaction(PlayerFollowerFaction) || akVictim.IsPlayerTeammate()
  bool plVic = akVictim == PlayerRef
  If (isFolA && (MCM.iFolAttac == 0 || MCM.iFolAttac == 2 && isFolV))
    return false
  ElseIf (!isFolA && MCM.iNPCAttac != 1)
    If (MCM.iNPCAttac == 0)
      return false
    ElseIf (plVic)
      If (MCM.iNPCAttac < 4)
        return false
      EndIf
    ElseIf (isFolV && MCM.iNPCAttac != 3 && MCM.iNPCAttac != 5 || !isFolV && MCM.iNPCAttac != 2)
      return false
    EndIf
  EndIf
	int agrGender = GetActorType(akAggressor)
  If(!plVic)
    int vicGender = GetActorType(akVictim)
		If(isFolV)
			return MCM.bAssaultFol[vicGender * 5 + agrGender]
		else ; Victim NPC
			return MCM.bAssaultNPC[vicGender * 5 + agrGender]
		EndIf
  else
    return MCM.bAssaultPl[agrGender] && (!akAggressor.IsInFaction(PlayerFollowerFaction) && !akAggressor.IsPlayerTeammate())
  EndIf
EndFunction

bool Function isValidCreature(Actor me)
  If(MCM.iCrtFilterMethod == 0 || me.HasKeyword(ActorTypeNPC)) ; Any or NPC
    return true
  ElseIf(MCM.iCrtFilterMethod == 1) ; None
    return false
  EndIf
  bool allow = false
	Race myRace = me.GetRace()
  int myPlace = raceList.Find(myRace)
  If(myPlace < 0)
    Debug.Trace("[Yamete] isValidCreature() -> Race " + myRace + " returned outside the Valid Range: " + myPlace)
  Else
    If(myPlace > 51)
      If(myPlace == 81 || myPlace == 82) ; Bear
        myPlace = 2
      ElseIf(myPlace == 80) ; Chaurus
        myPlace = 5
      ElseIf(myPlace == 79) ; Death Hound
        myPlace = 10
      ElseIf(myPlace == 78) ; Deer
        myPlace = 11
      ElseIf(myPlace <= 77 && myPlace > 71) ; Dog
        myPlace = 12
      ElseIf(myPlace <= 71 && myPlace > 68) ; Dragon
        myPlace = 13
      Elseif(myPlace == 68 || myPlace == 67) ; Draugr
        myPlace = 15
      ElseIf(myPlace == 66) ; Falmer
        myPlace = 20
      ElseIf(myPlace == 65 || myPlace == 64) ; Gargoyles
        myPlace = 24
      ElseIf(myPlace == 63) ; Giant
        myPlace = 25
      ElseIf(myPlace == 62) ; Horse
        myPlace = 29
      ElseIf(myPlace == 61) ; Netch
        myPlace = 34
      ElseIf(myPlace == 60) ; Riekling
        myPlace = 36
      ElseIf(myPlace == 59 || myPlace == 58) ; Sabre Cat
        myPlace = 37
      ElseIf(myPlace == 57) ; Storm Atronach
        myPlace = 45
      ElseIf(myPlace <= 56 && myPlace > 53) ; Spriggan
        myPlace = 44
      ElseIf(myPlace == 53) ; Troll
        myPlace = 46
      ElseIf(myPlace == 52) ; Werewolf
        myPlace = 49
      else
        Debug.Trace("[Yamete] isValidCreature() -> Race " + myRace + " returned outside the Valid Range: " + myPlace)
      EndIf
    EndIf
    allow = MCM.bValidRace[myPlace]
  EndIf
  If(MCM.iCrtFilterMethod == 2) ; Use List
    return allow
  else ; Use List Reverse
    return !allow
  EndIf
EndFunction

bool Function isImportant(Actor akActor)
  If(akActor == PlayerRef)
    return akActor.GetActorBase().IsEssential()
  ElseIf((akActor.IsInFaction(PlayerFollowerFaction) || akActor.IsPlayerTeammate()) && MCM.bImportantFollowers)
    return true
  EndIf
  ActorBase baseActor = akActor.GetLeveledActorBase()
  If(MCM.iImportance == 0)
    return (baseActor.IsEssential() || baseActor.IsInvulnerable())
  ElseIf(MCM.iImportance == 1)
    return (baseActor.IsEssential() || baseActor.IsProtected()  || baseActor.IsInvulnerable())
  Else
    return (baseActor.IsEssential() || baseActor.IsProtected()  || baseActor.IsInvulnerable() || baseActor.IsUnique())
  EndIf
EndFunction

; ======================= UTILITY // VOID
Function HealActor(Actor target)
  Float BaseValue = target.GetBaseActorValue("Health")
  Float CurrentMaxValue = Math.Ceiling(target.GetActorValue("Health") / target.GetActorValuePercentage("Health"))
  if BaseValue < CurrentMaxValue
    target.RestoreActorValue("Health", (BaseValue * MCM.fRushedHeal))
  else
    target.RestoreActorValue("Health", (CurrentMaxValue * MCM.fRushedHeal))
  endif
EndFunction

;/ FIXME /;
Function playKillmove(Actor killer, Actor victim)
  int toPlay = killer.GetEquippedItemType(1)
  If(killer == Game.GetPlayer())
    Game.SetPlayerAIDriven(true)
  EndIf
  If(toPlay == 0 || toPlay > 6)
    killer.EquipItem(SteelDagger)
    toPlay = 2
  EndIf
  killer.MoveTo(victim, 30 * Math.cos(victim.GetAngleZ()), 50 * Math.sin(victim.GetAngleZ()), 0.0)
  Utility.Wait(0.65)
  If(toPlay == 2) ; Dagger
    If(killer.PlayIdleWithTarget(killMoves[0], victim))
      victim.Kill(killer)
    EndIf
  ElseIf(toPlay < 5) ; Onehand
    If(killer.PlayIdleWithTarget(killMoves[1], victim))
      victim.Kill(killer)
    EndIf
  Else ; Zweihand
    If(killer.PlayIdleWithTarget(killMoves[2], victim))
      victim.Kill(killer)
    EndIf
  EndIf
  If(killer == Game.GetPlayer())
    Game.SetPlayerAIDriven(false)
  EndIf
EndFunction
; ======================================================================
; ================================== GENERIC RESOLUTION
; ======================================================================
; 0 - Invalid, 1 - Robbed, 2 - Raped
int Function getResolutionAction(Actor victoire, Actor victim)
  int[] actions = MCM.getAllResActions()
  bool npcV = victim.HasKeyword(ActorTypeNPC)
  bool npcW = victoire.HasKeyword(ActorTypeNPC)
  If(!npcV || !npcW)
    ; Creatures cant rob - or engage in adult Scenes (unless SL is allowed)
    If(MCM.FrameCreature == false)
      Debug.Trace("[Yamete] getResolutionAction() Contains Creatures but no Creature Compatible Frame allowed, setting A1 to 0")
      actions[1] = 0
    else
      If(!isValidCreature(victoire) || !isValidCreature(victim))
        actions[1] = 0
      EndIf
    EndIf
    actions[0] = 0
  ElseIf(MCM.bOnlyBanditsRob)
    int i = 0
    bool isBandit = false
    While(i < BanditFactions.length && isBandit == false)
      If(victoire.IsInFaction(BanditFactions[i]))
        isBandit = true
      EndIf
      i += 1
    EndWhile
    If(isBandit == false)
      actions[0] = 0
    EndIf
  EndIf
  If(actions[1] != 0)
		bool aroused = true
		If(MCM.bSLAllowed)
			bool isFol = victoire.IsInFaction(PlayerFollowerFaction) || victoire.IsPlayerTeammate()
			int ar = YamSexLab.GetArousal(victoire)
			aroused = ar >= MCM.iSLArousalThresh && (!isFol || MCM.iSLArousalFollower == 0) || isFol && ar >= MCM.iSLArousalFollower
		EndIf
    If(!isValidGenderCombination(victim, victoire) || !aroused)
      actions[1] = 0
    EndIf
  EndIf
  int allChambers = 0
  int i = 0
  While(i < actions.length)
    allChambers += actions[i]
    i += 1
  EndWhile
  If(allChambers == 0)
    Debug.Trace("[Yamete] getResolutionAction() -> Sum of Chambers is 0")
    return 0
  else
    int draw = Utility.RandomInt(1, allChambers)
    int n = 0
    int chamber = 0
    While(chamber < draw)
      chamber += actions[n]
      n += 1
    EndWhile
		Debug.Trace("[Yamete] getResolutionAction() -> returning " + n)
		return n
  EndIf
EndFunction

Function RemoveItemsFromTo(ObjectReference victim, Actor robber)
	Debug.Trace("[Yamete] RemoveItemsFromTo() -> victim: " + victim + "; robber: " + robber)
	; Debug.Notification(vic + " is being robbed by " + rob)
  If(victim.GetDistance(robber) > 200)
    robber.MoveTo(victim, 120 * Math.cos(victim.Z), 120 * Math.sin(victim.Z), 0.0, false)
    robber.SetAngle(victim.GetAngleX(), victim.GetAngleY(), (victim.GetAngleZ() + victim.GetHeadingAngle(robber) - 180))
  EndIf
  If(robber.PlayIdle(StealingIdle))
    Utility.Wait(1.5)
  EndIf
  ; 0 - Everything, 1 - by Value, 2 - Random
  Form[] items = PO3_SKSEFunctions.AddAllItemsToArray(victim, !MCM.bResRWorn, false, !MCM.bResRQstItm)
  int i = items.length
  If(MCM.iResRType == 0)
    While(i > 0)
      i -= 1
      victim.RemoveItem(items[i], victim.GetItemCount(items[i]), true, robber)
    EndWhile
  ElseIf(MCM.iResRType == 1)
    While(i > 0)
      i -= 1
      If(items[i].GetGoldValue() < MCM.iResRItmVal)
        victim.RemoveItem(items[i], victim.GetItemCount(items[i]), true, robber)
      EndIf
    EndWhile
  ElseIf(MCM.iResRType == 2)
    While(i > 0)
      i -= 1
      If(Utility.RandomInt(0, 99) < MCM.iResRStealChance)
        victim.RemoveItem(items[i], victim.GetItemCount(items[i]), true, robber)
      EndIf
    EndWhile
  EndIf
	If(MCM.bShowNotifySteal)
		string first = (victim as Actor).GetLeveledActorBase().GetName()
		string second = robber.GetLeveledActorBase().GetName()
		If(MCM.bShowNotifyColor)
			Debug.Notification("<font color='" + MCM.sNotifyColor + "'>" + first + " had their Items stolen by " + second)
		else
			Debug.Notification(first + " had their Items stolen by " + second)
		EndIf
	EndIf
EndFunction

; Assume this to be called after getResolutionAction and thus Actors are already validated
bool Function CreateEndlessScene(Actor sub, Actor dom)
  return EndlessSceneKW.SendStoryEventAndWait(none, sub, dom)
EndFunction

; ======================================================================
; ================================== INTERNALS
; ======================================================================
Event OnKeyDown(int KeyCode)
	If(Utility.IsInMenuMode() || !Game.IsLookingControlsEnabled() || UI.IsMenuOpen("Dialogue Menu"))
		return
	EndIf
  If(KeyCode == MCM.iPlAggrKey)
    ; Manage Aura
    If(PlayerRef.HasSpell(ReapersMercy))
      PlayerRef.RemoveSpell(ReapersMercy)
      Debug.Notification("Reapers Mercy removed")
    else
      PlayerRef.AddSpell(ReapersMercy)
    EndIf
  ElseIf(KeyCode == MCM.iPauseKey)
    MCM.bModPaused = !MCM.bModPaused
    If(MCM.bModPaused == true)
      Debug.Notification("Yamete! paused")
      If(ScanQ.IsRunning())
        ScanQ.SetStage(999)
      EndIf
    else
      Debug.Notification("Yamete! unpaused")
    EndIf
  EndIf
EndEvent

; ======================================================================
; ================================== EVENTS
; ======================================================================
Event Yam_ConsequencePlayer(int type)
  Debug.Trace("[Yamete] Received Consequence Event for Player; overwrite: " + type)
  PlayerConsequence(type)
EndEvent

Event Yam_BleedoutPlayer(int type)
  Debug.Trace("[Yamete] Received Bleedout Event for Player; overwrite: " + type)
  playerBleedout(type)
EndEvent

Event Yam_BleedoutNPC(Form victim, int overwrite)
  Debug.Trace("[Yamete] Received Event for NPC; overwrite: " + overwrite)
  Actor akVictim = victim as Actor
  If(akVictim == none)
    Debug.Trace("[Yamete] ConsequenceNPC received invalid victim Argument")
    return
  EndIf
  NPCBleedout(akVictim, overwrite)
EndEvent

Event Yam_Pause(string eventName, string strArg, float numArg, Form sender)
  ModPaused = true
  If(ScanQ.IsRunning())
    ScanQ.SetStage(999)
  EndIf
  UnregisterForUpdate()
EndEvent

Event Yam_Resume(string eventName, string strArg, float numArg, Form sender)
  ModPaused = false
EndEvent
