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
  public let imageWidth : Int
  public let imageHeight : Int

  //····················································································································

  init (string inString : String,
        errorCorrectionLevel inErrorCorrectionLevel : CIQRCodeDescriptor.ErrorCorrectionLevel,
        framed inFramed : Bool) {
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
    self.imageWidth = ciImageRepresentation.pixelsWide + (inFramed ? 2 : 0)
    imageHeight = ciImageRepresentation.pixelsHigh + (inFramed ? 2 : 0)
    let possibleOffscreenRep = NSBitmapImageRep (
      bitmapDataPlanes: nil,
      pixelsWide: ciImageRepresentation.pixelsWide,
      pixelsHigh: ciImageRepresentation.pixelsHigh,
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
      for y in 0 ..< ciImageRepresentation.pixelsHigh {
        for x in 0 ..< ciImageRepresentation.pixelsWide {
          if let color = offscreenRep.colorAt (x: x, y: y) {
            var redComponent : CGFloat = 0.0
            var greenComponent : CGFloat = 0.0
            var blueComponent : CGFloat = 0.0
            var alphaComponent : CGFloat = 0.0
            color.getRed (&redComponent, green:&greenComponent, blue:&blueComponent, alpha:&alphaComponent)
            if redComponent < 0.5 {
              pixels.append (QRCodePixel (x: x + (inFramed ? 1 : 0), y: ciImageRepresentation.pixelsHigh - (inFramed ? 0 : 1) - y))
            }
          }
        }
      }
      NSGraphicsContext.restoreGraphicsState ()
    }
  //--- Add Frame
    if inFramed {
      for x in 0 ..< self.imageWidth {
        pixels.append (QRCodePixel (x: x, y: self.imageHeight - 1))
        pixels.append (QRCodePixel (x: x, y: 0))
      }
      for y in 1 ..< (self.imageHeight - 1) {
        pixels.append (QRCodePixel (x: 0, y: y))
        pixels.append (QRCodePixel (x: self.imageWidth - 1, y: y))
      }
    }
  //---
    self.blackPixels = pixels
    Swift.print ("QR Code: \(pixels.count) pixels")
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
