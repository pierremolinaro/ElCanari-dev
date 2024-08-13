//
//  codable-utilities.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------

protocol DefaultValueProviderProtocol {
  associatedtype Value : Equatable & Codable
  static var defaultValue : Value { get }
}

//--------------------------------------------------------------------------------------------------

enum False : DefaultValueProviderProtocol {
  static let defaultValue = false
}

//--------------------------------------------------------------------------------------------------

enum True : DefaultValueProviderProtocol {
  static let defaultValue = true
}

//--------------------------------------------------------------------------------------------------

enum EmptyString : DefaultValueProviderProtocol {
  static let defaultValue = ""
}

//--------------------------------------------------------------------------------------------------

enum Empty <A>: DefaultValueProviderProtocol where A: Codable & Equatable & RangeReplaceableCollection {
  static var defaultValue: A { A () }
}

//--------------------------------------------------------------------------------------------------

enum EmptyDictionary <K, V>: DefaultValueProviderProtocol where K: Hashable & Codable, V: Equatable & Codable {
  static var defaultValue: [K : V] { Dictionary () }
}

//--------------------------------------------------------------------------------------------------

enum FirstCase <A> : DefaultValueProviderProtocol where A : Codable & Equatable & CaseIterable {
  static var defaultValue: A { A.allCases.first! }
}

//--------------------------------------------------------------------------------------------------

enum Zero: DefaultValueProviderProtocol {
  static let defaultValue : Int = 0
}

//--------------------------------------------------------------------------------------------------

enum One: DefaultValueProviderProtocol {
  static let defaultValue : Int = 1
}

//--------------------------------------------------------------------------------------------------

enum ZeroDouble: DefaultValueProviderProtocol {
  static let defaultValue : Double = 0.0
}

//--------------------------------------------------------------------------------------------------

@propertyWrapper struct Default <Provider: DefaultValueProviderProtocol>: Codable {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var wrappedValue : Provider.Value

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init () {
    self.wrappedValue = Provider.defaultValue
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (wrappedValue inWrappedValue : Provider.Value) {
    self.wrappedValue = inWrappedValue
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (from decoder : Decoder) throws {
    let container = try decoder.singleValueContainer ()
    if container.decodeNil () {
      self.wrappedValue = Provider.defaultValue
    }else{
      self.wrappedValue = try container.decode (Provider.Value.self)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

//extension Default: Equatable where Provider.Value: Equatable {}
//extension Default: Hashable where Provider.Value: Hashable {}

//--------------------------------------------------------------------------------------------------

extension KeyedDecodingContainer {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func decode <P> (_ : Default<P>.Type, forKey inKey : Key) throws -> Default<P> {
    if let value = try decodeIfPresent (Default <P>.self, forKey: inKey) {
      return value
    }else{
      return Default ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

extension KeyedEncodingContainer {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func encode <P> (_ inValue : Default<P>, forKey inKey : Key) throws {
    guard inValue.wrappedValue != P.defaultValue else { return }
    try encode (inValue.wrappedValue, forKey: inKey)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
