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
    let boardBoundBox = self.rootObject.boardBoundBox!.cocoaRect
  //--- Build drill dictionary
    let holeDictionary = self.buildHoleDictionary ()
  //--- Create gerber directory (first, delete existing dir)
    let gerberDirPath = inDocumentFilePathWithoutExtension + "-gerber"
    let generatedGerberFilePath = gerberDirPath + "/" + baseName + "."
    try self.removeAndCreateDirectory (atPath: gerberDirPath)
  //--- Write gerber files
    try self.writeGerberDrillFile (atPath: generatedGerberFilePath + inArtwork.drillDataFileExtension, holeDictionary)
  //--- Create PDF directory (first, delete existing dir)
    let pdfDirPath = inDocumentFilePathWithoutExtension + "-pdf"
    let generatedPDFFilePath = pdfDirPath + "/" + baseName + "."
    try self.removeAndCreateDirectory (atPath: pdfDirPath)
  //--- Write PDF files
    try self.writePDFDrillFile (atPath: generatedPDFFilePath + inArtwork.drillDataFileExtension + ".pdf", holeDictionary, boardBoundBox)
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

  fileprivate func buildHoleDictionary () -> [Int : [(NSPoint, NSPoint)]] {
    var result = [Int : [(NSPoint, NSPoint)]] ()
    for object in self.rootObject.mBoardObjects {
      if let connector = object as? BoardConnector, let isVia = connector.isVia, isVia {
        let p = connector.location!.cocoaPoint
        let hd = connector.actualHoleDiameter!
        result [hd] = (result [hd] ?? []) + [(p, p)]
      }else if let component = object as? ComponentInProject {
        let packagePadDictionary : PackageMasterPadDictionary = component.packagePadDictionary!
      //---
        let center = packagePadDictionary.padsRect.center.cocoaPoint
        var af = AffineTransform ()
        af.translate (x: canariUnitToCocoa (component.mX), y: canariUnitToCocoa (component.mY))
        af.rotate (byDegrees: CGFloat (component.mRotation) / 1000.0)
        if component.mSide == .back {
          af.scale (x: -1.0, y: 1.0)
        }
        af.translate (x: -center.x, y: -center.y)
      //---
        for (_, masterPad) in packagePadDictionary {
          switch masterPad.style {
          case .traversing :
            let p = masterPad.center.cocoaPoint
            let holeSize = masterPad.holeSize.cocoaSize
            if masterPad.holeSize.width < masterPad.holeSize.height { // Vertical oblong
              let p1 = af.transform (NSPoint (x: p.x, y: p.y - (holeSize.height - holeSize.width) / 2.0))
              let p2 = af.transform (NSPoint (x: p.x, y: p.y + (holeSize.height - holeSize.width) / 2.0))
              result [masterPad.holeSize.width] = (result [masterPad.holeSize.width] ?? []) + [(p1, p2)]
            }else if masterPad.holeSize.width > masterPad.holeSize.height { // Horizontal oblong
              let p1 = af.transform (NSPoint (x: p.x - (holeSize.width - holeSize.height) / 2.0, y: p.y))
              let p2 = af.transform (NSPoint (x: p.x + (holeSize.width - holeSize.height) / 2.0, y: p.y))
              result [masterPad.holeSize.height] = (result [masterPad.holeSize.height] ?? []) + [(p1, p2)]
            }else{ // Circular
              let pp = af.transform (p)
              result [masterPad.holeSize.width] = (result [masterPad.holeSize.width] ?? []) + [(pp, pp)]
            }
          case .surface :
            ()
          }
          for slavePad in masterPad.slavePads {
            switch slavePad.style {
            case .traversing :
              let p = slavePad.center.cocoaPoint
              let holeSize = slavePad.holeSize.cocoaSize
              if slavePad.holeSize.width < slavePad.holeSize.height { // Vertical oblong
                let p1 = af.transform (NSPoint (x: p.x, y: p.y - (holeSize.height - holeSize.width) / 2.0))
                let p2 = af.transform (NSPoint (x: p.x, y: p.y + (holeSize.height - holeSize.width) / 2.0))
                result [slavePad.holeSize.width] = (result [slavePad.holeSize.width] ?? []) + [(p1, p2)]
              }else if slavePad.holeSize.width > slavePad.holeSize.height { // Horizontal oblong
                let p1 = af.transform (NSPoint (x: p.x - (holeSize.width - holeSize.height) / 2.0, y: p.y))
                let p2 = af.transform (NSPoint (x: p.x + (holeSize.width - holeSize.height) / 2.0, y: p.y))
                result [slavePad.holeSize.height] = (result [slavePad.holeSize.height] ?? []) + [(p1, p2)]
              }else{ // Circular
                let pp = af.transform (p)
                result [slavePad.holeSize.width] = (result [slavePad.holeSize.width] ?? []) + [(pp, pp)]
              }
            case .bottomSide, .topSide :
              ()
            }
          }
        }
      }
    }
    return result
  }

  //····················································································································

  private func writeGerberDrillFile (atPath inPath : String, _ inHoleDictionary : [Int : [(NSPoint, NSPoint)]]) throws {
    self.mProductFileGenerationLogTextView?.appendMessageString ("Generating \(inPath.lastPathComponent)…")
    var s = "M48\n"
    s += "INCH\n"
    let keys = inHoleDictionary.keys.sorted ()
 //--- Write hole diameters
    var idx = 0
    for diameter in keys {
      idx += 1
      s += "T\(idx)C\(String(format: "%.4f", canariUnitToInch (diameter)))\n"
    }
 //--- Write holes
    s += "%\n"
    s += "G05\n"
    s += "M72\n"
    idx = 0
    for diameter in keys {
      idx += 1
      s += "T\(idx)\n"
      for (p1, p2) in inHoleDictionary [diameter]! {
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

  private func writePDFDrillFile (atPath inPath : String, _ inHoleDictionary : [Int : [(NSPoint, NSPoint)]], _ inBoardBoundBox : NSRect) throws {
    self.mProductFileGenerationLogTextView?.appendMessageString ("Generating \(inPath.lastPathComponent)…")
    var pathes = [EBBezierPath] ()
    for (holeDiameter, segmentList) in inHoleDictionary {
      var bp = EBBezierPath ()
      bp.lineWidth = canariUnitToCocoa (holeDiameter)
      bp.lineCapStyle = .round
      for segment in segmentList {
        bp.move (to: segment.0)
        bp.line (to: segment.1)
      }
      pathes.append (bp)
    }
    let shape = EBShape (stroke: pathes, .black)
    let data = buildPDFimageData (frame: inBoardBoundBox, shape: shape, backgroundColor: .white)
    try data.write (to: URL (fileURLWithPath: inPath))
    self.mProductFileGenerationLogTextView?.appendSuccessString (" Ok\n")
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

