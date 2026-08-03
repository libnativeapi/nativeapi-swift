// AUTO-GENERATED. DO NOT EDIT.
// Any manual changes WILL BE LOST when this file is regenerated.

import CNativeAPI
import Foundation

/// Identifies one registered event listener.
public typealias ListenerId = native_listener_id_t

final class CallbackBox0 {
  let body: () -> Void
  init(_ body: @escaping () -> Void) { self.body = body }
}

final class CallbackBox1<A0> {
  let body: (A0) -> Void
  init(_ body: @escaping (A0) -> Void) { self.body = body }
}

