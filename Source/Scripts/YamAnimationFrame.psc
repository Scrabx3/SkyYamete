Scriptname YamAnimationFrame Hidden


; ======================================================================
; ================================== UTILITY
; ======================================================================
bool Function SLThere() global
  return Game.GetModByName("SexLab.esm") != 255
EndFunction

bool Function FGThere() global
  return Game.GetModByName("FlowerGirls SE.esm") != 255
EndFunction

bool Function OStimThere() global
  return Game.GetModByName("OStim.esp") != 255
EndFunction

;/ Takes the Number of potential users in an Animation and returns
the Number of Actors that should participate in it based on MCM Settings /;
int Function calcThreesome(YamMCM MCM, int cap) global
  If(cap == 2)
    Debug.Trace("[Yamete] Calc Threesome; Cap: " + cap + "; return: 2")
    return 2
  EndIf
  int[] weights = MCM.getXsomeWeight()
  int allCells = 0
  int i = 0
  While(i < weights.length && i < cap)
    allCells += weights[i]
    i += 1
  EndWhile
  int thisCell = Utility.RandomInt(1, allCells)
  int sol = 0
  i = 0
  While(sol < thisCell)
    sol += weights[i]
    i += 1
  EndWhile
  i += 1 ; Return number of partners not chamber. (1st Chamber <=> 2some, 2nd chamber <=> 3some, ...)
  Debug.Trace("[Yamete] Calc Threesome; Cap: " + cap + "; return: " + i)
  return i
EndFunction

bool Function hasCreaturesSingle(Actor one, Actor two) global
  Keyword ActorTypeNPC = Keyword.GetKeyword("ActorTypeNPC")
  return one.HasKeyword(ActorTypeNPC) || two.HasKeyword(ActorTypeNPC)
EndFunction

bool Function hasCreaturesArray(Actor one, Actor[] two) global
  Keyword ActorTypeNPC = Keyword.GetKeyword("ActorTypeNPC")
  bool sol = !one.HasKeyword(ActorTypeNPC)
  int i = 0
  While(i < two.length && sol == false)
    If(two[i].HasKeyword(ActorTypeNPC) == false)
      sol = true
    EndIf
    i += 1
  EndWhile
  return sol
EndFunction

; ======================================================================
; ================================== START SCENE FUNCTIONS
; ======================================================================
;/ NOTE
@params
• asVictim -> 0 - no victim; 1 - victim as victim; 2 - first actor in array as victim

@returns
• -1 -> No animation
• 0 ~ 14 -> SexLab
• 15 -> Flowergirls
• 16 -> OStim, Mainthread
/;
; =========================================================== GENERIC
int Function StartAnimationWithPlayer(YamMCM MCM, Actor other, int asVictim = 1) global
  Actor[] others = PapyrusUtil.ActorArray(1, other)
  Actor PlayerRef = Game.GetPlayer()
  return StartAnimation(MCM, PlayerRef, others, asVictim = asVictim)
EndFunction

int Function StartAnimation(YamMCM MCM, Actor victim, Actor[] partners, Form source = none, int asVictim = 1, String hook = "") global
  If(!MCM.bSLScenes)
    Debug.Notification("Imagine a Scene to start here")
    return -1
  EndIf
  int sol = -1
  If(hasCreaturesArray(victim, partners))
		If(MCM.bSLAllowed)
			sol = YamSexLab.StartAnimation(MCM, victim, partners, asVictim, hook)
		EndIf
    ; startAnimationCreature(MCM, victim, partners, asVictim, hook)
  else
    int[] frames = MCM.getFrameWeights()
    int repeats = 0
    While(repeats < 3 && sol == -1)
      int chamber0 = frames[0]
      int chamber1 = chamber0 + frames[1]
      int chamber2 = chamber1 + frames[2]
      If(chamber2 == 0)
        return -1
      else
        int nextChamber = Utility.RandomInt(0, chamber2)
        If(nextChamber < chamber0) ; OStim
          If(YamOStim.StartScene(MCM, victim, partners, asVictim))
            If(source)
              source.RegisterForModEvent("ostim_end", "OStimEnd")
            EndIf
            sol = 16
          Else
            frames[0] = 0
            repeats += 1
          EndIf
        ElseIf(nextChamber < chamber1) ; FG
          If(YamFlowerGirls.StartSceneForm(victim, partners, source))
            ; Register Event in YamFlowerGirls since this Script has no access to the FG Quests..
            sol = 15
          else
            frames[1] = 0
            repeats += 1
          EndIf
        Else ; SL
          int tmp = YamSexLab.StartAnimation(MCM, victim, partners, asVictim, hook)
          If(tmp == -1)
            frames[2] = 0
            repeats += 1
          else
            ; Register for SL Events in the calling Script, doesnt work otherwise..
            sol = tmp
          EndIf
        EndIf
      EndIf
    EndWhile
  EndIf
  If(sol != -1 && MCM.bNotifyAF)
    String vicName = victim.GetLeveledActorBase().GetName()
    String otherName = partners[0].GetLeveledActorBase().GetName()
    If(MCM.bNotifyColorAF)
      Debug.Notification("<font color='" + MCM.sNotifyColorAF + "'>" + vicName + " is being assaulted by " + otherName + "</font>")
    else
      Debug.Notification(vicName + " is being assaulted by " + otherName + "</font>")
    EndIf
  EndIf
  return sol
EndFunction

; =========================================================== RUSHED
int Function StartSceneRushed(YamMCM MCM, ReferenceAlias source, Actor[] partners) global
  If(!MCM.bSLScenes)
    Debug.Notification("Imagine a Scene to start here")
    return -1
  EndIf
  Actor victim = source.GetReference() as Actor
  If(!victim)
    Debug.Trace("[Yamete] startSceneRushed() received invalid Victim")
    return -1
  EndIf
  int sol = -1
  If(hasCreaturesArray(victim, partners))
		If(MCM.bSLAllowed)
    	sol = YamSexLab.StartAnimation(MCM, victim, partners, 1, source.GetName())
		EndIf
  else
    int[] frames = MCM.getFrameWeights()
    int repeats = 0
    While(repeats < 3 && sol == -1)
      int chamber0 = frames[0]
      int chamber1 = chamber0 + frames[1]
      int chamber2 = chamber1 + frames[2]
      If(chamber2 == 0)
        return -1
      else
        int nextChamber = Utility.RandomInt(0, chamber2)
        If(nextChamber < chamber0) ; OStim
          If(YamOStim.StartScene(MCM, victim, partners, 1))
            source.RegisterForModEvent("ostim_end", "OStimEnd")
            sol = 16
          Else
            frames[0] = 0
            repeats += 1
          EndIf
        ElseIf(nextChamber < chamber1) ; FG
          If(YamFlowerGirls.StartSceneAlias(victim, partners, source))
            ; Register Event in YamFlowerGirls since this Script has no access to the FG Quests..
            sol = 15
          else
            frames[1] = 0
            repeats += 1
          EndIf
        Else ; SL
          int tmp = YamSexLab.StartAnimation(MCM, victim, partners, 1, source.GetName())
          If(tmp == -1)
            frames[2] = 0
            repeats += 1
          else
            ; Register for SL Events in the calling Script, doesnt work otherwise..
            sol = tmp
          EndIf
        EndIf
      EndIf
    EndWhile
  EndIf
  If(sol != -1 && MCM.bNotifyAF)
    String vicName = victim.GetLeveledActorBase().GetName()
    String otherName = partners[0].GetLeveledActorBase().GetName()
    If(MCM.bNotifyColorAF)
      Debug.Notification("<font color='" + MCM.sNotifyColorAF + "'>" + vicName + " is being assaulted by " + otherName + "</font>")
    else
      Debug.Notification(vicName + " is being assaulted by " + otherName + "</font>")
    EndIf
  EndIf
  return sol
EndFunction

; =========================================================== SURRENDER
int Function StartSceneSurrender(YamMCM MCM, Actor[] positions, Actor victim, String tags, Form source) global
  If(!MCM.bSLScenes)
    Debug.Notification("Imagine a Scene to start here")
    return -1
  EndIf
  int sol = -1
  If(!positions[1].HasKeyword(Keyword.GetKeyword("ActorTypeNPC")))
    sol = YamSexLab.StartAnimationCustom(positions, victim, tags, "YamSurrender")
  Else
    int[] frames = MCM.getFrameWeights()
    int repeats = 0
    While(repeats < 3 && sol == -1)
      int chamber0 = frames[0]
      int chamber1 = chamber0 + frames[1]
      int chamber2 = chamber1 + frames[2]
      If(chamber2 == 0)
        return -1
      else
        int nextChamber = Utility.RandomInt(0, chamber2)
        If(nextChamber < chamber0) ; OStim
          If(YamOStim.StartSceneCustom(positions, victim != none))
            If(source)
              source.RegisterForModEvent("ostim_end", "OStimEnd")
            EndIf
            sol = 16
          Else
            frames[0] = 0
            repeats += 1
          EndIf
        ElseIf(nextChamber < chamber1) ; FG
          victim = positions[0]
          Actor[] partners = new Actor[2]
          partners[0] = positions[1]
          partners[1] = positions[2]
          If(YamFlowerGirls.StartSceneForm(victim, partners, source))
            ; Register Event in YamFlowerGirls since this Script has no access to the FG Quests..
            sol = 15
          else
            frames[1] = 0
            repeats += 1
          EndIf
        Else ; SL
          int tmp = YamSexLab.StartAnimationCustom(positions, victim, tags, "YamSurrender")
          If(tmp == -1)
            frames[2] = 0
            repeats += 1
          else
            ; Register for SL Events in the calling Script, doesnt work otherwise..
            sol = tmp
          EndIf
        EndIf
      EndIf
    EndWhile
  EndIf
  return sol
EndFunction
