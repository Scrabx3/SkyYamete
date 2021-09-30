;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 7
Scriptname SF_YamResRobbing_05460431 Extends Scene Hidden

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
YamResolution res = GetOwningQuest() as YamResolution
res.Main.playKillmove(res.primWin.GetReference() as Actor, res.primVic.GetReference() as Actor)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
;
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
(GetOwningQuest() as YamResolution).primaryRobEntry()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
doneDoing = false
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN CODE
(GetOwningQuest() as YamResolution).primaryRobDone()
doneDoing = true
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
If(!doneDoing)
  YamResolution q = GetOwningQuest() as YamResolution
  q.handleSceneCancel()
  ; int stage = q.GetStage()
  ; If(stage == 30)
  ;   q.primaryRobEntry()
  ;   q.primaryRobDone()
  ; ElseIf(stage == 40)
  ;   q.chainRapeEntry()
  ; ElseIf(stage == 50)
  ;   q.primVic.GetActorRef().Kill(q.primWin.GetReference() as Actor)
  ; EndIf
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
(GetOwningQuest() as YamResolution).chainRapeEntry()
doneDoing = true
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Bool Property doneDoing  Auto
