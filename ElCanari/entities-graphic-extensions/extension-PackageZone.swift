import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let PACKAGE_ZONE_BOTTOM = 1
let PACKAGE_ZONE_RIGHT  = 2
let PACKAGE_ZONE_LEFT   = 3
let PACKAGE_ZONE_TOP    = 4
let PACKAGE_ZONE_NAME   = 5

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION PackageZone
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension PackageZone {

  //····················································································································

  func cursorForKnob_PackageZone (knob inKnobIndex: Int) -> NSCursor? {
    if (inKnobIndex == PACKAGE_ZONE_RIGHT) && (inKnobIndex == PACKAGE_ZONE_LEFT) {
      return NSCursor.resizeLeftRight
    }else if (inKnobIndex == PACKAGE_ZONE_BOTTOM) && (inKnobIndex == PACKAGE_ZONE_TOP) {
      return NSCursor.resizeUpDown
    }else if inKnobIndex == PACKAGE_ZONE_NAME {
      return NSCursor.upDownRightLeftCursor
    }else{
      return nil
    }
  }

  //····················································································································

  func acceptToTranslate_PackageZone (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  func translate_PackageZone (xBy inDx: Int, yBy inDy: Int, userSet ioSet : inout EBReferenceSet <AnyObject>) {
    self.x += inDx
    self.y += inDy
    self.xName += inDx
    self.yName += inDy
  }

  //····················································································································
  //  Knob
  //····················································································································

  func canMove_PackageZone (knob inKnobIndex : Int,
                         proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : CanariPoint,
                         proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                         unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : CanariPoint,
                         shift inShift : Bool) -> CanariPoint {
    var dx = inProposedAlignedTranslation.x
    var dy = inProposedAlignedTranslation.y
    if inKnobIndex == PACKAGE_ZONE_LEFT {
      if (self.width - dx) < 0 {
        dx = self.width
      }
    }else if inKnobIndex == PACKAGE_ZONE_RIGHT {
      if (self.width + dx) < 0 {
        dx = -self.width
      }
    }else if inKnobIndex == PACKAGE_ZONE_BOTTOM {
      if (self.height - dy) < 0 {
        dy = self.height
      }
    }else if inKnobIndex == PACKAGE_ZONE_TOP {
      if (self.height + dy) < 0 {
        dy = -self.height
      }
    }else if inKnobIndex == PACKAGE_ZONE_NAME {
      if (self.xName + dx) < 0 {
        dx = -self.xName
      }
      if (self.yName + dy) < 0 {
        dy = -self.yName
      }
    }
    return CanariPoint (x: dx, y: dy)
 }

  //····················································································································

  func move_PackageZone (knob inKnobIndex: Int,
                      proposedDx inDx: Int,
                      proposedDy inDy: Int,
                      unalignedMouseLocationX inUnlignedMouseLocationX : Int,
                      unalignedMouseLocationY inUnlignedMouseLocationY : Int,
                      alignedMouseLocationX inAlignedMouseLocationX : Int,
                      alignedMouseLocationY inAlignedMouseLocationY : Int,
                      shift inShift : Bool) {
    if inKnobIndex == PACKAGE_ZONE_RIGHT {
      self.width += inDx
    }else if inKnobIndex == PACKAGE_ZONE_LEFT {
      self.x += inDx
      self.width -= inDx
    }else if inKnobIndex == PACKAGE_ZONE_TOP {
      self.height += inDy
    }else if inKnobIndex == PACKAGE_ZONE_BOTTOM {
      self.y += inDy
      self.height -= inDy
    }else if inKnobIndex == PACKAGE_ZONE_NAME {
      self.xName += inDx
      self.yName += inDy
    }
  }

  //····················································································································
  //  SNAP TO GRID
  //····················································································································

  func canSnapToGrid_PackageZone (_ inGrid : Int) -> Bool {
    var result = (self.x % inGrid) != 0
    if !result {
      result = (self.y % inGrid) != 0
    }
    if !result {
      result = (self.width % inGrid) != 0
    }
    if !result {
      result = (self.height % inGrid) != 0
    }
    if !result {
      result = (self.xName % inGrid) != 0
    }
    if !result {
      result = (self.yName % inGrid) != 0
    }
    return result
  }

  //····················································································································

  func snapToGrid_PackageZone (_ inGrid : Int) {
    self.x = ((self.x + inGrid / 2) / inGrid) * inGrid
    self.y = ((self.y + inGrid / 2) / inGrid) * inGrid
    self.width = ((self.width + inGrid / 2) / inGrid) * inGrid
    self.height = ((self.height + inGrid / 2) / inGrid) * inGrid
    self.xName = ((self.xName + inGrid / 2) / inGrid) * inGrid
    self.yName = ((self.yName + inGrid / 2) / inGrid) * inGrid
  }

  //····················································································································

  func alignmentPoints_PackageZone () -> Set <CanariPoint> {
    var result = Set <CanariPoint> ()
    result.insertCanariPoint (x: self.x, y: self.y)
    result.insertCanariPoint (x: self.x + self.width, y: self.y + self.height)
    result.insertCanariPoint (x: self.xName, y: self.yName)
    return result
  }

  //····················································································································
  //  HORIZONTAL FLIP
  //····················································································································

  func flipHorizontally_PackageZone () {
  }

  //····················································································································

  func canFlipHorizontally_PackageZone () -> Bool {
    return false
  }

  //····················································································································
  //  VERTICAL FLIP
  //····················································································································

  func flipVertically_PackageZone () {
  }

  //····················································································································

  func canFlipVertically_PackageZone () -> Bool {
    return false
  }

  //····················································································································
  //  operationBeforeRemoving
  //····················································································································

  func operationBeforeRemoving_PackageZone () {
  }

  //····················································································································

  override func program () -> String {
    var s = "zone "
    s += stringFrom (valueInCanariUnit: self.x, displayUnit : self.xUnit)
    s += " : "
    s += stringFrom (valueInCanariUnit: self.y, displayUnit : self.yUnit)
    s += " size "
    s += stringFrom (valueInCanariUnit: self.width, displayUnit : self.widthUnit)
    s += " : "
    s += stringFrom (valueInCanariUnit: self.height, displayUnit : self.heightUnit)
    s += " label "
    s += stringFrom (valueInCanariUnit: self.xName, displayUnit : self.xNameUnit)
    s += " : "
    s += stringFrom (valueInCanariUnit: self.yName, displayUnit : self.yNameUnit)
    s += " name "
    s += "\"" + self.zoneName + "\""
    s += " numbering "
    s += self.zoneNumbering.descriptionForExplorer ()
    s += ";\n"
    return s
  }

 //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
