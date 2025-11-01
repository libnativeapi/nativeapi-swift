import Foundation
import CNativeAPI

/// Placement options for positioning UI elements relative to an anchor.
///
/// Placement defines how a UI element (such as a menu or popover) should be
/// positioned relative to a reference point or rectangle.
///
/// Primary directions:
/// - Top: Element appears above the anchor
/// - Right: Element appears to the right of the anchor
/// - Bottom: Element appears below the anchor
/// - Left: Element appears to the left of the anchor
///
/// Alignments:
/// - Start: Element aligns to the start edge (left for horizontal, top for vertical)
/// - Center: Element centers along the anchor (default if not specified)
/// - End: Element aligns to the end edge (right for horizontal, bottom for vertical)
///
/// Example:
/// ```swift
/// // Position menu below the anchor, horizontally centered
/// menu.open(strategy, placement: .bottom)
///
/// // Position menu below the anchor, aligned to the left
/// menu.open(strategy, placement: .bottomStart)
///
/// // Position menu above the anchor, aligned to the right
/// menu.open(strategy, placement: .topEnd)
/// ```
public enum Placement: Int32, CaseIterable {
    /// Position above the anchor, horizontally centered.
    case top = 0
    
    /// Position above the anchor, aligned to the start (left).
    case topStart = 1
    
    /// Position above the anchor, aligned to the end (right).
    case topEnd = 2
    
    /// Position to the right of the anchor, vertically centered.
    case right = 3
    
    /// Position to the right of the anchor, aligned to the start (top).
    case rightStart = 4
    
    /// Position to the right of the anchor, aligned to the end (bottom).
    case rightEnd = 5
    
    /// Position below the anchor, horizontally centered.
    case bottom = 6
    
    /// Position below the anchor, aligned to the start (left).
    case bottomStart = 7
    
    /// Position below the anchor, aligned to the end (right).
    case bottomEnd = 8
    
    /// Position to the left of the anchor, vertically centered.
    case left = 9
    
    /// Position to the left of the anchor, aligned to the start (top).
    case leftStart = 10
    
    /// Position to the left of the anchor, aligned to the end (bottom).
    case leftEnd = 11
    
    internal var nativeValue: native_placement_t {
        switch self {
        case .top: return NATIVE_PLACEMENT_TOP
        case .topStart: return NATIVE_PLACEMENT_TOP_START
        case .topEnd: return NATIVE_PLACEMENT_TOP_END
        case .right: return NATIVE_PLACEMENT_RIGHT
        case .rightStart: return NATIVE_PLACEMENT_RIGHT_START
        case .rightEnd: return NATIVE_PLACEMENT_RIGHT_END
        case .bottom: return NATIVE_PLACEMENT_BOTTOM
        case .bottomStart: return NATIVE_PLACEMENT_BOTTOM_START
        case .bottomEnd: return NATIVE_PLACEMENT_BOTTOM_END
        case .left: return NATIVE_PLACEMENT_LEFT
        case .leftStart: return NATIVE_PLACEMENT_LEFT_START
        case .leftEnd: return NATIVE_PLACEMENT_LEFT_END
        }
    }
    
    internal init(nativeValue: native_placement_t) {
        switch nativeValue {
        case NATIVE_PLACEMENT_TOP: self = .top
        case NATIVE_PLACEMENT_TOP_START: self = .topStart
        case NATIVE_PLACEMENT_TOP_END: self = .topEnd
        case NATIVE_PLACEMENT_RIGHT: self = .right
        case NATIVE_PLACEMENT_RIGHT_START: self = .rightStart
        case NATIVE_PLACEMENT_RIGHT_END: self = .rightEnd
        case NATIVE_PLACEMENT_BOTTOM: self = .bottom
        case NATIVE_PLACEMENT_BOTTOM_START: self = .bottomStart
        case NATIVE_PLACEMENT_BOTTOM_END: self = .bottomEnd
        case NATIVE_PLACEMENT_LEFT: self = .left
        case NATIVE_PLACEMENT_LEFT_START: self = .leftStart
        case NATIVE_PLACEMENT_LEFT_END: self = .leftEnd
        default: self = .bottomStart
        }
    }
}

