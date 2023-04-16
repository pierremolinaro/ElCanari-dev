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

  struct QRCodeRectangle : Hashable {
    let x : Int
    let y : Int
    let width : Int
    let height : Int
  }

  //····················································································································

  public let blackRectangles : [QRCodeRectangle]
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
    var rects = [QRCodeRectangle] ()
    if let offscreenRep = possibleOffscreenRep,
       let graphicContext = NSGraphicsContext (bitmapImageRep: offscreenRep) {
      NSGraphicsContext.saveGraphicsState ()
      NSGraphicsContext.current = graphicContext
      graphicContext.imageInterpolation = .none
      ciImageRepresentation.draw (in: NSRect (origin: .zero, size: ciImageRepresentation.size))
      for y in 0 ..< ciImageRepresentation.pixelsHigh {
        let rectOriginY = ciImageRepresentation.pixelsHigh - (inFramed ? 0 : 1) - y
        var originX = 0
        var width = 0 // Empty rect
        for x in 0 ..< ciImageRepresentation.pixelsWide {
          if let color = offscreenRep.colorAt (x: x, y: y) {
            var redComponent : CGFloat = 0.0
            var greenComponent : CGFloat = 0.0
            var blueComponent : CGFloat = 0.0
            var alphaComponent : CGFloat = 0.0
            color.getRed (&redComponent, green:&greenComponent, blue:&blueComponent, alpha:&alphaComponent)
            let blackPixel = redComponent < 0.5
            if blackPixel {
              if width == 0 { // Begin a new rect
                originX = x + (inFramed ? 1 : 0)
                width = 1
              }else{ // Extend an existing rect
                width += 1
              }
            }else if width > 0 { // White pixel, closing an existing rect
              let r = QRCodeRectangle (x: originX, y: rectOriginY, width: width, height: 1)
              rects.append (r)
              width = 0
            }
          }
        }
        if width > 0 { // closing the last existing rect
          let r = QRCodeRectangle (x: originX, y: rectOriginY, width: width, height: 1)
          rects.append (r)
        }
      }
      NSGraphicsContext.restoreGraphicsState ()
    }
  //--- Add Frame
    if inFramed {
      rects.append (QRCodeRectangle (x: 0, y: 0, width: self.imageWidth, height: 1))
      rects.append (QRCodeRectangle (x: 0, y: self.imageHeight - 1, width: self.imageWidth, height: 1))
      rects.append (QRCodeRectangle (x: 0, y: 1, width: 1, height: self.imageHeight - 2))
      rects.append (QRCodeRectangle (x: self.imageWidth - 1, y: 1, width: 1, height: self.imageHeight - 2))
    }
  //---
    self.blackRectangles = rects
//    Swift.print ("QR Code: \(rects.count) rectangles")
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
