Scriptname YamOStim Hidden
{Global Script to control Yamete - OStim Integration}

bool Function FindActor(Actor that, int ID) global
  OSexIntegrationMain OStim = OUtils.GetOstim()
  If(ID == -1)
    return OStim.IsActorInvolved(that)
  Else
    OStimSubthread st = OStim.GetSubthread(ID)
    If(st)
      return st.actorlist.Find(that) > -1
    EndIf
  EndIf
  return false
EndFunction

; ======================================================================
; ================================== ANIMATION
; ======================================================================
; Return -1 if the Scene failed to start, 0 if it started, 1+ if it started in a subthread, the return value is equal the Scene Duration
bool Function StartScene(YamMCM MCM, Actor first, Actor[] others, int asVictim) Global
  OSexIntegrationMain OStim = Quest.GetQuest("OSexIntegrationMainQuest") as OSexIntegrationMain
  Actor Player = Game.GetPlayer()
	bool hasPlayer = (first == Player || others.Find(Player) > -1)
	bool aggressive = true
	If(asVictim == 0)
		aggressive = false
	ElseIf(asVictim == 2)
		Actor tmp = first
		first = others[0]
		others[0] = tmp
	EndIf
  Actor third = none
  If(others.length > 1)
    third = others[1]
  EndIf
  OStim.AddSceneMetadata("or_player_nocheat")
  OStim.AddSceneMetadata("or_npc_nocheat")
  If(hasPlayer)
    If(OStim.StartScene(others[0], first, false, true, false, zThirdActor = third, aggressive = aggressive, AggressingActor = others[0]))
      return 0
    EndIf
  else
    OStimSubthread st = OStim.GetUnusedSubthread()
    float timer = Utility.RandomFloat(MCM.fOtMinD, MCM.fOtMaxD)
    If(st.StartScene(others[0], first, third, timer, isaggressive = aggressive, aggressingActor = others[0]))
      return 0
    EndIf
  EndIf
  return -1
EndFunction
