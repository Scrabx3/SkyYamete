Scriptname YamResVictoire extends ReferenceAlias

YamMCM Property MCM Auto
Keyword Property resLinked Auto
Package Property move2Claimed Auto

; YamResVictim Property target Auto Hidden
; YamResolution res
; int myAction
;
; Event OnInit()
;   res = GetOwningQuest() as YamResolution
; EndEvent
;
; ;/ IDEA put a switch here that allows Victoires to individually use the Complex Scenario instead (if enabled) /;
; Function findNextVictim()
;   target = res.primVic
;   myAction = -1
;   RegisterForSingleUpdate(1)
; EndFunction
;
; Event OnUpdate()
;   Actor mySelf = GetReference() as Actor
;   Actor myTarget = target.GetReference() as Actor
;   Utility.Wait(2)
;   While(mySelf.GetDistance(myTarget) > 200)
;     Utility.Wait(2)
;   EndWhile
;   target.userNum += 1
;   Debug.Trace("[Yamete] " + GetName() + " reached Target: " + target.GetName())
;   ;/ 0 - Rob; 1 - Rape; 2 - Kill /;
;   If(myAction == 0)
;     res.robVictim(myTarget, mySelf)
;   ElseIf(myAction == 1)
;     startRape()
;   ElseIf(myAction == 2)
;     ;/ NOTE when the target dies, claimers will automatically look for a new Target and the Mark dispells itself
;     + FIXME /;
;     res.Main.playKillmove(mySelf, myTarget)
;   EndIf
;   ; .. if we get here without an Action, the Victim should be claimed by someone else
;   ; .. have this Aggressor stand ready in case the Claiming Victoire needs another Actor and  wait for the Victim to be set done while spaming idles! Yay
; EndEvent
;
; ; =========================================================================
; ; ============================================ COMPLEX STUFF
; ; ========================================================================
; ;/ NOTE Called when this Victoire should look for a new Victim
; When searching, there can be one of the following cases:
; 1) No Victim found
; 2) The found Victim is claimable (not used by someone else)
; 3) The found Victim is already used by someone else
;
; Case..
; 1 > This should only happen when all Victims have been processed and the Quest can be closed off
; 2 > Choose an outcome for this Victim and execute it once close enough
; 3 > Let this Victoire path towards the Victim and laugh at it.. ye.. /;
; Function findNextVictimComplex()
;   target = res.getNearestVic(self)
;   If(target == none)
;     Debug.Trace("[Yamete] " + GetName() + " didnt find a Victim..")
;     res.checkCloseCondition()
;     return
;   EndIf
;   Debug.Trace("[Yamete] " + GetName() + ": Found Target: " + target.GetName())
;   Actor mySelf = GetReference() as Actor
;   Actor myTarget = target.GetReference() as Actor
;   If(target.claimVictim(self) == true)
;     If(Utility.RandomInt(0, 99) < MCM.iResIgnore)
;       ; Ignore this Victim..
;       target.setDone()
;       return
;     EndIf
;     myAction = res.getOutcome(myTarget, mySelf)
;     If(myAction < 0)
;       ; Invalid return.. should only happen with invalid MCM Settings.. ayah
;       target.setDone()
;       return
;     ElseIf(myAction != 1)
;       ; By the time of writing this, all outcomes except the Rape are too simplistic to allow an audience..
;       target.onlyOne = true
;     EndIf
;   else
;     myAction = -1
;   EndIf
;   ; If we get till here, should make sure the Victoire can path towards its Victim..
;   PO3_SKSEFunctions.SetLinkedRef(mySelf, myTarget, resLinked)
;   Utility.Wait(0.5)
;   mySelf.EvaluatePackage()
;   ; To not pause the other instances..
;   RegisterForSingleUpdate(1)
; EndFunction
;
; ; =========================================================================
; ; ============================================ CHAIN RAPE
; ; ========================================================================
; int rounds
; bool usesSL
; Function startRape()
;   If(Utility.RandomInt(0, 99) < MCM.iResNPCendless)
;     ;/ TODO create a Threading Quest to handle endless Rape and return /;
;     rounds = -1
;   EndIf
;   res.Main.RemoveBleedoutMarks(target.GetReference() as Actor)
;   Actor[] acR = res.fillSceneArray(self, target)
;   int sceneType = YamAnimationFrame.startAnimationAlias(MCM, self, acR, false, 2)
;   If(sceneType > -1)
;     RegisterForModEvent("HookAnimationEnd_" + GetName(), "AfterScene")
;     GotoState("ChainRape")
;     rounds = 1
;     If(sceneType < 15)
;       usesSL = true
;     else
;       usesSL = false
;     EndIf
;   else
;     target.setDone()
;   EndIf
; EndFunction
;
; State ChainRape
;   Event AfterScene(int tid, bool hasPlayer)
;     nextScene()
;   EndEvent
;   Event OStimEnd(string eventName, string strArg, float numArg, Form sender)
;     nextScene()
;   EndEvent
;   Event OnQuestStop(Quest akQuest)
;     nextScene()
;   EndEvent
;
;   Function nextScene()
;     If(res.playNextScene(rounds) == false)
;       target.SetDone()
;     else
;       Actor[] acR = res.fillSceneArray(self, target)
;       int sceneType = YamAnimationFrame.startAnimationAlias(MCM, self, acR, false, 2)
;       If(sceneType > -1)
;         If(sceneType < 15)
;           usesSL = true
;         else
;           usesSL = false
;         EndIf
;       else
;         target.setDone()
;       EndIf
;     EndIf
;   EndFunction
;
;   Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
;     If(usesSL)
;       YamSexLab.stopAnimation(GetReference() as Actor)
;     EndIf
;     rounds = 999
;   EndEvent
; EndState
;
;
; Event AfterScene(int tid, bool hasPlayer)
; EndEvent
; Event OStimEnd(string eventName, string strArg, float numArg, Form sender)
; EndEvent
; Event OnQuestStop(Quest akQuest)
; EndEvent
; Function nextScene()
; EndFunction
