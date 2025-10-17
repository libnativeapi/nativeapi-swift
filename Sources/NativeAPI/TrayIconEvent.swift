import Foundation

/// Tray icon clicked event
public struct TrayIconClickedEvent: Event {
    public static let eventType = "TrayIconClickedEvent"
    
    public init() {}
}

/// Tray icon right-clicked event
public struct TrayIconRightClickedEvent: Event {
    public static let eventType = "TrayIconRightClickedEvent"
    
    public init() {}
}

/// Tray icon double-clicked event
public struct TrayIconDoubleClickedEvent: Event {
    public static let eventType = "TrayIconDoubleClickedEvent"
    
    public init() {}
}
