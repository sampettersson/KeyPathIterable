//
//  File.swift
//
//
//  Created by Sam Pettersson on 2023-11-23.
//

import KeyPathIterable

extension _KeyPathIterable {
  public static var allAnyKeyPaths: [AnyKeyPath] {
    (/Self.self).map {
      $0 as AnyKeyPath
    }
  }

  public static var allKeyPaths: [PartialKeyPath<Self>] {
    /Self.self
  }

  public var allKeyPaths: [PartialKeyPath<Self>] {
    /Self.self
  }

  public var allAnyKeyPaths: [AnyKeyPath] {
    allKeyPaths.map {
      $0 as AnyKeyPath
    }
  }

  public var recursivelyAllKeyPaths: [PartialKeyPath<Self>] {
    var recursivelyKeyPaths = [PartialKeyPath<Self>]()
    for keyPath in allKeyPaths {
      recursivelyKeyPaths.append(
        keyPath
      )
      if let anyKeyPathIterable = self[keyPath: keyPath] as? any _KeyPathIterable {
        for childKeyPath in anyKeyPathIterable.recursivelyAllAnyKeyPaths {
          if let appendedKeyPath = keyPath.appending(
            path: childKeyPath
          ) {
            recursivelyKeyPaths.append(
              appendedKeyPath
            )
          }
        }
      }
    }
    return recursivelyKeyPaths
  }

  public var recursivelyAllAnyKeyPaths: [AnyKeyPath] {
    recursivelyAllKeyPaths.map {
      $0 as AnyKeyPath
    }
  }
}
