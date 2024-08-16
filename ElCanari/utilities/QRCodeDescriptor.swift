//
//  QRCodeDescriptor.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/04/2023.
//
//--------------------------------------------------------------------------------------------------
// https://www.keyence.com/ss/products/auto_id/codereader/basic_2d/qr.jsp
// https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIQRCodeGenerator
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

fileprivate let QR_CODE_MARGIN = 3 // 4 modules are required, ci image provides one
fileprivate let PRINT_BIT_MAP = false
fileprivate let PRINT_PIXEL_RECT_COUNT = false

//--------------------------------------------------------------------------------------------------

struct QRCodeDescriptor : Hashable {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  struct QRCodePoint {
    let x : Int
    let y : Int
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  struct QRCodeRectangle : Hashable {
    let x : Int
    let y : Int
    let width : Int
    let height : Int
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let blackRectangles : [QRCodeRectangle]
  let imageWidth : Int
  let imageHeight : Int

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (string inString : String,
        errorCorrectionLevel inErrorCorrectionLevel : CIQRCodeDescriptor.ErrorCorrectionLevel,
        framed inFramed : Bool) {
    var rects = [QRCodeRectangle] ()
    if let isoLatin1Data = inString.data (using: .isoLatin1) {
      let inputParams : [String : Any] = [
        "inputMessage" : isoLatin1Data, // ISOLatin1 string encoding is required
        "inputCorrectionLevel" : inErrorCorrectionLevel.string
      ]
      if let barcodeCreationFilter = CIFilter (name: "CIQRCodeGenerator", parameters: inputParams),
         let ciImage = barcodeCreationFilter.outputImage {
      //--- Build bit map
        let ciImageRep = NSCIImageRep (ciImage: ciImage)
        self.imageWidth  = ciImageRep.pixelsWide + (inFramed ? 2 : 0) + QR_CODE_MARGIN * 2
        self.imageHeight = ciImageRep.pixelsHigh + (inFramed ? 2 : 0) + QR_CODE_MARGIN * 2
      //--- Build bit map representation
        let bitMap : [[Bool]] = bitMap (forImageRep : ciImageRep)
      //--- Trace
        if PRINT_BIT_MAP {
          Swift.print ("*** BIT MAP ***")
          var pixelCount = 0
          var blackPixelCount = 0
          for row in bitMap {
            var s = ""
            for pixel : Bool in row {
              s += pixel ? "█" : "◻"
              pixelCount += 1
              blackPixelCount += pixel ? 1 : 0
            }
            Swift.print (s)
          }
          Swift.print ("\(pixelCount) pixels, \(100.0 * Double (blackPixelCount) / Double (pixelCount))% noirs")
        }
      //--- Build QR Code representation
        var pixels : [QRCodePoint]
        (pixels, rects) = Self.buildPixelAndRectArray (
          from: bitMap,
          hOrigin: (inFramed ? 1 : 0) + QR_CODE_MARGIN,
          vOrigin: ciImageRep.pixelsHigh + QR_CODE_MARGIN - (inFramed ? 0 : 1)
        )
      //--- Print result
        if PRINT_PIXEL_RECT_COUNT {
          Swift.print ("Bit Map: \(pixels.count) pixels, \(rects.count) rects")
        }
      //--- Sort pixel array
        pixels.sort { ($0.x < $1.x) || (($0.x == $1.x) && ($0.y < $1.y)) }
      //--- Group pixels in vertical lines
        Self.groupVerticalPixels (from: pixels, &rects)
      }else{
        self.imageWidth  = (inFramed ? 2 : 0) + QR_CODE_MARGIN * 2
        self.imageHeight = (inFramed ? 2 : 0) + QR_CODE_MARGIN * 2
      }
    }else{
      self.imageWidth  = (inFramed ? 2 : 0) + QR_CODE_MARGIN * 2
      self.imageHeight = (inFramed ? 2 : 0) + QR_CODE_MARGIN * 2
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
    if PRINT_PIXEL_RECT_COUNT {
      Swift.print ("QR Code: \(rects.count) rectangles")
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate static func buildPixelAndRectArray (
                 from inBitMap : [[Bool]],
                 hOrigin inHorizontalOrigin : Int,
                 vOrigin inVerticalOrigin : Int) -> ([QRCodePoint], [QRCodeRectangle]) {
    var pixels = [QRCodePoint] ()
    var rects = [QRCodeRectangle] ()
    do{
      var width = 0 // Used for building horizontal rect, 0 means empty rect
      var y = 0
      for row in inBitMap {
        let originY = inVerticalOrigin - y
        y += 1
        var originX = 0
        var x = -1
        for pixel : Bool in row {
          x += 1
          if pixel {
            if width == 0 { // Begin a new rect
              originX = x + inHorizontalOrigin
              width = 1
            }else{ // Extend an existing rect
              width += 1
            }
          }else if width == 1 { // White pixel, closing an existing rect of 1 pixel
            pixels.append (QRCodePoint (x: originX, y: originY))
            width = 0
          }else if width > 0 { // White pixel, closing an existing rect
            let r = QRCodeRectangle (x: originX, y: originY, width: width, height: 1)
            rects.append (r)
            width = 0
          }
        }
        if width == 1 { // closing the last existing rect of 1 pixel
          pixels.append (QRCodePoint (x: originX, y: originY))
        }else if width > 1 { // closing the last existing rect
          let r = QRCodeRectangle (x: originX, y: originY, width: width, height: 1)
          rects.append (r)
        }
      }
    }
    return (pixels, rects)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate static func groupVerticalPixels (from inSortedPixelArray : [QRCodePoint],
                                               _ ioRectArray : inout [QRCodeRectangle]) {
    var x = 0
    var y = 0
    var height = 0 // Empty rect
    for p in inSortedPixelArray {
      if height == 0 { // Start a new rect
        x = p.x
        y = p.y
        height = 1
      }else if p.x == x, p.y == (y + height) { // Extend a vertical line
        height += 1
      }else{ // Close vertical line
        ioRectArray.append (QRCodeRectangle (x: x, y: y, width: 1, height: height))
        x = p.x
        y = p.y
        height = 1
      }
    }
    if height > 0 {
      ioRectArray.append (QRCodeRectangle (x: x, y: y, width: 1, height: height))
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

fileprivate extension CIQRCodeDescriptor.ErrorCorrectionLevel {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var string : String {
    switch self {
    case .levelL : return "L"
    case .levelM : return "M"
    case .levelQ : return "Q"
    case .levelH : return "H"
    @unknown default: return "H"
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

fileprivate func bitMap (forImageRep inImageRep : NSCIImageRep) -> [[Bool]] {
  let w = inImageRep.pixelsWide
  let h = inImageRep.pixelsHigh
  let possibleOffscreenRep = NSBitmapImageRep (
    bitmapDataPlanes: nil,
    pixelsWide: w,
    pixelsHigh: h,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: NSColorSpaceName.deviceRGB,
    bitmapFormat: NSBitmapImageRep.Format.alphaFirst,
    bytesPerRow: 0,
    bitsPerPixel: 0
  )
  var result = [[Bool]] ()
  if let offscreenRep = possibleOffscreenRep,
     let graphicContext = NSGraphicsContext (bitmapImageRep: offscreenRep) {
    NSGraphicsContext.saveGraphicsState ()
    NSGraphicsContext.current = graphicContext
    graphicContext.imageInterpolation = .none
    inImageRep.draw (in: NSRect (origin: .zero, size: inImageRep.size))
    for y in 0 ..< h {
      var boolArray = [Bool] ()
      for x in 0 ..< w {
        if let color = offscreenRep.colorAt (x:x, y:y) {
          var redComponent : CGFloat = 0.0
          var greenComponent : CGFloat = 0.0
          var blueComponent : CGFloat = 0.0
          var alphaComponent : CGFloat = 0.0
          color.getRed (&redComponent, green:&greenComponent, blue:&blueComponent, alpha:&alphaComponent)
          boolArray.append (redComponent < 0.5)
        }else{
          boolArray.append (false)
        }
      }
      result.append (boolArray)
    }
    NSGraphicsContext.restoreGraphicsState ()
  }
  return result
}

//--------------------------------------------------------------------------------------------------
