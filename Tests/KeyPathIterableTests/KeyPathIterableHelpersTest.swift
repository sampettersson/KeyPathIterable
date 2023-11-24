import KeyPathIterableAccessor
import XCTest

final class KeyPathIterableHelpersTest: XCTestCase {

  func testRecursivelyAllKeyPaths() throws {
    let recursivelyAllKeyPaths = Set(
      NestedStruct(hoge: .init(), fuga: .init()).recursivelyAllKeyPaths)

    var expectedKeyPaths: Set<PartialKeyPath<NestedStruct>> = [
      \.hoge.hoge,
      \.hoge.fuga,
      \.hoge.foo,
      \.fuga,
      \.fuga.fuga,
      \.fuga.hoge,
    ]

    StructHoge.expectedKeyPaths.forEach { keyPath in
      let nestedKeyPath = \NestedStruct.hoge as PartialKeyPath<NestedStruct>
      expectedKeyPaths.insert(nestedKeyPath.appending(path: keyPath)!)
    }

    expectedKeyPaths.forEach { keyPath in
      XCTAssertTrue(recursivelyAllKeyPaths.contains(keyPath))
    }
  }
}
