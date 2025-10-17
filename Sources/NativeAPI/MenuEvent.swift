import Foundation

/// Menu item clicked event
public struct MenuItemClickedEvent: Event {
    public static let eventType = "MenuItemClickedEvent"
    public let menuItemId: Int
    
    public init(_ menuItemId: Int) {
        self.menuItemId = menuItemId
    }
}

/// Menu item submenu opened event
public struct MenuItemSubmenuOpenedEvent: Event {
    public static let eventType = "MenuItemSubmenuOpenedEvent"
    public let menuItemId: Int
    
    public init(_ menuItemId: Int) {
        self.menuItemId = menuItemId
    }
}

/// Menu item submenu closed event
public struct MenuItemSubmenuClosedEvent: Event {
    public static let eventType = "MenuItemSubmenuClosedEvent"
    public let menuItemId: Int
    
    public init(_ menuItemId: Int) {
        self.menuItemId = menuItemId
    }
}

/// Menu opened event
public struct MenuOpenedEvent: Event {
    public static let eventType = "MenuOpenedEvent"
    public let menuId: Int
    
    public init(_ menuId: Int) {
        self.menuId = menuId
    }
}

/// Menu closed event
public struct MenuClosedEvent: Event {
    public static let eventType = "MenuClosedEvent"
    public let menuId: Int
    
    public init(_ menuId: Int) {
        self.menuId = menuId
    }
}
