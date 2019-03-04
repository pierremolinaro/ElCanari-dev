//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedPackageDocument {

  //····················································································································

  internal func addPadNumberingObservers () {
    self.mPadNumberingObserver.mEventCallBack = { [weak self] in self?.handlePadNumbering () }
    self.rootObject.packagePads_property.addEBObserverOf_xCenter (self.mPadNumberingObserver)
    self.rootObject.packagePads_property.addEBObserverOf_yCenter (self.mPadNumberingObserver)
    self.rootObject.padNumbering_property.addEBObserver (self.mPadNumberingObserver)
    self.rootObject.packageZones_property.addEBObserverOf_rect (self.mPadNumberingObserver)
    self.rootObject.packageZones_property.addEBObserverOf_zoneNumbering (self.mPadNumberingObserver)
    self.rootObject.packageZones_property.addEBObserver (self.mPadNumberingObserver)
  }

  //····················································································································

  private func handlePadNumbering () {
    var allPads = self.rootObject.packagePads_property.propval
    let aPad = allPads.first
    var zoneDictionary = [PackageZone : [PackagePad]] ()
    for zone in self.rootObject.packageZones_property.propval {
      let zoneRect = zone.rect!
      var idx = 0
      while idx < allPads.count {
        let pad = allPads [idx]
        idx += 1
        if zoneRect.contains (x: pad.xCenter, y: pad.yCenter) {
          let a = zoneDictionary [zone] ?? []
          zoneDictionary [zone] = a + [pad]
          pad.zone_property.setProp (zone)
          idx -= 1
          allPads.remove(at: idx)
        }
      }
    }
  //---
    for (zone, padArray) in zoneDictionary {
      self.performPadNumbering (padArray, zone.zoneNumbering)
    }
  //--- Handle pads outside zones
    for pad in allPads {
      pad.zone_property.setProp (nil)
    }
    self.performPadNumbering (allPads, self.rootObject.padNumbering)
  //--- Link slave pads to any pad
    let allSlavePads = self.rootObject.packageSlavePads_property.propval
    for slavePad in allSlavePads {
      if slavePad.master_property.propval == nil {
        slavePad.master_property.setProp (aPad)
      }
    }
  }

  //····················································································································

  private func performPadNumbering (_ inPadArray : [PackagePad], _ inNumberingPolicy : PadNumbering) {
    // Swift.print ("handlePadNumbering")
  //--- Get all pads
    var allPads = inPadArray
  //--- Apply pad numbering
    switch inNumberingPolicy {
    case .noNumbering :
    //--- Find max pad number
      var maxPadNumber = 0
      for pad in allPads {
        if maxPadNumber < pad.padNumber {
          maxPadNumber = pad.padNumber
        }
      }
    //--- Set a number to pad with number equal to 0
      for pad in allPads {
        if pad.padNumber == 0 {
          maxPadNumber += 1
          pad.padNumber = maxPadNumber
        }
      }
    //--- Sort pads by pad number
      allPads.sort (by: { $0.padNumber < $1.padNumber } )
    case .counterClock :
      if allPads.count > 0 {
        var xMin = Int.max
        var yMin = Int.max
        var xMax = Int.min
        var yMax = Int.min
        for pad in allPads {
          if xMin > pad.xCenter {
            xMin = pad.xCenter
          }
          if yMin > pad.yCenter {
            yMin = pad.yCenter
          }
          if xMax < pad.xCenter {
            xMax = pad.xCenter
          }
          if yMax < pad.yCenter {
            yMax = pad.yCenter
          }
        }
        let center = CanariPoint (x: (xMin + xMax) / 2, y: (yMin + yMax) / 2)
        allPads.sort (by: { $0.angle (from: center) < $1.angle (from: center) } )
      }
    case .upRight :
      allPads.sort (by: { ($0.yCenter > $1.yCenter) || (($0.yCenter == $1.yCenter) && ($0.xCenter > $1.xCenter)) } )
    case .upLeft :
      allPads.sort (by: { ($0.yCenter > $1.yCenter) || (($0.yCenter == $1.yCenter) && ($0.xCenter < $1.xCenter)) } )
    case .downRight :
      allPads.sort (by: { ($0.yCenter < $1.yCenter) || (($0.yCenter == $1.yCenter) && ($0.xCenter > $1.xCenter)) } )
    case .downLeft :
      allPads.sort (by: { ($0.yCenter < $1.yCenter) || (($0.yCenter == $1.yCenter) && ($0.xCenter < $1.xCenter)) } )
    case .rightUp :
      allPads.sort (by: { ($0.xCenter > $1.xCenter) || (($0.xCenter == $1.xCenter) && ($0.yCenter < $1.yCenter)) } )
    case .rightDown :
      allPads.sort (by: { ($0.xCenter > $1.xCenter) || (($0.xCenter == $1.xCenter) && ($0.yCenter > $1.yCenter)) } )
    case .leftUp :
      allPads.sort (by: { ($0.xCenter < $1.xCenter) || (($0.xCenter == $1.xCenter) && ($0.yCenter < $1.yCenter)) } )
    case .leftDown :
      allPads.sort (by: { ($0.xCenter < $1.xCenter) || (($0.xCenter == $1.xCenter) && ($0.yCenter > $1.yCenter)) } )
    }
  //--- Set pad numbers from 1
    var idx = 1
    for pad in allPads {
      pad.padNumber = idx
      idx += 1
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
