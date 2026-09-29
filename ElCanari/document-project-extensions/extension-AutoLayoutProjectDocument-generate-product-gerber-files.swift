//
//  ProjectDocument-generate-product-gerber-files.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 31/07/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

/*fileprivate struct ApertureKey : Hashable, Comparable {

  let value : CGFloat
  let shape : Shape

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static func < (lhs: ApertureKey, rhs: ApertureKey) -> Bool {
    return (lhs.value < rhs.value)
      || ((lhs.value == rhs.value) && (lhs.shape < rhs.shape))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  init (circular inValue : CGFloat) {
//    self.value = inValue
//    self.shape = .circular
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  init (square inValue : CGFloat) {
//    self.value = inValue
//    self.shape = .square
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var gerberAperture : String {
    let a = String (format: "%.4f", cocoaToInch (self.value))
    switch self.shape {
    case .circular : return "C,\(a)"
    case .square : return "R,\(a)X\(a)"
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  enum Shape : Comparable {
  case circular
  case square
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

} */

//--------------------------------------------------------------------------------------------------

extension AutoLayoutProjectDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func writeGerberDrillFile (atURL inURL : URL,
                             _ inProduct : ProductRepresentation) throws {
    self.mProductFileGenerationLogTextView?.appendMessage ("Generating \(inURL.lastPathComponent)…")
    let drillString = inProduct.excellonDrillString (unit: self.rootObject.mGerberProductUnit)
    let drillData : Data? = drillString.data (using: .ascii, allowLossyConversion: false)
    try drillData?.write (to: inURL, options: .atomic)
    self.mProductFileGenerationLogTextView?.appendSuccess (" Ok\n")
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func writeGerberProductFile (atURL inURL : URL,
                               _ inDescriptor : ArtworkFileGenerationParameters,
//                               _ inLayerConfiguration : LayerConfiguration,
                               _ inProductRepresentation : ProductRepresentation) throws {
    let url = inURL.appendingPathExtension (inDescriptor.fileExtension)
    self.mProductFileGenerationLogTextView?.appendMessage ("Generating \(url.lastPathComponent)…")
    let mirror : ProductHorizontalMirror = inDescriptor.horizontalMirror
      ? .mirror (boardWidth: self.rootObject.boardBoundBox!.size.width)
      : .noMirror
    let gerber : GerberRepresentation = inProductRepresentation.gerber (
      items: inDescriptor.layerItems,
      mirror: mirror
    )
    let gerberString = gerber.gerberString (unit: self.rootObject.mGerberProductUnit)
    let gerberData : Data? = gerberString.data (using: .ascii, allowLossyConversion: false)
    try gerberData?.write (to: url, options: .atomic)
    self.mProductFileGenerationLogTextView?.appendSuccess (" Ok\n")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

extension EBLinePath {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  func appendGerberCodeTo (_ ioStringArray : inout [String], _ inAffineTransform : AffineTransform) {
//    let to = inAffineTransform.transform (self.origin)
//    let x = cocoaToMilTenth (to.x)
//    let y = cocoaToMilTenth (to.y)
//    ioStringArray.append ("X\(x)Y\(y)D02")
//    for p in self.lines {
//      let tp = inAffineTransform.transform (p)
//      let x = cocoaToMilTenth (tp.x)
//      let y = cocoaToMilTenth (tp.y)
//      ioStringArray.append ("X\(x)Y\(y)D01")
//    }
//    if self.closed {
//      ioStringArray.append ("X\(x)Y\(y)D01")
//    }
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------


/* extension Dictionary where Key == ApertureKey, Value == [String] {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func append (_ inStringArray : [String], for inAperture : ApertureKey) {
   self [inAperture] = self [inAperture, default: []] + inStringArray
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendCircular (_ inApertureDict : [CGFloat : [EBLinePath]], _ inAffineTransform : AffineTransform) {
    for (aperture, pathArray) in inApertureDict {
      var drawings = [String] ()
      for path in pathArray {
        path.appendGerberCodeTo (&drawings, inAffineTransform)
      }
      self.append (drawings, for: ApertureKey (circular: aperture))
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

} */

//--------------------------------------------------------------------------------------------------
