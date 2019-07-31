//
//  ProjectDocument-generate-product-files.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/07/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ProjectDocument {

  //····················································································································

  internal func generateProductFiles () {
    if self.fileURL != nil {
      self.testBoardIssuesERCandGenerateProductFiles ()
    }else{
      let alert = NSAlert ()
      alert.messageText = "The document should be saved before performing product file generation."
      alert.addButton (withTitle: "Save…")
      alert.addButton (withTitle: "Cancel")
      alert.beginSheetModal (for: self.windowForSheet!) { (response : NSApplication.ModalResponse) in
        if response == .alertFirstButtonReturn {
          self.save (nil)
        }
      }
    }
  }

  //····················································································································

  internal func testBoardIssuesERCandGenerateProductFiles () {
    if self.rootObject.boardIssues!.isEmpty {
      self.testERCandGenerateProductFiles ()
    }else{
      let alert = NSAlert ()
      alert.messageText = "There are issues in board. Continue anyway?"
      alert.addButton (withTitle: "Cancel")
      alert.addButton (withTitle: "Continue")
      alert.beginSheetModal (for: self.windowForSheet!) { (response : NSApplication.ModalResponse) in
        if response == .alertSecondButtonReturn {
          self.testERCandGenerateProductFiles ()
        }
      }
    }
  }

  //····················································································································

  private func testERCandGenerateProductFiles () {
    if self.rootObject.mLastERCCheckingSignature == self.rootObject.signatureForERCChecking {
      self.checkERCAndGenerate ()
    }else{
      let alert = NSAlert ()
      alert.messageText = "ERC checking should be done before generating product files."
      alert.addButton (withTitle: "Perform ERC Checking")
      alert.addButton (withTitle: "Cancel")
      alert.beginSheetModal (for: self.windowForSheet!) { (response : NSApplication.ModalResponse) in
        if response == .alertFirstButtonReturn {
          _ = self.performERCChecking ()
          self.checkERCAndGenerate ()
        }
      }
    }
  }

  //····················································································································

  private func checkERCAndGenerate () {
     if self.rootObject.mLastERCCheckingIsSuccess {
       self.performProductFilesGeneration ()
     }else{
      let alert = NSAlert ()
      alert.messageText = "ERC checking has detected errors. Continue anyway?"
      alert.addButton (withTitle: "Cancel")
      alert.addButton (withTitle: "Continue")
      alert.beginSheetModal (for: self.windowForSheet!) { (response : NSApplication.ModalResponse) in
        if response == .alertSecondButtonReturn {
          self.performProductFilesGeneration ()
        }
      }
     }
  }

  //····················································································································

  private func performProductFilesGeneration () {
    self.mProductFileGenerationLogTextView?.clear ()
    self.mArtworkTabView?.selectTabViewItem (at: 4)
    do{
      try self.performProductFilesGeneration (atPath: self.fileURL!.path.deletingPathExtension, self.rootObject.mArtwork!)
    }catch let error {
      self.windowForSheet?.presentError (error)
    }
  }

  //····················································································································

  private func performProductFilesGeneration (atPath inDocumentFilePathWithoutExtension : String, _ inArtwork : ArtworkRoot) throws {
    let baseName = inDocumentFilePathWithoutExtension.lastPathComponent
  //--- Build product data 
    let productData = self.buildProductData ()
  //--- Create gerber directory (first, delete existing dir)
    let gerberDirPath = inDocumentFilePathWithoutExtension + "-gerber"
    let generatedGerberFilePath = gerberDirPath + "/" + baseName + "."
    try self.removeAndCreateDirectory (atPath: gerberDirPath)
  //--- Write gerber files
    try self.writeGerberDrillFile (atPath: generatedGerberFilePath + inArtwork.drillDataFileExtension, productData)
    for productDescriptor in inArtwork.fileGenerationParameterArray {
      try self.writeGerberProductFile (atPath: generatedGerberFilePath, productDescriptor, productData)
    }
  //--- Create PDF directory (first, delete existing dir)
    let pdfDirPath = inDocumentFilePathWithoutExtension + "-pdf"
    let generatedPDFFilePath = pdfDirPath + "/" + baseName + "."
    try self.removeAndCreateDirectory (atPath: pdfDirPath)
  //--- Write PDF files
    try self.writePDFDrillFile (atPath: generatedPDFFilePath + inArtwork.drillDataFileExtension + ".pdf", productData)
    for productDescriptor in inArtwork.fileGenerationParameterArray {
      try self.writePDFProductFile (atPath: generatedPDFFilePath, productDescriptor, productData)
    }
  }

  //····················································································································

  private func removeAndCreateDirectory (atPath inDirectoryPath : String) throws {
    let fm = FileManager ()
    self.mProductFileGenerationLogTextView?.appendMessageString ("Directory \(inDirectoryPath)\n")
    var isDir : ObjCBool = false
    if fm.fileExists (atPath: inDirectoryPath, isDirectory: &isDir) {
      self.mProductFileGenerationLogTextView?.appendMessageString (" Remove recursively...")
      try fm.removeItem (atPath: inDirectoryPath) // Remove dir recursively
      self.mProductFileGenerationLogTextView?.appendSuccessString (" ok.\n")
    }
    self.mProductFileGenerationLogTextView?.appendMessageString (" Creation...")
    try fm.createDirectory (atPath: inDirectoryPath, withIntermediateDirectories: true, attributes: nil)
    self.mProductFileGenerationLogTextView?.appendSuccessString (" ok.\n")
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

