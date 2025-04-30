//
//  document-AutoLayoutDeviceDocument-checkPackageVersion.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 18/10/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutDeviceDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func triggerStandAlonePropertyComputationForDeviceDocument () {
    self.checkEmbeddedPackages ()
    self.checkEmbeddedSymbols ()

    if let deviceCategorySet = gPreferences?.deviceCategorySet {
      let array = deviceCategorySet.keys.sorted { $0.lowercased () < $1.lowercased () }
      self.mCategoryComboBox?.setItems (array)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func checkEmbeddedPackages () {
    let fm = FileManager ()
    for package in self.rootObject.mPackages.values {
      let pathes = packageFilePathInLibraries (package.mName)
      package.mFileSystemStatusMessage = "Ok"
      package.mFileSystemStatusRequiresAttention = false
      if pathes.count == 0 {
        package.mFileSystemStatusMessage = "No file in Library"
        package.mFileSystemStatusRequiresAttention = true
      }else if pathes.count == 1 {
        if let data = fm.contents (atPath: pathes [0]) {
          let documentReadData = loadEasyBindingFile (fromData: data, documentName: pathes [0].lastPathComponent, undoManager: nil)
          switch documentReadData {
          case .ok (let documentData) :
            if let _ = documentData.documentRootObject as? PackageRoot,
              let version = documentData.documentMetadataDictionary [PMPackageVersion] as? Int {
              if version > package.mVersion {
                package.mFileSystemStatusMessage = "Package is updatable to version \(version)"
                package.mFileSystemStatusRequiresAttention = true
              }
            }else{
              package.mFileSystemStatusMessage = "Invalid file at path \(pathes [0])"
              package.mFileSystemStatusRequiresAttention = true
            }
          case .readError (_) :
            package.mFileSystemStatusMessage = "Cannot read file at path \(pathes [0])"
            package.mFileSystemStatusRequiresAttention = true
          }
        }else{
          package.mFileSystemStatusMessage = "Cannot read file at path \(pathes [0])"
          package.mFileSystemStatusRequiresAttention = true
        }
      }else{ // pathes.count > 1
        package.mFileSystemStatusMessage = "Several files in Library for package"
        package.mFileSystemStatusRequiresAttention = true
//        ioMessages.append ("Cannot update, several files in Library for package \(package.mName):")
//        for path in pathes {
//          ioMessages.append ("  - \(path)")
//        }
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func checkEmbeddedSymbols () {
    let fm = FileManager ()
    for symbolType in self.rootObject.mSymbolTypes.values {
      symbolType.mFileSystemStatusMessage = "Ok"
      symbolType.mFileSystemStatusRequiresAttention = false
      let pathes = symbolFilePathInLibraries (symbolType.mTypeName)
      if pathes.count == 0 {
        symbolType.mFileSystemStatusMessage = "No file in Library"
        symbolType.mFileSystemStatusRequiresAttention = true
//        ioMessages.append ("No file in Library for \(symbolType.mTypeName) symbol")
      }else if pathes.count == 1 {
        if let data = fm.contents (atPath: pathes [0]) {
          let documentReadData = loadEasyBindingFile (fromData: data, documentName: pathes [0].lastPathComponent, undoManager: nil)
          switch documentReadData {
          case .ok (let documentData) :
            if let symbolRoot = documentData.documentRootObject as? SymbolRoot,
               let version = documentData.documentMetadataDictionary [PMSymbolVersion] as? Int {
              if version > symbolType.mVersion {
                let strokeBezierPathes = NSBezierPath ()
                let filledBezierPathes = NSBezierPath ()
                var newSymbolPinTypes = EBReferenceArray <SymbolPinTypeInDevice> ()
                symbolRoot.accumulate (
                  withUndoManager: self.undoManager,
                  strokeBezierPathes: strokeBezierPathes,
                  filledBezierPathes: filledBezierPathes,
                  symbolPins: &newSymbolPinTypes
                )
                strokeBezierPathes.lineCapStyle = .round
                strokeBezierPathes.lineJoinStyle = .round
              //--- Check if symbol pin name set is the same
                var currentPinNameSet = Set <String> ()
                for pinType in symbolType.mPinTypes_property.propval.values {
                  currentPinNameSet.insert (pinType.mName)
                }
                var newPinNameDictionary = [String : SymbolPinTypeInDevice] ()
                for pinType in newSymbolPinTypes.values {
                  newPinNameDictionary [pinType.mName] = pinType
                }
                symbolType.mFileSystemStatusRequiresAttention = true
                if currentPinNameSet != Set (newPinNameDictionary.keys) {
                  symbolType.mFileSystemStatusMessage = "Cannot update: pin name set has changed"
//                  ioMessages.append ("Cannot update \(symbolType.mTypeName) symbol: pin name set has changed.")
                }else{ // Ok, make update
                  symbolType.mFileSystemStatusMessage = "Updatable to version \(version)"
//                  ioMessages.append ("Symbol \(symbolType.mTypeName) is updatable to version \(version).")
                }
              }
            }
          case .readError (_) :
            symbolType.mFileSystemStatusRequiresAttention = true
            symbolType.mFileSystemStatusMessage = "Cannot read at path \(pathes [0])"
//            ioMessages.append ("Invalid file at path \(pathes [0])")
          }
        }else{
          symbolType.mFileSystemStatusRequiresAttention = true
          symbolType.mFileSystemStatusMessage = "Cannot read at path \(pathes [0])"
//          ioMessages.append ("Invalid file at path \(pathes [0])")
        }
      }else{ // pathes.count > 1
        symbolType.mFileSystemStatusRequiresAttention = true
        symbolType.mFileSystemStatusMessage = "Cannot update, several files in Library"
//        ioMessages.append ("Cannot update, several files in Library for \(symbolType.mTypeName) symbol:")
//        for path in pathes {
//          ioMessages.append ("  - \(path)")
//        }
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

