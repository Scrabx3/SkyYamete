Scriptname YamBlackMarket extends Quest Conditional

YamEnslavement Property Enslavement Auto
Actor Property Charon Auto
Spell Property Transfer Auto
Race Property ElderRace Auto
Keyword Property ActorTypeNPC Auto
MiscObject Property Gold001 Auto
; ------------------------ Variables
int Property soldPayment Auto Hidden Conditional ; Pay for the sold slave

; ------------------------ Code
Function SellVictims()
	UIListMenu menu = UIExtensions.GetMenu("UIListMenu") as UIListMenu
	Alias[] tmp = Enslavement.GetAliases()
	Actor player = Game.GetPlayer()
	int i = 0
	While(i < tmp.length)
		Actor victim = (tmp[i] as ReferenceAlias).GetReference() as Actor
		If(victim)
			ActorBase vicBase = victim.GetLeveledActorBase()
			int vicLv = victim.GetLevel()
			String entryName = vicBase.GetName() + "\t (Lv. " + vicLv
			If(vicBase.GetSex() == 0)
				entryName += "/Him"
			else
				entryName += "/Her"
			EndIf
			float priceMult = 1
			If(vicBase.GetRace() == ElderRace)
				priceMult /= 3
			ElseIf(victim.HasKeyword(ActorTypeNPC))
				priceMult *= 2
			EndIf
			If(vicBase.IsUnique())
				priceMult *= 4
			EndIf
			priceMult *= 1 + (vicLv - player.GetLevel() * 0.15)
			int price = Math.Floor(Utility.RandomFloat(150, 300) * priceMult)
			entryName += "/" + price + "g)"
			menu.AddEntryItem(entryName)
		EndIf
		i += 1
	EndWhile
	menu.AddEntryItem("Cancel")
	menu.OpenMenu()
	int resultInt = menu.GetResultInt()
	String resultString = menu.GetResultString()
	If(resultInt == -1 || resultString == "Cancel")
		soldPayment = 0
		Debug.Trace("[Yamete] <BlackMarket> Canceled Selling of Enslaved Victim")
		return
	EndIf
	YamEnslavementAlias sell = tmp[resultInt] as YamEnslavementAlias
	sell.GetActorReference().AddSpell(Transfer)
	sell.FreeEnslaved(true)
	String[] lineSplit = PapyrusUtil.StringSplit(resultString, "/")
	String line = lineSplit[lineSplit.length - 1]
	soldPayment = StringUtil.Substring(line, 0, StringUtil.GetLength(line) - 2) as int
	player.AddItem(Gold001, soldPayment)
	((Self as Quest) as YamReapersMercy).AddXp(3)
	Debug.Trace("[Yamete] <BlackMarket> Selling Enslaved Victim for " + soldPayment)
EndFunction
