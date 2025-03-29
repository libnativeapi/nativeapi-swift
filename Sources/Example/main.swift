import libnativeapi

var screenRetriever = ScreenRetrieverMacOS()
let cursorPoint = screenRetriever.GetCursorScreenPoint()
let primaryDisplay = screenRetriever.GetPrimaryDisplay()
let allDisplays = screenRetriever.GetAllDisplays()

print(cursorPoint)
print(primaryDisplay)
print(allDisplays)

print(String(cString: primaryDisplay.id))
print(String(cString: primaryDisplay.name))
