Scriptname YamPlayer extends ReferenceAlias

YamMain Property Main Auto
Perk Property ReapersMercyInteractPerk Auto

Event OnInit()
  Main.Maintenance()
  Game.GetPlayer().AddPerk(ReapersMercyInteractPerk)
endEvent

Event OnPlayerLoadGame()
  Main.Maintenance()
EndEvent
