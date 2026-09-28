import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

let PACKAGE_ZONE_BOTTOM = 1
let PACKAGE_ZONE_RIGHT  = 2
let PACKAGE_ZONE_LEFT   = 3
let PACKAGE_ZONE_TOP    = 4
let PACKAGE_ZONE_NAME   = 5

//--------------------------------------------------------------------------------------------------
//   EXTENSION PackageZone
//--------------------------------------------------------------------------------------------------

extension PackageZone {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationAfterPasting
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationAfterPasting_PackageZone (additionalDictionary _ : [String : Any],
                                          optionalDocument _ : EBAutoLayoutManagedDocument?,
                                          objectArray _ : [EBGraphicManagedObject]) -> String {
    return ""
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Save into additional dictionary
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func saveIntoAdditionalDictionary_PackageZone (_ _ : inout [String : Any]) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Translation
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptedTranslation_PackageZone (xBy inDx: CanariLength, yBy inDy: CanariLength) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptToTranslate_PackageZone (xBy _ : CanariLength, yBy _ : CanariLength) -> Bool {
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func translate_PackageZone (xBy inDx: CanariLength,
                              yBy inDy: CanariLength,
                              userSet _ : inout EBReferenceSet <EBManagedObject>) {
    self.x += inDx.cuValue
    self.y += inDy.cuValue
    self.xName += inDx.cuValue
    self.yName += inDy.cuValue
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Knob
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canMove_PackageZone (knob inKnobIndex : Int,
                            proposedUnalignedAlignedTranslation _ : CanariPoint,
                            proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                            unalignedMouseDraggedLocation _ : CanariPoint,
                            shift _ : Bool) -> CanariPoint {
    var dx = inProposedAlignedTranslation.x.cuValue
    var dy = inProposedAlignedTranslation.y.cuValue
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
    return CanariPoint (x: .cu (dx), y: .cu (dy))
 }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func move_PackageZone (knob inKnobIndex : Int,
                         proposedDx inDx : CanariLength,
                         proposedDy inDy : CanariLength,
                         unalignedMouseLocationX _ : CanariLength,
                         unalignedMouseLocationY _ : CanariLength,
                         alignedMouseLocationX _ : CanariLength,
                         alignedMouseLocationY _ : CanariLength,
                         shift _ : Bool) {
    if inKnobIndex == PACKAGE_ZONE_RIGHT {
      self.width += inDx.cuValue
    }else if inKnobIndex == PACKAGE_ZONE_LEFT {
      self.x += inDx.cuValue
      self.width -= inDx.cuValue
    }else if inKnobIndex == PACKAGE_ZONE_TOP {
      self.height += inDy.cuValue
    }else if inKnobIndex == PACKAGE_ZONE_BOTTOM {
      self.y += inDy.cuValue
      self.height -= inDy.cuValue
    }else if inKnobIndex == PACKAGE_ZONE_NAME {
      self.xName += inDx.cuValue
      self.yName += inDy.cuValue
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  SNAP TO GRID
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func snapToGrid_PackageZone (_ inGrid : Int) {
    self.x = ((self.x + inGrid / 2) / inGrid) * inGrid
    self.y = ((self.y + inGrid / 2) / inGrid) * inGrid
    self.width = ((self.width + inGrid / 2) / inGrid) * inGrid
    self.height = ((self.height + inGrid / 2) / inGrid) * inGrid
    self.xName = ((self.xName + inGrid / 2) / inGrid) * inGrid
    self.yName = ((self.yName + inGrid / 2) / inGrid) * inGrid
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func alignmentPoints_PackageZone () -> Set <CanariPoint> {
    var result = Set <CanariPoint> ()
    result.insert (x: self.x, y: self.y)
    result.insert (x: self.x + self.width, y: self.y + self.height)
    result.insert (x: self.xName, y: self.yName)
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  HORIZONTAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipHorizontally_PackageZone () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipHorizontally_PackageZone () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  VERTICAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipVertically_PackageZone () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipVertically_PackageZone () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationBeforeRemoving
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationBeforeRemoving_PackageZone () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func program () -> String {
    var s = "zone "
    s += intValueAndUnitStringFrom (valueInCanariUnit: self.x, displayUnit : self.xUnit)
    s += " : "
    s += intValueAndUnitStringFrom (valueInCanariUnit: self.y, displayUnit : self.yUnit)
    s += " size "
    s += intValueAndUnitStringFrom (valueInCanariUnit: self.width, displayUnit : self.widthUnit)
    s += " : "
    s += intValueAndUnitStringFrom (valueInCanariUnit: self.height, displayUnit : self.heightUnit)
    s += " label "
    s += intValueAndUnitStringFrom (valueInCanariUnit: self.xName, displayUnit : self.xNameUnit)
    s += " : "
    s += intValueAndUnitStringFrom (valueInCanariUnit: self.yName, displayUnit : self.yNameUnit)
    s += " name "
    s += "\"" + self.zoneName + "\""
    s += " numbering "
    s += self.zoneNumbering.string
    s += ";\n"
    return s
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  ROTATE 90
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canRotate90_PackageZone (accumulatedPoints _ : inout Set <CanariPoint>) -> Bool {
    return false
  }

 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -····················

  func rotate90Clockwise_PackageZone (from _ : CanariPoint,
                                      userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -····················

  func rotate90CounterClockwise_PackageZone (from _ : CanariPoint,
                                             userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -····················

}

//--------------------------------------------------------------------------------------------------
