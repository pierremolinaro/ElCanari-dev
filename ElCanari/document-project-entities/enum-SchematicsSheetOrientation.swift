//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

enum SchematicsSheetOrientation : Int, EnumPropertyProtocol {
  case horizontal = 0
  case vertical = 1


  //····················································································································

  init? (string : String) {
    switch string {
      case "horizontal" : self = .horizontal // 0
      case "vertical" : self = .vertical // 1
      case _ : return nil
    }
  }

  //····················································································································

  func descriptionForExplorer () -> String {
    switch self {
      case .horizontal : return "horizontal" // 0
      case .vertical : return "vertical" // 1
    }
  }

  //····················································································································
  //  Enum generic bindings utility functions
  //····················································································································

  static func buildfromRawValue (rawValue : Int) -> SchematicsSheetOrientation? {
    if let v = SchematicsSheetOrientation (rawValue:rawValue) {
      return v
    }else{
      return nil
    }
  }

  //····················································································································

  func enumfromRawValue (rawValue : Int) -> SchematicsSheetOrientation {
    var result = self
    let v : SchematicsSheetOrientation? = SchematicsSheetOrientation (rawValue:rawValue) ;
    if let unwrappedV = v {
      result = unwrappedV
    }
    return result
  }

  //····················································································································
  //  ValuePropertyProtocol
  //····················································································································

  func ebHashValue () -> UInt32 {
    return UInt32 (self.rawValue)
  }

  func convertToNSObject () -> NSObject {
    return NSNumber (value: self.rawValue)
  }

  static func convertFromNSObject (object : NSObject) -> SchematicsSheetOrientation {
    var result = SchematicsSheetOrientation.horizontal
    if let number = object as? NSNumber, let v = SchematicsSheetOrientation (rawValue: number.intValue) {
      result = v
    }
    return result
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

typealias EBReadOnlyProperty_SchematicsSheetOrientation = EBReadOnlyEnumProperty <SchematicsSheetOrientation>
typealias EBTransientProperty_SchematicsSheetOrientation = EBTransientEnumProperty <SchematicsSheetOrientation>
typealias EBReadWriteProperty_SchematicsSheetOrientation = EBReadWriteEnumProperty <SchematicsSheetOrientation>
typealias EBStoredProperty_SchematicsSheetOrientation = EBStoredEnumProperty <SchematicsSheetOrientation>
typealias EBPropertyProxy_SchematicsSheetOrientation = EBPropertyEnumProxy <SchematicsSheetOrientation>

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————