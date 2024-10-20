//
//  extension-AutoLayoutProjectDocument-artwork.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 19/10/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutProjectDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func checkArtwork () {
    if self.rootObject.mArtworkName != "" {
      let fm = FileManager ()
      self.rootObject.mArtworkIsUpdatable = false
      var foundPaths = [String] ()
      let fileName = self.rootObject.mArtworkName + "." + ElCanariArtwork_EXTENSION
      for path in existingLibraryPathArray () {
        let artworkLibraryPath = artworkLibraryPathForPath (path)
        if let unwSubpaths = fm.subpaths (atPath: artworkLibraryPath) {
          for path in unwSubpaths {
            if path.lastPathComponent.lowercased () == fileName {
              let fullsubpath = artworkLibraryPath.appendingPathComponent (path)
              foundPaths.append (fullsubpath)
            }
          }
        }
      }
      if foundPaths.count == 0 {
        self.rootObject.mArtworkFileSystemLibraryStatus = "No Artwork file in Library"
        self.rootObject.mArtworkFileSystemLibraryRequiresAttention = true
      }else if foundPaths.count > 1 {
        self.rootObject.mArtworkFileSystemLibraryStatus = "Several Artwork files in Library"
        self.rootObject.mArtworkFileSystemLibraryRequiresAttention = true
      }else{
        let result : EBDocumentReadData = loadEasyBindingFile (fromURL: URL (fileURLWithPath: foundPaths [0]))
        switch result {
        case .ok (let documentData) :
          if let version = documentData.documentMetadataDictionary [PMArtworkVersion] as? Int {
            if version > self.rootObject.mArtworkVersion {
              self.rootObject.mArtworkFileSystemLibraryStatus = "Updatable to version \(version)"
              self.rootObject.mArtworkFileSystemLibraryRequiresAttention = true
              self.rootObject.mArtworkIsUpdatable = true
            }else{
              self.rootObject.mArtworkFileSystemLibraryStatus = "Up to date"
              self.rootObject.mArtworkFileSystemLibraryRequiresAttention = false
            }
          }else{
            self.rootObject.mArtworkFileSystemLibraryStatus = "Cannot get version in library file"
            self.rootObject.mArtworkFileSystemLibraryRequiresAttention = true
          }
        case .readError :
          self.rootObject.mArtworkFileSystemLibraryStatus = "Cannot read file in Library"
          self.rootObject.mArtworkFileSystemLibraryRequiresAttention = true
        }
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func updateArtwork () {
    let fm = FileManager ()
    var foundPaths = [String] ()
    let fileName = self.rootObject.mArtworkName + "." + ElCanariArtwork_EXTENSION
    for path in existingLibraryPathArray () {
      let artworkLibraryPath = artworkLibraryPathForPath (path)
      if let unwSubpaths = fm.subpaths (atPath: artworkLibraryPath) {
        for path in unwSubpaths {
          if path.lastPathComponent.lowercased () == fileName {
            let fullsubpath = artworkLibraryPath.appendingPathComponent (path)
            foundPaths.append (fullsubpath)
          }
        }
      }
    }
    if foundPaths.count == 1, let data = try? Data (contentsOf: URL (fileURLWithPath: foundPaths [0])) {
      let documentReadData = loadEasyBindingFile (fromData: data, documentName: foundPaths [0].lastPathComponent, undoManager: nil) // self.undoManager)
      switch documentReadData {
      case .ok (let documentData) :
        if let artworkRoot = documentData.documentRootObject as? ArtworkRoot,
           let version = documentData.documentMetadataDictionary [PMArtworkVersion] as? Int {
          self.registerUndoForTriggeringStandAlonePropertyComputationForProject ()
          self.invalidateERC ()
          self.rootObject.mArtwork = nil
          self.rootObject.mArtwork = artworkRoot
          self.rootObject.mArtworkVersion = version
          self.triggerStandAlonePropertyComputationForProject ()
        }
      case .readError :
        ()
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
