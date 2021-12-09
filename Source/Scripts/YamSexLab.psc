Scriptname YamSexLab Hidden
{Global Script to control Yamete - SexLab Interactions}


; Return the Actor Type based on SL's own Gender Definition
;0 - Male, 1 - Female, 2 - Futa, 3 - Male Creature, 4 - Female Creature
int Function getActorType(Actor me) Global
  SexLabFramework SL = Quest.GetQuest("SexLabQuestFramework") as SexLabFramework
  int mySLGender = SL.GetGender(me)
  If(mySLGender == 3) ;Female Creature
    return 4
  ElseIf(mySLGender == 2) ;Male Creature
    return 3
  Else ;Humanoid
    int myVanillaGender = me.GetLeveledActorBase().GetSex()
    If(myVanillaGender == mySLGender) ;Either male or female
      return myVanillaGender
    Else ;Futa
      return 2
    EndIf
  EndIf
EndFunction

bool Function validateActor(Actor me) Global
  SexLabFramework SL = Quest.GetQuest("SexLabQuestFramework") as SexLabFramework
  return SL.IsValidActor(me)
EndFunction

bool Function ValidateActorArray(Actor[] meR) Global
  SexLabFramework SL = Quest.GetQuest("SexLabQuestFramework") as SexLabFramework
  int i = 0
  While(i < meR.length)
    If(SL.IsValidActor(meR[i]) == false)
      return false
    EndIf
    i += 1
  EndWhile
  return true
EndFunction

int Function GetArousal(Actor t) global
	return (Quest.GetQuest("sla_Framework") as slaFrameworkScr).GetActorArousal(t)
EndFunction

;/ Stops the Animation this Actor is particiapting in /;
int Function stopAnimation(Actor that) Global
  SexLabFramework SL = Quest.GetQuest("SexLabQuestFramework") as SexLabFramework
  int sol = SL.FindActorController(that)
  If(sol != -1)
    SL.GetController(sol).EndAnimation()
  EndIf
  return sol
EndFunction

; ======================================================================
; ================================== ANIMATION
; ======================================================================
; Start an SexLab Animation with the specified Actors using the Settings in Yametes MCM
; Return true if an Animation started, otherwise false
int Function StartAnimation(YamMCM MCM, Actor first, Actor[] others, int asVictim, string hook = "") Global
  SexLabFramework SL = Quest.GetQuest("SexLabQuestFramework") as SexLabFramework
  If(SL.Enabled == false)
    return -1
  ElseIf(SL.IsValidActor(first) == false)
    return -1
  ELse
    int i = 0
    While(i < others.length)
      If(SL.IsValidActor(others[i]) == false)
        return -1
      EndIf
      i += 1
    EndWhile
  EndIf
  Actor victim = none
  If(MCM.bSLAsVictim)
    If(asVictim == 1)
      victim = first
    ElseIf(asVictim == 2)
      victim = others[0]
    EndIf
  EndIf

  others = SL.SortActors(PapyrusUtil.PushActor(others, first))
  int[] g = Utility.CreateIntArray(others.Length)
  g[0] = SL.GetGender(others[0])
  int i = 1
  While(i < g.Length)
    g[i] = SL.GetGender(others[0])
    If(g[i] != g[0])
      i = g.Length + 1
    Else
      i += 1
    EndIf
  EndWhile
  If(i == g.Length)
    int f = others.Find(first)
    If(f != 0)
      Actor tmp = others[0]
      others[0] = first
      others[f] = tmp
      g[0] = g[f]
    EndIf
  EndIf

  sslBaseAnimation[] anims
	bool breakLoop = false
	While(!breakLoop)
    String[] tags
		If(g[0] > 1) ; Creature
      tags = GetTags(MCM.SLTags[10])
	    ; anims = SL.GetAnimationsByTags(others.length, MCM.SLTags[10])
	  ElseIf(others.length == 2)
	    int males = SL.MaleCount(others)
	    If(g[0] == 1 && males > 0) ; Female first & Male Partner
        tags = GetTags(MCM.SLTags[0])
	      ; anims = SL.GetAnimationsByTags(others.length, MCM.SLTags[0])
	    else ; male count is now 0 for lesbian; 2 for gay or 1 for male first & female partner
        tags = GetTags(MCM.SLTags[males + 1])
	      ; anims = SL.GetAnimationsByTags(others.length, MCM.SLTags[males + 1])
	    EndIf
	  else ; Array Entry (4/5) for 3, (6/7) for 4 or (8/9) for 5
      tags = GetTags(MCM.SLTags[(others.length * 2) - (1 + g[0])])
	    ; anims = SL.GetAnimationsByTags(others.length, MCM.SLTags[(others.length * 2) - (1 + g[0])])
	  EndIf
    anims = SL.GetAnimationsByTags(others.length, tags[0], tags[1])
		If(anims)
			breakLoop = true
		ElseIf(others.length < 2)
			return -1
		else
			others = PapyrusUtil.RemoveActor(others, others[0])
		EndIf
	EndWhile
  ; Start Scene
  return SL.StartSex(others, anims, victim, hook = hook)
EndFunction

String[] Function GetTags(string get) global
  String[] all = PapyrusUtil.StringSplit(get, ",")
  String[] sol = new String[2]
  int i = 0
  While(i < all.Length)
    If(StringUtil.GetNthChar(all[i], 0) == "=")
      sol[1] = sol[1] + (StringUtil.Substring(all[i], 1) + ",")
    Else
      sol[0] = sol[0] + all[i]
    EndIf
    i += 1
  EndWhile
  return sol
EndFunction

int Function StartAnimationCustom(Actor[] positions, Actor victim, string tags, string hook) global
  SexLabFramework SL = SexLabUtil.GetAPI()
  sslBaseAnimation[] anims = SL.GetAnimationsByTags(positions.Length, tags)
  return SL.StartSex(positions, anims, victim, hook = hook)
EndFunction
