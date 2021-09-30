Scriptname YamScanCacheOutfit extends ActiveMagicEffect

Quest Property Resolution Auto
Keyword Property BleedoutMark Auto
Keyword Property BleedoutPerm Auto
string storageID
Actor Target

Event OnEffectStart(Actor akTarget, Actor akCaster)
	storageID = "YamOutfit" + akTarget.GetFormID()
	Form[] items = PO3_SKSEFunctions.AddAllEquippedItemsToArray(akTarget)
	StorageUtil.FormListCopy(akTarget, storageID, items)
	RegisterForModEvent("Yam_CombatStop", "ScanStop")
	RegisterForModEvent("Yam_ResolutionStop", "ResoStop")
	Target = akTarget
EndEvent

Event ScanStop(string asEventName, string asStringArg, float afNumArg, form akSender)
	If(Resolution.IsRunning() && Target.HasMagicEffectWithKeyword(BleedoutMark))
		return
	ElseIf(!Target.HasMagicEffectWithKeyword(BleedoutPerm))
		YamMain.EquipCachedOutfit(Target)
	EndIf
	Dispel()
EndEvent

Event ResoStop(string asEventName, string asStringArg, float afNumArg, form akSender)
	If(!Target.HasMagicEffectWithKeyword(BleedoutPerm))
		YamMain.EquipCachedOutfit(Target)
	EndIf
	Dispel()
EndEvent
