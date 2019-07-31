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

  private func writeGerberDrillFile (atPath inPath : String, _ inProductData : ProductData) throws {
    self.mProductFileGenerationLogTextView?.appendMessageString ("Generating \(inPath.lastPathComponent)…")
    var s = "M48\n"
    s += "INCH\n"
    let keys = inProductData.holeDictionary.keys.sorted ()
 //--- Write hole diameters
    var idx = 0
    for diameter in keys {
      idx += 1
      s += "T\(idx)C\(String(format: "%.4f", cocoaToInch (diameter)))\n"
    }
 //--- Write holes
    s += "%\n"
    s += "G05\n"
    s += "M72\n"
    idx = 0
    for diameter in keys {
      idx += 1
      s += "T\(idx)\n"
      for (p1, p2) in inProductData.holeDictionary [diameter]! {
        if (p1.x == p2.x) && (p1.y == p2.y) { // Circular
          s += "X\(String(format: "%.4f", cocoaToInch (p1.x)))Y\(String(format: "%.4f", cocoaToInch (p1.y)))\n"
        }else{ // oblong
          s += "X\(String(format: "%.4f", cocoaToInch (p1.x)))Y\(String(format: "%.4f", cocoaToInch (p1.y)))"
          s += "G85X\(String(format: "%.4f", cocoaToInch (p2.x)))Y\(String(format: "%.4f", cocoaToInch (p2.y)))\n"
        }
      }
    }
 //--- End of file
    s += "T0\n"
    s += "M30\n" // End code
 //--- Write file
    let data : Data? = s.data (using: .ascii, allowLossyConversion:false)
    try data?.write (to: URL (fileURLWithPath: inPath), options: .atomic)
    self.mProductFileGenerationLogTextView?.appendSuccessString (" Ok\n")
  }

  //····················································································································

  private func writeGerberProductFile (atPath inPath : String, _ inDescriptor : ArtworkFileGenerationParameters, _ inProductData : ProductData) throws {
    let path = inPath + inDescriptor.fileExtension
    self.mProductFileGenerationLogTextView?.appendMessageString ("Generating \(path.lastPathComponent)…")
    var s = "%FSLAX24Y24*%\n" // A = Absolute coordinates, 24 = all data are in 2.4 form
    s += "%MOIN*%\n" // length unit is inch
    var apertureDictionary = [String : [String]] ()
    var polygons = [[String]] ()
    if inDescriptor.drawBoardLimits {
      let boardLimitPolygon = inProductData.boardLimitPolygon
      var drawings = [String] ()
      drawings.append ("X\(cocoaToMilTenth (boardLimitPolygon.origin.x))Y\(boardLimitPolygon.origin.y)D02")
      for p in boardLimitPolygon.lines {
        let x = cocoaToMilTenth (p.x)
        let y = cocoaToMilTenth (p.y)
        drawings.append ("X\(x)Y\(y)D01")
      }
      if boardLimitPolygon.closed {
        drawings.append ("X\(cocoaToMilTenth (boardLimitPolygon.origin.x))Y\(boardLimitPolygon.origin.y)D01")
      }
      let apertureString = "C,\(String(format: "%.4f", cocoaToInch (inProductData.boardLimitWidth)))"
      apertureDictionary [apertureString] = (apertureDictionary [apertureString] ?? []) + drawings
    }
    let keys = apertureDictionary.keys.sorted ()
  //--- Write aperture diameters
    var idx = 10
    for aperture in keys {
      s += "%ADD\(idx)\(aperture)*%\n"
      idx += 1
    }
  //--- Write drawings
    idx = 10
    for aperture in keys {
      s += "D\(idx)*\n"
      s += "G01" // Linear interpolation
      for element in apertureDictionary [aperture]! {
        s += element + "*\n"
      }
      idx += 1
    }
  //--- Write polygon fills
    for poly in polygons {
      s += "G36*\n"
      for str in poly {
        s += str + "*\n"
      }
      s += "G37*\n"
    }
  //--- Write file
    s += "M02*\n"
    let data : Data? = s.data (using: .ascii, allowLossyConversion:false)
    try data?.write (to: URL (fileURLWithPath: path), options: .atomic)
    self.mProductFileGenerationLogTextView?.appendSuccessString (" Ok\n")
  }

  //····················································································································

  private func writePDFDrillFile (atPath inPath : String, _ inProductData : ProductData) throws {
    self.mProductFileGenerationLogTextView?.appendMessageString ("Generating \(inPath.lastPathComponent)…")
    var pathes = [EBBezierPath] ()
    for (holeDiameter, segmentList) in inProductData.holeDictionary {
      var bp = EBBezierPath ()
      bp.lineWidth = holeDiameter
      bp.lineCapStyle = .round
      for segment in segmentList {
        bp.move (to: segment.0)
        bp.line (to: segment.1)
      }
      pathes.append (bp)
    }
    let shape = EBShape (stroke: pathes, .black)
    let data = buildPDFimageData (frame: inProductData.boardBoundBox, shape: shape, backgroundColor: .white)
    try data.write (to: URL (fileURLWithPath: inPath))
    self.mProductFileGenerationLogTextView?.appendSuccessString (" Ok\n")
  }

  //····················································································································

  private func writePDFProductFile (atPath inPath : String,
                                    _ inDescriptor : ArtworkFileGenerationParameters,
                                    _ inProductData : ProductData) throws {
    let path = inPath + inDescriptor.fileExtension + ".pdf"
    self.mProductFileGenerationLogTextView?.appendMessageString ("Generating \(path.lastPathComponent)…")
    var pathes = [EBBezierPath] ()
    if inDescriptor.drawBoardLimits {
      var bp = EBBezierPath ()
      bp.move (to: inProductData.boardLimitPolygon.origin)
      for p in inProductData.boardLimitPolygon.lines {
        bp.line (to: p)
      }
      if inProductData.boardLimitPolygon.closed {
        bp.close ()
      }
      bp.lineCapStyle = .round
      bp.lineJoinStyle = .round
      bp.lineWidth = inProductData.boardLimitWidth
      pathes.append (bp)
    }
    if inDescriptor.drawPackageLegendTopSide {
      for (aperture, pathArray) in inProductData.frontPackageLegend {
        var bp = EBBezierPath ()
        bp.lineCapStyle = .round
        bp.lineJoinStyle = .round
        bp.lineWidth = aperture
        for path in pathArray {
          path.appendToBezierPath (&bp)
        }
        pathes.append (bp)
      }
    }


    let shape = EBShape (stroke: pathes, .black)
    let data = buildPDFimageData (frame: inProductData.boardBoundBox, shape: shape, backgroundColor: .white)
    try data.write (to: URL (fileURLWithPath: path))
    self.mProductFileGenerationLogTextView?.appendSuccessString (" Ok\n")
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

