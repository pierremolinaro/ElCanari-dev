//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func computed_BoardImage_computedDataImage (
       _ self_mImageData : Data,                       
       _ self_mScale : Double,                         
       _ self_mImageDisplay : BoardImageDisplay
) -> Data {
//--- START OF USER ZONE 2
        switch self_mImageDisplay {
        case .original :
           return self_mImageData
        case .gray :
          let ciOriginalImage = CIImage (data: self_mImageData, options: [.applyOrientationProperty : true])!
          let ciGrayImage : CIImage  = ciOriginalImage
            .applyingFilter ("CIPhotoEffectNoir") // Obtenir une image en tons de gris
            .applyingFilter ("CILanczosScaleTransform", parameters : ["inputScale" : self_mScale]) // Réduire l'image
          let ciBackgroundImage = CIImage (color: .white).cropped (to: ciGrayImage.extent)
          let ciGrayImageWithBackground : CIImage = ciGrayImage.composited (over: ciBackgroundImage)
          let nsGrayImage = NSImage (size: ciGrayImageWithBackground.extent.size)
          nsGrayImage.lockFocus ()
          ciGrayImageWithBackground.draw (at: .zero, from: ciGrayImageWithBackground.extent, operation: .copy, fraction: 1.0)
          nsGrayImage.unlockFocus ()
          return nsGrayImage.tiffRepresentation ?? Data ()
        case .histogram :
          let ciOriginalImage = CIImage (data: self_mImageData, options: [.applyOrientationProperty : true])!
          let ciGrayImage : CIImage  = ciOriginalImage
            .applyingFilter ("CIPhotoEffectNoir") // Obtenir une image en tons de gris
            .applyingFilter ("CILanczosScaleTransform", parameters : ["inputScale" : self_mScale]) // Réduire l'image
          let ciBackgroundImage = CIImage (color: .white).cropped (to: ciGrayImage.extent)
          let ciGrayImageWithBackground : CIImage = ciGrayImage.composited (over: ciBackgroundImage)
   //       Swift.print ("ciGrayImageWithBackground.extent \(ciGrayImageWithBackground.extent)")
          let histogramImage = ciGrayImageWithBackground
            .applyingFilter ("CIAreaHistogram", parameters : ["inputExtent" : ciGrayImageWithBackground.extent, "inputScale" : ciGrayImageWithBackground.extent.size.width, "inputCount" : 256.0])
            .applyingFilter ("CIHistogramDisplayFilter", parameters : [:])
          let nsGrayImage = NSImage (size: histogramImage.extent.size)
          nsGrayImage.lockFocus ()
          histogramImage.draw (at: .zero, from: histogramImage.extent, operation: .copy, fraction: 1.0)
          nsGrayImage.unlockFocus ()
          return nsGrayImage.tiffRepresentation ?? Data ()
        }
//--- END OF USER ZONE 2
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————