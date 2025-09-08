import Foundation
import NativeAPI

/// Create minimal tray icon with context menu
@MainActor func createTrayIconWithContextMenu() {
    print("=== Tray Icon with Context Menu Demo ===")
    let trayManager = TrayManager.shared

    // Check if system tray is supported
    guard trayManager.isSupported() else {
        print("❌ System tray is not supported on this platform")
        return
    }

    // Create a basic tray icon
    guard let trayIcon = trayManager.create() else {
        print("❌ Failed to create tray icon")
        return
    }

    trayIcon.setTitle("NativeAPI Demo")
    trayIcon.setTooltip("NativeAPI Tray Icon Demo")

    // Create context menu for tray icon
    guard let contextMenu = Menu.create() else {
        print("❌ Failed to create context menu")
        return
    }

    // Add "Show Window" menu item
    guard let showItem = MenuItem.create("显示窗口") else {
        print("❌ Failed to create show item")
        return
    }
    contextMenu.addItem(showItem)
    showItem.onClicked { menuItem in
        print("📱 显示窗口")
    }

    // Add separator
    contextMenu.addSeparator()

    // Add "About" menu item
    guard let aboutItem = MenuItem.create("关于") else {
        print("❌ Failed to create about item")
        return
    }
    contextMenu.addItem(aboutItem)
    aboutItem.onClicked { menuItem in
        print("ℹ️ 关于 - NativeAPI Demo v1.0")
    }

    // Add "Settings" menu item
    guard let settingsItem = MenuItem.create("设置") else {
        print("❌ Failed to create settings item")
        return
    }
    contextMenu.addItem(settingsItem)
    settingsItem.onClicked { menuItem in
        print("⚙️ 打开设置面板")
    }

    // Add separator
    contextMenu.addSeparator()

    // Add checkbox items for demonstration
    guard let showToolbarItem = MenuItem.create("显示工具栏", type: .checkbox) else {
        print("❌ Failed to create toolbar checkbox")
        return
    }
    showToolbarItem.setChecked(true)
    contextMenu.addItem(showToolbarItem)

    guard let autoSaveItem = MenuItem.create("自动保存", type: .checkbox) else {
        print("❌ Failed to create autosave checkbox")
        return
    }
    autoSaveItem.setChecked(false)
    contextMenu.addItem(autoSaveItem)

    // Add event handlers for checkboxes
    showToolbarItem.onClicked { menuItem in
        let isChecked = menuItem.isChecked()
        print("☑️ 工具栏\(isChecked ? "显示" : "隐藏")")
    }

    autoSaveItem.onClicked { menuItem in
        let isChecked = menuItem.isChecked()
        print("☑️ 自动保存\(isChecked ? "已启用" : "已禁用")")
    }

    // Add separator
    contextMenu.addSeparator()

    // Add radio button group for view mode selection
    guard let compactViewItem = MenuItem.create("紧凑视图", type: .radio) else {
        print("❌ Failed to create compact view radio")
        return
    }
    compactViewItem.setRadioGroup(1)
    compactViewItem.setChecked(false)
    contextMenu.addItem(compactViewItem)

    guard let normalViewItem = MenuItem.create("普通视图", type: .radio) else {
        print("❌ Failed to create normal view radio")
        return
    }
    normalViewItem.setRadioGroup(1)
    normalViewItem.setChecked(true)
    contextMenu.addItem(normalViewItem)

    guard let detailedViewItem = MenuItem.create("详细视图", type: .radio) else {
        print("❌ Failed to create detailed view radio")
        return
    }
    detailedViewItem.setRadioGroup(1)
    detailedViewItem.setChecked(false)
    contextMenu.addItem(detailedViewItem)

    // Add event handlers for radio buttons
    compactViewItem.onClicked { menuItem in
        menuItem.setState(.checked)
        print("🔘 视图模式: 紧凑视图")
    }

    normalViewItem.onClicked { menuItem in
        menuItem.setState(.checked)
        print("🔘 视图模式: 普通视图")
    }

    detailedViewItem.onClicked { menuItem in
        menuItem.setState(.checked)
        print("🔘 视图模式: 详细视图")
    }

    // Add separator
    contextMenu.addSeparator()

    // Add "Exit" menu item
    guard let exitItem = MenuItem.create("退出") else {
        print("❌ Failed to create exit item")
        return
    }
    contextMenu.addItem(exitItem)
    exitItem.onClicked { menuItem in
        print("👋 退出应用程序")
        exit(0)
    }

    // Set the context menu for tray icon
    trayIcon.setContextMenu(contextMenu)

    // Configure click handlers
    trayIcon.onLeftClick { trayIcon, event in
        print("👆 托盘图标左键点击")
    }

    trayIcon.onRightClick { trayIcon, event in
        print("👆 托盘图标右键点击")
    }

    trayIcon.onDoubleClick { trayIcon, event in
        print("👆 托盘图标双击")
    }

    // Show the tray icon
    if trayIcon.show() {
        print("✅ 托盘图标已显示，右键点击查看菜单")
    } else {
        print("❌ Failed to show tray icon")
    }
}

// MARK: - Main Application

@MainActor func runApplication() {
    // Create tray icon with context menu
    createTrayIconWithContextMenu()

    print("\n✅ NativeAPI 托盘图标演示已启动")
    print("💡 功能测试:")
    print("   • 普通菜单项: 显示窗口、关于、设置")
    print("   • 复选框菜单项: 显示工具栏、自动保存")
    print("   • 单选按钮组: 紧凑视图、普通视图、详细视图")
    print("   • 退出: 关闭应用程序")

    // Create a minimal window to keep the app running
    let windowOptions = WindowOptions()
    _ = windowOptions.setTitle("NativeAPI Demo")
    windowOptions.setSize(Size(width: 400, height: 300))

    guard let window = WindowManager.shared.create(with: windowOptions) else {
        print("❌ 无法创建窗口")
        return
    }

    // Hide the window so only tray icon is visible
    window.hide()

    let exitCode = AppRunner.shared.run(with: window)
    print("💡 应用程序退出，退出码: \(exitCode.rawValue)")
}

runApplication()
