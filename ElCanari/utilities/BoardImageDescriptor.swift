//
//  BoardImageDescriptor.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 17/04/2023.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIPhotoEffectMono
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct BoardImageDescriptor : Hashable {

  //····················································································································

  struct BoardImageElementRectangle : Hashable {
    let x : Int
    let y : Int
    let width : Int
    let height : Int
  }

  //····················································································································

  public let blackRectangles : [BoardImageElementRectangle]
  public let originalImageWidth : Int
  public let originalImageHeight : Int
  public let scaledImageWidth : Int
  public let scaledImageHeight : Int

  //····················································································································

  init (imageData inImageData : Data, threshold inThreshold : Int, invert inInvert : Bool, scale inScale : Double) {
    var rectArray = [BoardImageElementRectangle] ()
  //--- Construire l'image originale ----> CIImage
    if let ciOriginalImage = CIImage (data: inImageData, options: [.applyOrientationProperty : true]) {
      self.originalImageWidth  = Int (ciOriginalImage.extent.size.width)
      self.originalImageHeight = Int (ciOriginalImage.extent.size.height)
    //--- Appliquer les filtres
      let ciGrayImage : CIImage  = ciOriginalImage
        .applyingFilter ("CIPhotoEffectNoir") // Obtenir une image en tons de gris
        .applyingFilter ("CILanczosScaleTransform", parameters : ["inputScale" : inScale]) // Réduire l'image
    //--- Définir une couleur de fond (apparaît aux endroits où l'image est transparente)
      let ciBackgroundImage = CIImage (color: .white).cropped (to: ciGrayImage.extent)
      let ciGrayImageWithBackground : CIImage  = ciGrayImage.composited (over: ciBackgroundImage)
    //--- Construire la représentation bit map ----> NSBitmapImageRep
      let grayImageBitMap = NSBitmapImageRep (ciImage: ciGrayImageWithBackground)
      self.scaledImageWidth = grayImageBitMap.pixelsWide
      self.scaledImageHeight = grayImageBitMap.pixelsHigh
    //--- Échantillonner de nouveau l'image
    //---
//      Swift.print ("grayImageBitMap.samplesPerPixel \(grayImageBitMap.samplesPerPixel)")
      var peek = [Int] (repeating: 0, count: grayImageBitMap.samplesPerPixel)
      for y in 0 ..< grayImageBitMap.pixelsHigh {
        var originX = 0
        let originY = grayImageBitMap.pixelsHigh - y - 1
        var width = 0 // Empty rect
        for x in 0 ..< grayImageBitMap.pixelsWide {
          grayImageBitMap.getPixel (&peek, atX: x, y: y)
          let blackPixel = (peek [0] <= inThreshold) != inInvert
          if blackPixel {
            if width == 0 { // Begin a new rect
              originX = x
              width = 1
            }else{ // Extend an existing rect
              width += 1
            }
          }else if width > 0 { // White pixel, closing an existing rect
            rectArray.append (BoardImageElementRectangle (x: originX, y: originY, width: width, height: 1))
            width = 0
          }
        }
        if width > 0 { // closing the last existing rect
          rectArray.append (BoardImageElementRectangle (x: originX, y: originY, width: width, height: 1))
        }
      }
    }else{
      self.originalImageWidth  = 20
      self.originalImageHeight = 20
      self.scaledImageWidth = 20
      self.scaledImageHeight = 20
    }
  //---
    self.blackRectangles = rectArray
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
