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

    print("✅ System tray is supported")

    // Create a basic tray icon
    guard let trayIcon = trayManager.create() else {
        print("❌ Failed to create tray icon")
        return
    }

    print("✅ Tray icon created successfully with ID: \(trayIcon.id)")

    trayIcon.setTitle("NativeAPI Demo")
    trayIcon.setTooltip("NativeAPI Tray Icon Demo")
    print("✅ Tray icon configured")

    // Create context menu for tray icon
    let contextMenu = Menu()

    // Add "Show Window" menu item
    let showItem = contextMenu.addItem(text: "显示窗口") { event in
        print("📱 显示窗口 - 菜单项点击成功!")
        print("   事件详情: ID=\(event.itemId), Text='\(event.itemText)'")
    }
    print("✅ 创建'显示窗口'菜单项，ID: \(showItem.id)")

    // Add separator
    contextMenu.addSeparator()

    // Add "About" menu item
    let aboutItem = contextMenu.addItem(text: "关于") { event in
        print("ℹ️ 关于菜单项点击成功!")
        print("   NativeAPI Demo v1.0")
        print("   事件详情: ID=\(event.itemId), Text='\(event.itemText)'")
    }
    print("✅ 创建'关于'菜单项，ID: \(aboutItem.id)")

    // Add "Settings" menu item
    let settingsItem = contextMenu.addItem(text: "设置") { event in
        print("⚙️ 设置菜单项点击成功!")
        print("   打开设置面板")
        print("   事件详情: ID=\(event.itemId), Text='\(event.itemText)'")
    }
    print("✅ 创建'设置'菜单项，ID: \(settingsItem.id)")

    // Add separator
    contextMenu.addSeparator()

    // Add checkbox items for demonstration
    print("📝 添加 Checkbox 菜单项演示...")

    // First create the checkbox items without event handlers
    let showToolbarItem = contextMenu.addCheckboxItem(text: "显示工具栏", checked: true)
    print("✅ 创建复选框'显示工具栏'，ID: \(showToolbarItem.id), 初始状态: \(showToolbarItem.isChecked)")

    let autoSaveItem = contextMenu.addCheckboxItem(text: "自动保存", checked: false)
    print("✅ 创建复选框'自动保存'，ID: \(autoSaveItem.id), 初始状态: \(autoSaveItem.isChecked)")

    // Now add event handlers after the variables are declared
    showToolbarItem.onClick { event in
        let isChecked = showToolbarItem.isChecked
        print("☑️ 工具栏显示状态切换: \(isChecked)")
        print("   工具栏现在\(isChecked ? "显示" : "隐藏")")
        print("   事件详情: ID=\(event.itemId), Text='\(event.itemText)'")
    }

    autoSaveItem.onClick { event in
        let isChecked = autoSaveItem.isChecked
        print("☑️ 自动保存状态切换: \(isChecked)")
        print("   自动保存功能\(isChecked ? "已启用" : "已禁用")")
        print("   事件详情: ID=\(event.itemId), Text='\(event.itemText)'")
    }

    // Add separator
    contextMenu.addSeparator()

    // Add radio button group for view mode selection
    print("📝 添加 Radio 按钮组演示...")

    // First create the radio items without event handlers
    let compactViewItem = contextMenu.addRadioItem(text: "紧凑视图", groupId: 1, checked: false)
    print("✅ 创建单选按钮'紧凑视图'，ID: \(compactViewItem.id), 组: 1, 选中: \(compactViewItem.isChecked)")

    let normalViewItem = contextMenu.addRadioItem(text: "普通视图", groupId: 1, checked: true)
    print("✅ 创建单选按钮'普通视图'，ID: \(normalViewItem.id), 组: 1, 选中: \(normalViewItem.isChecked)")

    let detailedViewItem = contextMenu.addRadioItem(text: "详细视图", groupId: 1, checked: false)
    print("✅ 创建单选按钮'详细视图'，ID: \(detailedViewItem.id), 组: 1, 选中: \(detailedViewItem.isChecked)")

    // Now add event handlers after the variables are declared
    compactViewItem.onClick { event in
        print("🔘 视图模式切换为: 紧凑视图")
        print("   Radio 组 ID: 1")
        print("   事件详情: ID=\(event.itemId), Text='\(event.itemText)'")
    }

    normalViewItem.onClick { event in
        print("🔘 视图模式切换为: 普通视图")
        print("   Radio 组 ID: 1")
        print("   事件详情: ID=\(event.itemId), Text='\(event.itemText)'")
    }

    detailedViewItem.onClick { event in
        print("🔘 视图模式切换为: 详细视图")
        print("   Radio 组 ID: 1")
        print("   事件详情: ID=\(event.itemId), Text='\(event.itemText)'")
    }

    // Add separator
    contextMenu.addSeparator()

    // Add "Exit" menu item
    let exitItem = contextMenu.addItem(text: "退出") { event in
        print("👋 退出菜单项点击成功!")
        print("   退出应用程序")
        print("   事件详情: ID=\(event.itemId), Text='\(event.itemText)'")
        exit(0)
    }
    print("✅ 创建'退出'菜单项，ID: \(exitItem.id)")

    // Set the context menu for tray icon
    trayIcon.setContextMenu(contextMenu)
    print("✅ 上下文菜单已设置")

    // Configure click handlers
    trayIcon.onLeftClick { event in
        print("👆 Tray icon left clicked, ID: \(event.trayIconId)")
        print("💡 左键点击 - 可以显示主窗口或切换可见性")
    }

    trayIcon.onRightClick { event in
        print("👆 Tray icon right clicked, ID: \(event.trayIconId)")
        print("💡 右键点击 - 显示上下文菜单")
    }

    trayIcon.onDoubleClick { event in
        print("👆 Tray icon double clicked, ID: \(event.trayIconId)")
        print("💡 双击事件触发")
    }

    print("✅ Click handlers configured")

    // Show the tray icon
    if trayIcon.show() {
        print("✅ Tray icon shown successfully")
        print("💡 Tray icon is visible: \(trayIcon.isVisible)")
        print("💡 右键点击托盘图标可查看菜单")

        if let bounds = trayIcon.bounds {
            print("💡 Tray icon bounds: (\(bounds.x), \(bounds.y), \(bounds.width)x\(bounds.height))")
        }
    } else {
        print("❌ Failed to show tray icon")
    }
}
// MARK: - Main Application

print("=== NativeAPI Tray Icon Demo ===")
print("🚀 Testing TrayIcon with ContextMenu")
print()

// Create and run the application with tray icon
@MainActor func runApplication() {
    // Create tray icon with context menu
    createTrayIconWithContextMenu()

    // Keep the application running
    print("\n✅ Tray icon demo started")
    print("💡 应用程序正在运行，托盘图标已显示")
    print("💡 右键点击托盘图标查看上下文菜单")
    print("💡 测试功能:")
    print("   • 普通菜单项: 显示窗口、关于、设置")
    print("   • 复选框菜单项: 显示工具栏、自动保存")
    print("   • 单选按钮组: 紧凑视图、普通视图、详细视图")
    print("   • 退出: 关闭应用程序")
    print("💡 点击菜单项测试各种事件处理")

    // Create a minimal window to keep the app running
    let windowOptions = WindowOptions()
    _ = windowOptions.setTitle("NativeAPI Demo")
    windowOptions.setSize(Size(width: 400, height: 300))

    print("💡 创建后台窗口以保持应用程序运行")
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
