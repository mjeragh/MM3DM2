//
//  PropertyWrappers.swift
//  MM3DM2
//
//  Created by Mohammad Jeragh on 28/07/2023.
//

import Foundation
@propertyWrapper
struct UnwrapOrThrow<T> {
  var wrappedValue: T? {
    get {
      if let value = value {
        return value
      } else {
        fatalError("Unexpected nil value")
      }
    }
    set {
      value = newValue
    }
  }
  
  private var value: T?
  
  init(wrappedValue: T?) {
    self.value = wrappedValue
  }
}
