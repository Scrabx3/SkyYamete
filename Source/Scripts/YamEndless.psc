Scriptname YamEndless extends Quest

YamMCM Property MCM Auto
Faction Property PlayerFollowerFaction Auto
; Faction Property friendFac Auto
; Spell Property calmMark Auto
int Property Id Auto

Actor sub
Actor dom
int unloadTimer
bool timerActive
bool isAnimating

;/ NOTE
Assume this Quest will never be started if those Actors wouldnt be valid for Animation /;
Event OnStoryScript(Keyword akKeyword, Location akLocation, ObjectReference akRef1, ObjectReference akRef2, int aiValue1, int aiValue2)
  sub = akRef1 as Actor
  dom = akRef2 as Actor
  bool sf = sub.IsInFaction(PlayerFollowerFaction)
  bool df = dom.IsInFaction(PlayerFollowerFaction)
  If(sf || df)
    unloadTimer = -1
    If(sf)
      sub.SetAV("WaitingForPlayer", 1)
      sub.SetPlayerTeammate(false, false)
    EndIf
    If(df)
      dom.SetAV("WaitingForPlayer", 1)
      dom.SetPlayerTeammate(false, false)
    EndIf
  Else
    ActorBase sb = sub.GetActorBase()
    ActorBase db = dom.GetActorBase()
    If(sb.IsUnique() || db.IsUnique())
      unloadTimer = 1
    else
      unloadTimer = 0
    EndIf
  EndIf
  startAnimation()
  timerActive = false
  isAnimating = false
EndEvent

Event AfterScene(int tid, bool hasPlayer)
  isAnimating = false
  startAnimation()
EndEvent
Event OStimEnd(string eventName, string strArg, float numArg, Form sender)
  If(numArg > -2)
    If(YamOStim.FindActor(sub, numArg as int) == false)
      return
    EndIf
  EndIf
  isAnimating = false
  startAnimation()
EndEvent
Event OnQuestStop(Quest akQuest)
  isAnimating = false
  startAnimation()
EndEvent

Function startAnimation()
  If(isAnimating)
    return
  EndIf
  Actor[] partner = new Actor[1]
  partner[0] = dom
  If(YamAnimationFrame.StartAnimation(MCM, sub, partner, self, 1, "endless" + Id) > -1)
    RegisterForModEvent("HookAnimationEnd_endless" + Id, "AfterScene")
    isAnimating = true
  else
    StopQst()
  EndIf
EndFunction

Function StopQst()
  If(sub.IsInFaction(PlayerFollowerFaction))
    sub.SetAV("WaitingForPlayer", 0)
    sub.SetPlayerTeammate(true, true)
  EndIf
  If(dom.IsInFaction(PlayerFollowerFaction))
    dom.SetAV("WaitingForPlayer", 0)
    dom.SetPlayerTeammate(true, true)
  EndIf
  ; sub.RemoveSpell(calmMark)
  ; sub.RemoveFromFaction(friendFac)
  ; dom.RemoveSpell(calmMark)
  ; dom.RemoveFromFaction(friendFac)
  Stop()
EndFunction

; === Load/Unload
Function startTimer()
  If(unloadTimer == -1)
    return
  ElseIf(unloadTimer == 0)
    RegisterForSingleUpdateGameTime(72)
    GotoState("Waiting")
  Else
    StopQst()
  EndIf
EndFunction
Function stopTimer()
EndFunction

State Waiting
  Function startTimer()
  EndFunction
  Function stopTimer()
    UnregisterForUpdateGameTime()
    GotoState("")
  EndFunction
EndState

Event OnUpdateGameTime()
  StopQst()
EndEvent
