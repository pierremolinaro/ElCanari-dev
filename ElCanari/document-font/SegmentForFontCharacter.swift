
import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct FontCharacterSegment : Hashable {

  let x1 : Int
  let y1 : Int
  let x2 : Int
  let y2 : Int

  //····················································································································

  init (x1 inX1 : Int, y1 inY1 : Int, x2 inX2 : Int, y2 inY2 : Int) {
    x1 = inX1
    y1 = inY1
    x2 = inX2
    y2 = inY2
  }

  //····················································································································

  init () {
    x1 = 0
    y1 = 0
    x2 = 0
    y2 = 0
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————