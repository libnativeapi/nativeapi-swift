import nativeapi

var displayManager = nativeapi.DisplayManager()
let allDisplays = displayManager.GetAll()
let primaryDisplay = displayManager.GetPrimary()
let cursorPosition = displayManager.GetCursorPosition()

print(cursorPosition)
print(primaryDisplay)
print(allDisplays)

print(primaryDisplay.width)
print(primaryDisplay.height)
