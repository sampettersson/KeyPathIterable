public protocol _KeyPathIterable {
  static prefix func / (_ self: Self.Type) -> [PartialKeyPath<Self>]
}

prefix operator /
