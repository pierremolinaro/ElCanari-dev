//
//  extension-BoardText.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 16/06/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

let BOARD_TEXT_ORIGIN_KNOB  = 0
let BOARD_TEXT_ROTATION_KNOB  = 1

fileprivate let BOARD_TEXT_ROTATION_KNOB_DISTANCE = CanariLength.pt (30)
fileprivate let FONT_NAME_IN_DICTIONARY = "*FONT-NAME*"

//--------------------------------------------------------------------------------------------------
//   EXTENSION BoardText
//--------------------------------------------------------------------------------------------------

extension BoardText {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func cursorForKnob_BoardText (knob inKnobIndex : Int) -> NSCursor? {
    if inKnobIndex == BOARD_TEXT_ORIGIN_KNOB {
      return NSCursor.upDownRightLeftCursor
    }else if inKnobIndex == BOARD_TEXT_ROTATION_KNOB {
      return NSCursor.rotationCursor
    }else{
      return nil
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Translation
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptedTranslation_BoardText (xBy inDx: CanariLength, yBy inDy: CanariLength) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptToTranslate_BoardText (xBy _ : CanariLength, yBy _ : CanariLength) -> Bool {
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func translate_BoardText (xBy inDx : CanariLength, yBy inDy : CanariLength, userSet _ : inout EBReferenceSet <EBManagedObject>) {
    self.mX += inDx
    self.mY += inDy
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationAfterPasting
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationAfterPasting_BoardText (additionalDictionary inDictionary : [String : Any],
                                        optionalDocument inOptionalDocument : EBAutoLayoutManagedDocument?,
                                        objectArray _ : [EBGraphicManagedObject]) -> String {
    if let fontName = inDictionary [FONT_NAME_IN_DICTIONARY] as? String,
       let projectDocument = inOptionalDocument as? AutoLayoutProjectDocumentSubClass {
      var optionalFont : FontInProject? = nil
      for font in projectDocument.rootObject.mFonts.values {
        if font.mFontName == fontName {
          optionalFont = font
        }
      }
      if let font = optionalFont {
        self.mFont = font
        return "" // Ok, no error
      }else{
        return "Cannot paste board text: \(fontName) board font is not installed in document"
      }
    }else{
      return "Cannot paste board text: internal error"
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Save into additional dictionary
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func saveIntoAdditionalDictionary_BoardText (_ ioDictionary : inout [String : Any]) {
    ioDictionary [FONT_NAME_IN_DICTIONARY] = self.fontName
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Knob
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canMove_BoardText (knob inKnobIndex : Int,
                          proposedUnalignedAlignedTranslation _ : CanariPoint,
                          proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                          unalignedMouseDraggedLocation _ : CanariPoint,
                          shift _ : Bool) -> CanariPoint {
    if inKnobIndex == BOARD_TEXT_ORIGIN_KNOB {
      return inProposedAlignedTranslation
    }else if inKnobIndex == BOARD_TEXT_ROTATION_KNOB {
      return inProposedAlignedTranslation
    }else{
      return .zero
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func move_BoardText (knob inKnobIndex: Int,
                      proposedDx inDx: CanariLength,
                      proposedDy inDy: CanariLength,
                      unalignedMouseLocationX _ : CanariLength,
                      unalignedMouseLocationY _ : CanariLength,
                      alignedMouseLocationX inAlignedMouseLocationX : CanariLength,
                      alignedMouseLocationY inAlignedMouseLocationY : CanariLength,
                      shift _ : Bool) {
    if inKnobIndex == BOARD_TEXT_ORIGIN_KNOB {
      self.mX += inDx
      self.mY += inDy
    }else if inKnobIndex == BOARD_TEXT_ROTATION_KNOB, let fontDescriptor = self.mFont?.descriptor {
      let (_, _, origin, _, _) = boardText_displayInfos (
        x: self.mX,
        y: self.mY,
        string: self.mText,
        fontSize: self.mFontSize,
        fontDescriptor,
        horizontalAlignment: self.mHorizontalAlignment,
        verticalAlignment: self.mVerticalAlignment,
        frontSide: (self.mLayer == .layoutFront) || (self.mLayer == .legendFront),
        rotation: self.mRotation,
        weight: self.mWeight,
        oblique: self.mOblique,
        extraWidth: .zero
      )
      let newRotationKnobLocation = CanariPoint (x: inAlignedMouseLocationX, y: inAlignedMouseLocationY)
//      let newAngleInDegrees = NSPoint.angleInDegrees (origin, newRotationKnobLocation)
//      self.mRotation = degreesToCanariRotation (newAngleInDegrees)
      self.mRotation = origin.angle (to: newRotationKnobLocation)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   SNAP TO GRID
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canSnapToGrid_BoardText (_ inGrid : CanariLength) -> Bool {
    var isAligned = self.mX.isAligned (on: inGrid)
    if isAligned {
      isAligned = self.mY.isAligned (on: inGrid)
    }
    return !isAligned
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func snapToGrid_BoardText (_ inGrid : CanariLength) {
    self.mX.align (on: inGrid)
    self.mY.align (on: inGrid)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Rotate 90°
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canRotate90_BoardText (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    accumulatedPoints.insert (x: self.mX, y: self.mY)
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90Clockwise_BoardText (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    let p = inRotationCenter.rotated90Clockwise (x: self.mX, y: self.mY)
    self.mX = p.x
    self.mY = p.y
  //  self.mRotation = (self.mRotation + degreesToCanariRotation (270.0)) % degreesToCanariRotation (360.0)
    self.mRotation += .degrees270
    ioSet.insert (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90CounterClockwise_BoardText (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    let p = inRotationCenter.rotated90CounterClockwise (x: self.mX, y: self.mY)
    self.mX = p.x
    self.mY = p.y
//    self.mRotation = (self.mRotation + degreesToCanariRotation (90.0)) % degreesToCanariRotation (360.0)
    self.mRotation += .degrees90
    ioSet.insert (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Alignment Points
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func alignmentPoints_BoardText () -> Set <CanariPoint> {
    return Set <CanariPoint> ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  REMOVING
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationBeforeRemoving_BoardText () {
    self.mFont = nil
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  HORIZONTAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipHorizontally_BoardText () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipHorizontally_BoardText () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  VERTICAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipVertically_BoardText () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipVertically_BoardText () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func displayInfos (extraWidth inExtraWidth : CanariLength) -> (BezierPath, BezierPath, CanariPoint, CanariPoint, [GeometricOblong]) { // (textDisplay, frame, origin, rotation knob)
    return boardText_displayInfos (
      x: self.mX,
      y: self.mY,
      string: self.mText,
      fontSize: self.mFontSize,
      self.mFont!.descriptor!,
      horizontalAlignment: self.mHorizontalAlignment,
      verticalAlignment: self.mVerticalAlignment,
      frontSide: (self.mLayer == .legendFront) || (self.mLayer == .layoutFront),
      rotation: self.mRotation,
      weight: self.mWeight,
      oblique: self.mOblique,
      extraWidth: inExtraWidth
    )
  }
}

//--------------------------------------------------------------------------------------------------

@MainActor func boardText_displayInfos (
       x self_mX : CanariLength,
       y self_mY : CanariLength,
       string self_mText : String,
       fontSize self_mFontSize : Double,
       _ self_mFont_descriptor : BoardFontDescriptor,
       horizontalAlignment self_mHorizontalAlignment : HorizontalAlignment,
       verticalAlignment self_mVerticalAlignment : BoardTextVerticalAlignment,
       frontSide inFrontSide : Bool,
       rotation self_mRotation : CanariAngle,
       weight self_mWeight : Double,
       oblique self_mOblique : Bool,
       extraWidth inExtraWidth : CanariLength // Used for ERC checking
) -> (BezierPath, BezierPath, CanariPoint, CanariPoint, [GeometricOblong]) { // (textDisplay, frame, origin, rotation knob)
  let s = (self_mText.isEmpty) ? "Empty" : self_mText
  var stringWidth = CanariLength.zero
  let oblique = self_mOblique ? CGFloat (0.25) : CGFloat (0.0)
  let fontFactor = CGFloat (self_mFontSize) / CGFloat (self_mFont_descriptor.nominalSize)
  let lineThickness = fontFactor * 2.0 * CanariLength.pt (self_mWeight) + inExtraWidth
  var bp = BezierPath ()
  bp.lineWidth = lineThickness
  bp.lineCapStyle = .round
  bp.lineJoinStyle = .round
  var oblongs = [GeometricOblong] ()
  for character in s.unicodeScalars {
    if let characterDescriptor = self_mFont_descriptor.dictionary [character.value] {
      for segment in characterDescriptor.segments {
        let x1 = fontFactor * (CanariLength.pt (CGFloat (segment.x1)) + oblique * CanariLength.pt (CGFloat (segment.y1)))
        let y1 = fontFactor * CanariLength.pt (CGFloat (segment.y1))
        let x2 = fontFactor * (CanariLength.pt (CGFloat (segment.x2)) + oblique * CanariLength.pt (CGFloat (segment.y2)))
        let y2 = fontFactor * CanariLength.pt (CGFloat (segment.y2))
        let p1 = CanariPoint (x: stringWidth + x1, y: y1)
        let p2 = CanariPoint (x: stringWidth + x2, y: y2)
        bp.move (to: p1)
        bp.line (to: p2)
        oblongs.append (GeometricOblong (p1: p1, p2: p2, width: lineThickness, capStyle: .round))
      }
      stringWidth += .pt (CGFloat (characterDescriptor.advancement) * fontFactor)
    }
  }
  let bounds = bp.bounds
  var frameBP = BezierPath ()
  if !bp.isEmpty {
    frameBP.appendRect (bp.bounds.insetBy (dx: .pt (-1.0), dy: .pt (-1.0)))
  }
  var tr = CanariAffinity
    .translating (x: self_mX, y: self_mY)
    .rotating (by: self_mRotation)
  if !inFrontSide {
    tr.scale (x: -1.0, y: 1.0)
  }

  switch self_mHorizontalAlignment {
  case .onTheLeft :
    tr.translate (x: -stringWidth, y: .zero)
  case .center :
    tr.translate (x: -stringWidth / 2.0, y: .zero)
  case .onTheRight :
    ()
  }

  switch self_mVerticalAlignment {
  case .above :
    tr.translate (x: .zero, y: -bounds.minY)
  case .base :
    ()
  case .center :
    tr.translate (x: .zero, y: -(bounds.maxY + bounds.minY) / 2.0)
  case .below :
    tr.translate (x: .zero, y: -bounds.maxY)
  }
  bp.transform (using: tr)

  var transformedOblongs = [GeometricOblong] ()
  for ob in oblongs {
    transformedOblongs.append (ob.transformed (by: tr))
  }
  frameBP.transform (using: tr)
  frameBP.lineWidth = CanariLength.pt (0.5)
  frameBP.lineCapStyle = .round
  frameBP.lineJoinStyle = .round
//--- Rotation knob
  let rotationKnobTransform = CanariAffinity
    .translating (x: self_mX, y: self_mY)
    .rotating (by: self_mRotation)
  let rotationKnobLocation = rotationKnobTransform.transforming (x: BOARD_TEXT_ROTATION_KNOB_DISTANCE)
//---
  return (bp, frameBP, CanariPoint (x: self_mX, y: self_mY), rotationKnobLocation, transformedOblongs)
}

//--------------------------------------------------------------------------------------------------
