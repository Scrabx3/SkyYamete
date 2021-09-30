Scriptname YamLeftForDead extends Quest Conditional

YamMCM Property MCM Auto
ReferenceAlias Property Follower Auto
bool Property FrameLoaded Auto Hidden Conditional
bool Property DFLoaded Auto Hidden Conditional

Function init2()
  If(Game.GetModByName("DeviousFollowers.esp") != 255)
    FrameLoaded = true
    If(StorageUtil.GetIntValue(Follower.GetReference(), "DF_FollowerMaster", -1) >= 0)
      DFLoaded = true
    EndIf
  Else
    FrameLoaded = MCM.FrameAny
    DFLoaded = false
  EndIf
EndFunction

Function stackDFDebt()
  SendModEvent("DF-DebtAdjust", "", Utility.RandomFloat(100.0, 300.0))
EndFunction
