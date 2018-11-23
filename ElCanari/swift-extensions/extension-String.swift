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
  // https://books.google.fr/books?id=uMfFHpNpWQsC&pg=SA10-PA61&lpg=SA10-PA61&dq=SpeedometerView+cocoa&source=bl&ots=gMHeJzL9x4&sig=YYjlnoQdCFmBfQmavu8iky5OaJ8&hl=fr&sa=X&ved=2ahUKEwiLju73lObeAhVLzIUKHes2DPsQ6AEwBnoECAQQAQ#v=onepage&q=SpeedometerView%20cocoa&f=false

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
