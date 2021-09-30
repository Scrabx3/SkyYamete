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
  ; FG unfortunately doesnt report back if an Animation failed to start, so there always somewhat of a gamble if the mod gets stuck using it
  ; I believe all I can do here for now is checking if a Thread exists and then menually building the function. oof
  ; return none
  dxFlowerGirlsScript FG = (Quest.GetQuest("FlowerGirls") as dxFlowerGirlsScript)
  dxSceneThread thread = FG.ValidateThread(first, partners[0])
  If(thread == none)
    return none
  EndIf
  ; Building our own FG Function here I guess
  ; I mostly rely on FGs logic and wont question its doings, I will only rephrase the syntax to allow the script to compile
  FormList tokensF
  FormList tokensM
  If(partners.length == 1)
    int gender0 = thread.Participant01.Gender ; 0 - Male // 1 - Female
    int gender1 = thread.Participant02.Gender
    If(gender0 == gender1) ; Gay
      If(gender0 == 0) ; Male on Male
        tokensF = FG.RandomTokensMMActor2
        tokensM = FG.RandomTokensMMActor1
      else ; Female on Female
        tokensF = FG.RandomTokensFFActor2
        tokensM = FG.RandomTokensFFActor1
      EndIf
    ElseIf(gender0 == 0) ; Male on Female
      tokensF = FG.RandomTokensMFActor2
      tokensM = FG.RandomTokensMFActor1
    else ; Female on Male
      tokensF = FG.RandomTokensFMActor2
      tokensM = FG.RandomTokensFMActor1
    EndIf
    Form tokenF = tokensF.GetAt(Utility.RandomInt(0, tokensF.GetSize() - 1))
  	Form tokenM = tokensM.GetAt(Utility.RandomInt(0, tokensM.GetSize() - 1))
    If(tokenF == none || tokenM == none)
      Debug.Trace("Yamete: FG-Clone of RandomScene(); at least one of tokens received is none; tokenF = " + tokenF + " // tokenM: " + tokenM)
      return none
    EndIf
    thread.Participant01.SexType = tokenM as Ammo
  	thread.Participant02.SexType = tokenF as Ammo
    thread.SceneType = 11
    FG.FlowerGirlsConfig.DX_LAST_SCENETYPE.SetValueInt(thread.SceneType)
  Else ; partners.length == 2
    ; Add the 3rd Actor into the slot or so
    thread.Participant03.ForceRefTo(partners[1])
    If(thread.Participant01.Gender == 0) ; Male 1st
  	  If(thread.Participant02.Gender == thread.Participant03.Gender)
        If(thread.Participant02.Gender == 1) ; Female Partners
          thread.Participant03.SexType = FG.SexPositions.TokenFFMActor1
    			thread.Participant01.SexType = FG.SexPositions.TokenFFMActor2
    			thread.Participant02.SexType = FG.SexPositions.TokenFFMActor3
        else ; ALl Male
          thread.Participant02.SexType = FG.SexPositions.TokenMMFActor3
  				thread.Participant01.SexType = FG.SexPositions.TokenMMFActor1
  				thread.Participant03.SexType = FG.SexPositions.TokenMMFActor2
        EndIf
  		else
        thread.Participant01.SexType = FG.SexPositions.TokenMMFActor2
  			If(thread.Participant02.Gender == 1) ; All Male except 2nd
  				thread.Participant02.SexType = FG.SexPositions.TokenMMFActor1
  				thread.Participant03.SexType = FG.SexPositions.TokenMMFActor3
  			else ; All Male except 3rd
  				thread.Participant02.SexType = FG.SexPositions.TokenMMFActor3
  				thread.Participant03.SexType = FG.SexPositions.TokenMMFActor1
  			EndIf
  		EndIf
  	else ; Female 1st
  		If(thread.Participant02.Gender == thread.Participant03.Gender)
        If(thread.Participant02.Gender == 1) ; All Female
          if (Utility.RandomInt(0, 100) <= 50)
    				thread.Participant01.SexType = FG.SexPositions.TokenFFFActor1
    				thread.Participant02.SexType = FG.SexPositions.TokenFFFActor2
    				thread.Participant03.SexType = FG.SexPositions.TokenFFFActor3
    				thread.Participant01.HideStrapOn = True
    			else
    				thread.Participant03.SexType = FG.SexPositions.TokenFFMActor1
    				thread.Participant01.SexType = FG.SexPositions.TokenFFMActor2
    				thread.Participant02.SexType = FG.SexPositions.TokenFFMActor3
    				thread.Participant01.HideStrapOn = False
    			EndIf
        else ; Male Partners
          thread.Participant02.SexType = FG.SexPositions.TokenMMFActor3
  				thread.Participant01.SexType = FG.SexPositions.TokenMMFActor1
  				thread.Participant03.SexType = FG.SexPositions.TokenMMFActor2
        EndIf
  		else
  			If(thread.Participant02.Gender == 1) ; Female 2nd, male 3rd
  				thread.Participant03.SexType = FG.SexPositions.TokenFFMActor2
  				thread.Participant01.SexType = FG.SexPositions.TokenFFMActor1
  				thread.Participant02.SexType = FG.SexPositions.TokenFFMActor3
  			else ; Male 2nd, female 3rd
  				thread.Participant03.SexType = FG.SexPositions.TokenFFMActor3
  				thread.Participant01.SexType = FG.SexPositions.TokenFFMActor1
  				thread.Participant02.SexType = FG.SexPositions.TokenFFMActor2
  			EndIf
  			; Over-ride the user Strap On option.. flag to turn off.
  			thread.Participant01.HideStrapOn = True
  		EndIf
  	EndIf
    FG.FollowMeActorRef.Clear()
    thread.Participant02.GetActorRef().RemoveFromFaction(FG.FlowerGirlsMod.ThreewayFaction)
    FG.FlowerGirlsConfig.DX_LAST_SCENETYPE.SetValueInt(10)
  EndIf
  If(thread.StartScene())
    FG.FirstActorRef.TryToClear()
    FG.SecondActorRef.TryToClear()
    FG.ThirdActorRef.TryToClear()
    return thread
  EndIf
  return none
EndFunction
