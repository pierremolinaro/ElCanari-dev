//
//  DocumentStorablePropertyProtocol.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/12/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor protocol EBDocumentStorablePropertyAndRelationshipProtocol : AnyObject {

  var key : String? { get }

  func initialize (fromDictionary inDictionary : [String : Any],
                   managedObjectArray inManagedObjectArray : [EBManagedObject])

  func initialize (fromRange inRange : NSRange, ofData inData : Data, _ inManagedObjectArray : [RawObject])

  func store (inDictionary ioDictionary : inout [String : Any])

  func appendValueTo (data ioData : inout Data)

  func enterRelationshipObjects (intoArray ioArray : inout [EBManagedObject])
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

protocol EBDocumentStorablePropertyProtocol : EBDocumentStorablePropertyAndRelationshipProtocol {
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
