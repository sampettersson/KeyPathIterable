//
//  File.swift
//  
//
//  Created by Sam Pettersson on 2023-11-23.
//

import Foundation

@propertyWrapper struct Wrapper {
  var wrappedValue: Int
  var projectedValue: Self {
    self
  }
}
