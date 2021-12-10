;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 12
Scriptname SF_YamSurrenderScene_05A184D5 Extends Scene Hidden

;BEGIN FRAGMENT Fragment_7
Function Fragment_7()
;BEGIN CODE
; Debug.Trace("[Yamete] Surrender: Phase 3 start")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
; Phase 3 (after Dialogue), end
; If Quest isnt at least Stage 75 here, initiate Combat
; Stage100 flags the Surrender as successfull; Stage 75 starts an Adult Scene
; The Quest being set to either of those means the negotiations failed
Debug.Trace("[Yamete] Surrender: Phase 3 end")
If(GetOwningQuest().GetStage() < 75)
  Debug.Trace("[Yamete] Surrender: Phase 3 Starting Combat")
  Actor en = EnemyNPC.GetActorReference()
  en.StartCombat(Game.GetPlayer())
  en.SetPlayerResistingArrest()
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
; Phase 1 end
; Debug.Trace("[Yamete] Surrender: Phase 1 End")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
; Scene Start
; Debug.Trace("[Yamete] Surrender: Scene Start")
SetUp()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
; Debug.Trace("[Yamete] Surrender: Phase 2 start")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_10
Function Fragment_10()
;BEGIN CODE
; Debug.Trace("[Yamete] Surrender: Phase 5 end")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN CODE
; Debug.Trace("[Yamete] Surrender: Phase 4 start")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
; Debug.Trace("[Yamete] Surrender: Phase 2 end")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN CODE
; Scene End
; Reapply the cooldown. Depending on the paths the player took the 3min may already be over
Debug.Trace("[Yamete] Surrender: Scene End")
int j = 0
While(j < Enemies.Length)
  ObjectReference tmp = Enemies[j].GetReference()
  If(tmp)
    CooldownSpell.Cast(tmp)
  EndIf
  j += 1
EndWhile

; ; And remove the Calm Mark
int n = 0
Game.GetPlayer().RemoveSpell(CalmMark)
While(n < Enemies.Length)
  Actor tmp = Enemies[n].GetReference() as Actor
  If(tmp)
    tmp.RemoveSpell(CalmMark)
  EndIf
  n += 1
EndWhile
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_9
Function Fragment_9()
;BEGIN CODE
; Debug.Trace("[Yamete] Surrender: Phase 4 end")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_11
Function Fragment_11()
;BEGIN CODE
; Debug.Trace("[Yamete] Surrender: Phase 5 start")
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment


YamMain Property Main Auto
YamMCM Property MCM Auto
Quest Property Scan Auto
ReferenceAlias[] Property Enemies Auto
ReferenceAlias Property EnemyNPC Auto
ReferenceAlias Property Observer Auto
ReferenceAlias Property Bystander Auto
Keyword Property ActorTypeNPC Auto
Spell Property CooldownSpell Auto
Spell Property CalmMark Auto
Race Property ElderRace Auto
Keyword Property BleedoutMark Auto
Message Property Error3PartySurrender Auto
Message Property ErrorPlayerBleedout Auto
Message Property CreatureSurrenderIgnore Auto
Message Property CreatureSurrenderAccept Auto
;/ ===============================
  Setup sorts and analyzes the Actors for the Surrender Feature
  The Player can only surrender once to a single Actor every 3 Minutes. A spell (dur 3min) is cast on all Victoires, marking Actors as invalid
  The Quest will not start if no enemy is found that is: In combat, hostile towards the Player and not affected by above spell

  The Quest offers the following Aliases:
    - The Player
    - 2 Followers
    - A group of up to 6 Aliases taking on the Role of the Victoires. Those are hostile towards the Player
    - If one of this groups Team is an NPC, 1 additional NPC Alias. This one may or may not be included in the 6 Aliases above
    - A control group consisting of a single Alias to check if there is a 3rd Party involved in this fight

  SetUp() has the following functionality:
    - Check if the Player can surrender. A surrender is only valid if..
      - there are more than 2 parties fighting (<=> control alias isnt empty)
    - check for a Guard in Combat with the Player. If so, the Guard will take over the Surrender and attempt an arrest
=============================== /;
Function Setup()
  Actor PlayerRef = Game.GetPlayer()
  If(Bystander.GetReference())
    ; Nothing to do if there are 3 parties in a fight
    Error3PartySurrender.Show()
    Debug.Trace("[Yamete] Surrender: Invalid Surrender Request, more than 2 Parties involved.")
    Stop()
    return
  ElseIf(PlayerRef.HasMagicEffectWithKeyword(BleedoutMark) || PlayerRef.IsBleedingOut())
    ErrorPlayerBleedout.Show()
    Debug.Trace("[Yamete] Surrender: Invalid Surrender Request, Player is bleeding out.")
    Stop()
    return
  EndIf

  ; Analyze the Quest Aliases..
  YamSurrender sur = GetOwningQuest() as YamSurrender
  Actor[] every = new Actor[6]
  Race match = none
  Actor npc = none
  bool npcChild
  float npcConfi
  int i = 0
  While(i < Enemies.Length)
    Actor act = Enemies[i].GetReference() as Actor
    If(act)
      If(act.HasKeyword(ActorTypeNPC))
        ;/ -------------------------
          NPC Encounters are controlled through Dialogue
          This part here will..
          • look for a fitting NPC to do the greeting 
          • collect all NPC and hand them over the quest Script in case of an Adult Scene
          • define all Quest Variables used inside the Dialogue
        ------------------------- /;
        If(act.IsGuard())
          ; If this NPC is a Guard, cancel the Loop and hook into Vanilla Crime System..
          Debug.Trace("[Yamete] Surrender: Found Guard among Enemies")
          Faction cf = act.GetCrimeFaction()
          If(cf.GetCrimeGold() < 100)
            cf.ModCrimeGold(100)
          EndIf
          EnemyNPC.ForceRefTo(act)
          GetOwningQuest().SetStage(5)
          return
        Else
          bool child = act.isChild()
          bool elder = act.GetRace() == ElderRace
          If(!npc)
            ; if this is the first NPC found, have them take the lead
            ; also clear all previous actors in the array. Theyre creatures
            Debug.Trace("[Yamete] Surrender: Found First NPC Enemy at " + i)
            int ii = 0
            While(ii < i)
              every[ii] = none
              ii += 1
            EndWhile
            npc = act
            npcChild = child || elder
            If(!child && (MCM.bElderAggr || !elder))
              every[i] = act
              npcConfi = npc.GetActorValue("Confidence")
            EndIf
          Else
            ; .. else check if this new actor is better suited the the job
            ; preferring: High Confidence > Low Confidence > Elder > Childs              
            If(npcChild)
              ; If the current NPC is a Child or ELder, skip confidence Check
              If(!child)
                ; Only care if this isnt a child. The current npc is already a child or elder
                If(!elder)
                  ; this npc is neither child nor elder, prefer them over the other
                  npc = act
                  npcChild = false
                  npcConfi = npc.GetActorValue("Confidence")
                Else
                  ; this npc is an elder. Just replace the previous one ..
                  npc = act
                EndIf
              EndIf
            ElseIf(!child && !elder)
              ; we only want npc here that are neihter child nor elder
              every[i] = act
              float confi = act.GetActorValue("Confidence")
              If(confi > npcConfi)
                ; if this NPCs confidence is higher than the previous one, replace the old one with the new one
                npc = act
                npcConfi = confi
              EndIf
            EndIf
          EndIf
        EndIf
      ElseIf(!npc && MCM.FrameCreature && Main.isValidCreature(act)) 
        ; Creatures, skip them if a NPC has been found already and only if we allow Creature Scenes
        ; (The individual creature enemies only matter for adult scenes)
        Race actRace = act.GetRace()
        If(!match) ; define matching Race
          every[i] = act
          match = actRace
        ElseIf(actRace == match)
          ; only allow creatures of same Races (adult scene stuff)
          every[i] = act
        EndIf
      EndIf
    EndIf
    i += 1
  EndWhile
  ;/ -------------------------
    Processed all Enemies here
    Every collects all Actors for an adult Animations
    • every.Length = 0 and no npc -> Creature Encounter
    • every.Length = 0 and npc found -> child or elder encounter
    • every.Length > 0 and no npc -> Creature Encounter with potential adult content
    • every.Length > 0 and npc -> npc encounter with potential adult content
  ------------------------- /;
  every = PapyrusUtil.RemoveActor(every, none)
  Debug.Trace("[Yamete] Surrender: Total Actors found = " + every.Length)
  sur.Enemies = every
  ; If(every.Length == 0 && !npc)
  ;   Stop()
  ;   return
  ; Else
  ;   sur.Enemies = every
  ; EndIf
  ; Have the Player surrender
  Game.SetPlayerAIDriven(true)
  Debug.SendAnimationEvent(PlayerRef, "IdleSurrender")
  ; Stop Combat Quest if running
  Scan.SetStage(999)
  ; Cooldown, so the player can't surrender to them again within 3minutes
  ; ..also Calm Mark to stop & prevent combat during negotiation
  int n = 0
  PlayerRef.AddSpell(CalmMark, false)
  While(n < Enemies.Length)
    Actor act = Enemies[n].GetReference() as Actor
    If(act)
      act.AddSpell(CalmMark, false)
      CooldownSpell.Cast(act)
    EndIf
    n += 1
  EndWhile
  ; Creature or NPC Consequence?
  If(!npc)
    ;/ -------------------------
      Creatures will either..
      • accept the surrender & move on,
      • create an assault, or
      • ignore the surrender
    ------------------------- /;
    If(Utility.RandomInt(0, 99) < 10) ; -- Accept & Move On
      Debug.Trace("[Yamete] Surrender: Creature Accepts")
      CreatureSurrenderAccept.Show()
      GetOwningQuest().SetStage(100)
    ElseIf(MCM.FrameCreature) ; ---------- Assault
      Debug.Trace("[Yamete] Surrender: Creature Assaults")
      sur.StartScene()
    Else ; ------------------------------- Ignore
      Debug.Trace("[Yamete] Surrender: Creature Ignores")
      CreatureSurrenderIgnore.Show()
    EndIf
  Else
    ; Create the NPC alias
    EnemyNPC.ForceRefTo(npc)
    npc.EvaluatePackage()
    ; Set the Dialogue Flags..
    sur.allowAdult = MCM.FrameAny && every.Length
    sur.numVictoire = every.Length
    sur.victoireGen = Main.GetActorType(npc)
    sur.KnowsAbout = StorageUtil.GetIntValue(npc, "YamKnowsAbout")
    sur.isAlone = Observer.GetReference() == none
    sur.isOutlaw = npc.GetCrimeFaction() == none
    ; checking for the crime faction will cover all (or most?) enemy factions
    ; there are some false positives with this (like modded followers) but should overall be more precise than checking for individual factions (e.g. forsworn & banditfaction) as it should also recognize enemy factions added by other mods. All folk living in cities usually have their holds crime faction assigned to them, or have a custom one (e.g. guilds)
    sur.isNude = PlayerRef.GetWornForm(4) == none
  EndIf
  Debug.Trace("[Yamete] Surrender: Completed Setup, Setting Stage 5")
  GetOwningQuest().SetStage(5)
  Utility.Wait(2)
  Game.SetPlayerAIDriven(false)
EndFunction

