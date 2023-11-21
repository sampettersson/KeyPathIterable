import KeyPathIterable
import KeyPathIterableMacrosPlugin
import SwiftSyntaxMacrosTestSupport
import XCTest

final class KeyPathIterableTests: XCTestCase {
  func testMacro() {
    assertMacroExpansion(
      """
      @propertyWrapper struct Wrapper {
        var wrappedValue: Int
        var projectedValue: Self {
          self
        }
      }

      @KeyPathIterable
      struct Foo {
        @Wrapper(wrappedValue: 1) var hello
        func bar() { }
      }
      """,
      expandedSource:
        """
        @propertyWrapper struct Wrapper {
          var wrappedValue: Int
          var projectedValue: Self {
            self
          }
        }
        struct Foo {
          @Wrapper(wrappedValue: 1) var hello
          func bar() { }

            static var allKeyPaths: [PartialKeyPath<Foo>] {
                [\\._hello, \\.hello] + additionalKeyPaths
            }
        }

        extension Foo: KeyPathIterable {
        }
        """,
      macros: ["KeyPathIterable": KeyPathIterableMacro.self]
    )
  }

  func testStructKeyPathIterable() throws {
    XCTAssertEqual(StructHoge.allKeyPaths, StructHoge.expectedKeyPaths)

    let count = StructHoge.allKeyPaths.compactMap { $0 as? WritableKeyPath<StructHoge, Int> }.count
    XCTAssertEqual(count, 3)
  }

  func testEnumKeyPathIterable() throws {
    XCTAssertEqual(EnumHoge.allKeyPaths, [\.hoge, \.fuga])

    let count = EnumHoge.allKeyPaths.compactMap { $0 as? WritableKeyPath<EnumHoge, Int> }.count
    XCTAssertEqual(count, 0)
  }

  func testClassKeyPathIterable() throws {
    XCTAssertEqual(ClassHoge.allKeyPaths, [\.hoge, \.fuga, \.foo])

    let count = ClassHoge.allKeyPaths.compactMap { $0 as? WritableKeyPath<ClassHoge, Int> }.count
    XCTAssertEqual(count, 2)
  }

  func testActorKeyPathIterable() throws {
    XCTAssertEqual(ActorHoge.allKeyPaths, [\.hoge])

    let count = ActorHoge.allKeyPaths.compactMap { $0 as? WritableKeyPath<ActorHoge, Int> }.count
    XCTAssertEqual(count, 0)
  }

  func testRecursivelyAllKeyPaths() throws {
    let recursivelyAllKeyPaths = Set(NestedStruct(hoge: .init(), fuga: .init()).recursivelyAllKeyPaths)

    var expectedKeyPaths: Set<PartialKeyPath<NestedStruct>> = [
      \.hoge.hoge,
      \.hoge.fuga,
      \.hoge.foo,
      \.fuga,
      \.fuga.fuga,
      \.fuga.hoge,
      \.other,
      \.other2,
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

@propertyWrapper struct Wrapper {
  var wrappedValue: Int
  var projectedValue: Self {
    self
  }
}

@KeyPathIterable
struct StructHoge {
  @Wrapper(wrappedValue: 1) var hello
  var hoge = 1
  var fuga = 2
  let foo = 1
}

extension StructHoge {
  static var expectedKeyPaths: [PartialKeyPath<Self>] {
    [\._hello, \.hello, \.hoge, \.fuga, \.foo]
  }
}

@KeyPathIterable
enum EnumHoge {
  case caseOne

  var hoge: Int { 1 }
  var fuga: Int { 2 }

  init() {
    self = .caseOne
  }
}

@KeyPathIterable
final class ClassHoge {
  var hoge = 1
  var fuga = 2
  let foo = 1

  init() {}
}

@KeyPathIterable
actor ActorHoge {
  nonisolated var hoge: Int { 1 }
  var fuga = 2
}

@KeyPathIterable
struct NestedStruct {
  let hoge: StructHoge
  let fuga: EnumHoge
}

extension NestedStruct {
  static var additionalKeyPaths: [PartialKeyPath<Self>] {
    [\.other, \.other2]
  }

  var other: Int { 0 }
  var other2: Int { 0 }
}
