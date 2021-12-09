Scriptname YamFlowerGirls Hidden
{Global script to control Yamete - Flowergirls Intergration}

; ======================================================================
; ================================== ANIMATION
; ======================================================================
bool Function StartSceneAlias(Actor first, Actor[] partners, ReferenceAlias source = none) global
  dxSceneThread tmp = StartSceneFlowergirls(first, partners)
  If(tmp)
    If(source)
      PO3_Events_Alias.RegisterForQuest(source, tmp as Quest)
    EndIf
    return true
  else
    return false
  EndIf
EndFunction

bool Function StartSceneForm(Actor first, Actor[] partners, Form source = none) global
  dxSceneThread tmp = StartSceneFlowergirls(first, partners)
  If(tmp)
    If(source)
      PO3_Events_Form.RegisterForQuest(source, tmp as Quest)
    EndIf
    return true
  else
    return false
  EndIf
EndFunction

dxSceneThread Function StartSceneFlowergirls(Actor first, Actor[] partners) global
  ; FG doesnt report back if an Animation failed to start, will need this workaround instead Zzz
  ; Majority Code here is copied from dxFlowerGirlsScript.psc
  If(!first || !partners[0])
    return none
  EndIf
  dxFlowerGirlsScript FG = (Quest.GetQuest("FlowerGirls") as dxFlowerGirlsScript)
  dxSceneThread thread = FG.ThreadManager.GetNextAvailableThread()  
  If(thread)
    thread.Participant01.ForceRefTo(first)
    thread.Participant02.ForceRefTo(partners[0])
  Else
    Debug.Trace("[Yamete] <Flowergirls> No Thread Found")
    return none
  EndIf
  If(partners.Length == 1) ; 2p Scene
    Form tokenFemale
	  Form tokenMale
		If(thread.Participant01.Gender == 0) ; Male
      If(thread.Participant02.Gender == 0) ; Actor2 is Male
        int rnd = Utility.RandomInt(0, (FG.RandomTokensMMActor1.GetSize() - 1))
        tokenFemale = FG.RandomTokensMMActor2.GetAt(rnd) 
        tokenMale = FG.RandomTokensMMActor1.GetAt(rnd)
      Else ; Actor1 is Male and Actor2 is Female
        int rnd = Utility.RandomInt(0, (FG.RandomTokensMFActor1.GetSize() - 1))
        tokenFemale = FG.RandomTokensMFActor2.GetAt(rnd) 
        tokenMale = FG.RandomTokensMFActor1.GetAt(rnd)
      EndIf
    Else ; Actor1 is Female
      thread.Participant01.HideStrapOn = True
      If(thread.Participant02.Gender == 0) ; Actor2 is Male
        int rnd = Utility.RandomInt(0, (FG.RandomTokensFMActor1.GetSize() - 1))
        tokenFemale = FG.RandomTokensFMActor2.GetAt(rnd) 
        tokenMale = FG.RandomTokensFMActor1.GetAt(rnd)
      Else ; Actor1 is Female and Actor2 is Female
        If(FG.FlowerGirlsConfig.DX_FEMALE_ISMALEROLE.GetValueInt() > 0)
          FormList actor1MaleRole = FG.RandomTokensFFActor1MaleNoLes
          FormList actor2MaleRole = FG.RandomTokensFFActor2MaleNoLes
          If(FG.FlowerGirlsConfig.DX_ALLOW_LESBIAN_ANIMS)
            actor1MaleRole = FG.RandomTokensFFActor1MaleRole
            actor2MaleRole = FG.RandomTokensFFActor2MaleRole
          EndIf
          int rnd = Utility.RandomInt(0, (actor1MaleRole.GetSize() - 1))
          tokenFemale = actor2MaleRole.GetAt(rnd) 
          tokenMale = actor1MaleRole.GetAt(rnd) 
          If(tokenMale == FG.SexPositions.TokenCowgirlMale || tokenMale == FG.SexPositions.TokenDoggyMale || tokenMale == FG.SexPositions.TokenMissionaryMale || tokenMale == FG.SexPositions.TokenStandingMale)
            thread.Participant01.HideStrapOn = False
          EndIf
        Else
          int rnd = Utility.RandomInt(0, (FG.RandomTokensFFActor1.GetSize() - 1))
          tokenFemale = FG.RandomTokensFFActor2.GetAt(rnd) 
          tokenMale = FG.RandomTokensFFActor1.GetAt(rnd)
        EndIf
      EndIf
    EndIf
    If(!tokenFemale || !tokenMale)
      Debug.Trace("[Yamete] <Flowergirls> Invalid Tokens Passed")
      return none
    endIf
    thread.Participant01.SexType = tokenMale as Ammo
    thread.Participant02.SexType = tokenFemale as Ammo
    thread.SceneType = 11
    FG.FlowerGirlsConfig.DX_LAST_SCENETYPE.SetValueInt(thread.SceneType)
    bool started = thread.StartScene()
    ; Clean up the local aliases.
    FG.FirstActorRef.Clear()
    FG.SecondActorRef.Clear()
    If(started)
      return thread
    Else
      return none
    EndIf
  Else ; 3p
    thread.Participant03.ForceRefTo(partners[1])
    If(thread.Participant01.Gender == 0) ; Actor 1 is male
		  If(thread.Participant02.Gender == 1 && thread.Participant03.Gender == 1)
        thread.Participant03.SexType = FG.SexPositions.TokenFFMActor1
        thread.Participant01.SexType = FG.SexPositions.TokenFFMActor2
        thread.Participant02.SexType = FG.SexPositions.TokenFFMActor3
      Else
			  If(thread.Participant02.Gender == 1)
				  thread.Participant02.SexType = FG.SexPositions.TokenMMFActor1 	; SecondActorRef is female
				  thread.Participant01.SexType = FG.SexPositions.TokenMMFActor2		; Player is male
				  thread.Participant03.SexType = FG.SexPositions.TokenMMFActor3		; ThirdActorRef is male
        ElseIf(thread.Participant03.Gender == 1)
          thread.Participant02.SexType = FG.SexPositions.TokenMMFActor3 	; SecondActorRef is male
          thread.Participant01.SexType = FG.SexPositions.TokenMMFActor2		; Player is male
          thread.Participant03.SexType = FG.SexPositions.TokenMMFActor1		; ThirdActorRef is female
        Else ; All participants are male. Make player assume the female role.
          thread.Participant02.SexType = FG.SexPositions.TokenMMFActor3 	; SecondActorRef is male
          thread.Participant01.SexType = FG.SexPositions.TokenMMFActor1		; Player is male assuming female role.
          thread.Participant03.SexType = FG.SexPositions.TokenMMFActor2		; ThirdActorRef is male
        EndIf		
      EndIf
    Else 
		; Player is female and both participants are female:
		  If(thread.Participant02.Gender == 1 && thread.Participant03.Gender == 1)
			  If(Utility.RandomInt(0, 100) <= 50)
          thread.Participant01.SexType = FG.SexPositions.TokenFFFActor1
          thread.Participant02.SexType = FG.SexPositions.TokenFFFActor2
          thread.Participant03.SexType = FG.SexPositions.TokenFFFActor3				
          thread.Participant01.HideStrapOn = True
        Else
          thread.Participant03.SexType = FG.SexPositions.TokenFFMActor1
          thread.Participant01.SexType = FG.SexPositions.TokenFFMActor2			; Player assumes the male role.
          thread.Participant02.SexType = FG.SexPositions.TokenFFMActor3
          thread.Participant01.HideStrapOn = False
        EndIf
      Else
			  If(thread.Participant02.Gender == 1)
          thread.Participant03.SexType = FG.SexPositions.TokenFFMActor2		; ThirdActorRef is in the male role
          thread.Participant01.SexType = FG.SexPositions.TokenFFMActor1		; Player is female.
          thread.Participant02.SexType = FG.SexPositions.TokenFFMActor3	; SecondActorRef is female.			
        ElseIF(thread.Participant03.Gender == 1)
          thread.Participant03.SexType = FG.SexPositions.TokenFFMActor3		; ThirdActorRef is female.
          thread.Participant01.SexType = FG.SexPositions.TokenFFMActor1		; Player is female.
          thread.Participant02.SexType = FG.SexPositions.TokenFFMActor2	; SecondActorRef is male.
        Else
          thread.Participant02.SexType = FG.SexPositions.TokenMMFActor3 	; SecondActorRef is male
          thread.Participant01.SexType = FG.SexPositions.TokenMMFActor1		; Player is female.
          thread.Participant03.SexType = FG.SexPositions.TokenMMFActor2		; ThirdActorRef is male
        EndIf
        ; Over-ride the user Strap On option.. flag to turn off.
        thread.Participant01.HideStrapOn = True
			EndIf
    EndIf
    ; Remove the temporary follower
	  FG.FollowMeActorRef.Clear()
    ; Clear the faction stuff
    thread.Participant02.GetActorRef().RemoveFromFaction(FG.FlowerGirlsMod.ThreewayFaction)
	  FG.FlowerGirlsConfig.DX_LAST_SCENETYPE.SetValueInt(10)
  	bool started = thread.StartScene()	
    FG.FirstActorRef.Clear()
    FG.SecondActorRef.Clear()
    FG.ThirdActorRef.Clear()
    If(started)
      return thread
    Else
      return none
    EndIf
  EndIf
EndFunction
