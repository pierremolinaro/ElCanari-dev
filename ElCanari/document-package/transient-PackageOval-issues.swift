//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func transient_PackageOval_issues (
       _ self_x : Int,             
       _ self_y : Int,             
       _ self_width : Int,         
       _ self_height : Int
) -> CanariIssueArray {
//--- START OF USER ZONE 2
  var issues = [CanariIssue] ()
  if self_width == 0 {
    issues.appendOvalZeroWidthIssueAt (x: self_x, y: self_y + self_height / 2)
  }
  if self_height == 0 {
    issues.appendOvalZeroHeightIssueAt (x: self_x + self_width / 2, y: self_y)
  }
  return issues
//--- END OF USER ZONE 2
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————