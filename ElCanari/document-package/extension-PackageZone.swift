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

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  override func translate (xBy inDx: Int, yBy inDy: Int, userSet ioSet : OCObjectSet) {
    self.x += inDx
    self.y += inDy
    self.xName += inDx
    self.yName += inDy
  }

  //····················································································································
  //  Knob
  //····················································································································

  override func canMove (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int) -> OCCanariPoint {
    var dx = inDx
    var dy = inDy
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
    return OCCanariPoint (x: dx, y: dy)
 }

  //····················································································································

  override func move (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int, newX inNewX : Int, newY inNewY : Int) {
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
  //  COPY AND PASTE
  //····················································································································

  override func canCopyAndPaste () -> Bool {
    return true
  }

  //····················································································································
  //  SNAP TO GRID
  //····················································································································

  override func canSnapToGrid (_ inGrid : Int) -> Bool {
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

  override func snapToGrid (_ inGrid : Int) {
    self.x = ((self.x + inGrid / 2) / inGrid) * inGrid
    self.y = ((self.y + inGrid / 2) / inGrid) * inGrid
    self.width = ((self.width + inGrid / 2) / inGrid) * inGrid
    self.height = ((self.height + inGrid / 2) / inGrid) * inGrid
    self.xName = ((self.xName + inGrid / 2) / inGrid) * inGrid
    self.yName = ((self.yName + inGrid / 2) / inGrid) * inGrid
  }

  //····················································································································

  override func alignmentPoints () -> OCCanariPointSet {
    let result = OCCanariPointSet ()
    result.points.insert (CanariPoint (x: self.x, y: self.y))
    result.points.insert (CanariPoint (x: self.x + self.width, y: self.y + self.height))
    result.points.insert (CanariPoint (x: self.xName, y: self.yName))
    return result
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
