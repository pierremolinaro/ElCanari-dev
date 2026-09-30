//
//  extension-BoardModel-updateLegacyModel.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 02/06/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

extension AutoLayoutMergerDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func updateLegacyModel (legacyBoardModels inLegacyBoardModels : [BoardModel]) {
  //--- Show update sheet
    let updateSheet = CanariWindow (
      contentRect: NSRect (x: 0, y: 0, width: 200, height: 50),
      styleMask: .nonactivatingPanel,
      backing: .buffered,
      defer: true
    )
    updateSheet.isReleasedWhenClosed = false
    let textField = AutoLayoutLabel (bold: false, size: .small).set (alignment: .center)
    textField.stringValue = "Updating…"
    let hStackView = AutoLayoutHorizontalStackView ()
      .set (margins: .zero)
      .appendFlexibleSpace ()
      .appendView (AutoLayoutSpinningProgressIndicator (size: .small))
      .appendFlexibleSpace ()
    let vStackView = AutoLayoutVerticalStackView ()
      .set (margins: .large)
      .appendView (textField)
      .appendView (hStackView)
    updateSheet.contentView = vStackView
    self.windowForSheet?.beginSheet (updateSheet)
    RunLoop.current.run (until: Date ())
  //--- Update models
    for model in inLegacyBoardModels {
      self.internalUpdateLegacyModel (legacyBoardModel: model)
    }
  //--- Remove update sheet
    self.windowForSheet?.endSheet (updateSheet)
    RunLoop.current.run (until: Date ())
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func internalUpdateLegacyModel (legacyBoardModel inLegacyBoardModel : BoardModel) {
    var product = ProductRepresentation (
      boardWidth : inLegacyBoardModel.modelWidth,
      boardWidthUnit: inLegacyBoardModel.modelWidthUnit, // Canari Unit
      boardHeight: inLegacyBoardModel.modelHeight,
      boardHeightUnit: inLegacyBoardModel.modelHeightUnit, // Canari Unit
      artworkName: inLegacyBoardModel.artworkName,
      layerConfiguration: inLegacyBoardModel.layerConfiguration
    )
  //--- Internal board limits
    self.appendSegments (from: inLegacyBoardModel.internalBoardsLimits, layer: .internalBoardLimits, to: &product)
  //--- Texts
    self.appendSegments (from: inLegacyBoardModel.frontLegendTexts, layer: .frontSideLegendText, to: &product)
    self.appendSegments (from: inLegacyBoardModel.backLegendTexts, layer: .backSideLegendText, to: &product)
    self.appendSegments (from: inLegacyBoardModel.frontLayoutTexts, layer: .frontSideLayoutText, to: &product)
    self.appendSegments (from: inLegacyBoardModel.backLayoutTexts, layer: .backSideLayoutText, to: &product)
  //--- Lines
    self.appendSegments (from: inLegacyBoardModel.frontLegendLines, layer: .frontSideLegendLine, to: &product)
    self.appendSegments (from: inLegacyBoardModel.backLegendLines, layer: .backSideLegendLine, to: &product)
  //--- Component names
    self.appendSegments (from: inLegacyBoardModel.frontComponentNames, layer: .frontSideComponentName, to: &product)
    self.appendSegments (from: inLegacyBoardModel.backComponentNames, layer: .backSideComponentName, to: &product)
  //--- Component values
    self.appendSegments (from: inLegacyBoardModel.frontComponentValues, layer: .frontSideComponentValue, to: &product)
    self.appendSegments (from: inLegacyBoardModel.backComponentValues, layer: .backSideComponentValue, to: &product)
  //--- Packages
    self.appendSegments (from: inLegacyBoardModel.frontPackages, layer: .frontSidePackageLegend, to: &product)
    self.appendSegments (from: inLegacyBoardModel.backPackages, layer: .backSidePackageLegend, to: &product)
  //--- Tracks
    self.appendSegments (from: inLegacyBoardModel.frontTracks, layer: .frontSideTrack, to: &product)
    self.appendSegments (from: inLegacyBoardModel.backTracks, layer: .backSideTrack, to: &product)
    self.appendSegments (from: inLegacyBoardModel.inner1Tracks, layer: .inner1Track, to: &product)
    self.appendSegments (from: inLegacyBoardModel.inner2Tracks, layer: .inner2Track, to: &product)
    self.appendSegments (from: inLegacyBoardModel.inner3Tracks, layer: .inner3Track, to: &product)
    self.appendSegments (from: inLegacyBoardModel.inner4Tracks, layer: .inner4Track, to: &product)
// §    self.appendSegments (from: inLegacyBoardModel.frontTracksNoSilkScreen, layer: .frontSideExposedTrack, to: &product)
// §    self.appendSegments (from: inLegacyBoardModel.backTracksNoSilkScreen, layer: .backSideExposedTrack, to: &product)
  //--- Images
    self.appendRectangles (from: inLegacyBoardModel.legendFrontImages, layer: .frontSideImage, to: &product)
    self.appendRectangles (from: inLegacyBoardModel.legendBackImages, layer: .backSideImage, to: &product)
  //--- QRCodes
    self.appendRectangles (from: inLegacyBoardModel.legendFrontQRCodes, layer: .frontSideQRCode, to: &product)
    self.appendRectangles (from: inLegacyBoardModel.legendBackQRCodes, layer: .backSideQRCode, to: &product)
  //--- Holes
    self.appendHoles (from: inLegacyBoardModel.drills, to: &product)
  //--- Vias
    self.appendVias (from: inLegacyBoardModel.vias, to: &product)
  //--- Pads
    self.appendPads (from: inLegacyBoardModel.backPads, layer: .backSideComponentPad, to: &product)
    self.appendPads (from: inLegacyBoardModel.frontPads, layer: .frontSideComponentPad, to: &product)
    self.appendPads (from: inLegacyBoardModel.traversingPads, layer: .innerComponentPad, to: &product)
  //--- Perform update
    self.internalLoadELCanariBoardArchive (
      product,
      named: inLegacyBoardModel.name,
      callBack: { self.performUpdateModel (inLegacyBoardModel, with: $0) }
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func appendRectangles (from inArray : EBReferenceArray <RectangleEntity>,
                                     layer inLayer : ProductLayerSet,
                                     to ioProduct : inout ProductRepresentation) {
    for rect in inArray.values {
      let centerX = (rect.p0x + rect.p1x + rect.p2x + rect.p3x) / 4
      let centerY = (rect.p0y + rect.p1y + rect.p2y + rect.p3y) / 4
      let p0 = NSPoint (x: rect.p0x, y: rect.p0y)
      let p1 = NSPoint (x: rect.p1x, y: rect.p1y)
      let width = p0.distance (to: p1)
      let p2 = NSPoint (x: rect.p2x, y: rect.p2y)
      let height = p1.distance (to: p2)
      let angleInDegrees = NSPoint.angleInDegrees (p0, p1)
      var af = AffineTransform ()
      af.translate (x: centerX.ptValue, y: centerY.ptValue)
      af.rotate (byDegrees: angleInDegrees)
      af.scale (x: width, y: height)
      let s = LayeredProductRectangle (af: af, layers: inLayer)
      ioProduct.append (rectangle: s)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func appendSegments (from inArray : EBReferenceArray <SegmentEntity>,
                                   layer inLayer : ProductLayerSet,
                                   to ioProduct : inout ProductRepresentation) {
    for segment in inArray.values {
      let p1 = ProductPoint (canariPoint: CanariPoint (x: segment.x1, y: segment.y1))
      let p2 = ProductPoint (canariPoint: CanariPoint (x: segment.x2, y: segment.y2))
      if p1 == p2 {
        let s = LayeredProductCircle (
          center: p1,
          diameter: segment.width,
          layers: inLayer
        )
        ioProduct.append (circle: s)
      }else{
        let s = LayeredProductSegment (
          p1: p1,
          p2: p2,
          width: segment.width,
          layers: inLayer
        )
        switch segment.endStyle {
        case .round :
          ioProduct.append (roundSegment: s)
        case .square :
          ioProduct.append (squareSegment: s)
        }
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func appendHoles (from inArray : EBReferenceArray <SegmentEntity>,
                                to ioProduct : inout ProductRepresentation) {
    for segment in inArray.values {
      let p1 = ProductPoint (canariPoint: CanariPoint (x: segment.x1, y: segment.y1))
      let p2 = ProductPoint (canariPoint: CanariPoint (x: segment.x2, y: segment.y2))
      let width = segment.width
      if p1 == p2 {
        let s = LayeredProductCircle (
          center: p1,
          diameter: width,
          layers: .hole
        )
        ioProduct.append (circle: s)
      }else{
        let s = LayeredProductSegment (
          p1: p1,
          p2: p2,
          width: width,
          layers: .hole
        )
        ioProduct.append (roundSegment: s)
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func appendVias (from inArray : EBReferenceArray <BoardModelVia>,
                               to ioProduct : inout ProductRepresentation) {
    for via in inArray.values {
      let center = ProductPoint (canariPoint: CanariPoint (x: via.x, y: via.y))
      let s = LayeredProductCircle (
        center: center,
        diameter: via.padDiameter,
        layers: .viaPad
      )
      ioProduct.append (circle: s)
    }
  }

 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func appendPads (from inArray : EBReferenceArray <BoardModelPad>,
                               layer inLayer : ProductLayerSet,
                               to ioProduct : inout ProductRepresentation) {
    for pad in inArray.values {
      let width = pad.width
      let height = pad.height
      let angleDegrees = Double (pad.rotation) / 1000.0
      var af = AffineTransform ()
      af.translate (x: pad.x.ptValue, y: pad.y.ptValue)
      af.rotate (byDegrees: angleDegrees)
      let s = LayeredProductComponentPad (
        width: width,
        height: height,
        af: af,
        shape: pad.shape,
        layers: inLayer
      )
      ioProduct.append (pad: s)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
