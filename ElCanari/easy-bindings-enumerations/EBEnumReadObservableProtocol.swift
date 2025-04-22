//
//  EBEnumReadObservableProtocol.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/10/2023.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

@MainActor protocol EBEnumReadObservableProtocol : EBObservableObjectProtocol {
  var rawSelection : EBSelection <Int> { get }
}

//--------------------------------------------------------------------------------------------------
