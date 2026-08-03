// Menu example — builds a menu with every item type, attaches accelerators
// and a submenu, and listens for menu events.
//
// Usage:
//   swift run MenuExample

import Foundation
import NativeAPI

guard let menu = Menu.create() else {
  fatalError("Failed to create a menu")
}
print("Created menu #\(menu.id)")

// A menu and each of its items are separate emitters, so listen on both.
let menuListener = menu.addListener { event in print("[menu] \(event)") }

// --- 1. A plain item with an accelerator ---
guard let newFile = MenuItem.createWithLabelAndType(label: "New File", type: .normal) else {
  fatalError("Failed to create a menu item")
}
newFile.setTooltip(tooltip: "Create an empty document")
newFile.setAccelerator(accelerator: KeyboardAccelerator(modifiers: .ctrl, key: "N"))
let clickListener = newFile.addListener { event in
  if case .itemClicked(let itemId) = event {
    print("[item] \(itemId) clicked")
  }
}
menu.addItem(item: newFile)

menu.addSeparator()

// --- 2. A checkbox, cycled through its three states ---
if let wordWrap = MenuItem.createWithLabelAndType(label: "Word Wrap", type: .checkbox) {
  for state in [MenuItemState.unchecked, .checked, .mixed] {
    wordWrap.setState(state: state)
    print("Word Wrap state -> \(wordWrap.state)")
  }
  menu.addItem(item: wordWrap)
}

// --- 3. A radio group ---
for (index, label) in ["Light", "Dark", "Auto"].enumerated() {
  guard let item = MenuItem.createWithLabelAndType(label: label, type: .radio) else { continue }
  item.setRadioGroup(groupId: 1)
  if index == 0 { item.setState(state: .checked) }
  menu.addItem(item: item)
}

// --- 4. A submenu ---
if let tools = Menu.create() {
  for label in ["Clear Cache", "Reset Settings"] {
    if let item = MenuItem.createWithLabelAndType(label: label, type: .normal) {
      tools.addItem(item: item)
    }
  }
  if let toolsItem = MenuItem.createWithLabelAndType(label: "Tools", type: .submenu) {
    toolsItem.setSubmenu(submenu: tools)
    menu.addItem(item: toolsItem)
  }
}

// --- 5. A disabled item ---
if let quit = MenuItem.createWithLabelAndType(label: "Quit", type: .normal) {
  quit.setEnabled(enabled: false)
  print("Quit enabled = \(quit.isEnabled)")
  menu.addItem(item: quit)
}

// --- 6. Inspect ---
print("Menu holds \(menu.itemCount) item(s)")
for item in menu.allItems {
  print("  #\(item.id) \(item.label ?? "(no label)") type=\(item.type) enabled=\(item.isEnabled)")
}
if let found = menu.getItemById(itemId: newFile.id) {
  print("Found by id: \(found.label ?? "(no label)")")
}

// --- 7. Open as a context menu ---
// Without a running event loop this is expected to fail; it shows the shape
// of the call.
if let strategy = PositioningStrategy.absolute(point: Point(x: 100, y: 200)) {
  let at = strategy.absolutePosition
  print("Positioning at (\(at.x), \(at.y))")
  let opened = menu.open(strategy: strategy, placement: .bottomStart)
  print("Context menu opened: \(opened)")
  if opened { _ = menu.close() }
}
if let atCursor = PositioningStrategy.cursorPosition() {
  print("Cursor strategy type: \(atCursor.type)")
}

// --- 8. Clean up ---
_ = newFile.removeListener(clickListener)
_ = menu.removeListener(menuListener)
menu.clear()
print("After clear: \(menu.itemCount) item(s)")
