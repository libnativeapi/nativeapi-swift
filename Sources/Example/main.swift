import nativeapi

var screenRetriever = nativeapi.ScreenRetriever()
let cursorPoint = screenRetriever.GetCursorScreenPoint()
let primaryDisplay = screenRetriever.GetPrimaryDisplay()
let allDisplays = screenRetriever.GetAllDisplays()

print(cursorPoint)
print(primaryDisplay)
print(allDisplays)

print(primaryDisplay.id)
print(primaryDisplay.name)
