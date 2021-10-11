;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 19
Scriptname QF_Yam_BlackMarket00_05803CF6 Extends Quest Hidden

;BEGIN ALIAS PROPERTY Captured
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Captured Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Charon
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Charon Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Agent
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Agent Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Letter
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Letter Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY AgemtSpawn
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_AgemtSpawn Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Letter2
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Letter2 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Player
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Player Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
; Player read letter
Alias_Charon.GetReference().Enable()
SetObjectiveDisplayed(10)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN CODE
; Silent Stage. Set by YamBlackMarket00Player
ObjectReference Letter = Alias_Letter2.GetReference()
Letter.Enable()
CourierScript.AddItemToContainer(Letter)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
; Player talked to Charon
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_18
Function Fragment_18()
;BEGIN CODE
Actor player = Game.GetPlayer()
Game.DisablePlayerControls(abLooking = true, abMenu = false)

Actor agent = Alias_Agent.GetReference() as Actor
FXAgentAbsorbEffect.Play(agent, 7, player)
;AgentPowerAbsorbFXS.Play(agent)
;AgentPlayerPowerAbsorbFXS.Play(player)
agent.PlayIdle(BracedPainIdle)
NPCDragonDeathSequenceWind.play(agent)
AgentPowerAbsorbImod.Apply()

; Use OnUpdate here because the Dialogue would otherwise prevent the Skilltree from opening in the desired time
; Utility.Wait(6.7)
RegisterForSingleUpdate(6.7)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_9
Function Fragment_9()
;BEGIN CODE
; Player denied Charons task
SetObjectiveCompleted(10)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_15
Function Fragment_15()
;BEGIN CODE
; Scene finished, Charon announced the Player a Hunter
Game.GetPlayer().AddItem(Gold001, 300)
BlackMarket.AddXp(7)

CompleteAllObjectives()
entranceColli.DisableNoWait()
colliWallAgent.EnableNoWait()
Alias_Agent.GetReference().Enable()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_11
Function Fragment_11()
;BEGIN CODE
; Player gave up on Charons Mission
SetObjectiveFailed(50)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN CODE
; Player accepted Charons Task
SetObjectiveCompleted(10)
SetObjectiveDisplayed(50)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_14
Function Fragment_14()
;BEGIN CODE
; Completed Agent Encounter, Agent no longer in LOS of player
Alias_Agent.GetReference().Disable()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
; Silent Stage. Set by YamBlackMarket00Player
ObjectReference Letter = Alias_Letter.GetReference()
Letter.Enable()
CourierScript.AddItemToContainer(Letter)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_16
Function Fragment_16()
;BEGIN CODE
; player talks to agent

; Dont do anything if the Player attacked the Agent
If(Game.GetPlayer().HasMagicEffectWithKeyword(AgentRobe))
return
EndIf

SetStage(101)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
; Player enters Black Market for the first time
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_17
Function Fragment_17()
;BEGIN CODE
; Player leaves the Cave, Stop Quest
SetStage(105) ; Fallback
Stop()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_7
Function Fragment_7()
;BEGIN CODE
; Finished Intro Dialogue Part1
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_13
Function Fragment_13()
;BEGIN CODE
; Player returned with a captured NPC
entranceColli.Enable()
SetObjectiveCompleted(50)
EvalScene.Start()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_10
Function Fragment_10()
;BEGIN CODE
; Player exited Cave after accepting Charons quest
Debug.Messagebox("You can now capture Targets in Bleedout.\nCaptured Targets will follow you around the world but be aware that they can free themselves if you go too far away or they are engaged in Combat.\n\nEnable Reapers Mercy in the MCM to force Targets into Bleedout yourself")
Utility.Wait(0.1)
Debug.Notification("You can now capture bleeding out Targets")
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Event OnUpdate()
	AgentPowerAbsorbImod.PopTo(FadeToBlackHoldImod)
	Actor agent = Alias_Agent.GetReference() as Actor
	; Debug.MessageBox("OPEN MENU")
	BlackMarket.OpenMenu()
	; Utility.WaitMenuMode(1)
	AgentIntro.Show()
	agent.MoveTo(AgentWaitMarker)
	colliWallAgent.Disable()
	Utility.Wait(0.1)
	; Debug.MessageBox("CLOSED MENU")

	FadeToBlackHoldImod.PopTo(FadeToBlackBackImod)
	RegisterForSingleLOSLost(Game.GetPlayer(), agent)
	Game.EnablePlayerControls()
EndEvent

Event OnLostLOS(Actor akViewer, ObjectReference akTarget)
	SetStage(105)
EndEvent


WICourierScript Property CourierScript  Auto

Scene Property EvalScene  Auto

MiscObject Property Gold001  Auto

ObjectReference Property entranceColli  Auto

ObjectReference Property colliWallAgent  Auto

Keyword Property AgentRobe  Auto

VisualEffect Property FXAgentAbsorbEffect  Auto

EffectShader Property AgentPowerAbsorbFXS  Auto

EffectShader Property AgentPlayerPowerAbsorbFXS  Auto

Idle Property BracedPainIdle  Auto

Sound Property NPCDragonDeathSequenceWind  Auto

ImageSpaceModifier Property AgentPowerAbsorbImod  Auto

Message Property AgentIntro  Auto

ObjectReference Property AgentWaitMarker  Auto

YamReapersMercy Property BlackMarket  Auto

ImageSpaceModifier Property FadeToBlackHoldImod Auto

ImageSpaceModifier Property FadeToBlackBackImod Auto
