//
//  EBGraphicView-working-area.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 01/03/2024.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   EBGraphicView
//——————————————————————————————————————————————————————————————————————————————————————————————————

extension EBGraphicView {

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

  func drawWorkingArea (_ inDirtyRect : NSRect) {
    if !self.mWorkingArea.isEmpty {
      let bp = NSBezierPath (rect: self.mWorkingArea.cocoaRect)
      NSColor.blue.setStroke ()
      bp.lineWidth = 1.0 / self.actualScale
      bp.lineCapStyle = .round
      bp.stroke ()
      let r = self.rect (forZone: self.mWorkingAreaCursorZone)
      NSColor.blue.setFill ()
      r.fill ()
    }
  }

  //································································································

  func workingAreaCursor (forZone inZone : WorkingAreaCursorZone) -> NSCursor? {
    switch inZone {
    case .none : return nil
    case .top, .bottom : return NSCursor.resizeUpDown
    case .left, .right : return NSCursor.resizeLeftRight
    case .topLeft, .bottomLeft, .topRight, .bottomRight : return NSCursor.upDownRightLeftCursor
    }
  }

  //································································································

 func workingAreaZone (forLocationInView inLocation : NSPoint) -> WorkingAreaCursorZone {
    var zone = WorkingAreaCursorZone.none
    if !self.mWorkingArea.isEmpty && (self.indexOfFrontObject (at: inLocation).0 == nil) {
      let r = self.mWorkingArea.cocoaRect
      let outerR = r.insetBy (dx: -5.0, dy: -5.0)
      let innerR = r.insetBy (dx:  5.0, dy:  5.0)
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
    return zone
  }

  //································································································

  func rect (forZone inZone : WorkingAreaCursorZone) -> NSRect {
    if self.mWorkingArea.isEmpty {
      return NSRect ()
    }else{
      let r = self.mWorkingArea.cocoaRect
      let outerR = r.insetBy (dx: -5.0, dy: -5.0)
      let innerR = r.insetBy (dx:  5.0, dy:  5.0)
      switch inZone {
      case .none : return NSRect ()
      case .top : return NSRect (x: innerR.minX, y: innerR.maxY, width: innerR.width, height: 10.0)
      case .bottom : return NSRect (x: innerR.minX, y: outerR.minY, width: innerR.width, height: 10.0)
      case .left : return NSRect (x: outerR.minX, y: innerR.minY, width: 10.0, height: innerR.height)
      case .right : return NSRect (x: innerR.maxX, y: innerR.minY, width: 10.0, height: innerR.height)
      case .topLeft : return NSRect (x: outerR.minX, y: innerR.maxY, width: 10.0, height: 10.0)
      case .bottomLeft : return NSRect (x: outerR.minX, y: outerR.minY, width: 10.0, height: 10.0)
      case .topRight : return NSRect (x: innerR.maxX, y: innerR.maxY, width: 10.0, height: 10.0)
      case .bottomRight : return NSRect (x: innerR.maxX, y: outerR.minY, width: 10.0, height: 10.0)
      }
    }
  }

  //································································································

  func resizeWorkingArea (mouseDraggedUnalignedLocation inUnalignedLocationInView : NSPoint) {

  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
