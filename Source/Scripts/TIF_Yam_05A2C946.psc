;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname TIF_Yam_05A2C946 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
Actor pl = Game.GetPlayer()
YamSurrender sur = GetOwningQuest() as YamSurrender

; pl.GetAllForms(Yam_SurrenderPlayerItems)
; int iItm = Yam_SurrenderPlayerItems.GetSize()
; Debug.Trace("[Yamete] Surrender: Player Items (Before Trade) = " + iItm)
; While(n > 0)
;   n -= 1
;   Form thisform = Yam_SurrenderPlayerItems.GetAt(n)
;   If(thisForm != Gold001 && thisform.GetGoldValue() < 50)
;     Yam_SurrenderPlayerItems.RemoveAddedForm(thisform)
;   EndIf
; EndWhile

int iItm = pl.GetNumItems()
Debug.Trace("[Yamete] Surrender: Player Items (Before Trade) = " + iItm)
If(iItm <= 3)
  sur.passItemsGiven = 4
  return
EndIf

float numGold = pl.GetItemCount(Gold001) as float

akSpeaker.ShowGiftMenu(true, none, true)

int nItm = pl.GetNumItems()
Debug.Trace("[Yamete] Surrender: Player Items (After Trade) = " + nItm)

If(nItm == iItm)
  ; Didnt give any Items but has Items
  Debug.Trace("[Yamete] Surrender: No Items handed over")
  sur.passItemsGiven = 0
ElseIf(nItm < 7)
  ; player only got a couple of items left. Want to divide here between "barely anything" and "essentiall nothing" - where "essentiall nothing" means that the Player has given away majority of their money, got no body armor and no weapons with them anymore
  Debug.Trace("[Yamete] Surrender: Player owns less than 7 Items")
  int i = 0
  While(i < nItm)
    Form f = pl.GetNthForm(i)
    Armor ar = f as Armor
    If(ar && Math.LogicalAND(ar.GetSlotMask(), 4) != 0 || f as Weapon || f == Gold001 && pl.GetItemCount(f) > (numGold * 0.3))
      ; If we got a weapn or armor on Slot 32, set to 2 (barely anything)
      Debug.Trace("[Yamete] Surrender: Player owns Armor, Weapon or some Gold")
      sur.passItemsGiven = 2
      return
    EndIf
    i += 1
  EndWhile
  ; If the remaining items are only junk, little money and no weapon & body armor, set it to 3. Our lil adventuerer is officially considered failed.. or so
  sur.passItemsGiven = 3
Else
  ; got some stuff left. Check that what has been given is at least acceptable or else the transaction is considered failed. Acceptable is 20% of your gear, 40% if the enemy is considered an Outlaw. Money needs to be given at least 70% to be considered part of the transaction
  int req = ((0.2 + (0.2 * sur.isOutlaw as int)) * (iItm as float)) as int
  Debug.Trace("[Yamete] Surrender: Total Items = " + iItm + ", After Trade = " + nItm + " Required To Give = " + req)
  If(pl.GetItemCount(Gold001) < (numGold * 0.3) as int)
    ; If 70%+ money has been given, remove the gold
    Debug.Trace("[Yamete] Surrender: Player gave 70%+ Gold") 
    nItm -= 1
  EndIf
  If(iItm - nItm >= req)
    sur.passItemsGiven = 1
  Else
    sur.passItemsGiven = 0
  EndIf
  ; int collected = (pl.GetItemCount(Gold001) < numGold * 0.3) as int
  ; While(i > 0)
  ;   i -= 1
  ;   Form f = pl.GetNthForm(i)
  ;   If(pl.GetItemCount(f) == 0)
  ;     collected += 1
  ;     If(req == collected)
  ;       Debug.Trace("[Yamete] Surrender: Matched Required")
  ;       sur.passItemsGiven = 1
  ;       return
  ;     EndIf
  ;   EndIf
  ; EndWhile
EndIf

;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

FormList Property Yam_SurrenderPlayerItems  Auto  

MiscObject Property Gold001 Auto
