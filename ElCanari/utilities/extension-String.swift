//
//  extension-String.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 04/09/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//struct BezierNSLayoutManager {
//  var theBezierPath : NSBezierPath? = nil
//
//
//
//
//    /* convert the NSString into a NSBezierPath using a specific font. */
//
//- (void)showPackedGlyphs:(char *)glyphs length:(unsigned)glyphLen
//
//        glyphRange:(NSRange)glyphRange atPoint:(NSPoint)point font:(NSFont *)font
//
//        color:(NSColor *)color printingAdjustment:(NSSize)printingAdjustment {
//
//
//
//        /* if there is a NSBezierPath associated with this
//
//        layout, then append the glyphs to it. */
//
//    NSBezierPath *bezier = [self theBezierPath];
//
//
//
//    if ( nil != bezier ) {
//
//
//
//            /* add the glyphs to the bezier path */
//
//        [bezier moveToPoint:point];
//
//        [bezier appendBezierPathWithPackedGlyphs: glyphs];
//
//    }
//
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension String {

  //····················································································································

  var unicodeArray : [UnicodeScalar] {
    var array = [UnicodeScalar] ()
    for scalar in self.unicodeScalars {
      array.append (scalar)
    }
    return array
  }

  //····················································································································

  func bezier (withFont inFont : NSFont, origin inOrigin : NSPoint) -> NSBezierPath {
    let textStorage = NSTextStorage (string: self)
    let textContainer = NSTextContainer ()
    let layout = NSLayoutManager ()
    layout.addTextContainer (textContainer)
    textStorage.addLayoutManager (layout)
    textStorage.font = inFont
    let bp = NSBezierPath ()
    bp.move (to: inOrigin)
    let range = layout.glyphRange (for: textContainer)
    let cgGlyphBuffer = UnsafeMutablePointer<CGGlyph>.allocate (capacity: range.length)
    let glyphLength = layout.getGlyphs (
      in: range,
      glyphs: cgGlyphBuffer,
      properties: nil,
      characterIndexes: nil,
      bidiLevels: nil
    )
    let nsGlyphBuffer = UnsafeMutablePointer<NSGlyph>.allocate (capacity: range.length)
    (0..<range.length).forEach { nsGlyphBuffer [$0] = NSGlyph (cgGlyphBuffer [$0]) }
    bp.appendGlyphs (nsGlyphBuffer, count: glyphLength, in: inFont)
    return bp
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
