@attached(member, names: named(allKeyPaths))
@attached(extension, conformances: KeyPathIterable, names: named(allKeyPaths))
public macro KeyPathIterable() = #externalMacro(module: "KeyPathIterableMacrosPlugin", type: "KeyPathIterableMacro")
