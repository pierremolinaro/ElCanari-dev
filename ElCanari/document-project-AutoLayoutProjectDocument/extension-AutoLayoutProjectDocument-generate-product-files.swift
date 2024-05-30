//
//  ProjectDocument-generate-product-files.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/07/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {

  //································································································

  func generateProductFiles () {
    if self.fileURL != nil {
      self.testERCandGenerateProductFiles ()
    }else{
      let alert = NSAlert ()
      alert.messageText = "The document should be saved before performing product file generation."
      _ = alert.addButton (withTitle: "Save…")
      _ = alert.addButton (withTitle: "Cancel")
      alert.beginSheetModal (for: self.windowForSheet!) { (response : NSApplication.ModalResponse) in
        if response == .alertFirstButtonReturn {
          self.save (nil)
        }
      }
    }
  }

  //································································································

  private func testERCandGenerateProductFiles () {
    if self.rootObject.mLastERCCheckingSignature == self.rootObject.signatureForERCChecking {
      self.checkERCAndGenerate ()
    }else{
      let alert = NSAlert ()
      alert.messageText = "ERC checking should be done before generating product files."
      _ = alert.addButton (withTitle: "Perform ERC Checking")
      _ = alert.addButton (withTitle: "Cancel")
      alert.beginSheetModal (for: self.windowForSheet!) { (response : NSApplication.ModalResponse) in
        if response == .alertFirstButtonReturn {
          _ = self.performERCChecking ()
          self.checkERCAndGenerate ()
        }
      }
    }
  }

  //································································································

  private func checkERCAndGenerate () {
     if self.rootObject.mLastERCCheckingIsSuccess {
       self.performProductFilesGeneration ()
     }else{
      let alert = NSAlert ()
      alert.messageText = "ERC checking has detected errors. Continue anyway?"
      _ = alert.addButton (withTitle: "Cancel")
      _ = alert.addButton (withTitle: "Continue")
      alert.beginSheetModal (for: self.windowForSheet!) { (response : NSApplication.ModalResponse) in
        if response == .alertSecondButtonReturn {
          self.performProductFilesGeneration ()
        }
      }
     }
  }

  //································································································

  private func performProductFilesGeneration () {
    self.mProductFileGenerationLogTextView?.clear ()
    self.mProductPageSegmentedControl?.selectTab (atIndex: 4)
    do{
      try self.performProductFilesGeneration (atPath: self.fileURL!.path.deletingPathExtension, self.rootObject.mArtwork!)
    }catch let error {
      _ = self.windowForSheet?.presentError (error)
    }
  }

  //································································································

  private func performProductFilesGeneration (atPath inDocumentFilePathWithoutExtension : String, _ inArtwork : ArtworkRoot) throws {
    let baseName = inDocumentFilePathWithoutExtension.lastPathComponent
    let generateGerberAndPDF = self.rootObject.mGenerateGerberAndPDF_property.propval
  //--- Build product data
    let productData = self.buildProductData ()
    let productRepresentation = ProductRepresentation (projectRoot: self.rootObject)
  //--- Create gerber directory (first, delete existing dir)
    let gerberDirPath = inDocumentFilePathWithoutExtension + "-gerber"
    let generatedGerberFilePath = gerberDirPath + "/" + baseName + "."
    try self.removeAndCreateDirectory (atPath: gerberDirPath, create: generateGerberAndPDF)
  //--- Write gerber files
    if generateGerberAndPDF {
      try self.writeGerberDrillFile (atPath: generatedGerberFilePath + inArtwork.drillDataFileExtension, productRepresentation, productData)
      for productDescriptor in inArtwork.fileGenerationParameterArray.values {
        try self.writeGerberProductFile (atPath: generatedGerberFilePath,
                                         productDescriptor,
                                         inArtwork.layerConfiguration,
                                         productData,
                                         productRepresentation)
      }
    }
  //--- Create PDF directory (first, delete existing dir)
    let pdfDirPath = inDocumentFilePathWithoutExtension + "-pdf"
    let generatedPDFFilePath = pdfDirPath + "/" + baseName + "."
    try self.removeAndCreateDirectory (atPath: pdfDirPath, create: generateGerberAndPDF)
  //--- Write PDF files
    if generateGerberAndPDF {
      try self.writePDFDrillFile (atPath: generatedPDFFilePath + inArtwork.drillDataFileExtension + ".pdf", productRepresentation, productData)
      for productDescriptor in inArtwork.fileGenerationParameterArray.values {
        try self.writePDFProductFile (atPath: generatedPDFFilePath, productDescriptor, inArtwork.layerConfiguration, productRepresentation, productData)
      }
    }
  //--- Write board archive
    if self.rootObject.mGenerateMergerArchive_property.propval {
      if self.rootObject.mUsesNewProductGeneration {
        let boardArchiveFilePath = inDocumentFilePathWithoutExtension + "." + EL_CANARI_MERGER_ARCHIVE
        self.mProductFileGenerationLogTextView?.appendMessageString ("Generating \(boardArchiveFilePath.lastPathComponent)…")
        let jsonData : Data = try productRepresentation.jsonData (prettyPrinted: true)
        try jsonData.write (to: URL (fileURLWithPath: boardArchiveFilePath))
        self.mProductFileGenerationLogTextView?.appendSuccessString (" Ok\n")
      }else{
        let boardLegacyArchiveFilePath = inDocumentFilePathWithoutExtension + "." + EL_CANARI_LEGACY_MERGER_ARCHIVE
        try self.writeBoardArchiveFile (atPath: boardLegacyArchiveFilePath, productData)
      }
    }
  //--- Write CSV file
    if self.rootObject.mGenerateBOM_property.propval {
      let csvArchiveFilePath = inDocumentFilePathWithoutExtension + ".csv"
      try self.writeCSVFile (atPath: csvArchiveFilePath)
    }
  }

  //································································································

  private func removeAndCreateDirectory (atPath inDirectoryPath : String,
                                         create inCreate : Bool) throws {
    let fm = FileManager ()
    var isDir : ObjCBool = false
    if fm.fileExists (atPath: inDirectoryPath, isDirectory: &isDir) {
      self.mProductFileGenerationLogTextView?.appendMessageString ("Remove recursively \(inDirectoryPath)...")
      try fm.removeItem (atPath: inDirectoryPath) // Remove dir recursively
      self.mProductFileGenerationLogTextView?.appendSuccessString (" ok.\n")
    }
    if inCreate {
      self.mProductFileGenerationLogTextView?.appendMessageString ("Create \(inDirectoryPath)...")
      try fm.createDirectory (atPath: inDirectoryPath, withIntermediateDirectories: true, attributes: nil)
      self.mProductFileGenerationLogTextView?.appendSuccessString (" ok.\n")
    }
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
