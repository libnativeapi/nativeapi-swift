import Foundation

/// Event emitter protocol that provides event emission capabilities
public protocol EventEmitter: AnyObject {
    /// Add a typed event listener for a specific event type
    /// - Parameter listener: The event listener
    /// - Returns: Unique listener ID that can be used to remove the listener
    func addListener<T: Event>(_ listener: CallbackEventListener<T>) -> Int
    
    /// Add a callback function as a listener for a specific event type
    /// - Parameter callback: The callback function
    /// - Returns: Unique listener ID that can be used to remove the listener
    func addCallbackListener<T: Event>(_ callback: @escaping (T) -> Void) -> Int
    
    /// Remove a listener by its ID
    /// - Parameter listenerId: The listener ID
    /// - Returns: true if the listener was found and removed, false otherwise
    func removeListener(_ listenerId: Int) -> Bool
    
    /// Remove all listeners for a specific event type, or all listeners if no type is specified
    func removeAllListeners<T: Event>(_ eventType: T.Type)
    func removeAllListeners()
    
    /// Get the number of listeners registered for a specific event type
    func getListenerCount<T: Event>(_ eventType: T.Type) -> Int
    
    /// Get the total number of registered listeners across all event types
    var totalListenerCount: Int { get }
    
    /// Check if there are any listeners for a specific event type
    func hasListeners<T: Event>(_ eventType: T.Type) -> Bool
    
    /// Emit an event synchronously to all registered listeners
    func emitSync<T: Event>(_ event: T)
    
    /// Emit an event synchronously using a factory function
    func emitSyncWithFactory<T: Event>(_ eventFactory: () -> T)
    
    /// Emit an event asynchronously
    func emitAsync<T: Event>(_ event: T)
    
    /// Emit an event asynchronously using a factory function
    func emitAsyncWithFactory<T: Event>(_ eventFactory: @escaping () -> T)
    
    /// Dispose of the event emitter and clean up resources
    func disposeEventEmitter()
}

/// Default implementation of EventEmitter
open class BaseEventEmitter: EventEmitter {
    /// Map of event types to their listeners
    private var listeners: [String: [Int: any EventListener]] = [:]
    
    /// Counter for generating unique listener IDs
    private var nextListenerId: Int = 0
    
    /// Queue for asynchronous event emission
    private let eventQueue = DispatchQueue(label: "EventEmitter.queue", qos: .userInitiated)
    
    public init() {}
    
    /// Called when the first listener is added.
    /// Subclasses can override this to start platform-specific event monitoring.
    open func startEventListening() {}
    
    /// Called when the last listener is removed.
    /// Subclasses can override this to stop platform-specific event monitoring.
    open func stopEventListening() {}
    
    public func addListener<T: Event>(_ listener: CallbackEventListener<T>) -> Int {
        let eventType = T.eventType
        let listenerId = nextListenerId
        nextListenerId += 1
        
        // Check if this is the first listener
        let wasEmpty = totalListenerCount == 0
        
        if listeners[eventType] == nil {
            listeners[eventType] = [:]
        }
        listeners[eventType]![listenerId] = listener
        
        // Call hook when transitioning from 0 to 1+ listeners
        if wasEmpty {
            startEventListening()
        }
        
        return listenerId
    }
    
    public func addCallbackListener<T: Event>(_ callback: @escaping (T) -> Void) -> Int {
        let listener = CallbackEventListener<T>(callback)
        return addListener(listener)
    }
    
    public func removeListener(_ listenerId: Int) -> Bool {
        for (eventType, eventListeners) in listeners {
            var mutableListeners = eventListeners
            if mutableListeners.removeValue(forKey: listenerId) != nil {
                if mutableListeners.isEmpty {
                    listeners.removeValue(forKey: eventType)
                } else {
                    listeners[eventType] = mutableListeners
                }
                
                // Check if this was the last listener
                if totalListenerCount == 0 {
                    stopEventListening()
                }
                
                return true
            }
        }
        return false
    }
    
    public func removeAllListeners<T: Event>(_ eventType: T.Type) {
        let hadListeners = totalListenerCount > 0
        listeners.removeValue(forKey: T.eventType)
        
        // Call hook if we had listeners and now have none
        if hadListeners && totalListenerCount == 0 {
            stopEventListening()
        }
    }
    
    public func removeAllListeners() {
        let hadListeners = totalListenerCount > 0
        listeners.removeAll()
        
        // Call hook if we had listeners
        if hadListeners {
            stopEventListening()
        }
    }
    
    public func getListenerCount<T: Event>(_ eventType: T.Type) -> Int {
        return listeners[T.eventType]?.count ?? 0
    }
    
    public var totalListenerCount: Int {
        return listeners.values.reduce(0) { $0 + $1.count }
    }
    
    public func hasListeners<T: Event>(_ eventType: T.Type) -> Bool {
        return getListenerCount(eventType) > 0
    }
    
    public func emitSync<T: Event>(_ event: T) {
        let eventType = T.eventType
        guard let eventListeners = listeners[eventType] else { return }
        
        // Create a copy of the listeners list to avoid concurrent modification
        let listenersCopy = Array(eventListeners.values)
        
        for listener in listenersCopy {
            if let callbackListener = listener as? CallbackEventListener<T> {
                callbackListener.onEvent(event)
            }
        }
    }
    
    public func emitSyncWithFactory<T: Event>(_ eventFactory: () -> T) {
        let event = eventFactory()
        emitSync(event)
    }
    
    public func emitAsync<T: Event>(_ event: T) {
        eventQueue.async { [weak self] in
            self?.emitSync(event)
        }
    }
    
    public func emitAsyncWithFactory<T: Event>(_ eventFactory: @escaping () -> T) {
        eventQueue.async { [weak self] in
            let event = eventFactory()
            self?.emitSync(event)
        }
    }
    
    public func disposeEventEmitter() {
        let hadListeners = totalListenerCount > 0
        
        // Clear all listeners
        listeners.removeAll()
        
        // Call hook if we had listeners
        if hadListeners {
            stopEventListening()
        }
    }
}

/// Extension methods for easier event listener registration
public extension EventEmitter {
    /// Convenience method to add a callback listener using a function
    /// Note: Swift does not support explicit specialization of generic methods,
    /// so we provide type-specific methods (onClicked, onOpened, etc.) instead
    func on<T: Event>(_ callback: @escaping (T) -> Void) -> Int {
        return addCallbackListener(callback)
    }
    
    /// Convenience method to add a one-time listener that removes itself after firing
    func once<T: Event>(_ callback: @escaping (T) -> Void) -> Int {
        var listenerId: Int = 0
        listenerId = addCallbackListener { [weak self] event in
            self?.removeListener(listenerId)
            callback(event)
        }
        return listenerId
    }
    
    /// Remove a listener (alias for removeListener)
    func off(_ listenerId: Int) -> Bool {
        return removeListener(listenerId)
    }
}

