//
//  ProjectDocument-generate-product-csv.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/11/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate struct CSVKey : Hashable, Comparable {

  let deviceName : String
  let package : String
  let componentValue : String

  //································································································

  static func < (lhs: CSVKey, rhs: CSVKey) -> Bool {
    if lhs.deviceName < rhs.deviceName {
      return true
      }else if (lhs.deviceName == rhs.deviceName) {
        if String.numericCompare (lhs.package, rhs.package) {
          return true
        }else if (lhs.package == rhs.package) && String.numericCompare (lhs.componentValue, rhs.componentValue) {
          return true
        }else{
          return false
        }
    }else{
      return false
    }
  }

  //································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {

  //································································································

  func writeCSVFile (atPath inPath : String) throws {
    self.mProductFileGenerationLogTextView?.appendMessageString ("Generating \(inPath.lastPathComponent)…")
  //--- Iterate on components
    var dictionary = [CSVKey : [String]] ()
    for component in self.rootObject.mComponents.values {
      let deviceName = component.mDevice!.mDeviceName
      let componentValue = component.mComponentValue
      let componentName = component.componentName!
      let package = component.mSelectedPackage!.mPackageName
      let key = CSVKey (deviceName: deviceName, package: package, componentValue: componentValue)
      dictionary [key] = dictionary [key, default: []] + [componentName]
    }
    var csvContent = "\"Device\";\"Package\";\"Value\";\"Count\";\"Component Names\"\n"
    let sortedKeys = Array (dictionary.keys).sorted ()
    for key in sortedKeys {
      let componentNames = dictionary [key]!
      csvContent += "\"\(key.deviceName)\";\"\(key.package)\";\"\(key.componentValue)\";\"\(componentNames.count)\";\""
      var first = true
      for name in componentNames.numericallySorted () {
        if first {
          first = false
        }else{
          csvContent += ", "
        }
        csvContent += name
      }
      csvContent += "\"\n"
    }
  //--- Write file
    if let data = csvContent.data (using: .utf8) {
      try data.write (to: URL (fileURLWithPath: inPath))
      self.mProductFileGenerationLogTextView?.appendSuccessString (" Ok\n")
    }
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
