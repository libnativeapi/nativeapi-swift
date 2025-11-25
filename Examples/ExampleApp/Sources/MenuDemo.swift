import Foundation
import NativeAPI
import Observation
import Shaft

@Observable
class MenuState {
    var itemCount: Int = 0
    var checkboxState: Bool = false
    var radioSelection: String = "Option 1"
    var eventHistory: [String] = []

    func addEvent(_ message: String) {
        let timestamp = SharedHelpers.formatTimestamp()
        eventHistory.insert("[\(timestamp)] \(message)", at: 0)
        if eventHistory.count > 20 {
            eventHistory.removeLast()
        }
    }
}

final class MenuDemo: StatefulWidget {
    func createState() -> MenuDemoState {
        MenuDemoState()
    }
}

final class MenuDemoState: State<MenuDemo> {
    let state = MenuState()
    var menu: Menu?
    var menuItems: [MenuItem] = []

    // Menu item references for state management
    var checkboxItem: MenuItem?
    var radio1: MenuItem?
    var radio2: MenuItem?
    var radio3: MenuItem?
    var submenu: Menu?
    var submenuItem: MenuItem?

    override func initState() {
        super.initState()
        setupMenu()
        state.addEvent("Menu system initialized")
    }

    override func dispose() {
        menu?.dispose()
        for item in menuItems {
            item.dispose()
        }
        super.dispose()
    }

    private func setupMenu() {
        menu = Menu()
        guard let menu = menu else { return }

        // Listen to menu events
        _ = menu.onOpened { [weak self] event in
            self?.state.addEvent("Menu opened (ID: \(event.menuId))")
        }

        _ = menu.onClosed { [weak self] event in
            self?.state.addEvent("Menu closed (ID: \(event.menuId))")
        }

        // 1. Normal menu item
        let normalItem = MenuItem("Normal Menu Item", type: .normal)
        _ = normalItem.onClicked { [weak self] event in
            self?.state.addEvent("Normal item clicked (ID: \(event.menuItemId))")
        }
        menu.addItem(normalItem)
        menuItems.append(normalItem)

        // 2. Separator
        menu.addSeparator()

        // 3. Checkbox item
        checkboxItem = MenuItem("Checkbox Item", type: .checkbox)
        checkboxItem?.state = .unchecked
        _ = checkboxItem?.onClicked { [weak self] event in
            guard let self = self else { return }
            self.state.checkboxState.toggle()
            self.checkboxItem?.state = self.state.checkboxState ? .checked : .unchecked
            self.state.addEvent("Checkbox clicked - State: \(self.state.checkboxState)")
        }
        if let checkboxItem = checkboxItem {
            menu.addItem(checkboxItem)
            menuItems.append(checkboxItem)
        }

        // 4. Radio items
        radio1 = MenuItem("Radio Option 1", type: .radio)
        radio1?.radioGroup = 1
        radio1?.state = .checked
        _ = radio1?.onClicked { [weak self] event in
            guard let self = self else { return }
            self.state.radioSelection = "Option 1"
            self.radio1?.state = .checked
            self.radio2?.state = .unchecked
            self.radio3?.state = .unchecked
            self.state.addEvent("Radio Option 1 selected")
        }
        if let radio1 = radio1 {
            menu.addItem(radio1)
            menuItems.append(radio1)
        }

        radio2 = MenuItem("Radio Option 2", type: .radio)
        radio2?.radioGroup = 1
        radio2?.state = .unchecked
        _ = radio2?.onClicked { [weak self] event in
            guard let self = self else { return }
            self.state.radioSelection = "Option 2"
            self.radio1?.state = .unchecked
            self.radio2?.state = .checked
            self.radio3?.state = .unchecked
            self.state.addEvent("Radio Option 2 selected")
        }
        if let radio2 = radio2 {
            menu.addItem(radio2)
            menuItems.append(radio2)
        }

        radio3 = MenuItem("Radio Option 3", type: .radio)
        radio3?.radioGroup = 1
        radio3?.state = .unchecked
        _ = radio3?.onClicked { [weak self] event in
            guard let self = self else { return }
            self.state.radioSelection = "Option 3"
            self.radio1?.state = .unchecked
            self.radio2?.state = .unchecked
            self.radio3?.state = .checked
            self.state.addEvent("Radio Option 3 selected")
        }
        if let radio3 = radio3 {
            menu.addItem(radio3)
            menuItems.append(radio3)
        }

        // 5. Separator
        menu.addSeparator()

        // 6. Menu item with tooltip
        let tooltipItem = MenuItem("Item with Tooltip", type: .normal)
        tooltipItem.tooltip = "This is a helpful tooltip"
        _ = tooltipItem.onClicked { [weak self] event in
            self?.state.addEvent("Tooltip item clicked")
        }
        menu.addItem(tooltipItem)
        menuItems.append(tooltipItem)

        // 7. Submenu
        submenu = Menu()
        submenuItem = MenuItem("Submenu", type: .submenu)

        if let submenu = submenu, let submenuItem = submenuItem {
            let subItem1 = MenuItem("Submenu Item 1")
            _ = subItem1.onClicked { [weak self] event in
                self?.state.addEvent("Submenu Item 1 clicked")
            }
            submenu.addItem(subItem1)

            let subItem2 = MenuItem("Submenu Item 2")
            _ = subItem2.onClicked { [weak self] event in
                self?.state.addEvent("Submenu Item 2 clicked")
            }
            submenu.addItem(subItem2)

            submenuItem.submenu = submenu
            menu.addItem(submenuItem)
            menuItems.append(submenuItem)
        }

        state.itemCount = menu.itemCount
    }

    private func showMenu() {
        menu?.open(PositioningStrategy.cursorPosition())
        state.addEvent("Menu opened at cursor position")
    }

    private func showMenuAt(x: Double, y: Double) {
        menu?.open(PositioningStrategy.absolute(Point(x: x, y: y)))
        state.addEvent("Menu opened at (\(Int(x)), \(Int(y)))")
    }

    private func addNewItem() {
        guard let menu = menu else { return }
        let newItem = MenuItem("New Item \(menuItems.count + 1)")
        _ = newItem.onClicked { [weak self] event in
            self?.state.addEvent("New item clicked")
        }
        menu.addItem(newItem)
        menuItems.append(newItem)
        state.itemCount = menu.itemCount
        state.addEvent("Added new menu item")
    }

    private func removeFirstItem() {
        guard let menu = menu, !menuItems.isEmpty else { return }
        let item = menuItems.removeFirst()
        let _ = menu.removeItem(item)
        state.itemCount = menu.itemCount
        state.addEvent("Removed first menu item")
    }

    private func setCheckboxMixed() {
        checkboxItem?.state = .mixed
        state.addEvent("Checkbox state set to Mixed")
    }

    override func build(context: BuildContext) -> Widget {
        Column(crossAxisAlignment: .stretch, spacing: 16) {
            // Header
            buildHeader()

            // Content area
            Expanded {
                Row(spacing: 16) {
                    // Demo area and controls (2/3 width)
                    Expanded(flex: 2) {
                        Column(spacing: 16) {
                            buildDemoArea()
                            buildControlsArea()
                        }
                    }

                    // Event history (1/3 width)
                    Expanded(flex: 1) {
                        buildEventHistory()
                    }
                }
            }
        }
        .padding(.all(16))
    }

    private func buildHeader() -> Widget {
        Row(mainAxisAlignment: .spaceBetween) {
            Column(crossAxisAlignment: .start, spacing: 4) {
                Text("Menu System")
                    .textStyle(
                        TextStyle(
                            fontSize: 24,
                            fontWeight: .bold
                        )
                    )
                Text("\(state.itemCount) menu items")
                    .textStyle(
                        TextStyle(
                            color: Color(0xFF66_6666),
                            fontSize: 14
                        )
                    )
            }
        }
        .padding(EdgeInsets.all(16))
        .boxDecoration(color: Color(0xFFFF_FFFF), borderRadius: .circular(8))
    }

    private func buildDemoArea() -> Widget {
        Column(crossAxisAlignment: .stretch, spacing: 12) {
            SectionHeader("Demo Area")

            Text("Click the button to show the context menu")
                .textStyle(
                    TextStyle(
                        color: Color(0xFF66_6666),
                        fontSize: 13
                    )
                )

            Button {
                self.showMenu()
            } child: {
                Text("Show Menu at Cursor")
            }
            .padding(EdgeInsets.symmetric(vertical: 8))

            Row(spacing: 8) {
                Button {
                    self.showMenuAt(x: 100, y: 100)
                } child: {
                    Text("Show at (100, 100)")
                }

                Button {
                    self.showMenuAt(x: 300, y: 200)
                } child: {
                    Text("Show at (300, 200)")
                }
            }

            HorizontalDivider()

            // Menu state display
            Column(spacing: 4) {
                PropertyRow(
                    label: "Item Count",
                    value: "\(state.itemCount)"
                )
                PropertyRow(
                    label: "Checkbox State",
                    value: "\(state.checkboxState)"
                )
                PropertyRow(
                    label: "Radio Selection",
                    value: state.radioSelection
                )
            }
        }
        .padding(EdgeInsets.all(16))
        .boxDecoration(color: Color(0xFFFF_FFFF), borderRadius: .circular(8))
    }

    private func buildControlsArea() -> Widget {
        Column(crossAxisAlignment: .stretch, spacing: 12) {
            SectionHeader("Controls")

            Text("Manipulate menu items dynamically")
                .textStyle(
                    TextStyle(
                        color: Color(0xFF66_6666),
                        fontSize: 13
                    )
                )

            Row(spacing: 8) {
                Button {
                    self.addNewItem()
                } child: {
                    Text("Add Item")
                }

                Button {
                    self.removeFirstItem()
                } child: {
                    Text("Remove First")
                }
            }

            Row(spacing: 8) {
                Button {
                    self.setCheckboxMixed()
                } child: {
                    Text("Set Checkbox Mixed")
                }
            }
        }
        .padding(EdgeInsets.all(16))
        .boxDecoration(color: Color(0xFFFF_FFFF), borderRadius: .circular(8))
    }

    private func buildEventHistory() -> Widget {
        Column(crossAxisAlignment: .stretch, spacing: 8) {
            SectionHeader("Event History")

            Expanded {
                EventHistoryView(events: state.eventHistory)
            }
        }
        .padding(EdgeInsets.all(16))
        .boxDecoration(color: Color(0xFFFF_FFFF), borderRadius: .circular(8))
    }
}
