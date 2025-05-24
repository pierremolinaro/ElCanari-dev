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

  private struct SubCategoryDescriptor {
    let subCategory : String
    let category : String
    let count : Int
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private struct CategoryDescriptor {
    let subCategories : [SubCategoryDescriptor]
    let count : Int
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func triggerStandAlonePropertyComputationForDeviceDocument () {
    self.checkEmbeddedPackages ()
    self.checkEmbeddedSymbols ()

    if let deviceCategorySet : CountedSet <String> = gPreferences?.deviceCategorySet {
      var dict = [String : CategoryDescriptor] ()
      for (category, count) in deviceCategorySet.values {
        if category.isEmpty {
          dict [""] = CategoryDescriptor (subCategories: [], count: count)
        }else{
          let names = category.split (separator: " ", maxSplits: 1)
          let baseCategory = String (names [0])
          let subCategory = (names.count > 1) ? String (names[1]) : "—"
          let a = dict [baseCategory] ?? CategoryDescriptor (subCategories: [], count: 0)
          let s = SubCategoryDescriptor (subCategory: subCategory, category: category, count: count)
          dict [baseCategory] = CategoryDescriptor (
            subCategories: a.subCategories + [s],
            count: a.count + count
          )
        }
      }
      let keys = dict.keys.sorted { $0.lowercased () < $1.lowercased () }
      var pullDownMenuItems : [AutoLayoutPullDownButton.MenuItem] = []

      let action = { [weak self] (inUserObject : Any?) in
        if let category = inUserObject as? String {
          self?.rootObject.mCategory_property.setProp (category)
        }
      }

      for baseCategory in keys {
        let descriptor = dict [baseCategory]!
        var subItems = [AutoLayoutPullDownButton.MenuItem] ()
        for subCategory in descriptor.subCategories {
          let item = AutoLayoutPullDownButton.MenuItem (
            title: subCategory.subCategory + " (\(subCategory.count))",
            userObject: subCategory.category,
            action: action,
            items: []
          )
          subItems.append (item)
        }
        let item = AutoLayoutPullDownButton.MenuItem (
          title: baseCategory + " (\(descriptor.count))",
          userObject: baseCategory,
          action: action,
          items: subItems
        )
        pullDownMenuItems.append (item)
      }
      self.mCategoryPullDownButton?.populate (from: pullDownMenuItems)

    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func checkEmbeddedPackages () {
    let fm = FileManager ()
    for package in self.rootObject.mPackages.values {
      let pathes = packageFilePathInLibraries (package.mName)
      package.mFileSystemStatusMessageForPackageInDevice = "Ok"
      package.mFileSystemStatusRequiresAttentionForPackageInDevice = false
      if pathes.count == 0 {
        package.mFileSystemStatusMessageForPackageInDevice = "No file in Library"
        package.mFileSystemStatusRequiresAttentionForPackageInDevice = true
      }else if pathes.count == 1 {
        if let data = fm.contents (atPath: pathes [0]) {
          let documentReadData = loadEasyBindingFile (fromData: data, documentName: pathes [0].lastPathComponent, undoManager: nil)
          switch documentReadData {
          case .ok (let documentData) :
            if let _ = documentData.documentRootObject as? PackageRoot,
              let version = documentData.documentMetadataDictionary [PMPackageVersion] as? Int {
              if version > package.mVersion {
                package.mFileSystemStatusMessageForPackageInDevice = "Package is updatable to version \(version)"
                package.mFileSystemStatusRequiresAttentionForPackageInDevice = true
              }
            }else{
              package.mFileSystemStatusMessageForPackageInDevice = "Invalid file at path \(pathes [0])"
              package.mFileSystemStatusRequiresAttentionForPackageInDevice = true
            }
          case .readError (_) :
            package.mFileSystemStatusMessageForPackageInDevice = "Cannot read file at path \(pathes [0])"
            package.mFileSystemStatusRequiresAttentionForPackageInDevice = true
          }
        }else{
          package.mFileSystemStatusMessageForPackageInDevice = "Cannot read file at path \(pathes [0])"
          package.mFileSystemStatusRequiresAttentionForPackageInDevice = true
        }
      }else{ // pathes.count > 1
        package.mFileSystemStatusMessageForPackageInDevice = "Several files in Library for package"
        package.mFileSystemStatusRequiresAttentionForPackageInDevice = true
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func checkEmbeddedSymbols () {
    let fm = FileManager ()
    for symbolType in self.rootObject.mSymbolTypes.values {
      symbolType.mFileSystemStatusMessageForSymbolTypeInDevice = "Ok"
      symbolType.mFileSystemStatusRequiresAttentionForSymbolTypeInDevice = false
      let pathes = symbolFilePathInLibraries (symbolType.mTypeName)
      if pathes.count == 0 {
        symbolType.mFileSystemStatusMessageForSymbolTypeInDevice = "No file in Library"
        symbolType.mFileSystemStatusRequiresAttentionForSymbolTypeInDevice = true
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
                symbolType.mFileSystemStatusRequiresAttentionForSymbolTypeInDevice = true
                if currentPinNameSet != Set (newPinNameDictionary.keys) {
                  symbolType.mFileSystemStatusMessageForSymbolTypeInDevice = "Cannot update: pin name set has changed"
                }else{ // Ok, make update
                  symbolType.mFileSystemStatusMessageForSymbolTypeInDevice = "Updatable to version \(version)"
                }
              }
            }
          case .readError (_) :
            symbolType.mFileSystemStatusRequiresAttentionForSymbolTypeInDevice = true
            symbolType.mFileSystemStatusMessageForSymbolTypeInDevice = "Cannot read at path \(pathes [0])"
          }
        }else{
          symbolType.mFileSystemStatusRequiresAttentionForSymbolTypeInDevice = true
          symbolType.mFileSystemStatusMessageForSymbolTypeInDevice = "Cannot read at path \(pathes [0])"
        }
      }else{ // pathes.count > 1
        symbolType.mFileSystemStatusRequiresAttentionForSymbolTypeInDevice = true
        symbolType.mFileSystemStatusMessageForSymbolTypeInDevice = "Cannot update, several files in Library"
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

