//
//  DeviceDocument-extension-add-symbol.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/03/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension DeviceDocument {

  //····················································································································

  internal func symbolTypeFromLoadSymbolDialog (_ inData : Data, _ inName : String) {
    if let (_, metadataDictionary, rootObject) = try? loadEasyBindingFile (nil, from: inData),
       let version = metadataDictionary [PMSymbolVersion] as? Int,
       let symbolRoot = rootObject as? SymbolRoot {
      let strokeBezierPathes = NSBezierPath ()
      let filledBezierPathes = NSBezierPath ()
      var symbolPinTypes = [SymbolPinTypeInDevice] ()
      symbolRoot.accumulate (
        withUndoManager: self.ebUndoManager,
        strokeBezierPathes: strokeBezierPathes,
        filledBezierPathes: filledBezierPathes,
        symbolPins: &symbolPinTypes
      )
      symbolRoot.removeRecursivelyAllRelationsShips ()

      let symbolType = SymbolTypeInDevice (self.ebUndoManager)
      symbolType.mVersion = version
      symbolType.mTypeName = inName
      symbolType.mFileData = inData
      symbolType.mStrokeBezierPath = strokeBezierPathes
      symbolType.mFilledBezierPath = filledBezierPathes
      symbolType.mPinTypes_property.setProp (symbolPinTypes)
      self.rootObject.mSymbolTypes_property.add (symbolType)
      let symbolInstance = SymbolInstanceInDevice (self.ebUndoManager)
      self.rootObject.mSymbolInstances_property.add (symbolInstance)
      symbolInstance.mType_property.setProp (symbolType)
    //--- Add pin instances
      for pinType in symbolPinTypes {
        let pinInstance = SymbolPinInstanceInDevice (self.ebUndoManager)
        pinInstance.mType_property.setProp (pinType)
        symbolInstance.mPinInstances_property.add (pinInstance)
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
