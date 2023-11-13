import SwiftSyntax

public protocol NamespaceSyntax: SyntaxProtocol {
  var inheritanceClause: InheritanceClauseSyntax?  { get set }
  var identifier: TokenSyntax { get set }
}

extension StructDeclSyntax: NamespaceSyntax {}
extension EnumDeclSyntax: NamespaceSyntax {}
extension ClassDeclSyntax: NamespaceSyntax {}
extension ActorDeclSyntax: NamespaceSyntax {}
