//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_AutoLayoutMergerDocument_statusImage (
       _ self_issues : CanariIssueArray,                        
       _ self_modelVersionErrorMessage : String
) -> NSImage {
//--- START OF USER ZONE 2
          if (self_issues.count == 0) && self_modelVersionErrorMessage.isEmpty {
            return NSImage (named: okStatusImageName)!
          }else if (self_issues.errorCount != 0) || !self_modelVersionErrorMessage.isEmpty {
            return NSImage (named: errorStatusImageName)!
          }else{
            return NSImage (named: warningStatusImageName)!
          }
//          if (self_issues.count == 0) && root_boardLimitWidthOk && self_modelVersionErrorMessage.isEmpty {
//            return NSImage (named: okStatusImageName)!
//          }else if (self_issues.errorCount != 0) || !root_boardLimitWidthOk || !self_modelVersionErrorMessage.isEmpty {
//            return NSImage (named: errorStatusImageName)!
//          }else{
//            return NSImage (named: warningStatusImageName)!
//          }
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
