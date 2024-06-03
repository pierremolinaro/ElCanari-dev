//
//  ProjectDocument-generate-product-files.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/07/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit
import Compression

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
    RunLoop.current.run (until: Date ())
    do{
      try self.performProductFilesGeneration (atPath: self.fileURL!.path.deletingPathExtension, self.rootObject.mArtwork!)
    }catch let error {
      _ = self.windowForSheet?.presentError (error)
    }
  }

  //································································································

  private func performProductFilesGeneration (atPath inDocumentFilePathWithoutExtension : String,
                                              _ inArtwork : ArtworkRoot) throws {
    let baseName = inDocumentFilePathWithoutExtension.lastPathComponent
    let generateGerberAndPDF = self.rootObject.mGenerateGerberAndPDF_property.propval
  //--- Build product data
    let productData = self.buildProductData ()
    let boardBoundBox = self.rootObject.boardBoundBox!
    var productRepresentation = ProductRepresentation (
      boardWidth: ProductLength (valueInCanariUnit: boardBoundBox.width),
      boardWidthUnit:  self.rootObject.mRectangularBoardWidthUnit_property.propval, // Canari Unit
      boardHeight: ProductLength (valueInCanariUnit: boardBoundBox.height),
      boardHeightUnit: self.rootObject.mRectangularBoardHeightUnit_property.propval, // Canari Unit
      boardLimitWidth: ProductLength (valueInCanariUnit: self.rootObject.mBoardLimitsWidth),
      boardLimitWidthUnit: self.rootObject.mBoardLimitsWidthUnit, // Canari Unit
      artworkName: self.rootObject.mArtworkName,
      layerConfiguration: self.rootObject.mLayerConfiguration
    )
    self.populateProductRepresentation (to: &productRepresentation)
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
        self.mProductFileGenerationLogTextView?.appendMessage ("Generating \(boardArchiveFilePath.lastPathComponent)…")
        let jsonData : Data = productRepresentation.encodedJSONCompressedData (
          prettyPrinted: true,
          using: COMPRESSION_LZMA
        )
        try jsonData.write (to: URL (fileURLWithPath: boardArchiveFilePath))
        self.mProductFileGenerationLogTextView?.appendSuccess (" Ok\n")
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
      self.mProductFileGenerationLogTextView?.appendMessage ("Remove recursively \(inDirectoryPath)...")
      try fm.removeItem (atPath: inDirectoryPath) // Remove dir recursively
      self.mProductFileGenerationLogTextView?.appendSuccess (" ok.\n")
    }
    if inCreate {
      self.mProductFileGenerationLogTextView?.appendMessage ("Create \(inDirectoryPath)...")
      try fm.createDirectory (atPath: inDirectoryPath, withIntermediateDirectories: true, attributes: nil)
      self.mProductFileGenerationLogTextView?.appendSuccess (" ok.\n")
    }
  }

  //································································································
  //  Populate product representation
  //································································································

  func populateProductRepresentation (to ioProduct : inout ProductRepresentation) {
  //--- Board limit path
    do{
      var points = self.buildBoardLimitFlattenedPath ()
      let firstPoint = points [0]
      var currentPoint = firstPoint
      points.removeFirst ()
      for p in points {
        let oblong = LayeredProductSegment (
          p1: currentPoint,
          p2: p,
          width: ioProduct.boardLimitWidth,
          layers: .boardLimits
        )
        ioProduct.append (roundSegment: oblong)
        currentPoint = p
      }
      let oblong = LayeredProductSegment (
        p1: currentPoint,
        p2: firstPoint,
        width: ioProduct.boardLimitWidth,
        layers: .boardLimits
      )
      ioProduct.append (roundSegment: oblong)
    }
  //--- Populate
    self.appendPackageLegends (to: &ioProduct)
    self.appendComponentNamePathes (to: &ioProduct)
    self.appendComponentValuePathes (to: &ioProduct)
    self.appendTextPathes (to: &ioProduct)
    self.appendLegendLines (to: &ioProduct)
    self.appendVias (to: &ioProduct)
    self.appendPads (to: &ioProduct)
    self.appendQRCodePathes (to: &ioProduct)
    self.appendImagesPathes (to: &ioProduct)
    self.appendTracks (to: &ioProduct)
  }

  //································································································

  private func appendPackageLegends (to ioProduct : inout ProductRepresentation) {
    let cocoaBoardRect = self.rootObject.boardBoundBox!.cocoaRect
    let width = ProductLength (Double (self.rootObject.packageDrawingWidthMultpliedByTenForBoard) / 10.0, .cocoa)
    for object in self.rootObject.mBoardObjects.values {
      if let component = object as? ComponentInProject, component.mDisplayLegend {
        let strokeBezierPath = component.strokeBezierPath!
        if !strokeBezierPath.isEmpty {
          let af = component.packageToComponentAffineTransform ()
          let layer : ProductLayerSet
          switch component.mSide {
          case .back :
            layer = .backSidePackageLegend
          case .front :
            layer = .frontSidePackageLegend
          }
          ioProduct.append (
            flattenedStrokeBezierPath: strokeBezierPath,
            transformedBy: af,
            clippedBy: cocoaBoardRect,
            width: width,
            layers: layer
          )
        }
      }
    }
  }

  //································································································

  private func appendComponentNamePathes (to ioProduct : inout ProductRepresentation) {
    let cocoaBoardRect = self.rootObject.boardBoundBox!.cocoaRect
    for object in self.rootObject.mBoardObjects.values {
      if let component = object as? ComponentInProject {
        if component.mNameIsVisibleInBoard, let fontDescriptor = component.mNameFont?.descriptor {
          let (textBP, _, _, _, _) = boardText_displayInfos (
            x: component.mXName + component.mX,
            y: component.mYName + component.mY,
            string: component.componentName!,
            fontSize: component.mNameFontSize,
            fontDescriptor,
            horizontalAlignment: .center,
            verticalAlignment: .center,
            frontSide: component.mSide == .front,
            rotation: component.mNameRotation,
            weight: 1.0,
            oblique: false,
            extraWidth: 0.0
          )
          let width = ProductLength (textBP.lineWidth, .cocoa)
          let layer : ProductLayerSet
          switch component.mSide {
          case .back :
            layer = .backSideComponentName
          case .front :
            layer = .frontSideComponentName
          }
          ioProduct.append (
            flattenedStrokeBezierPath: textBP,
            transformedBy: AffineTransform (),
            clippedBy: cocoaBoardRect,
            width: width,
            layers: layer
          )
        }
      }
    }
  }

  //································································································

  private func appendComponentValuePathes (to ioProduct : inout ProductRepresentation) {
    let cocoaBoardRect = self.rootObject.boardBoundBox!.cocoaRect
    for object in self.rootObject.mBoardObjects.values {
      if let component = object as? ComponentInProject {
        if component.mValueIsVisibleInBoard, let fontDescriptor = component.mValueFont?.descriptor {
          let (textBP, _, _, _, _) = boardText_displayInfos (
            x: component.mXValue + component.mX,
            y: component.mYValue + component.mY,
            string: component.mComponentValue,
            fontSize: component.mValueFontSize,
            fontDescriptor,
            horizontalAlignment: .center,
            verticalAlignment: .center,
            frontSide: component.mSide == .front,
            rotation: component.mValueRotation,
            weight: 1.0,
            oblique: false,
            extraWidth: 0.0
          )
          let width = ProductLength (textBP.lineWidth, .cocoa)
          let layer : ProductLayerSet
          switch component.mSide {
          case .back :
            layer = .backSideComponentValue
          case .front :
            layer = .frontSideComponentValue
          }
          ioProduct.append (
            flattenedStrokeBezierPath: textBP,
            transformedBy: AffineTransform (),
            clippedBy: cocoaBoardRect,
            width: width,
            layers: layer
          )
        }
      }
    }
  }

  //································································································

  private func appendTextPathes (to ioProduct : inout ProductRepresentation) {
    let cocoaBoardRect = self.rootObject.boardBoundBox!.cocoaRect
    for object in self.rootObject.mBoardObjects.values {
      if let text = object as? BoardText {
        let (textBP, _, _, _, _) = boardText_displayInfos (
          x: text.mX,
          y: text.mY,
          string: text.mText,
          fontSize: text.mFontSize,
          text.mFont!.descriptor!,
          horizontalAlignment: text.mHorizontalAlignment,
          verticalAlignment: text.mVerticalAlignment,
          frontSide: (text.mLayer == .layoutFront) || (text.mLayer == .legendFront),
          rotation: text.mRotation,
          weight: text.mWeight,
          oblique: text.mOblique,
          extraWidth: 0.0
        )
        let width = ProductLength (textBP.lineWidth, .cocoa)
        let layer : ProductLayerSet
        switch text.mLayer {
        case .legendFront :
          layer = .frontSideLegendText
        case .layoutFront :
          layer = .frontSideLayoutText
        case .legendBack :
          layer = .backSideLegendText
        case .layoutBack :
          layer = .backSideLayoutText
        }
        ioProduct.append (
          flattenedStrokeBezierPath: textBP,
          transformedBy: AffineTransform (),
          clippedBy: cocoaBoardRect,
          width: width,
          layers: layer
        )
      }
    }
  }

  //································································································

  private func appendLegendLines (to ioProduct : inout ProductRepresentation) {
    let cocoaBoardRect = self.rootObject.boardBoundBox!.cocoaRect
    for object in self.rootObject.mBoardObjects.values {
      if let line = object as? BoardLine {
        let p1 = CanariPoint (x: line.mX1, y: line.mY1).cocoaPoint
        let p2 = CanariPoint (x: line.mX2, y: line.mY2).cocoaPoint
        if let (clippedP1, clippedP2) = cocoaBoardRect.clippedSegment(p1: p1, p2: p2) {
          let width = ProductLength (valueInCanariUnit: line.mWidth)
          let layer : ProductLayerSet
          switch line.mLayer {
          case .legendFront :
            layer = .frontSideLegendLine
          case .legendBack :
            layer = .backSideLegendLine
          }
          let oblong = LayeredProductSegment (
            p1: ProductPoint (cocoaPoint: clippedP1),
            p2: ProductPoint (cocoaPoint: clippedP2),
            width: width,
            layers: layer
          )
          ioProduct.append (roundSegment: oblong)
        }
      }
    }
  }

  //································································································

  private func appendVias (to ioProduct : inout ProductRepresentation) {
    for object in self.rootObject.mBoardObjects.values {
      if let via = object as? BoardConnector, let isVia = via.isVia, isVia {
        let center = ProductPoint (canariPoint: via.location!)
        let padDiameter = ProductLength (valueInCanariUnit: via.actualPadDiameter!)
        let holeDiameter = ProductLength (valueInCanariUnit: via.actualHoleDiameter!)
        let pad = LayeredProductCircle (
          center: center,
          diameter: padDiameter,
          layers: .viaPad
        )
        ioProduct.append (circle: pad)
        let hole = LayeredProductCircle (
          center: center,
          diameter: holeDiameter,
          layers: .hole
        )
        ioProduct.append (circle: hole)
      }
    }
  }

  //································································································

  private func appendPads (to ioProduct : inout ProductRepresentation) {
    for object in self.rootObject.mBoardObjects.values {
      if let component = object as? ComponentInProject {
        let af = component.packageToComponentAffineTransform ()
        for (_, masterPad) in component.packagePadDictionary! {
        //--- Handle master pad
          let layers = masterPad.style.layers (component.mSide)
          self.appendPad (
            center: masterPad.center,
            padSize: masterPad.padSize,
            shape: masterPad.shape,
            transformedBy: af,
            layers: layers,
            to: &ioProduct
          )
          if masterPad.style == .traversing {
            self.appendPadHole (center: masterPad.center, holeSize: masterPad.holeSize, transformedBy: af, to: &ioProduct)
          }
        //--- Handle slave pads
          for slavePad in masterPad.slavePads {
            let layers = slavePad.style.layers (component.mSide)
            self.appendPad (
              center: slavePad.center,
              padSize: slavePad.padSize,
              shape: slavePad.shape,
              transformedBy: af,
              layers: layers,
              to: &ioProduct
            )
            if slavePad.style == .traversing {
              self.appendPadHole (center: slavePad.center, holeSize: slavePad.holeSize, transformedBy: af, to: &ioProduct)
            }
          }
        }
      }
    }
  }

  //································································································

  private func appendPad (center inCenter : CanariPoint,
                          padSize inPadSize : CanariSize,
                          shape inShape : PadShape,
                          transformedBy inAT : AffineTransform,
                          layers inLayers : ProductLayerSet,
                          to ioProduct : inout ProductRepresentation) {
    let center = ProductPoint (canariPoint: inCenter)
    let p = LayeredProductComponentPad (
      xCenter: center.x,
      yCenter: center.y,
      width: ProductLength (valueInCanariUnit: inPadSize.width),
      height: ProductLength (valueInCanariUnit: inPadSize.height),
      af: inAT,
      shape: inShape,
      layers: inLayers
    )
    ioProduct.append (pad: p)
  }

  //································································································

  private func appendPadHole (center inCenter : CanariPoint,
                              holeSize inHoleSize : CanariSize,
                              transformedBy inAT : AffineTransform,
                              to ioProduct : inout ProductRepresentation) {
    let p = inCenter.cocoaPoint
    let holeSize = inHoleSize.cocoaSize
    if inHoleSize.width < inHoleSize.height { // Vertical oblong
      let p1 = inAT.transform (NSPoint (x: p.x, y: p.y - (holeSize.height - holeSize.width) / 2.0))
      let p2 = inAT.transform (NSPoint (x: p.x, y: p.y + (holeSize.height - holeSize.width) / 2.0))
      let oblong = LayeredProductSegment (
        p1: ProductPoint (cocoaPoint: p1),
        p2: ProductPoint (cocoaPoint: p2),
        width: ProductLength (valueInCanariUnit: inHoleSize.width),
        layers: .hole
      )
      ioProduct.append (roundSegment: oblong)
    }else if inHoleSize.width > inHoleSize.height { // Horizontal oblong
      let p1 = inAT.transform (NSPoint (x: p.x - (holeSize.width - holeSize.height) / 2.0, y: p.y))
      let p2 = inAT.transform (NSPoint (x: p.x + (holeSize.width - holeSize.height) / 2.0, y: p.y))
      let oblong = LayeredProductSegment (
        p1: ProductPoint (cocoaPoint: p1),
        p2: ProductPoint (cocoaPoint: p2),
        width: ProductLength (valueInCanariUnit: inHoleSize.height),
        layers: .hole
      )
      ioProduct.append (roundSegment: oblong)
    }else{ // Circular
      let center = ProductPoint (cocoaPoint: inAT.transform (inCenter.cocoaPoint))
      let padDiameter = ProductLength (valueInCanariUnit: inHoleSize.width)
      let pad = LayeredProductCircle (
        center: center,
        diameter: padDiameter,
        layers: .hole
      )
      ioProduct.append (circle: pad)
    }
  }

  //································································································

  private func appendQRCodePathes (to ioProduct : inout ProductRepresentation) {
    for object in self.rootObject.mBoardObjects.values {
      if let qrCode = object as? BoardQRCode, let descriptor = qrCode.qrCodeDescriptor {
        let displayInfos = boardQRCode_displayInfos (
          centerX: qrCode.mCenterX,
          centerY: qrCode.mCenterY,
          descriptor,
          frontSide: qrCode.mLayer == .legendFront,
          moduleSizeInCanariUnit: qrCode.mModuleSize,
          rotation: qrCode.mRotation
        )
        let layer : ProductLayerSet
        switch qrCode.mLayer {
        case .legendFront :
          layer = .frontSideQRCode
        case .legendBack :
          layer = .backSideQRCode
        }
        for r in displayInfos.nonRotatedRectangles {
          let center = ProductPoint (cocoaPoint: r.center)
          let size = ProductSize (cocoaSize: r.size)
          let pr = LayeredProductRectangle (
            xCenter: center.x,
            yCenter: center.y,
            width: size.width,
            height: size.height,
            af: displayInfos.affineTransform,
            layers: layer
          )
          ioProduct.append (rectangle: pr)
        }
      }
    }
  }

  //································································································

  private func appendImagesPathes (to ioProduct : inout ProductRepresentation) {
    for object in self.rootObject.mBoardObjects.values {
      if let boardImage = object as? BoardImage, let descriptor = boardImage.boardImageCodeDescriptor {
        let displayInfos = boardImage_displayInfos (
          centerX: boardImage.mCenterX,
          centerY: boardImage.mCenterY,
          descriptor,
          frontSide: boardImage.mLayer == .legendFront,
          pixelSizeInCanariUnit: boardImage.mPixelSize,
          rotation: boardImage.mRotation
        )
        let layer : ProductLayerSet
        switch boardImage.mLayer {
        case .legendFront :
          layer = .frontSideImage
        case .legendBack :
          layer = .backSideImage
        }
        for r in displayInfos.nonRotatedRectangles {
          let center = ProductPoint (cocoaPoint: r.center)
          let size = ProductSize (cocoaSize: r.size)
          let pr = LayeredProductRectangle (
            xCenter: center.x,
            yCenter: center.y,
            width: size.width,
            height: size.height,
            af: displayInfos.affineTransform,
            layers: layer
          )
          ioProduct.append (rectangle: pr)
        }
      }
    }
  }

  //································································································

  private func appendTracks (to ioProduct : inout ProductRepresentation) {
    for object in self.rootObject.mBoardObjects.values {
      if let track = object as? BoardTrack {
        let width = ProductLength (valueInCanariUnit: track.actualTrackWidth!)
        let layer : ProductLayerSet
        switch track.mSide {
        case .front :
          if track.mAddedToSolderMask_property.propval {
            layer = .frontSideExposedTrack
          }else{
            layer = .frontSideTrack
          }
        case .back :
          if track.mAddedToSolderMask_property.propval {
            layer = .backSideExposedTrack
          }else{
            layer = .backSideTrack
          }
        case .inner1 :
          layer = .inner1Track
        case .inner2 :
          layer = .inner2Track
        case .inner3 :
          layer = .inner3Track
        case .inner4 :
          layer = .inner4Track
        }
        switch track.mEndStyle_property.propval {
        case .round :
          let p1 = ProductPoint (canariPoint: track.mConnectorP1!.location!)
          let p2 = ProductPoint (canariPoint: track.mConnectorP2!.location!)
          let t = LayeredProductSegment (p1: p1, p2: p2, width: width, layers: layer)
          ioProduct.append (roundSegment: t)
        case .square :
          let p1 = ProductPoint (canariPoint: track.mConnectorP1!.location!)
          let p2 = ProductPoint (canariPoint: track.mConnectorP2!.location!)
          let t = LayeredProductSegment (p1: p1, p2: p2, width: width, layers: layer)
          ioProduct.append (squareSegment: t)
        }
      }
    }
  }

  //································································································

  fileprivate func buildBoardLimitFlattenedPath () -> [ProductPoint] {
    var result = [ProductPoint] ()
    switch self.rootObject.mBoardShape {
    case .bezierPathes :
      var curveDictionary = [CanariPoint : BorderCurveDescriptor] ()
      for curve in self.rootObject.mBorderCurves.values {
        let descriptor = curve.descriptor!
        curveDictionary [descriptor.p1] = descriptor
      }
      var descriptor = self.rootObject.mBorderCurves [0].descriptor!
      let p = descriptor.p1
      var bp = EBBezierPath ()
      bp.move (to: p.cocoaPoint)
      var loop = true
      while loop {
        switch descriptor.shape {
        case .line :
          bp.line (to: descriptor.p2.cocoaPoint)
        case .bezier :
          let cp1 = descriptor.cp1.cocoaPoint
          let cp2 = descriptor.cp2.cocoaPoint
          bp.curve (to: descriptor.p2.cocoaPoint, controlPoint1: cp1, controlPoint2: cp2)
        }
        descriptor = curveDictionary [descriptor.p2]!
        loop = p != descriptor.p1
      }
      bp.close ()
    //---
      bp.lineJoinStyle = .round
      bp.lineCapStyle = .round
      bp.lineWidth = canariUnitToCocoa ((self.rootObject.mBoardLimitsWidth + self.rootObject.mBoardClearance) * 2)
      let strokeBP = bp.pathToFillByStroking
      var closedPathCount = 0
      let retainedClosedPath = 2
      var retainedBP = EBBezierPath ()
      var points = [NSPoint] (repeating: .zero, count: 3)
      for i in 0 ..< strokeBP.nsBezierPath.elementCount {
        let type = strokeBP.nsBezierPath.element (at: i, associatedPoints: &points)
        switch type {
        case .moveTo:
          closedPathCount += 1
          if closedPathCount == retainedClosedPath {
            retainedBP.move (to: points[0])
          }
        case .lineTo:
          if closedPathCount == retainedClosedPath {
            retainedBP.line (to: points[0])
          }
        case .curveTo:
          if closedPathCount == retainedClosedPath {
            retainedBP.curve (to: points[2], controlPoint1: points[0], controlPoint2: points[1])
          }
        case .closePath:
          if closedPathCount == retainedClosedPath {
            retainedBP.close ()
          }
        case .cubicCurveTo:
          ()
        case .quadraticCurveTo:
          ()
        @unknown default :
          ()
        }
      }
      let linePath = retainedBP.linePathesByFlattening (withFlatness: 0.1) [0]
      result.append (ProductPoint (cocoaPoint: linePath.origin))
      for p in linePath.lines {
        result.append (ProductPoint (cocoaPoint: p))
      }
    case .rectangular :
      let width = ProductLength (valueInCanariUnit: self.rootObject.mRectangularBoardWidth)
      let height = ProductLength (valueInCanariUnit: self.rootObject.mRectangularBoardHeight)
      result.append (.zero) // Bottom left
      result.append (ProductPoint (x: .zero, y: height)) // Top left
      result.append (ProductPoint (x: width, y: height)) // Top right
      result.append (ProductPoint (x: width, y: .zero)) // Bottom right
    }
    return result
  }

  //································································································

//  fileprivate func buildBoardLimitFlattenedPath () -> [ProductPoint] {
//    var result = [ProductPoint] ()
//    switch self.rootObject.mBoardShape {
//    case .bezierPathes :
//      var curveDictionary = [CanariPoint : BorderCurveDescriptor] ()
//      for curve in self.rootObject.mBorderCurves.values {
//        let descriptor = curve.descriptor!
//        curveDictionary [descriptor.p1] = descriptor
//      }
//      var descriptor = self.rootObject.mBorderCurves [0].descriptor!
//      let firstPoint = descriptor.p1
//      var currentPoint = firstPoint
//      result.append (ProductPoint (canariPoint: firstPoint))
//      var loop = true
//      while loop {
//        switch descriptor.shape {
//        case .line :
//          result.append (ProductPoint (canariPoint: descriptor.p2))
//        case .bezier :
//          let cp1 = descriptor.cp1.cocoaPoint
//          let cp2 = descriptor.cp2.cocoaPoint
//          let bp = NSBezierPath ()
//          bp.move (to: currentPoint.cocoaPoint)
//          bp.curve (to: descriptor.p2.cocoaPoint, controlPoint1: cp1, controlPoint2: cp2)
//          bp.flatness = 0.1
//          let flattenedBezierPath = bp.flattened
//          var points = [NSPoint] (repeating: .zero, count: 3)
//          for i in 0 ..< flattenedBezierPath.elementCount {
//            let type = flattenedBezierPath.element (at: i, associatedPoints: &points)
//            switch type {
//            case .moveTo, .cubicCurveTo, .closePath, .quadraticCurveTo:
//              ()
//            case .lineTo: ()
//               result.append (ProductPoint (canariPoint: points[0].canariPoint))
//            @unknown default:
//              ()
//            }
//          }
//        }
//        currentPoint = descriptor.p2
//        descriptor = curveDictionary [descriptor.p2]!
//        loop = firstPoint != descriptor.p1
//      }
//    case .rectangular :
//      let width = ProductLength (valueInCanariUnit: self.rootObject.mRectangularBoardWidth)
//      let height = ProductLength (valueInCanariUnit: self.rootObject.mRectangularBoardHeight)
//      result.append (.zero) // Bottom left
//      result.append (ProductPoint (x: .zero, y: height)) // Top left
//      result.append (ProductPoint (x: width, y: height)) // Top right
//      result.append (ProductPoint (x: width, y: .zero)) // Bottom right
//    }
//    return result
//  }

  //································································································

}

//--------------------------------------------------------------------------------------------------

fileprivate extension PadStyle {

  //································································································

  func layers (_ inComponentSide : ComponentSide) -> ProductLayerSet {
    switch self {
    case .traversing :
      return [.frontSideComponentPad, .backSideComponentPad, .innerComponentPad]
    case .surface :
      switch inComponentSide {
      case .back :
        return .backSideComponentPad
      case .front :
        return .frontSideComponentPad
      }
    }
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------

fileprivate extension SlavePadStyle {

  //································································································

  func layers (_ inComponentSide : ComponentSide) -> ProductLayerSet {
    switch self {
    case .traversing :
      return [.frontSideComponentPad, .backSideComponentPad, .innerComponentPad]
    case .componentSide :
      switch inComponentSide {
      case .back :
        return .backSideComponentPad
      case .front :
        return .frontSideComponentPad
      }
    case .oppositeSide :
      switch inComponentSide {
      case .front :
        return .backSideComponentPad
      case .back :
        return .frontSideComponentPad
      }
    }
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
