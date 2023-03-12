//
//  EBReadWriteProperty.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 12/03/2023.
//

import Foundation

protocol EBReadWriteProperty : EBObservedObject, EBObserverProtocol {
  associatedtype TYPE
  var propval : TYPE { get set }
  var selection : EBSelection <TYPE> { get }
  func setProp (_ inValue : TYPE)
}
