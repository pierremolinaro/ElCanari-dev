//
//  EBObserverProtocol.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 20/12/2021.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------

 @MainActor protocol EBObserverProtocol : AnyObject {
   func observedObjectDidChange ()
}

//--------------------------------------------------------------------------------------------------
