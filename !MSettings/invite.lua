local Main = CreateFrame("Frame", "Main", UIParent)
Main:RegisterEvent("CHAT_MSG_WHISPER")
Main:SetScript("OnEvent", function(self, event, ...)

if ( event == "CHAT_MSG_WHISPER" ) then 
     if ( arg1 == "ulduar" ) then
InviteUnit(arg2)
end
     end

end)

