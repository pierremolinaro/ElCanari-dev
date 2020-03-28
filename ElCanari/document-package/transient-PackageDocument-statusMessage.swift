//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func transient_PackageDocument_statusMessage (
       _ root_issues : CanariIssueArray
) -> String {
//--- START OF USER ZONE 2
  var s = "No error, no warning"
  if root_issues.count > 0 {
    let errorCount = root_issues.errorCount
    let warningCount = root_issues.warningCount
    if errorCount == 0 {
      s = "No error"
    }else if errorCount == 1 {
      s = "1 error"
    }else {
      s = "\(errorCount) errors"
    }
    s += ", "
    if warningCount == 0 {
      s += "no warning"
    }else if warningCount == 1 {
      s += "1 warning"
    }else {
      s += "\(warningCount) warnings"
    }
    s += "."
  }
  return s
//--- END OF USER ZONE 2
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————