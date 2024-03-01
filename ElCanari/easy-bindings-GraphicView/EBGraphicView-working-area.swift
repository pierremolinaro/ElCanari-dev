//
//  EBGraphicView-working-area.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 01/03/2024.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

private let SIZE : CGFloat = 5.0

//——————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor struct WorkingArea {

  //································································································
  //   Private properties
  //································································································

  private var mArea = CanariRect (left: -CANARI_UNITS_PER_INCH / 2,
                                  bottom: -CANARI_UNITS_PER_INCH / 2,
                                  width: CANARI_UNITS_PER_INCH * 5,
                                  height: CANARI_UNITS_PER_INCH * 5)

  private var mAreaCursorZone = WorkingAreaCursorZone.none

  private var mUnalignedMouseDownLocation = NSPoint ()

  //································································································

  var rect : NSRect { return self.mArea.cocoaRect }
  
  //································································································

  func union (withRect ioRect : inout NSRect) {
    ioRect = ioRect.union (self.mArea.cocoaRect.insetBy (dx: -SIZE, dy: -SIZE))
  }

  //································································································

  mutating func set (unalignedMouseDownLocation inUnalignedMouseDownLocation : NSPoint) {
    self.mUnalignedMouseDownLocation = inUnalignedMouseDownLocation
  }

  //································································································

  mutating func resetCurrentZone (withView inView : NSView) {
    if self.mAreaCursorZone != .none {
      inView.setNeedsDisplay (self.rect (forZone: self.mAreaCursorZone))
      self.mAreaCursorZone = .none
    }
  }

  //································································································

  func drawWorkingArea (lineWidth inLineWidth : CGFloat) {
    if !self.mArea.isEmpty {
      let bp = NSBezierPath (rect: self.mArea.cocoaRect)
      NSColor.blue.setStroke ()
      bp.lineWidth = inLineWidth
      bp.lineCapStyle = .round
      bp.stroke ()
      let r = self.rect (forZone: self.mAreaCursorZone)
      NSColor.blue.setFill ()
      r.fill ()
    }
  }

  //································································································

  func workingAreaCursor () -> NSCursor? {
    switch self.mAreaCursorZone {
    case .none : return nil
    case .top, .bottom : return NSCursor.resizeUpDown
    case .left, .right : return NSCursor.resizeLeftRight
    case .topLeft, .bottomLeft, .topRight, .bottomRight : return NSCursor.upDownRightLeftCursor
    }
  }

  //································································································

  mutating func setZone (forLocationInView inLocation : NSPoint, withView inView : NSView) {
    var zone = WorkingAreaCursorZone.none
    if !self.mArea.isEmpty { // && (self.indexOfFrontObject (at: inLocation).0 == nil) {
      let r = self.mArea.cocoaRect
      let outerR = r.insetBy (dx: -SIZE, dy: -SIZE)
      let innerR = r.insetBy (dx:  SIZE, dy:  SIZE)
      if outerR.contains (inLocation) && !innerR.contains (inLocation) {
        if inLocation.x < innerR.minX {
          if inLocation.y < innerR.minY {
            zone = .bottomLeft
          }else if inLocation.y < innerR.maxY {
            zone = .left
          }else{
            zone = .topLeft
          }
        }else if inLocation.x > innerR.maxX {
          if inLocation.y < innerR.minY {
            zone = .bottomRight
          }else if inLocation.y < innerR.maxY {
            zone = .right
          }else{
            zone = .topRight
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

  //································································································

  private func rect (forZone inZone : WorkingAreaCursorZone) -> NSRect {
    if self.mArea.isEmpty {
      return NSRect ()
    }else{
      let r = self.mArea.cocoaRect
      let outerR = r.insetBy (dx: -SIZE, dy: -SIZE)
      let innerR = r.insetBy (dx:  SIZE, dy:  SIZE)
      switch inZone {
      case .none : return NSRect ()
      case .top : return NSRect (x: innerR.minX, y: innerR.maxY, width: innerR.width, height: 2.0 * SIZE)
      case .bottom : return NSRect (x: innerR.minX, y: outerR.minY, width: innerR.width, height: 2.0 * SIZE)
      case .left : return NSRect (x: outerR.minX, y: innerR.minY, width: 2.0 * SIZE, height: innerR.height)
      case .right : return NSRect (x: innerR.maxX, y: innerR.minY, width: 2.0 * SIZE, height: innerR.height)
      case .topLeft : return NSRect (x: outerR.minX, y: innerR.maxY, width: 2.0 * SIZE, height: 2.0 * SIZE)
      case .bottomLeft : return NSRect (x: outerR.minX, y: outerR.minY, width: 2.0 * SIZE, height: 2.0 * SIZE)
      case .topRight : return NSRect (x: innerR.maxX, y: innerR.maxY, width: 2.0 * SIZE, height: 2.0 * SIZE)
      case .bottomRight : return NSRect (x: innerR.maxX, y: outerR.minY, width: 2.0 * SIZE, height: 2.0 * SIZE)
      }
    }
  }

  //································································································

  mutating func mouseDragged (mouseDraggedUnalignedLocation inUnalignedLocationInView : NSPoint) {
    let dx = cocoaToCanariUnit (inUnalignedLocationInView.x - self.mUnalignedMouseDownLocation.x)
    let dy = cocoaToCanariUnit (inUnalignedLocationInView.y - self.mUnalignedMouseDownLocation.y)
    self.mUnalignedMouseDownLocation = inUnalignedLocationInView
    switch self.mAreaCursorZone {
    case .none :
      ()
    case .top :
      self.mArea.size.height += dy
    case .bottom :
      self.mArea.origin.y += dy
      self.mArea.size.height -= dy
    case .left :
      self.mArea.origin.x += dx
      self.mArea.size.width -= dx
    case .right :
      self.mArea.size.width += dx
    case .topLeft :
      self.mArea.size.height += dy
      self.mArea.origin.x += dx
      self.mArea.size.width -= dx
    case .bottomLeft :
      self.mArea.origin.y += dy
      self.mArea.size.height -= dy
      self.mArea.origin.x += dx
      self.mArea.size.width -= dx
    case .topRight :
      self.mArea.size.width += dx
      self.mArea.size.height += dy
    case .bottomRight :
      self.mArea.size.width += dx
      self.mArea.origin.y += dy
      self.mArea.size.height -= dy
    }
  }

  //································································································

  enum WorkingAreaCursorZone {
    case none
    case top
    case bottom
    case left
    case right
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
