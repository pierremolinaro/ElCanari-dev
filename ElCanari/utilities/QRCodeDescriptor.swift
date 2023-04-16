//
//  QRCodeDescriptor.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/04/2023.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// https://www.keyence.com/ss/products/auto_id/codereader/basic_2d/qr.jsp
// https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIQRCodeGenerator
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate let QR_CODE_MARGIN = 3 // 4 modules are required, ci image provides one

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct QRCodeDescriptor : Hashable {

  //····················································································································

  struct QRCodePoint {
    let x : Int
    let y : Int
  }

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
    @unknown default: correctionLevelString = "H"
    }
    let inputParams : [String : Any] = [
      "inputMessage" : inString.data (using: .isoLatin1)!, // ISOLatin1 string encoding is required
      "inputCorrectionLevel" : correctionLevelString
    ]
    let barcodeCreationFilter = CIFilter (name: "CIQRCodeGenerator", parameters: inputParams)!
    let ciImage = barcodeCreationFilter.outputImage!
  //--- Build bit map
    let bitMapImageRep = NSBitmapImageRep (ciImage: ciImage)
    self.imageWidth = bitMapImageRep.pixelsWide + (inFramed ? 2 : 0) + QR_CODE_MARGIN * 2
    self.imageHeight = bitMapImageRep.pixelsHigh + (inFramed ? 2 : 0) + QR_CODE_MARGIN * 2
  //--- Build QR Code representation
    var rects = [QRCodeRectangle] ()
    var pixels = [QRCodePoint] ()
    for y in 0 ..< bitMapImageRep.pixelsHigh {
      let rectOriginY = bitMapImageRep.pixelsHigh + QR_CODE_MARGIN - (inFramed ? 0 : 1) - y
      var originX = 0
      var width = 0 // Empty rect
      for x in 0 ..< bitMapImageRep.pixelsWide {
        var p : Int = 0
        bitMapImageRep.getPixel (&p, atX: x, y: y)
        let blackPixel = p < 128
        if blackPixel {
          if width == 0 { // Begin a new rect
            originX = x + (inFramed ? 1 : 0) + QR_CODE_MARGIN
            width = 1
          }else{ // Extend an existing rect
            width += 1
          }
        }else if width == 1 { // White pixel, closing an existing rect
          pixels.append (QRCodePoint (x: originX, y: rectOriginY))
          width = 0
        }else if width > 0 { // White pixel, closing an existing rect
          let r = QRCodeRectangle (x: originX, y: rectOriginY, width: width, height: 1)
          rects.append (r)
          width = 0
        }
      }
      if width == 1 { // closing the last existing rect
        pixels.append (QRCodePoint (x: originX, y: rectOriginY))
      }else if width > 0 { // closing the last existing rect
        let r = QRCodeRectangle (x: originX, y: rectOriginY, width: width, height: 1)
        rects.append (r)
      }
    }
  //--- Sort pixel array
    pixels.sort { ($0.x < $1.x) || (($0.x == $1.x) && ($0.y < $1.y)) }
//    for p in pixels {
//      Swift.print ("\(p.x) \(p.y)")
//    }
  //--- Group pixels in vertical lines
    var x = 0
    var y = 0
    var height = 0 // Empty rect
    for p in pixels {
      if height == 0 { // Start a new rect
        x = p.x
        y = p.y
        height = 1
      }else if p.x == x, p.y == (y + height) { // Extend a vertical line
        height += 1
      }else{ // Close vertical line
        rects.append (QRCodeRectangle (x: x, y: y, width: 1, height: height))
        x = p.x
        y = p.y
        height = 1
      }
    }
    if height > 0 {
      rects.append (QRCodeRectangle (x: x, y: y, width: 1, height: height))
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
