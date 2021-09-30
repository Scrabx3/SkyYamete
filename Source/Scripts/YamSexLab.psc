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

  int fg = SL.GetGender(first)
  sslBaseAnimation[] anims
	bool breakLoop = false
	While(!breakLoop && others.length > 1)
		If(fg > 1) ; Creature
	    anims = SL.PickAnimationsByActors(others)
	  ElseIf(others.length == 2)
	    int males = SL.MaleCount(others)
	    If(fg == 1 && males > 0) ; Female first & Male Partner
	      anims = SL.GetAnimationsByTags(others.length, MCM.SLTags[0])
	    else ; male count is now 0 for lesbian; 2 for gay or 1 for male first & female partner
	      anims = SL.GetAnimationsByTags(others.length, MCM.SLTags[males + 1])
	    EndIf
	  else ; Array Entry (4/5) for 3, (6/7) for 4 or (8/9) for 5
	    anims = SL.GetAnimationsByTags(others.length, MCM.SLTags[(others.length * 2) - (1 + fg)])
	  EndIf
		If(anims)
			breakLoop = true
		else
			others = PapyrusUtil.RemoveActor(others, others[0])
		EndIf
	EndWhile
  ; Start Scene
  return SL.StartSex(others, anims, victim, hook = hook)
EndFunction
