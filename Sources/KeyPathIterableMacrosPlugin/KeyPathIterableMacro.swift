import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

fileprivate extension VariableDeclSyntax {
    var variableName: String? {
        bindings.first?.pattern.trimmed.description
    }
}

public struct KeyPathIterableMacro: MemberMacro {
    public static func expansion<
        Declaration: DeclGroupSyntax, Context: MacroExpansionContext
    >(
        of node: AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {

        guard let decl = decodeExpansion(of: node, attachedTo: declaration, in: context) else {
            return []
        }

        let namespace = decl.identifier.text

      declaration.memberBlock.members.forEach { member in
        if let attributes = member.decl.as(VariableDeclSyntax.self)?.attributes {
          let attributes = attributes.compactMap { $0.as(AttributeSyntax.self) }

          print(attributes)
        }
      }

        let keyPaths = declaration.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self)}
            .filter {
                if decl.is(ActorDeclSyntax.self) {
                    return $0.modifiers.contains { $0.name.text == "nonisolated" }
                } else {
                    return true
                }
            }
            .flatMap { node -> [String] in
              let attributes = node.attributes.compactMap { $0.as(AttributeSyntax.self) }

              if let variableName = node.variableName {
                if !attributes.isEmpty {
                  return ["$\(variableName)", variableName]
                }

                return [variableName]
              }

              return []
            }
            .compactMap { $0 }
            .map { "\\.\($0)" }
            .joined(separator: ", ")

        let codeBlockItemList = try VariableDeclSyntax("static var allKeyPaths: [PartialKeyPath<\(raw: namespace)>]") {
            StmtSyntax("[\(raw: keyPaths)] + additionalKeyPaths")
        }
        .formatted()
        .description
        return ["\(raw: codeBlockItemList)"]
    }
}

extension KeyPathIterableMacro: ExtensionMacro {
  public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
    guard let declaration = decodeExpansion(of: node, attachedTo: declaration, in: context) else {
        return []
    }

    if let inheritedTypes = declaration.inheritanceClause?.inheritedTypes,
       inheritedTypes.contains(where: { inherited in inherited.type.trimmedDescription == "KeyPathIterable" })
    {
        return []
    }

    return [try ExtensionDeclSyntax("extension \(type.trimmed): KeyPathIterable {}")]

  }
}

public extension KeyPathIterableMacro {
    static func decodeExpansion(
        of attribute: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) -> (any NamespaceSyntax)? {
        if let structDecl = declaration.as(StructDeclSyntax.self) {
            return structDecl
        } else if let enumDecl = declaration.as(EnumDeclSyntax.self) {
            return enumDecl
        } else if let classDecl = declaration.as(ClassDeclSyntax.self) {
            return classDecl
        } else if let actorDecl = declaration.as(ActorDeclSyntax.self) {
            return actorDecl
        } else {
            context.diagnose(KeyPathIterableMacroDiagnostic.requiresStructEnumClassActor.diagnose(at: attribute))
            return nil
        }
    }
}
