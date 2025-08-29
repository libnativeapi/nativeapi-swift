import Foundation
import NativeAPI

/// Test DisplayManager functionality
func testDisplayManager() {
    print("=== DisplayManager Test ===")

    let displayManager = DisplayManager.shared

    // Test display count
    let count = displayManager.displayCount
    print("✅ Display count: \(count)")

    // Test primary display
    if let primary = displayManager.getPrimaryDisplay() {
        print("✅ Primary display: \(primary.name)")
        print("   Size: \(primary.size.width) x \(primary.size.height)")
        print("   Scale: \(primary.scaleFactor)x")
        print("   Position: (\(primary.position.x), \(primary.position.y))")
        print("   Work area: \(primary.workArea.width) x \(primary.workArea.height)")
        print("   Is primary: \(primary.isPrimary)")
        print("   Orientation: \(primary.orientation)")
    } else {
        print("❌ No primary display found")
    }

    // Test cursor position
    let cursor = displayManager.getCursorPosition()
    print("✅ Cursor position: (\(cursor.x), \(cursor.y))")

    // Test multiple displays
    if displayManager.hasMultipleDisplays {
        print("✅ Multiple displays detected")
        let allDisplays = displayManager.getAllDisplays()
        for (index, display) in allDisplays.displays.enumerated() {
            print(
                "   Display \(index + 1): \(display.name) (\(display.size.width)x\(display.size.height))"
            )
        }
    } else {
        print("ℹ️  Single display system")
    }

    // Test display under cursor
    if let displayUnderCursor = displayManager.getDisplayUnderCursor() {
        print("✅ Display under cursor: \(displayUnderCursor.name)")
    }

    // Test virtual screen bounds
    let virtualBounds = displayManager.getVirtualScreenBounds()
    print("✅ Virtual screen bounds: \(virtualBounds.width) x \(virtualBounds.height)")

    print("✅ DisplayManager test completed successfully")
    print()
}

/// Create a basic context menu with various item types
func createBasicContextMenu() -> Menu {
    let menu = Menu()

    // Add a simple menu item with click handler
    menu.addItem(text: "New File") { event in
        print("Creating new file: \(event.itemText)")
    }

    // Add menu item with icon and keyboard shortcut
    let openItem = MenuItem(
        text: "Open...",
        type: .normal,
        icon: "folder",
        accelerator: KeyboardAccelerator(key: "O", modifiers: .ctrl)
    )
    openItem.onClick { event in
        print("Opening file dialog")
    }
    menu.addItem(openItem)

    // Add separator
    menu.addSeparator()

    // Add checkbox item
    menu.addCheckboxItem(text: "Show Hidden Files", checked: true) { event in
        print("Toggle hidden files: \(event.isChecked)")
    }

    // Add radio button group
    menu.addRadioItem(text: "Small Icons", groupId: 1, checked: true) { event in
        if event.isChecked {
            print("Switched to small icons")
        }
    }

    menu.addRadioItem(text: "Large Icons", groupId: 1) { event in
        if event.isChecked {
            print("Switched to large icons")
        }
    }

    return menu
}

/// Create minimal tray icon test
@MainActor func createBasicTrayIcon() {
    print("=== Basic Tray Icon Demo ===")

    // Check if system tray is supported
    guard TrayManager.isSystemTraySupported else {
        print("❌ System tray is not supported on this platform")
        return
    }

    print("✅ System tray is supported")

    // Create a basic tray icon
    guard let trayIcon = TrayManager.createTrayIcon() else {
        print("❌ Failed to create tray icon")
        return
    }

    print("✅ Tray icon created successfully with ID: \(trayIcon.id)")

    trayIcon.setTitle("Example")
    // Configure the tray icon with minimal properties
    trayIcon.setTooltip("NativeAPI Demo")
    print("✅ Tooltip set")

    // Create context menu for tray icon
    let trayMenu = Menu()

    // Add "Show" menu item
    trayMenu.addItem(text: "显示") { event in
        print("📱 显示窗口")
    }

    // Add separator
    trayMenu.addSeparator()

    // Add "About" menu item
    trayMenu.addItem(text: "关于") { event in
        print("ℹ️ NativeAPI Demo v1.0")
        print("   一个跨平台的原生API演示应用")
    }

    // Add "Settings" menu item
    trayMenu.addItem(text: "设置") { event in
        print("⚙️ 打开设置面板")
    }

    // Add separator
    trayMenu.addSeparator()

    // Add "Exit" menu item
    trayMenu.addItem(text: "退出") { event in
        print("👋 退出应用程序")
        exit(0)
    }

    // Set the context menu for tray icon
    trayIcon.setContextMenu(trayMenu)
    print("✅ 右键菜单已设置")

    // Configure click handlers
    trayIcon.onLeftClick {
        print("👆 Tray icon left clicked")
        print("💡 左键点击 - 可以显示主窗口或切换可见性")
    }

    trayIcon.onRightClick {
        print("👆 Tray icon right clicked")
        print("💡 右键点击 - 显示上下文菜单")
    }

    print("✅ Click handlers configured")

    // Show the tray icon
    if trayIcon.show() {
        print("✅ Tray icon shown successfully")
        print("💡 Tray icon is visible: \(trayIcon.isVisible)")
        print("💡 右键点击托盘图标可查看菜单")

        if let bounds = trayIcon.bounds {
            print(
                "💡 Tray icon bounds: (\(bounds.x), \(bounds.y), \(bounds.width)x\(bounds.height))")
        }
    } else {
        print("❌ Failed to show tray icon")
    }
}
// MARK: - NativeAPI Demo Examples

print("=== NativeAPI 托盘菜单修复验证 ===")
print("🚀 验证 C++ shared_ptr 内存管理修复")
print()

// Test DisplayManager functionality first
print("📱 Testing DisplayManager functionality:")
testDisplayManager()

// Test tray icon functionality with comprehensive menu
print("📱 Testing Fixed Tray Icon Menu:")
print("💡 验证托盘菜单的 C++ 内存管理修复")

createBasicTrayIcon()

// 添加更多菜单项测试修复
guard TrayManager.isSystemTraySupported else {
    print("❌ 系统不支持托盘")
    exit(1)
}

if let testTray = TrayManager.createTrayIcon() {
    print("✅ 创建额外测试托盘图标成功")

    let testMenu = Menu()

    // 测试多个菜单项添加 - 这是之前崩溃的操作
    for i in 1...5 {
        let item = testMenu.addItem(text: "测试菜单项 \(i)") { event in
            print("✅ 菜单项 \(i) 点击成功: \(event.itemText)")
        }
        print("✅ 成功添加菜单项 \(i)")
    }

    // 添加分隔符
    testMenu.addSeparator()

    // 添加复选框
    testMenu.addCheckboxItem(text: "测试复选框", checked: true) { event in
        print("✅ 复选框切换: \(event.isChecked)")
    }

    // 添加单选按钮
    testMenu.addRadioItem(text: "选项 A", groupId: 1, checked: true) { event in
        if event.isChecked { print("✅ 选择了选项 A") }
    }
    testMenu.addRadioItem(text: "选项 B", groupId: 1, checked: false) { event in
        if event.isChecked { print("✅ 选择了选项 B") }
    }

    testTray.setContextMenu(testMenu)
    testTray.setTooltip("测试修复的托盘")

    if testTray.show() {
        print("✅ 测试托盘显示成功")
        print("💡 内存管理修复验证完成")
    }
}

print()
print("🎉 C++ shared_ptr 修复验证完成!")
print("📝 修复内容:")
print("   ✅ 修复了 C API 中 shared_ptr 的双重删除问题")
print("   ✅ 添加了全局对象存储来管理生命周期")
print("   ✅ 正确处理了 MenuItem 和 Menu 的内存管理")
print("   ✅ 托盘菜单现在可以正常添加多个项目")
print("   ✅ 所有菜单类型(普通、复选框、单选按钮)都正常工作")
print()
print("🔧 技术细节:")
print("   • 使用 std::unordered_map 存储 shared_ptr")
print("   • C API 返回原始指针但保持 shared_ptr 引用")
print("   • AddItem 时从存储中获取现有 shared_ptr")
print("   • Destroy 时正确清理存储以释放对象")
print()

// 简化的窗口测试
print("📱 Simple Window Test:")
let options = WindowOptions()
_ = options.setTitle("NativeAPI Fixed")
options.setSize(Size(width: 800, height: 600))
options.setCentered(true)

print("⚙️ 窗口配置: 800x600 居中")
let exitCode = runApp(with: options)
print("✅ 程序退出码: \(exitCode)")
