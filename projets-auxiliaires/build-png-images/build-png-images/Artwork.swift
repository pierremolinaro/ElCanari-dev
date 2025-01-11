//
//  Artwork.swift
//  build-png-images
//
//  Created by Pierre Molinaro on 27/06/2021.
//  Copyright © 2021 Pierre Molinaro. All rights reserved.
//

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class ArtworkView : NSView {

  //····················································································································

  override var isFlipped: Bool { return false }
  override var isOpaque: Bool { return false }

  //····················································································································
  //  Draw
  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
//      NSColor.yellow.setFill ()
//      __NSRectFill (inDirtyRect)
    let S = self.bounds.size
  //--- Rectangle vert
    var r = self.bounds.insetBy (dx: 0.0, dy: S.height / 5.0)
    NSColor (red: 0.0, green: 144.0 / 255.0, blue: 80.0 / 255.0, alpha: 1.0).setFill ()
    __NSRectFill (r)
  //--- Piste droite
    r.origin.x = S.width * (1.0 - 0.1 - 0.05)
    r.size.width = S.width / 10.0
    r.origin.y = S.height / 5.0
    r.size.height = S.height * 3.0 / 5.0
    NSColor.orange.setFill ()
    __NSRectFill (r)
  //--- Piste précédente
    r.origin.x = S.width * (1.0 - 0.1 - 0.1 - 0.1 - 0.05)
    NSColor.orange.setFill ()
    __NSRectFill (r)
  //--- Pastille gauche
    r.origin.x = S.width * 0.05
    r.size.width = S.width / 5.0
    r.size.height = S.width / 5.0
    r.origin.y = S.height / 2.0 - r.size.height / 2.0
    var bp = NSBezierPath (ovalIn: r)
    NSColor.orange.setFill ()
    bp.fill ()
  //--- Perçage gauche
    r.origin.x = S.width * (0.05 +  0.2 / 5.0)
    r.size.width = S.width * 0.6 / 5.0
    r.size.height = S.width * 0.6 / 5.0
    r.origin.y = S.height / 2.0 - r.size.height / 2.0
    bp = NSBezierPath (ovalIn: r)
    NSColor.white.setFill ()
    bp.fill ()
//    NSColor.black.setStroke ()
//    bp.lineWidth = 2.0
//    bp.stroke ()
  //--- Pastille droite
    r.origin.x = S.width * 7.0 / 20.0
    r.size.width = S.width / 5.0
    r.size.height = S.width / 5.0
    r.origin.y = S.height / 2.0 - r.size.height / 2.0
    bp = NSBezierPath (ovalIn: r)
    NSColor.orange.setFill ()
    bp.fill ()
  //--- Perçage droit
    r.origin.x = S.width * (7.0 / 20.0 +  0.2 / 5.0)
    r.size.width = S.width * 0.6 / 5.0
    r.size.height = S.width * 0.6 / 5.0
    r.origin.y = S.height / 2.0 - r.size.height / 2.0
    bp = NSBezierPath (ovalIn: r)
    NSColor.white.setFill ()
    bp.fill ()
//    NSColor.black.setStroke ()
//    bp.lineWidth = 2.0
//    bp.stroke ()
  //--- Pointillé 1 (à gauche)
    let pointillé : [CGFloat] = [4.0, 3.0]
    bp = NSBezierPath ()
    bp.move (to: NSPoint (x: S.width * (0.05 + 0.04), y: S.height / 10.0))
    bp.line (to: NSPoint (x: S.width * (0.05 + 0.04), y: S.height / 1.75))
    bp.lineWidth = 1.0
    bp.setLineDash (pointillé, count: pointillé.count, phase: 0.0)
    bp.lineCapStyle = .round
    NSColor.black.setStroke ()
    bp.stroke ()
  //--- Pointillé 2
    bp = NSBezierPath ()
    bp.move (to: NSPoint (x: S.width * (0.05 + 0.04 + 0.12), y: S.height / 10.0))
    bp.line (to: NSPoint (x: S.width * (0.05 + 0.04 + 0.12), y: S.height / 1.75))
    bp.lineWidth = 1.0
    bp.setLineDash (pointillé, count: pointillé.count, phase: 0.0)
    bp.lineCapStyle = .round
    NSColor.black.setStroke ()
    bp.stroke ()
  //--- Pointillé 3
    bp = NSBezierPath ()
    bp.move (to: NSPoint (x: S.width * (0.05 + 0.2), y: S.height * 9.0 / 10.0))
    bp.line (to: NSPoint (x: S.width * (0.05 + 0.2), y: S.height / 2.25))
    bp.lineWidth = 1.0
    bp.setLineDash (pointillé, count: pointillé.count, phase: 0.0)
    bp.lineCapStyle = .round
    NSColor.black.setStroke ()
    bp.stroke ()
  //--- Pointillé 4
    bp = NSBezierPath ()
    bp.move (to: NSPoint (x: S.width * (7.0 / 20.0), y: S.height * 9.0 / 10.0))
    bp.line (to: NSPoint (x: S.width * (7.0 / 20.0), y: S.height / 10.0))
    bp.lineWidth = 1.0
    bp.setLineDash (pointillé, count: pointillé.count, phase: 0.0)
    bp.lineCapStyle = .round
    NSColor.black.setStroke ()
    bp.stroke ()
  //--- Pointillé 5
    bp = NSBezierPath ()
    bp.move (to: NSPoint (x: S.width * (7.0 / 20.0 + 0.2 / 5.0), y: S.height / 10.0))
    bp.line (to: NSPoint (x: S.width * (7.0 / 20.0 + 0.2 / 5.0), y: S.height / 1.75))
    bp.lineWidth = 1.0
    bp.setLineDash (pointillé, count: pointillé.count, phase: 0.0)
    bp.lineCapStyle = .round
    NSColor.black.setStroke ()
    bp.stroke ()
  //--- Pointillé 6
    bp = NSBezierPath ()
    bp.move (to: NSPoint (x: S.width * (7.0 / 20.0 + 1.0 / 5.0), y: S.height / 10.0))
    bp.line (to: NSPoint (x: S.width * (7.0 / 20.0 + 1.0 / 5.0), y: S.height * 9.0 / 10.0))
    bp.lineWidth = 1.0
    bp.setLineDash (pointillé, count: pointillé.count, phase: 0.0)
    bp.lineCapStyle = .round
    NSColor.black.setStroke ()
    bp.stroke ()
  //--- Pointillé 7
    bp = NSBezierPath ()
    bp.move (to: NSPoint (x: S.width * (1.0 - 7.0 / 20.0), y: S.height / 10.0))
    bp.line (to: NSPoint (x: S.width * (1.0 - 7.0 / 20.0), y: S.height * 9.0 / 10.0))
    bp.lineWidth = 1.0
    bp.setLineDash (pointillé, count: pointillé.count, phase: 0.0)
    bp.lineCapStyle = .round
    NSColor.black.setStroke ()
    bp.stroke ()
  //--- Pointillé 8
    bp = NSBezierPath ()
    bp.move (to: NSPoint (x: S.width * (1.0 - 5.0 / 20.0), y: S.height / 10.0))
    bp.line (to: NSPoint (x: S.width * (1.0 - 5.0 / 20.0), y: S.height * 9.0 / 10.0))
    bp.lineWidth = 1.0
    bp.setLineDash (pointillé, count: pointillé.count, phase: 0.0)
    bp.lineCapStyle = .round
    NSColor.black.setStroke ()
    bp.stroke ()
  //--- Pointillé 9
    bp = NSBezierPath ()
    bp.move (to: NSPoint (x: S.width * (1.0 - 3.0 / 20.0), y: S.height / 10.0))
    bp.line (to: NSPoint (x: S.width * (1.0 - 3.0 / 20.0), y: S.height * 9.0 / 10.0))
    bp.lineWidth = 1.0
    bp.setLineDash (pointillé, count: pointillé.count, phase: 0.0)
    bp.lineCapStyle = .round
    NSColor.black.setStroke ()
    bp.stroke ()
  //--- Pointillé 10 (à droite)
    bp = NSBezierPath ()
    bp.move (to: NSPoint (x: S.width * (1.0 - 1.0 / 20.0), y: S.height / 10.0))
    bp.line (to: NSPoint (x: S.width * (1.0 - 1.0 / 20.0), y: S.height * 9.0 / 10.0))
    bp.lineWidth = 1.0
    bp.setLineDash (pointillé, count: pointillé.count, phase: 0.0)
    bp.lineCapStyle = .round
    NSColor.black.setStroke ()
    bp.stroke ()
  //--- Flèche 1 (à gauche)
    var p1 = NSPoint (x: S.width * (0.05 + 0.04),        y: S.height * 1.0 / 10.0)
    var p2 = NSPoint (x: S.width * (0.05 + 0.04 + 0.12), y: S.height * 1.0 / 10.0)
    self.dessinerFlèche (p1, p2, "PHD", dessous: true)
  //--- Flèche 2
    p1 = NSPoint (x: S.width * (0.05 + 0.2), y: S.height * 9.0 / 10.0)
    p2 = NSPoint (x: S.width * (7.0 / 20.0), y: S.height * 9.0 / 10.0)
    self.dessinerFlèche (p1, p2, "PP", dessous: false)
  //--- Flèche 3
    p1 = NSPoint (x: S.width * (7.0 / 20.0), y: S.height * 1.0 / 10.0)
    p2 = NSPoint (x: S.width * (7.0 / 20.0 + 0.2 / 5.0), y: S.height * 1.0 / 10.0)
    self.dessinerFlèche (p1, p2, "OAR", dessous: true)
  //--- Flèche 4
    p1 = NSPoint (x: S.width * (7.0 / 20.0 + 1.0 / 5.0), y: S.height * 9.0 / 10.0)
    p2 = NSPoint (x: S.width * (1.0 - 7.0 / 20.0), y: S.height * 9.0 / 10.0)
    self.dessinerFlèche (p1, p2, "TP", dessous: false)
  //--- Flèche 5
    p1 = NSPoint (x: S.width * (1.0 - 5.0 / 20.0), y: S.height * 1.0 / 10.0)
    p2 = NSPoint (x: S.width * (1.0 - 3.0 / 20.0), y: S.height * 1.0 / 10.0)
    self.dessinerFlèche (p1, p2, "TT", dessous: true)
  //--- Flèche 6
    p1 = NSPoint (x: S.width * (1.0 - 3.0 / 20.0), y: S.height * 9.0 / 10.0)
    p2 = NSPoint (x: S.width * (1.0 - 1.0 / 20.0), y: S.height * 9.0 / 10.0)
    self.dessinerFlèche (p1, p2, "TW", dessous: false)
  }

  //····················································································································

  func dessinerFlèche (_ p1 : NSPoint, _ p2 : NSPoint, _ inString : String, dessous inDessous : Bool) {
    let tailleFlèche = self.bounds.size.width / 100.0
    var bp = NSBezierPath ()
    bp.move (to: p1)
    bp.line (to: p2)
    bp.close ()
    bp.lineWidth = 1.0
    bp.lineCapStyle = .round
    NSColor.black.setStroke ()
    bp.stroke ()
    bp = NSBezierPath ()
    bp.move (to: p1)
    bp.relativeLine (to: NSPoint (x: tailleFlèche, y:  tailleFlèche))
    bp.relativeLine (to: NSPoint (x: 0.0, y: -2.0 * tailleFlèche))
    bp.close ()
    bp.move (to: p2)
    bp.relativeLine (to: NSPoint (x: -tailleFlèche, y: tailleFlèche))
    bp.relativeLine (to: NSPoint (x:  0.0, y: -2.0 * tailleFlèche))
    bp.close ()
    bp.lineJoinStyle = .bevel
    NSColor.black.setFill ()
    bp.fill ()
  //---
    let font = NSFont.boldSystemFont (ofSize: 10.0)
    let textAttributes : [NSAttributedString.Key : Any] = [
      NSAttributedString.Key.font : font
    ]
    let size = inString.size (withAttributes: textAttributes)
    var p = NSPoint (x : (p1.x + p2.x - size.width) / 2.0, y: (p1.y + p2.y) / 2.0)
    if inDessous {
      p.y -= size.height
    }
    inString.draw (at: p, withAttributes: textAttributes)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
