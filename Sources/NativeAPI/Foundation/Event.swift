import Foundation

/// Base protocol for all events
public protocol Event {
    /// The event type identifier
    static var eventType: String { get }
}

/// Event listener protocol
public protocol EventListener {
    associatedtype EventType: Event
    func onEvent(_ event: EventType)
}

/// Callback-based event listener
public struct CallbackEventListener<EventType: Event>: EventListener {
    private let callback: (EventType) -> Void
    
    public init(_ callback: @escaping (EventType) -> Void) {
        self.callback = callback
    }
    
    public func onEvent(_ event: EventType) {
        callback(event)
    }
}
