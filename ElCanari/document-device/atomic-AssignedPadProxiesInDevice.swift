//
//  atomic-AssignedPadProxiesInDevice.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 09/03/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Foundation

//----------------------------------------------------------------------------------------------------------------------

typealias AssignedPadProxiesInDevice = [AssignedPadProxy]

//----------------------------------------------------------------------------------------------------------------------

struct AssignedPadProxy : Hashable {

  //····················································································································

  let padName : String
  let symbolInstanceName : String
  let pinName : String

  //····················································································································

  init (padName inPadName : String, symbolInstanceName inSymbolInstanceName : String, pinName inPinName : String) {
    padName = inPadName
    symbolInstanceName = inSymbolInstanceName
    pinName = inPinName
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
