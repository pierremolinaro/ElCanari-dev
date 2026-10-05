//
//  EBGraphicView-working-area.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 01/03/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

@MainActor struct WorkingArea {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Private properties
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mArea = CanariRect (left: .mil (-500),
                                  bottom: .mil (-500),
                                  width: .inch (5),
                                  height: .inch (5))

  private var mAreaCursorZone = WorkingAreaCursorZone.none

  private var mCurrentMouseLocation = CanariPoint ()

  private var mColor = NSColor.black

  private let mHiliteSize = CanariLength.pt (1.0)

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var rect : CanariRect { return self.mArea }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func union (withRect ioRect : inout CanariRect) {
    ioRect = ioRect.unioning (self.mArea.insetBy (dx: -self.mHiliteSize, dy: -self.mHiliteSize))
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
        self.mArea = CanariRect (left: .cu (x), bottom: .cu (y), width: .cu (w), height: .cu (h))
        inView.needsDisplay = true
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rectString () -> String {
    return "\(self.mArea.origin.x):\(self.mArea.origin.y):\(self.mArea.size.width):\(self.mArea.size.height)"
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func set (unalignedMouseDownLocation inUnalignedMouseDownLocation : CanariPoint) {
    self.mCurrentMouseLocation = inUnalignedMouseDownLocation
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func resetCurrentZone (withView inView : NSView) {
    if self.mAreaCursorZone != .none {
      inView.setNeedsDisplay (self.rect (forZone: self.mAreaCursorZone).ptValue)
      self.mAreaCursorZone = .none
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func drawWorkingArea (lineWidth inLineWidth : CanariLength) {
    if !self.mArea.isEmpty {
      var bp = NSBezierPath (rect: self.mArea.ptValue)
      bp.lineWidth = inLineWidth.ptValue * 2.0
      bp.lineCapStyle = .round
      bp.stroke ()
      let r = self.rect (forZone: self.mAreaCursorZone).insetBy (dx: inLineWidth, dy: inLineWidth)
      bp = NSBezierPath (roundedRect: r.ptValue, xRadius: self.mHiliteSize.ptValue * 0.5, yRadius: self.mHiliteSize.ptValue * 0.5)
      let color = preferences_selectionHiliteColor_property.propval.withAlphaComponent (0.25)
      color.setFill ()
      bp.fill ()
      bp.lineWidth = inLineWidth.ptValue * 2.0
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

  mutating func setZone (forLocationInView inLocation : CanariPoint, withView inView : NSView) {
    var zone = WorkingAreaCursorZone.none
    if !self.mArea.isEmpty {
      let r = self.mArea
      let hiliteSize = self.mHiliteSize
      let outerR = r.insetBy (dx: -hiliteSize, dy: -hiliteSize)
      let innerR = r.insetBy (dx:  hiliteSize, dy:  hiliteSize)
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
      inView.setNeedsDisplay (self.rect (forZone: self.mAreaCursorZone).ptValue)
      inView.setNeedsDisplay (self.rect (forZone: zone).ptValue)
      self.mAreaCursorZone = zone
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func rect (forZone inZone : WorkingAreaCursorZone) -> CanariRect {
    if self.mArea.isEmpty {
      return CanariRect ()
    }else{
      let r = self.mArea
      let outerR = r.insetBy (dx: -self.mHiliteSize, dy: -self.mHiliteSize)
      let innerR = r.insetBy (dx:  self.mHiliteSize, dy:  self.mHiliteSize)
      switch inZone {
      case .none   : return CanariRect ()
      case .top    : return CanariRect (left: innerR.minX, bottom: innerR.maxY, width: innerR.width, height: 2.0 * self.mHiliteSize)
      case .bottom : return CanariRect (left: innerR.minX, bottom: outerR.minY, width: innerR.width, height: 2.0 * self.mHiliteSize)
      case .left   : return CanariRect (left: outerR.minX, bottom: innerR.minY, width: 2.0 * self.mHiliteSize, height: innerR.height)
      case .right  : return CanariRect (left: innerR.maxX, bottom: innerR.minY, width: 2.0 * self.mHiliteSize, height: innerR.height)
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func mouseDragged (mouseDraggedUnalignedLocation inUnalignedLocationInView : CanariPoint,
                              handled ioHandled : inout Bool,
                              _ inView : EBGraphicView) {
    let dx = inUnalignedLocationInView.x - self.mCurrentMouseLocation.x
    let dy = inUnalignedLocationInView.y - self.mCurrentMouseLocation.y
    let oldRect = self.mArea.insetBy (dx: -self.mHiliteSize, dy: -self.mHiliteSize)
    let minimumSize = 2.0 * self.mHiliteSize
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
      let newRect = self.mArea.insetBy (dx: -self.mHiliteSize, dy: -self.mHiliteSize)
      inView.setNeedsDisplay (newRect.unioning (oldRect).ptValue)
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

//--------------------------------------------------------------------------------------------------
