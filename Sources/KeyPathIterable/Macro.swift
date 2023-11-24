@attached(member, names: named(/))
@attached(extension, conformances: _KeyPathIterable, names: named(/))
public macro KeyPathIterable() =
  #externalMacro(module: "KeyPathIterableMacrosPlugin", type: "KeyPathIterableMacro")
