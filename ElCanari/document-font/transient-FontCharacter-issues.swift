//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_FontCharacter_issues (
       _ self_codePoint : Int,                  
       _ self_advance : Int,                    
       _ self_mWarnsWhenNoSegment : Bool,       
       _ self_mWarnsWhenAdvanceIsZero : Bool,   
       _ self_segments_count : Int
) -> CanariIssueArray {
//--- START OF USER ZONE 2
  var issues = [CanariIssue] ()
  if (self_advance == 0) && self_mWarnsWhenAdvanceIsZero {
    let s = CanariIssue (
      kind: .warning,
      message: unsafe "+u\(String (format: "%04X", self_codePoint)): zero advancement",
      representativeValue: self_codePoint
    )
    issues.append (s)
  }
  if (self_segments_count == 0) && self_mWarnsWhenNoSegment {
    let s = CanariIssue (
      kind: .warning,
      message: unsafe "+u\(String (format: "%04X", self_codePoint)): no segment",
      representativeValue: self_codePoint
    )
    issues.append (s)
  }
  return issues
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
