//
//  EBGraphicView-working-area.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 01/03/2024.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor struct WorkingArea {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Private properties
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mArea = CanariRect (left: -CANARI_UNITS_PER_INCH / 2,
                                  bottom: -CANARI_UNITS_PER_INCH / 2,
                                  width: CANARI_UNITS_PER_INCH * 5,
                                  height: CANARI_UNITS_PER_INCH * 5)

  private var mAreaCursorZone = WorkingAreaCursorZone.none

  private var mCurrentMouseLocation = NSPoint ()

  private var mColor = NSColor.black

  private let mHiliteSize = 1.0

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var rect : NSRect { return self.mArea.cocoaRect }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func union (withRect ioRect : inout NSRect) {
    ioRect = ioRect.union (self.mArea.cocoaRect.insetBy (dx: -self.mHiliteSize, dy: -self.mHiliteSize))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func set (color inColor : NSColor) {
    self.mColor = inColor
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func set (rectString inString : String, _ inView : EBGraphicView) {
    let components = inString.components (separatedBy: ":")
    if components.count == 4 {
      let originX : Int? = Int (components [0])
      let originY : Int? = Int (components [1])
      let width   : Int? = Int (components [2])
      let height  : Int? = Int (components [3])
      if let x = originX, let y = originY, let w = width, let h = height {
        self.mArea = CanariRect (left: x, bottom: y, width: w, height: h)
        inView.needsDisplay = true
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rectString () -> String {
    return "\(self.mArea.origin.x):\(self.mArea.origin.y):\(self.mArea.size.width):\(self.mArea.size.height)"
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func set (unalignedMouseDownLocation inUnalignedMouseDownLocation : NSPoint) {
    self.mCurrentMouseLocation = inUnalignedMouseDownLocation
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func resetCurrentZone (withView inView : NSView) {
    if self.mAreaCursorZone != .none {
      inView.setNeedsDisplay (self.rect (forZone: self.mAreaCursorZone))
      self.mAreaCursorZone = .none
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func drawWorkingArea (lineWidth inLineWidth : CGFloat) {
    if !self.mArea.isEmpty {
      var bp = NSBezierPath (rect: self.mArea.cocoaRect)
      bp.lineWidth = inLineWidth * 2.0
      bp.lineCapStyle = .round
      bp.stroke ()
      let r = self.rect (forZone: self.mAreaCursorZone).insetBy (dx: inLineWidth, dy: inLineWidth)
      bp = NSBezierPath (roundedRect: r, xRadius: self.mHiliteSize * 0.5, yRadius: self.mHiliteSize * 0.5)
      let color = preferences_selectionHiliteColor_property.propval.withAlphaComponent (0.25)
      color.setFill ()
      bp.fill ()
      bp.lineWidth = inLineWidth * 2.0
      self.mColor.setStroke ()
      bp.stroke ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func workingAreaCursor () -> NSCursor? {
    switch self.mAreaCursorZone {
    case .none : return nil
    case .top, .bottom : return NSCursor.resizeUpDown
    case .left, .right : return NSCursor.resizeLeftRight
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func setZone (forLocationInView inLocation : NSPoint, withView inView : NSView) {
    var zone = WorkingAreaCursorZone.none
    if !self.mArea.isEmpty {
      let r = self.mArea.cocoaRect
      let outerR = r.insetBy (dx: -self.mHiliteSize, dy: -self.mHiliteSize)
      let innerR = r.insetBy (dx:  self.mHiliteSize, dy:  self.mHiliteSize)
      if outerR.contains (inLocation) && !innerR.contains (inLocation) {
        if inLocation.x < innerR.minX {
          if (inLocation.y > innerR.minY) && (inLocation.y < innerR.maxY) {
            zone = .left
          }
        }else if inLocation.x > innerR.maxX {
          if (inLocation.y > innerR.minY) && (inLocation.y < innerR.maxY) {
            zone = .right
          }
        }else if inLocation.y > innerR.minY {
          zone = .top
        }else{
          zone = .bottom
        }
      }
    }
  //--- Zone did change ?
    if self.mAreaCursorZone != zone {
      inView.setNeedsDisplay (self.rect (forZone: self.mAreaCursorZone))
      inView.setNeedsDisplay (self.rect (forZone: zone))
      self.mAreaCursorZone = zone
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func rect (forZone inZone : WorkingAreaCursorZone) -> NSRect {
    if self.mArea.isEmpty {
      return NSRect ()
    }else{
      let r = self.mArea.cocoaRect
      let outerR = r.insetBy (dx: -self.mHiliteSize, dy: -self.mHiliteSize)
      let innerR = r.insetBy (dx:  self.mHiliteSize, dy:  self.mHiliteSize)
      switch inZone {
      case .none   : return NSRect ()
      case .top    : return NSRect (x: innerR.minX, y: innerR.maxY, width: innerR.width, height: 2.0 * self.mHiliteSize)
      case .bottom : return NSRect (x: innerR.minX, y: outerR.minY, width: innerR.width, height: 2.0 * self.mHiliteSize)
      case .left   : return NSRect (x: outerR.minX, y: innerR.minY, width: 2.0 * self.mHiliteSize, height: innerR.height)
      case .right  : return NSRect (x: innerR.maxX, y: innerR.minY, width: 2.0 * self.mHiliteSize, height: innerR.height)
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func mouseDragged (mouseDraggedUnalignedLocation inUnalignedLocationInView : NSPoint,
                              handled ioHandled : inout Bool,
                              _ inView : EBGraphicView) {
    let dx = cocoaToCanariUnit (inUnalignedLocationInView.x - self.mCurrentMouseLocation.x)
    let dy = cocoaToCanariUnit (inUnalignedLocationInView.y - self.mCurrentMouseLocation.y)
    let oldRect = self.mArea.cocoaRect.insetBy (dx: -self.mHiliteSize, dy: -self.mHiliteSize)
    let minimumSize = 2 * cocoaToCanariUnit (self.mHiliteSize)
    switch self.mAreaCursorZone {
    case .none :
      ioHandled = false
    case .top :
      ioHandled = (self.mArea.size.height + dy) > minimumSize
      if ioHandled {
        self.mArea.size.height += dy
      }
    case .bottom :
      ioHandled = (self.mArea.size.height - dy) > minimumSize
      if ioHandled {
        self.mArea.origin.y += dy
        self.mArea.size.height -= dy
      }
    case .left :
      ioHandled = (self.mArea.size.width - dx) > minimumSize
      if ioHandled {
        self.mArea.origin.x += dx
        self.mArea.size.width -= dx
      }
    case .right :
      ioHandled = (self.mArea.size.width + dx) > minimumSize
      if ioHandled {
        self.mArea.size.width += dx
      }
    }
    if ioHandled {
      self.mCurrentMouseLocation = inUnalignedLocationInView
      let newRect = self.mArea.cocoaRect.insetBy (dx: -self.mHiliteSize, dy: -self.mHiliteSize)
      inView.setNeedsDisplay (newRect.union (oldRect))
      inView.mWorkingAreaRectStringController?.updateModel (withValue: self.rectString ())
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  enum WorkingAreaCursorZone {
    case none
    case top
    case bottom
    case left
    case right
//    case topLeft
//    case topRight
//    case bottomLeft
//    case bottomRight
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
