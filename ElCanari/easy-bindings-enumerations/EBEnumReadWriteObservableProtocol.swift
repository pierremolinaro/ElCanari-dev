//
//  EBEnumReadWriteObservableProtocol.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/10/2023.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor protocol EBEnumReadWriteObservableProtocol : EBEnumReadObservableProtocol {
  func setFrom (rawValue : Int)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
