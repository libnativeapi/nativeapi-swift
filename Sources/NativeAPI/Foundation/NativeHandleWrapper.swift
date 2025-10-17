import Foundation

/// Protocol for objects that wrap native handles
public protocol NativeHandleWrapper: AnyObject {
    associatedtype NativeHandleType
    
    /// The native handle associated with this wrapper
    var nativeHandle: NativeHandleType { get }
    
    /// Disposes of the native handle associated with this wrapper
    func dispose()
}

/// Base class that implements NativeHandleWrapper with automatic cleanup
open class BaseNativeHandleWrapper<NativeHandleType>: NativeHandleWrapper {
    public let nativeHandle: NativeHandleType
    private let disposeHandler: (NativeHandleType) -> Void
    
    public init(nativeHandle: NativeHandleType, disposeHandler: @escaping (NativeHandleType) -> Void) {
        self.nativeHandle = nativeHandle
        self.disposeHandler = disposeHandler
    }
    
    deinit {
        dispose()
    }
    
    public func dispose() {
        disposeHandler(nativeHandle)
    }
}
