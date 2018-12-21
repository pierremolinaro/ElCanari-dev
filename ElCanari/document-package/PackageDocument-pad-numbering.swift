//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedPackageDocument {

  //····················································································································
  //   Handle pad numbering
  // MARK: -
  //····················································································································

  internal func handlePadNumbering () {
    // Swift.print ("handlePadNumbering")
  //--- Get all pads
    var allPads = self.rootObject.packagePads_property.propval
  //--- Apply pad numbering
    switch self.rootObject.padNumbering {
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
        var x = 0
        var y = 0
        for pad in allPads {
          x += pad.xCenter
          y += pad.yCenter
        }
        let center = CanariPoint (x: x / allPads.count, y: y / allPads.count)
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
