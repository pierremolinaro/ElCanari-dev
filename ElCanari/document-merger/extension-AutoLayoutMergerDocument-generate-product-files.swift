//
//  extension-MergerDocument-generate-product-files.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/07/2018.
//
//
//--------------------------------------------------------------------------------------------------

import AppKit
import Compression

//--------------------------------------------------------------------------------------------------

extension AutoLayoutMergerDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func checkLayerConfigurationAndGenerateProductFiles () {
  //--- Layout layer configuration
    var layerSet = Set <LayerConfiguration> ()
    var artworkLayerConfiguration : LayerConfiguration? = nil
    if let artworkLayerConf = self.rootObject.mArtwork?.layerConfiguration {
      layerSet.insert (artworkLayerConf)
      artworkLayerConfiguration = artworkLayerConf
    }
    var boardLayerSet = Set <LayerConfiguration> ()
    for boardModel in self.rootObject.boardModels.values {
      layerSet.insert (boardModel.layerConfiguration)
      boardLayerSet.insert (boardModel.layerConfiguration)
    }
  //---
    if layerSet.count < 2 {
      self.generateProductFiles ()
    }else{
      let alert = NSAlert ()
      alert.messageText = "Inconsistent Board models / Artwork layout layer configuration."
      var s = ""
      for layer in boardLayerSet {
        if !s.isEmpty {
          s += ", "
        }
        switch layer {
        case  .twoLayers : s += "2"
        case .fourLayers : s += "4"
        case  .sixLayers : s += "6"
        }
      }
      var artworkLayerString = "?"
      if let alc = artworkLayerConfiguration {
        switch alc {
        case  .twoLayers : artworkLayerString = "2"
        case .fourLayers : artworkLayerString = "4"
        case  .sixLayers : artworkLayerString = "6"
        }
      }
      alert.informativeText = "Artwork handles \(artworkLayerString) layers, board elements have \(s) layers."
      _ = alert.addButton (withTitle: "Cancel")
      _ = alert.addButton (withTitle: "Proceed anyway")
      alert.beginSheetModal (
        for: self.windowForSheet!,
        completionHandler: {(response : NSApplication.ModalResponse) in
          if response == .alertSecondButtonReturn { // Proceed anyway
            self.generateProductFiles ()
          }
        }
      )
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func generateProductFiles () {
    do{
    //--- Create product directory
      if let documentFilePathWithoutExtension = self.fileURL?.path.deletingPathExtension {
        self.mLogTextView?.clear ()
        self.mProductPageSegmentedControl?.setSelectedSegment (atIndex: 4)
        let baseName = documentFilePathWithoutExtension.lastPathComponent
        let productDirectory = documentFilePathWithoutExtension.deletingLastPathComponent
        let product = self.generateProductRepresentation ()
      //--- Generate board archive
        if self.rootObject.mGenerateMergerArchive_property.propval {
          let boardArchivePath = productDirectory + "/" + baseName + "." + EL_CANARI_MERGER_ARCHIVE
          self.mLogTextView?.appendMessage ("Generating \(boardArchivePath.lastPathComponent)…")
          let data = product.encodedJSONCompressedData (
            prettyPrinted: true,
            using: COMPRESSION_LZMA
          )
          try data.write(to: URL (fileURLWithPath: boardArchivePath), options: .atomic)
          self.mLogTextView?.appendSuccess (" Ok\n")
        }
      //--- Gerber
        let gerberDirURL = URL (fileURLWithPath: NSTemporaryDirectory ())
                  .appendingPathComponent (NSUUID().uuidString)
                  .appendingPathComponent (baseName + "-gerber")
        let generateGerberAndPDF = self.rootObject.mGenerateGerberAndPDF_property.propval
        let targetArchiveURL = URL (fileURLWithPath: documentFilePathWithoutExtension + "-gerber.zip")
        try self.removeAndCreateDirectory (atURL: gerberDirURL, create: generateGerberAndPDF)
        if generateGerberAndPDF {
          let fileURL = gerberDirURL.appendingPathComponent (baseName)
          try self.generateGerberFiles (product, atURL: fileURL)
          try writeZipArchiveFile (at: targetArchiveURL, fromDirectoryURL: gerberDirURL)
        }
      //--- PDF
        let pdfDirectory = productDirectory + "/" + baseName + "-pdf"
        try self.removeAndCreateDirectory (atURL: URL (fileURLWithPath: pdfDirectory), create: generateGerberAndPDF)
        if generateGerberAndPDF {
          let filePath = pdfDirectory + "/" + baseName
          try self.generatePDFfiles (product, atPath: filePath)
          try self.writePDFDrillFile (product, atPath: filePath)
        }
      //--- Done !
        self.mLogTextView?.appendMessage ("Done.")
      }
    }catch let error {
      _ = self.windowForSheet?.presentError (error)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func removeAndCreateDirectory (atURL inDirectoryURL : URL,
                                         create inCreate : Bool) throws {
    let fm = FileManager ()
    var isDir : ObjCBool = false
    let directoryPath = inDirectoryURL.path
    if fm.fileExists (atPath: directoryPath, isDirectory: &isDir) {
      self.mLogTextView?.appendMessage ("Remove recursively \(directoryPath)...")
      try fm.removeItem (atPath: directoryPath) // Remove dir recursively
      self.mLogTextView?.appendSuccess (" ok.\n")
    }
    if inCreate {
      self.mLogTextView?.appendMessage ("Create \(directoryPath)...")
      try fm.createDirectory (atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
      self.mLogTextView?.appendSuccess (" ok.\n")
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func generateProductRepresentation () -> ProductRepresentation {
    let boardLimitWidth = ProductLength  (valueInCanariUnit: self.rootObject.boardLimitWidth)
    var product = ProductRepresentation (
      boardWidth : ProductLength (valueInCanariUnit: self.rootObject.boardWidth!),
      boardWidthUnit : self.rootObject.boardWidthUnit, // Canari Unit
      boardHeight : ProductLength (valueInCanariUnit: self.rootObject.boardHeight!),
      boardHeightUnit: self.rootObject.boardHeightUnit, // Canari Unit
      boardLimitWidth: boardLimitWidth,
      boardLimitWidthUnit: self.rootObject.boardLimitWidthUnit, // Canari Unit
      artworkName: self.rootObject.mArtworkName,
      layerConfiguration: self.rootObject.mArtwork!.layerConfiguration
    )
  //--- Add Board limits
    let boardRect = CanariRect (
      origin: .zero,
      size: CanariSize (width: self.rootObject.boardWidth!, height: self.rootObject.boardHeight!)
    ).insetBy (dx: self.rootObject.boardLimitWidth / 2, dy: self.rootObject.boardLimitWidth / 2)
    let p0 = ProductPoint (canariPoint: boardRect.bottomLeft)
    let p1 = ProductPoint (canariPoint: boardRect.bottomRight)
    let p2 = ProductPoint (canariPoint: boardRect.topRight)
    let p3 = ProductPoint (canariPoint: boardRect.topLeft)
    product.append (roundSegment: LayeredProductSegment (p1: p0, p2: p1, width: boardLimitWidth, layers: .boardLimits))
    product.append (roundSegment: LayeredProductSegment (p1: p1, p2: p2, width: boardLimitWidth, layers: .boardLimits))
    product.append (roundSegment: LayeredProductSegment (p1: p2, p2: p3, width: boardLimitWidth, layers: .boardLimits))
    product.append (roundSegment: LayeredProductSegment (p1: p3, p2: p0, width: boardLimitWidth, layers: .boardLimits))
  //--- board instances
    for element in self.rootObject.boardInstances.values {
      let boardModel : BoardModel = element.myModel!
      let compressedJSONData = boardModel.modelData
      let modelProduct = ProductRepresentation (
        fromJSONCompressedData: compressedJSONData,
        using: COMPRESSION_LZMA
      )!
      let x = ProductLength (valueInCanariUnit: element.x)
      let y = ProductLength (valueInCanariUnit: element.y)
      product.add (modelProduct, x: x, y: y, quadrantRotation: element.instanceRotation)
    }
    return product
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func generatePDFfiles (_ inProduct : ProductRepresentation,
                                     atPath inFilePath : String) throws {
    for descriptor in self.rootObject.mArtwork?.fileGenerationParameterArray.values ?? [] {
      let filePath = inFilePath + "." + descriptor.fileExtension + ".pdf"
      self.mLogTextView?.appendMessage ("Generating \(filePath.lastPathComponent)…")
      let mirror : ProductHorizontalMirror = descriptor.horizontalMirror
        ? .mirror (boardWidth: self.rootObject.boardWidth!)
        : .noMirror
      let pdfData = inProduct.pdf (
        items: descriptor.layerItems,
        mirror: mirror,
        backColor: self.rootObject.mPDFBoardBackgroundColor,
        grid: self.rootObject.mPDFProductGrid_property.propval
      )
      try pdfData.write (to: URL (fileURLWithPath: filePath), options: .atomic)
      self.mLogTextView?.appendSuccess (" Ok\n")
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func writePDFDrillFile (_ inProduct : ProductRepresentation,
                                      atPath inFilePath : String) throws {
    let drillDataFileExtension = self.rootObject.mArtwork?.drillDataFileExtension ?? "??"
    let filePath = inFilePath + "." + drillDataFileExtension + ".pdf"
    self.mLogTextView?.appendMessage ("Generating \(filePath.lastPathComponent)…")
    let pdfData = inProduct.pdf (
      items: .hole,
      mirror: .noMirror,
      backColor: self.rootObject.mPDFBoardBackgroundColor,
      grid: self.rootObject.mPDFProductGrid_property.propval
    )
    try pdfData.write (to: URL (fileURLWithPath: filePath), options: .atomic)
    self.mLogTextView?.appendSuccess (" Ok\n")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func generateGerberFiles (_ inProduct : ProductRepresentation, atURL inFileURL : URL) throws {
    for descriptor in self.rootObject.mArtwork?.fileGenerationParameterArray.values ?? [] {
      let fileURL = inFileURL.appendingPathExtension (descriptor.fileExtension)
      self.mLogTextView?.appendMessage ("Generating \(fileURL.lastPathComponent)…")
      let mirror : ProductHorizontalMirror = descriptor.horizontalMirror
        ? .mirror (boardWidth: self.rootObject.boardWidth!)
        : .noMirror
      let gerberRepresentation = inProduct.gerber (
        items: descriptor.layerItems,
        mirror: mirror
      )
      let gerberString = gerberRepresentation.gerberString (unit: self.rootObject.mGerberProductUnit)
      let gerberData : Data? = gerberString.data (using: .ascii, allowLossyConversion: false)
      try gerberData?.write (to: fileURL, options: .atomic)
      self.mLogTextView?.appendSuccess (" Ok\n")
    }
  //------------------------------------- Generate hole file
    let fileURL = inFileURL.appendingPathExtension (self.rootObject.mArtwork?.drillDataFileExtension ?? "??")
    self.mLogTextView?.appendMessage ("Generating \(fileURL.lastPathComponent)…")
    let drillString = inProduct.excellonDrillString (unit: self.rootObject.mGerberProductUnit)
    let drillData : Data? = drillString.data (using: .ascii, allowLossyConversion: false)
    try drillData?.write (to: fileURL, options: .atomic)
    self.mLogTextView?.appendSuccess (" Ok\n")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
