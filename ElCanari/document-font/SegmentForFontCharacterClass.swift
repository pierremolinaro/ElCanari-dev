
import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class SegmentForFontCharacterClass : EBSimpleClass {

  internal var mX1 : Int
  var x1 : Int { get { return mX1 } }

  internal var mY1 : Int
  var y1 : Int { get { return mY1 } }
  
  internal var mX2 : Int
  var x2 : Int { get { return mX2 } }

  internal var mY2 : Int
  var y2 : Int { get { return mY2 } }

  //····················································································································

  init (x1 inX1 : Int, y1 inY1 : Int, x2 inX2 : Int, y2 inY2 : Int) {
    mX1 = inX1
    mY1 = inY1
    mX2 = inX2
    mY2 = inY2
  }

  //····················································································································
  
}


//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

