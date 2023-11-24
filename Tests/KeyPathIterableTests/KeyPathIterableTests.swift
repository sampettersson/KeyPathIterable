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

            static prefix func / (_ self: Foo.Type) -> [PartialKeyPath<Foo>] {
                [\\._hello, \\.hello]
            }
        }

        extension Foo: _KeyPathIterable {

        }
        """,
      macros: ["KeyPathIterable": KeyPathIterableMacro.self]
    )
  }

  func testStructKeyPathIterable() throws {
    XCTAssertEqual(/StructHoge.self, StructHoge.expectedKeyPaths)

    let count = (/StructHoge.self).compactMap { $0 as? WritableKeyPath<StructHoge, Int> }.count
    XCTAssertEqual(count, 3)
  }

  func testEnumKeyPathIterable() throws {
    XCTAssertEqual((/EnumHoge.self), [\.hoge, \.fuga])

    let count = (/EnumHoge.self).compactMap { $0 as? WritableKeyPath<EnumHoge, Int> }.count
    XCTAssertEqual(count, 0)
  }

  func testClassKeyPathIterable() throws {
    XCTAssertEqual(/ClassHoge.self, [\.hoge, \.fuga, \.foo])

    let count = (/ClassHoge.self).compactMap { $0 as? WritableKeyPath<ClassHoge, Int> }.count
    XCTAssertEqual(count, 2)
  }
}

@KeyPathIterable
struct StructHoge {
  @Wrapper(wrappedValue: 1) var hello
  var hoge = 1
  @_spi(Internal) public var fuga = 2
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
struct NestedStruct {
  let hoge: StructHoge
  let fuga: EnumHoge
}
