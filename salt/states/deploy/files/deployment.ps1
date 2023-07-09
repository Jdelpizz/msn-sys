# Deploy msn-sys
# Depending on grain deploy different msn-system
# Depending on grain deploy different XML

# Fix Scheduled Tasks
# Needs xml for more granular options
# Needs /ru so it runs whether user is logged in or not
# Does not need authors or principles section of XML
schtasks.exe /Create /TN "\Mission System\server" /XML "C:\Mission System\scheduled task.xml" /ru SYSTEM 
