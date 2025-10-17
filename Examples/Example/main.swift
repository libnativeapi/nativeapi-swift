import Foundation
import NativeAPI

/// Create minimal tray icon with context menu
@MainActor func createTrayIconWithContextMenu() {
    print("=== Tray Icon with Context Menu Demo ===")
    let trayManager = TrayManager.shared

    // Check if system tray is supported
    guard trayManager.isSupported else {
        print("❌ System tray is not supported on this platform")
        return
    }

    // Create a basic tray icon
    let trayIcon = TrayIcon()
    trayIcon.title = "NativeAPI Demo"
    trayIcon.tooltip = "NativeAPI Tray Icon Demo"

    // Create context menu for tray icon
    let contextMenu = Menu()

    // Add "Show Window" menu item
    let showItem = MenuItem("显示窗口")
    contextMenu.addItem(showItem)
    showItem.onClicked { event in
        print("📱 显示窗口")
    }

    // Add separator
    contextMenu.addSeparator()

    // Add "About" menu item
    let aboutItem = MenuItem("关于")
    contextMenu.addItem(aboutItem)
    aboutItem.onClicked { event in
        print("ℹ️ 关于 - NativeAPI Demo v1.0")
    }

    // Add "Settings" menu item
    let settingsItem = MenuItem("设置")
    contextMenu.addItem(settingsItem)
    settingsItem.onClicked { event in
        print("⚙️ 打开设置面板")
    }

    // Add separator
    contextMenu.addSeparator()

    // Add checkbox items for demonstration
    let showToolbarItem = MenuItem("显示工具栏", type: .checkbox)
    contextMenu.addItem(showToolbarItem)

    let autoSaveItem = MenuItem("自动保存", type: .checkbox)
    contextMenu.addItem(autoSaveItem)

    // Add event handlers for checkboxes
    showToolbarItem.onClicked { event in
        print("☑️ 工具栏切换")
    }

    autoSaveItem.onClicked { event in
        print("☑️ 自动保存切换")
    }

    // Add separator
    contextMenu.addSeparator()

    // Add submenu for view modes
    let viewModeItem = MenuItem("视图模式", type: .submenu)
    let viewModeSubmenu = Menu()
    
    let compactViewItem = MenuItem("紧凑视图", type: .radio)
    viewModeSubmenu.addItem(compactViewItem)

    let normalViewItem = MenuItem("普通视图", type: .radio)
    viewModeSubmenu.addItem(normalViewItem)

    let detailedViewItem = MenuItem("详细视图", type: .radio)
    viewModeSubmenu.addItem(detailedViewItem)
    
    viewModeItem.submenu = viewModeSubmenu
    contextMenu.addItem(viewModeItem)

    // Add event handlers for radio buttons
    compactViewItem.onClicked { event in
        print("🔘 视图模式: 紧凑视图")
    }

    normalViewItem.onClicked { event in
        print("🔘 视图模式: 普通视图")
    }

    detailedViewItem.onClicked { event in
        print("🔘 视图模式: 详细视图")
    }
    
    // Add event handlers for submenu events
    viewModeItem.onSubmenuOpened { event in
        print("📂 子菜单已打开 (MenuItem ID: \(event.menuItemId))")
    }
    
    viewModeItem.onSubmenuClosed { event in
        print("📂 子菜单已关闭 (MenuItem ID: \(event.menuItemId))")
    }

    // Add separator
    contextMenu.addSeparator()

    // Add "Exit" menu item
    let exitItem = MenuItem("退出")
    contextMenu.addItem(exitItem)
    exitItem.onClicked { event in
        print("👋 退出应用程序")
        exit(0)
    }

    // Set the context menu for tray icon
    trayIcon.contextMenu = contextMenu

    // Configure tray icon event handlers
    trayIcon.onClicked { event in
        print("👆 托盘图标左键点击")
        trayIcon.openContextMenu()
    }

    trayIcon.onRightClicked { event in
        print("👆 托盘图标右键点击")
    }

    trayIcon.onDoubleClicked { event in
        print("👆 托盘图标双击")
    }
    
    // Configure menu event handlers
    contextMenu.onOpened { event in
        print("📋 菜单已打开 (Menu ID: \(event.menuId))")
    }
    
    contextMenu.onClosed { event in
        print("📋 菜单已关闭 (Menu ID: \(event.menuId))")
    }

    // Show the tray icon
    trayIcon.isVisible = true
    print("✅ 托盘图标已显示，右键点击查看菜单")
}

/// Display information demo
@MainActor func displayInfoDemo() {
    print("\n=== Display Information Demo ===")
    let displayManager = DisplayManager.shared
    
    // Get all displays
    let displays = displayManager.getAll()
    print("📺 Found \(displays.count) display(s)")
    
    for (index, display) in displays.enumerated() {
        print("\nDisplay \(index + 1):")
        print("  ID: \(display.id)")
        print("  Name: \(display.name)")
        print("  Size: \(display.size.width)x\(display.size.height)")
        print("  Position: (\(display.position.x), \(display.position.y))")
        print("  Scale Factor: \(display.scaleFactor)")
        print("  Primary: \(display.isPrimary ? "Yes" : "No")")
        print("  Orientation: \(display.orientation)")
        print("  Refresh Rate: \(display.refreshRate) Hz")
        print("  Bit Depth: \(display.bitDepth)")
    }
    
    // Get primary display
    if let primaryDisplay = displayManager.getPrimary() {
        print("\n🖥️ Primary Display: \(primaryDisplay.name)")
    }
    
    // Get cursor position
    let cursorPos = displayManager.getCursorPosition()
    print("🖱️ Cursor Position: (\(cursorPos.x), \(cursorPos.y))")
}

/// Image loading demo
@MainActor func imageLoadingDemo() {
    print("\n=== Image Loading Demo ===")
    
    // Try to load a system icon
    if let systemIcon = Image.fromSystemIcon("NSApplicationIcon") {
        print("✅ Loaded system icon: \(systemIcon.size.width)x\(systemIcon.size.height)")
        print("   Format: \(systemIcon.format ?? "unknown")")
    } else {
        print("❌ Failed to load system icon")
    }
    
    // Try to load from asset (if available)
    if let assetIcon = Image.fromAsset("assets/icons/app_icon.png") {
        print("✅ Loaded asset icon: \(assetIcon.size.width)x\(assetIcon.size.height)")
    } else {
        print("ℹ️ Asset icon not found (this is expected if not bundled)")
    }
}

// MARK: - Main Application

@MainActor func runApplication() {
    // Display information demo
    displayInfoDemo()
    
    // Image loading demo
    imageLoadingDemo()
    
    // Create tray icon with context menu
    createTrayIconWithContextMenu()

    print("\n✅ NativeAPI 演示已启动")
    print("💡 功能测试:")
    print("   • 普通菜单项: 显示窗口、关于、设置")
    print("   • 复选框菜单项: 显示工具栏、自动保存")
    print("   • 子菜单: 视图模式 (包含单选按钮组)")
    print("   • 事件监听: 托盘图标点击事件、菜单打开/关闭事件、子菜单事件")
    print("   • 退出: 关闭应用程序")

    // Create a minimal window to keep the app running
    let windowOptions = WindowOptions()
    _ = windowOptions.setTitle("NativeAPI Demo")
    windowOptions.setSize(Size(width: 400, height: 300))

    guard let window = WindowManager.shared.create(with: windowOptions) else {
        print("❌ 无法创建窗口")
        return
    }

    // Don't hide the window immediately - let AppRunner handle the visibility
    // window.hide()

    let exitCode = AppRunner.shared.run(with: window)
    print("💡 应用程序退出，退出码: \(exitCode.rawValue)")
}

runApplication()