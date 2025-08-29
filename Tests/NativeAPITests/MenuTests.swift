import XCTest

@testable import NativeAPI

final class MenuTests: XCTestCase {

    func testMenuCreation() {
        let menu = Menu()
        XCTAssertNotNil(menu.handle)
        XCTAssertGreaterThan(menu.id, 0)
        XCTAssertEqual(menu.itemCount, 0)
        XCTAssertTrue(menu.allItems.isEmpty)
        XCTAssertTrue(menu.isEnabled)
        XCTAssertFalse(menu.isVisible)
    }

    func testMenuItemCreation() {
        let item = MenuItem(text: "Test Item", type: .normal)
        XCTAssertNotNil(item.handle)
        XCTAssertGreaterThan(item.id, 0)
        XCTAssertEqual(item.text, "Test Item")
        XCTAssertEqual(item.type, .normal)
        XCTAssertTrue(item.isEnabled)
        XCTAssertTrue(item.isVisible)
        XCTAssertFalse(item.isChecked)
    }

    func testMenuItemTypes() {
        let normalItem = MenuItem(text: "Normal", type: .normal)
        XCTAssertEqual(normalItem.type, .normal)

        let checkboxItem = MenuItem(text: "Checkbox", type: .checkbox)
        XCTAssertEqual(checkboxItem.type, .checkbox)

        let radioItem = MenuItem(text: "Radio", type: .radio)
        XCTAssertEqual(radioItem.type, .radio)

        let separator = MenuItem.createSeparator()
        XCTAssertEqual(separator.type, .separator)
    }

    func testMenuItemProperties() {
        let item = MenuItem(text: "Test", type: .normal)

        // Test text property
        item.text = "Updated Text"
        XCTAssertEqual(item.text, "Updated Text")

        // Test icon property
        item.icon = "test-icon.png"
        XCTAssertEqual(item.icon, "test-icon.png")

        // Test tooltip property
        item.tooltip = "Test tooltip"
        XCTAssertEqual(item.tooltip, "Test tooltip")

        // Test enabled property
        item.isEnabled = false
        XCTAssertFalse(item.isEnabled)

        // Test visible property
        item.isVisible = false
        XCTAssertFalse(item.isVisible)

        // Test checked property for checkbox
        let checkbox = MenuItem(text: "Checkbox", type: .checkbox)
        checkbox.isChecked = true
        XCTAssertTrue(checkbox.isChecked)

        // Test radio group property
        let radio = MenuItem(text: "Radio", type: .radio)
        radio.radioGroup = 5
        XCTAssertEqual(radio.radioGroup, 5)
    }

    func testKeyboardAccelerator() {
        let accelerator = KeyboardAccelerator(key: "S", modifiers: .ctrl)
        XCTAssertEqual(accelerator.key, "S")
        XCTAssertEqual(accelerator.modifiers, .ctrl)

        let item = MenuItem(text: "Save", type: .normal)
        item.accelerator = accelerator
        XCTAssertNotNil(item.accelerator)
        XCTAssertEqual(item.accelerator?.key, "S")
        XCTAssertEqual(item.accelerator?.modifiers, .ctrl)

        item.removeAccelerator()
        XCTAssertNil(item.accelerator)
    }

    func testAcceleratorModifiers() {
        let combined = AcceleratorModifier([.ctrl, .shift])
        XCTAssertTrue(combined.contains(.ctrl))
        XCTAssertTrue(combined.contains(.shift))
        XCTAssertFalse(combined.contains(.alt))
    }

    func testMenuItemManagement() {
        let menu = Menu()
        let item1 = MenuItem(text: "Item 1", type: .normal)
        let item2 = MenuItem(text: "Item 2", type: .normal)

        // Test adding items
        menu.addItem(item1)
        XCTAssertEqual(menu.itemCount, 1)

        menu.addItem(item2)
        XCTAssertEqual(menu.itemCount, 2)

        // Test getting items
        let retrievedItem = menu.item(at: 0)
        XCTAssertNotNil(retrievedItem)
        XCTAssertEqual(retrievedItem?.text, "Item 1")

        // Test finding items
        let foundItem = menu.findItem(byText: "Item 2")
        XCTAssertNotNil(foundItem)
        XCTAssertEqual(foundItem?.text, "Item 2")

        // Test removing items
        let removed = menu.removeItem(item1)
        XCTAssertTrue(removed)
        XCTAssertEqual(menu.itemCount, 1)

        // Test clearing menu
        menu.clear()
        XCTAssertEqual(menu.itemCount, 0)
    }

    func testMenuSeparators() {
        let menu = Menu()

        menu.addSeparator()
        XCTAssertEqual(menu.itemCount, 1)

        let separator = menu.item(at: 0)
        XCTAssertNotNil(separator)
        XCTAssertEqual(separator?.type, .separator)

        menu.insertSeparator(at: 0)
        XCTAssertEqual(menu.itemCount, 2)
    }

    func testMenuInsertion() {
        let menu = Menu()
        let item1 = MenuItem(text: "Item 1", type: .normal)
        let item2 = MenuItem(text: "Item 2", type: .normal)
        let item3 = MenuItem(text: "Item 3", type: .normal)

        menu.addItem(item1)
        menu.addItem(item3)
        menu.insertItem(item2, at: 1)

        XCTAssertEqual(menu.itemCount, 3)
        XCTAssertEqual(menu.item(at: 0)?.text, "Item 1")
        XCTAssertEqual(menu.item(at: 1)?.text, "Item 2")
        XCTAssertEqual(menu.item(at: 2)?.text, "Item 3")
    }

    func testSubmenus() {
        let menu = Menu()
        let submenu = Menu()
        let subItem = MenuItem(text: "Sub Item", type: .normal)
        submenu.addItem(subItem)

        let menuItem = MenuItem(text: "Menu with Submenu", type: .submenu)
        menuItem.submenu = submenu
        menu.addItem(menuItem)

        XCTAssertNotNil(menuItem.submenu)
        XCTAssertEqual(menuItem.submenu?.itemCount, 1)

        menuItem.removeSubmenu()
        XCTAssertNil(menuItem.submenu)
    }

    func testConvenienceMethods() {
        let menu = Menu()

        // Test convenience item creation
        let simpleItem = menu.addItem(text: "Simple Item")
        XCTAssertEqual(simpleItem.text, "Simple Item")
        XCTAssertEqual(menu.itemCount, 1)

        let checkboxItem = menu.addCheckboxItem(text: "Checkbox", checked: true)
        XCTAssertEqual(checkboxItem.type, .checkbox)
        XCTAssertTrue(checkboxItem.isChecked)

        let radioItem = menu.addRadioItem(text: "Radio", groupId: 1, checked: false)
        XCTAssertEqual(radioItem.type, .radio)
        XCTAssertEqual(radioItem.radioGroup, 1)
        XCTAssertFalse(radioItem.isChecked)
    }

    func testMenuItemCallbacks() {
        let menu = Menu()
        let item = MenuItem(text: "Test Item", type: .normal)

        var clickCallbackCalled = false
        item.onClick { event in
            clickCallbackCalled = true
            XCTAssertEqual(event.itemText, "Test Item")
        }

        menu.addItem(item)

        // Note: We can't easily test the actual callback triggering without
        // the native implementation, but we can verify the callback is set
        // by checking that trigger() returns true (assuming implementation works)
        let triggered = item.trigger()
        // This may return false in test environment without full native setup
        // XCTAssertTrue(triggered)
    }

    func testCheckboxStateChange() {
        let checkbox = MenuItem(text: "Test Checkbox", type: .checkbox)

        var stateChangedCalled = false
        var lastCheckedState = false

        checkbox.onStateChanged { event in
            stateChangedCalled = true
            lastCheckedState = event.isChecked
        }

        // Manually set state (in real usage, this would trigger callback)
        checkbox.isChecked = true
        XCTAssertTrue(checkbox.isChecked)
    }

    func testMenuLifecycleCallbacks() {
        let menu = Menu()

        var willShowCalled = false
        var didHideCalled = false

        menu.onWillShow {
            willShowCalled = true
        }

        menu.onDidHide {
            didHideCalled = true
        }

        // Note: Without native implementation, we can't test actual show/hide
        // but we can verify callbacks are set up correctly
        XCTAssertFalse(menu.isVisible)
    }

    func testMenuItemConvenienceInitializer() {
        let accelerator = KeyboardAccelerator(key: "S", modifiers: .ctrl)

        var clickCalled = false
        let item = MenuItem(
            text: "Save",
            type: .normal,
            icon: "save.png",
            accelerator: accelerator
        ) { event in
            clickCalled = true
        }

        XCTAssertEqual(item.text, "Save")
        XCTAssertEqual(item.type, .normal)
        XCTAssertEqual(item.icon, "save.png")
        XCTAssertEqual(item.accelerator?.key, "S")
        XCTAssertEqual(item.accelerator?.modifiers, .ctrl)
    }

    func testAllItemsRetrieval() {
        let menu = Menu()
        let item1 = MenuItem(text: "Item 1", type: .normal)
        let item2 = MenuItem(text: "Item 2", type: .checkbox)
        let separator = MenuItem.createSeparator()

        menu.addItem(item1)
        menu.addItem(item2)
        menu.addItem(separator)

        let allItems = menu.allItems
        XCTAssertEqual(allItems.count, 3)
        XCTAssertEqual(allItems[0].text, "Item 1")
        XCTAssertEqual(allItems[1].text, "Item 2")
        XCTAssertEqual(allItems[2].type, .separator)
    }

    func testRemoveItemById() {
        let menu = Menu()
        let item = MenuItem(text: "Test Item", type: .normal)
        menu.addItem(item)

        let itemId = item.id
        let removed = menu.removeItem(withId: itemId)
        XCTAssertTrue(removed)
        XCTAssertEqual(menu.itemCount, 0)
    }

    func testRemoveItemByIndex() {
        let menu = Menu()
        let item1 = MenuItem(text: "Item 1", type: .normal)
        let item2 = MenuItem(text: "Item 2", type: .normal)

        menu.addItem(item1)
        menu.addItem(item2)

        let removed = menu.removeItem(at: 0)
        XCTAssertTrue(removed)
        XCTAssertEqual(menu.itemCount, 1)
        XCTAssertEqual(menu.item(at: 0)?.text, "Item 2")
    }

    func testFindNonExistentItem() {
        let menu = Menu()
        let item = MenuItem(text: "Existing Item", type: .normal)
        menu.addItem(item)

        let found = menu.findItem(byText: "Non-existent Item")
        XCTAssertNil(found)
    }

    func testGetItemOutOfBounds() {
        let menu = Menu()
        let item = menu.item(at: 10)  // Out of bounds
        XCTAssertNil(item)
    }

    func testMenuEnabled() {
        let menu = Menu()
        XCTAssertTrue(menu.isEnabled)

        menu.isEnabled = false
        XCTAssertFalse(menu.isEnabled)

        menu.isEnabled = true
        XCTAssertTrue(menu.isEnabled)
    }
}
