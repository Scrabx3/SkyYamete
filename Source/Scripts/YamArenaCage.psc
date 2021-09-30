Scriptname YamArenaCage extends ActiveMagicEffect

; -------------------------- Properties
ReferenceAlias Property Combatant0 Auto
{Scans mandatory Combatant}
Quest Property Yam_Scan  Auto

Faction Property PlayerSiders Auto
Faction Property RootSiders Auto
Faction Property Bystanders Auto

Actor target
; -------------------------- Code
Event OnEffectStart(Actor akTarget, Actor akCaster)
  ; Caster is Player
  If(!akTarget || !akCaster)
    return
  EndIf
  ; Cache this, skyrim is weird and sometimes passes some weird not-none none value in OnEffectFinish
  target = akTarget
  Actor combatant = Combatant0.GetReference() as Actor
  If(akTarget == combatant)
    akTarget.AddToFaction(RootSiders)
  else
    ; Hostile to Caster but not Hostile to Player => Player Sider
    ; Hostile to Player but not Hostile to Caster => Root Sider
    ; Hostile to both Player & Caster => Bystander
    ; Not Hostile to either of them => Civilian (ignore)
    bool hostileToPlayer = akTarget.IsHostileToActor(akCaster)
    bool hostileToRoot = true
    If(combatant)
      hostileToRoot = akTarget.IsHostileToActor(combatant)
    EndIf
    If(hostileToRoot && !hostileToPlayer)
      akTarget.AddToFaction(PlayerSiders)
    ; Debug.Trace("[Yamete] Added " + akTarget.GetLeveledActorBase().GetName() + " to PlayerSiders")
    ElseIf(!hostileToRoot && hostileToPlayer)
      akTarget.AddToFaction(RootSiders)
      ; Debug.Trace("[Yamete] Added " + akTarget.GetLeveledActorBase().GetName() + " to Rootsiders")
    elseIf(hostileToRoot && hostileToPlayer)
      akTarget.AddToFaction(Bystanders)
      ; Debug.Trace("[Yamete] Added " + akTarget.GetLeveledActorBase().GetName() + " to Bystanders")
    EndIf
  EndIf
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
  If(target.IsDead() == false)
    target.RemoveFromFaction(PlayerSiders)
    target.RemoveFromFaction(RootSiders)
    target.RemoveFromFaction(Bystanders)
  EndIf
EndEvent


; Event OnEffectStart(Actor akTarget, Actor akCaster)
;   ; Caster is always the Root Actor
;   If(akTarget == none || akCaster == none)
;     return
;   EndIf
;   ; Cache this here so it doesnt fail on OnEffectFinish...
;   target = akTarget
;   If(akTarget == PlayerRef)
;     akTarget.AddToFaction(PlayerSiders)
;     return
;   EndIf
;   ; Hostile to Caster but not Hostile to Player => Player Sider
;   ; Hostile to Player but not Hostile to Caster => Root Sider
;   ; Hostile to both Player & Caster => Bystander
;   ; Not Hostile to either of them => Civilian (ignore)
;   bool hostileToPlayer = akTarget.IsHostileToActor(PlayerRef)
;   bool hostileToRoot = akTarget.IsHostileToActor(akCaster)
;   If(hostileToRoot && !hostileToPlayer)
;     akTarget.AddToFaction(PlayerSiders)
;     ; Debug.Trace("[Yamete] Added " + akTarget.GetLeveledActorBase().GetName() + " to PlayerSiders")
;   ElseIf(!hostileToRoot && hostileToPlayer)
;     akTarget.AddToFaction(RootSiders)
;     ; Debug.Trace("[Yamete] Added " + akTarget.GetLeveledActorBase().GetName() + " to Rootsiders")
;   elseIf(hostileToRoot && hostileToPlayer)
;     akTarget.AddToFaction(Bystanders)
;     ; Debug.Trace("[Yamete] Added " + akTarget.GetLeveledActorBase().GetName() + " to Bystanders")
;   EndIf
; EndEvent
;
; Event OnEffectFinish(Actor akTarget, Actor akCaster)
;   If(target.IsDead() == false)
;     If(target == PlayerRef)
;       If(Yam_Scan.IsRunning())
;         Debug.Trace("[Yamete] Scan: Closed Quest through Arena")
;         Yam_Scan.SetStage(1050)
;       EndIf
;     EndIf
;     target.RemoveFromFaction(PlayerSiders)
;     target.RemoveFromFaction(RootSiders)
;     target.RemoveFromFaction(Bystanders)
;   EndIf
; EndEvent
