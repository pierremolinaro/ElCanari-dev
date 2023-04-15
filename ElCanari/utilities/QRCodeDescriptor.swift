//
//  QRCodeDescriptor.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/04/2023.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct QRCodeDescriptor : Hashable {

  //····················································································································

  struct QRCodePixel : Hashable {
    let x : Int
    let y : Int
  }

  //····················································································································

  public let blackPixels : [QRCodePixel]
  public let pixelsWide : Int
  public let pixelsHigh : Int

  //····················································································································

  init (string inString : String, errorCorrectionLevel inErrorCorrectionLevel : CIQRCodeDescriptor.ErrorCorrectionLevel) {
    let correctionLevelString : String
    switch inErrorCorrectionLevel {
    case .levelL : correctionLevelString = "L"
    case .levelM : correctionLevelString = "M"
    case .levelQ : correctionLevelString = "Q"
    case .levelH : correctionLevelString = "H"
    @unknown default: fatalError ()
    }
    let inputParams : [String : Any] = [
      "inputMessage" : inString.data (using: .isoLatin1)!, // ISOLatin1 string encoding is required
      "inputCorrectionLevel" : correctionLevelString
    ]
    let barcodeCreationFilter = CIFilter (name: "CIQRCodeGenerator", parameters: inputParams)!
    let ciImage = barcodeCreationFilter.outputImage!
    let ciImageRepresentation = NSCIImageRep (ciImage: ciImage)
  //--- Build bit map
    self.pixelsWide = ciImageRepresentation.pixelsWide
    self.pixelsHigh = ciImageRepresentation.pixelsHigh
    let possibleOffscreenRep = NSBitmapImageRep (
      bitmapDataPlanes: nil,
      pixelsWide: pixelsWide,
      pixelsHigh: pixelsHigh,
      bitsPerSample: 8,
      samplesPerPixel: 4,
      hasAlpha: true,
      isPlanar: false,
      colorSpaceName: NSColorSpaceName.deviceRGB,
      bitmapFormat: NSBitmapImageRep.Format.alphaFirst,
      bytesPerRow: 0,
      bitsPerPixel: 0
    )
    var pixels = [QRCodePixel] ()
    if let offscreenRep = possibleOffscreenRep,
       let graphicContext = NSGraphicsContext (bitmapImageRep: offscreenRep) {
      NSGraphicsContext.saveGraphicsState ()
      NSGraphicsContext.current = graphicContext
      graphicContext.imageInterpolation = .none
      ciImageRepresentation.draw (in: NSRect (origin: .zero, size: ciImageRepresentation.size))
      for y in 0 ..< pixelsHigh {
        for x in 0 ..< pixelsWide {
          if let color = offscreenRep.colorAt (x: x, y: y) {
            var redComponent : CGFloat = 0.0
            var greenComponent : CGFloat = 0.0
            var blueComponent : CGFloat = 0.0
            var alphaComponent : CGFloat = 0.0
            color.getRed (&redComponent, green:&greenComponent, blue:&blueComponent, alpha:&alphaComponent)
            if redComponent < 0.5 {
              pixels.append (QRCodePixel (x: x, y: pixelsHigh - 1 - y))
            }
          }
        }
      }
      NSGraphicsContext.restoreGraphicsState ()
    }
    self.blackPixels = pixels
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
