Scriptname YamSurrender extends Quest Conditional

YamMCM Property MCM Auto

bool Property allowAdult Auto Conditional
bool Property isOutlaw Auto Conditional
bool Property KnowsAbout Auto Conditional
bool Property isAlone Auto Conditional
bool Property isNude Auto Conditional
int Property numVictoire Auto Conditional
int Property victoireGen Auto Conditional

int Property passItemsGiven Auto Conditional

Actor[] Property Enemies Auto
ReferenceAlias Property EnemyNPC Auto

ImageSpaceModifier Property FadeToBlack Auto

; Bandits or similar selling out the Player to somewhere. 
; This is primarily intended to be a SS++ entry though I guess I also doom 
; myself to make the Blackmarket a functional market for player selling.. ayah..
Function SellOut()
  SetStage(75)
  FadeToBlack.Apply()
  Utility.Wait(2.1)
  If(MCM.cSimpleSlavery != 0)
    SendModEvent("SSLV Entry")
  Else
    ; This feature isnt fully implemented yet due to the Blackmarket missing player selling. Using Default Sendjail as temporary solution
    FormList CrimeFactions = Game.GetForm(0x00026953) as FormList
    Faction cf = CrimeFactions.GetAt(Utility.RandomInt(0, CrimeFactions.GetSize() - 1)) as Faction
    cf.ModCrimeGold(600, true)
    cf.SendPlayerToJail()
  EndIf
  FadeToBlack.Remove()
  Stop()
EndFunction

Function Imprison(Faction cf)
  FadeToBlack.Apply()
  Utility.Wait(2.1)
  cf.SendPlayerToJail()
  FadeToBlack.Remove()
EndFunction

Function StartScene(String tags = "", Actor victim = none)
  SetStage(75)
  Actor[] positions = new Actor[2]
  positions[0] = Game.GetPlayer()
  positions[1] = EnemyNPC.GetActorReference()
  If(YamAnimationFrame.StartSceneSurrender(MCM, positions, victim, tags, self) == -1)
    SetStage(100)
    Debug.Notification("Yamete: There was an Error starting the Scene")
  EndIf
  RegisterForModEvent("HookAnimationEnd_YamSurrender", "AnimEnd")
EndFunction

Function StartScene3p(String tags = "", Actor victim = none)
  SetStage(75)
  int l
  If(Enemies.Length + 1 < 5)
    l = Enemies.Length + 1
  Else
    l = 5
  EndIf
  Actor[] positions = PapyrusUtil.ActorArray(l)
  positions[0] = Game.GetPlayer()
  int i = 0
  While(i < positions.Length)
    positions[i + 1] = Enemies[i]
    i += 1
  EndWhile
  If(YamAnimationFrame.StartSceneSurrender(MCM, positions, victim, tags, self) == -1)
    SetStage(100)
    Debug.Notification("Yamete: There was an Error starting the Scene")
  EndIf
  RegisterForModEvent("HookAnimationEnd_YamSurrender", "AnimEnd")
EndFunction

Function StartSceneChained(String tags = "", bool aggressive = false)
  GoToState("ChainScene")
EndFunction


Event AnimEnd(int tid, bool hasPlayer)
  SetStage(100)
EndEvent
Event OStimEnd(string eventName, string strArg, float numArg, Form sender)
  If(numArg > -2)
    If(YamOStim.FindActor(Game.GetPlayer(), numArg as int) == false)
      return
    EndIf
  EndIf
  SetStage(100)
EndEvent
Event OnQuestStop(Quest akQuest)
  SetStage(100)
EndEvent
