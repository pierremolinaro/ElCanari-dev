//--------------------------------------------------------------------------------------------------
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

let ENTITY_KEY = "--entity"

//--------------------------------------------------------------------------------------------------
//  EBSignatureObserverProtocol
//--------------------------------------------------------------------------------------------------

@MainActor @objc protocol EBSignatureObserverProtocol : AnyObject {
  func clearSignatureCache ()
  func signature () -> UInt32
}

//--------------------------------------------------------------------------------------------------

struct RawObject {
  let object : EBManagedObject
  let propertyDictionary : [String : NSRange]
}

//--------------------------------------------------------------------------------------------------

protocol AnySendableObject : AnyObject, Sendable {
}

//--------------------------------------------------------------------------------------------------

class EBManagedObject : EBSignatureObserverProtocol, AnySendableObject {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final var className : String { return String (describing: type (of: self)) }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private weak final var mUndoManager : UndoManager? = nil // SOULD BE WEAK

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final var savingIndex : Int { return self.mSavingIndex }

  final private var mSavingIndex = 0

  final func setSavingIndex (_ inIndex : Int) {
    self.mSavingIndex = inIndex
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  init
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init (_ inUndoManager : UndoManager?) {
    self.mUndoManager = inUndoManager
    noteObjectAllocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final var objectIndex : Int { return objectIntIdentifier (self) }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Getters
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final var undoManager : UndoManager? { self.mUndoManager }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Property accumulator
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mPropertyArray = [AnyObject] ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func accumulateProperty (_ inProperty : AnyObject) {
    self.mPropertyArray.append (inProperty)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Setup from value dictionary (binary format)
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func setUpProperties (fromValueDictionary inDictionary : [String : Any],
                              managedObjectArray inManagedObjectArray : [EBManagedObject]) {
    for property in self.mPropertyArray {
      if let storedProperty = property as? any EBDocumentStorablePropertyAndRelationshipProtocol {
        storedProperty.initialize (fromValueDictionary: inDictionary, managedObjectArray: inManagedObjectArray)
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func setUpProperties (withRangeDictionary inRangeDictionary : [String : NSRange],
                              rawObjectArray inRawObjectArray : [RawObject],
                              data inData : Data) {
    for property in self.mPropertyArray {
      if let storedProperty = property as? any EBDocumentStorablePropertyAndRelationshipProtocol,
         let range = inRangeDictionary [storedProperty.key] {
        storedProperty.initialize (fromRange: range, ofData: inData, inRawObjectArray)
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   accessibleObjectsForSaveOperation
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func accessibleObjectsForSaveOperation (objects ioObjectArray : inout [EBManagedObject]) {
    for property in self.mPropertyArray {
      if let storedProperty = property as? any EBDocumentStorablePropertyAndRelationshipProtocol {
        storedProperty.enterRelationshipObjects (intoArray: &ioObjectArray)
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Save relationships
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func savePropertiesAndRelationshipsIntoDictionary (_ ioDictionary : inout [String : Any]) {
    ioDictionary [ENTITY_KEY] = self.className
    for property in self.mPropertyArray {
      if let storedProperty = property as? any EBDocumentStorablePropertyAndRelationshipProtocol {
        storedProperty.store (inDictionary: &ioDictionary)
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Save properties
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func savePropertiesIntoDictionary (_ ioDictionary : inout [String : Any]) {
    ioDictionary [ENTITY_KEY] = self.className
    for property in self.mPropertyArray {
      if let storedProperty = property as? any EBDocumentStorablePropertyProtocol {
        storedProperty.store (inDictionary: &ioDictionary)
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   appendPropertyNamesTo(string:)
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func appendPropertyNamesTo (string ioString : inout String) {
    for property in self.mPropertyArray {
      if let storedProperty = property as? any EBDocumentStorablePropertyAndRelationshipProtocol {
        ioString += storedProperty.key + "\n"
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   appendPropertyValuesTo(data:)
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func appendPropertyValuesTo (data ioData : inout Data) {
    for property in self.mPropertyArray {
      if let storedProperty = property as? any EBDocumentStorablePropertyAndRelationshipProtocol {
        storedProperty.appendValueTo (data: &ioData)
        ioData.append (ascii: .lineFeed)
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   setSignatureObserver
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private weak var mSignatureObserver : (any EBSignatureObserverProtocol)? = nil // SOULD BE WEAK

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func setSignatureObserver (observer inObserver : (any EBSignatureObserverProtocol)?) {
    self.mSignatureObserver?.clearSignatureCache ()
    self.mSignatureObserver = inObserver
    inObserver?.clearSignatureCache ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   clearSignatureCache
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func clearSignatureCache () {
    if self.mSignature != nil {
      self.mSignature = nil
      self.mSignatureObserver?.clearSignatureCache ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   signature
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mSignature : UInt32? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func signature () -> UInt32 {
    if let s = self.mSignature {
      return s
    }else{
      let s = self.computeSignature ()
      self.mSignature = s
      return s
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func computeSignature () -> UInt32 {
    return 0
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
