Scriptname YamArmorExclusion extends ObjectReference

import JsonUtil
; -------------------------- Properties
Actor Property PlayerRef Auto
; -------------------------- Variables
string filePath = "../Yamete/excluded.json"
; -------------------------- Code
Function triggered()
  RegisterforMenu("ContainerMenu")
  Debug.MessageBox("Put all Items you wish to exclude into the Container. Once closed, all Items currently contained in it will be flagged as indestructible and handed back to you one by one.\nPlease note that while it is technically possible to add any Item to this List, there is little meaning in adding Items that cannot be worn, other than increasing the amount of processing time whenever an Item is validated for Destruction.")
  Utility.Wait(0.5)
  Activate(PlayerRef)
EndFunction

Event OnMenuClose(string MenuName)
  int numbers = GetNumItems()
  While(numbers)
    numbers -= 1
    Form toAdd = GetNthForm(numbers)
    If(FormListAdd(filePath, "items", toAdd, false) > -1)
      Debug.Notification("Item " + toAdd.GetName() + " added to the List for indestructible Items")
    EndIf
    RemoveItem(toAdd, PlayerRef.GetItemCount(toAdd), true, PlayerRef)
    Utility.Wait(1)
  EndWhile
  Debug.Notification("Finished adding Items to json")
  UnregisterForMenu("ContainerMenu")
EndEvent
