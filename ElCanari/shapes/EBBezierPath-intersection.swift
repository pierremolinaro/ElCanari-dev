//
//  EBBezierPath-intersection.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 18/07/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// EBBezierPath : intersection
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension EBBezierPath {

  //····················································································································

  func intersects (bezierPath inOther : EBBezierPath) -> Bool {
    if !self.bounds.intersects (inOther.bounds) {
      return false
    }else{
      let r = self.bounds.union (inOther.bounds)
      Swift.print ("size \(r.size.width) \(r.size.height)")
      let context = self.create16BitsGrayContextOfSize (r.size)
      let testContext = self.create16BitsGrayContextOfSize (NSSize (width: 1, height: 1))
      self.drawPath (withClip: inOther, context: context)
      let image = context.makeImage ()! // CGImageRef img = CGBitmapContextCreateImage(computeContext);
      let onePixSquare = NSRect (x: 0, y: 0, width: 1, height: 1)
      testContext.clear (onePixSquare) // CGContextClearRect(testContext, onePixSquare);
      testContext.draw (image, in: onePixSquare) // CGContextDrawImage(testContext, onePixSquare, img);
      let dataPtr = testContext.data! //    long*   data = CGBitmapContextGetData(testContext);
      let x = dataPtr.load (as: UInt16.self) //    return (*data!=0);
      return x != 0
    }
  }

  //····················································································································

  private func create16BitsGrayContextOfSize (_ inSize : NSSize) -> CGContext {
    let w = Int (inSize.width)
    let h = Int (inSize.height)
    let nComps = 1
    let bits = 16
    let bitsPerPix = bits * nComps
    let bytesPerRow = bitsPerPix * w
    let cs = CGColorSpaceCreateDeviceGray ()

  //  let bmContext = CGBitmapContextCreate (NULL, w, h, bits, bytesPerRow, cs, 0)
    let context = CGContext (data: nil, width: w, height: h, bitsPerComponent: bits, bytesPerRow: bytesPerRow, space: cs, bitmapInfo: 0)!
    context.setFillColorSpace (cs)
    context.setStrokeColorSpace (cs)
//init?(data: UnsafeMutableRawPointer?, width: Int, height: Int, bitsPerComponent: Int, bytesPerRow: Int, space: CGColorSpace, bitmapInfo: UInt32)
//    if let context = bmContext {
//      CGContextSetFillColorSpace (context,cs);
//      CGContextSetStrokeColorSpace (context,cs);
//    }
    return context
  }

  //····················································································································

  private func drawPath (withClip inClipPath : EBBezierPath, context inContext : CGContext) {
    inContext.saveGState () // CGContextSaveGState(ctx);
    let bounds = NSRect (x: 0, y: 0, width: inContext.width, height: inContext.height)
    inContext.clear (bounds) //    CGContextClearRect(ctx, bounds);
    //    CGFloat clipedColor[] = {1.0f,1.0f,1.0f,1.0f}; // Full white
    inContext.setFillColor (red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)//    CGContextSetFillColor(ctx,clipedColor);
    inContext.addPath (inClipPath.cgPath)//    CGContextAddPath(ctx, clipPath);
    inContext.clip () //    CGContextClip(ctx);
    inContext.addPath (self.cgPath) //    CGContextAddPath(ctx, Path);
    inContext.fillPath () //    CGContextFillPath(ctx);
    inContext.restoreGState () //    CGContextRestoreGState(ctx);
  }

  //····················································································································

}

