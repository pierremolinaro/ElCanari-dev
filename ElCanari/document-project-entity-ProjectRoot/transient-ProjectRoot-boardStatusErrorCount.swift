//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_ProjectRoot_boardStatusErrorCount (
       _ self_boardIssues : CanariIssueArray
) -> Int {
//--- START OF USER ZONE 2
        var errorCount = 0
        for issue in self_boardIssues {
          switch issue.kind {
          case .error :
            errorCount += 1
          case .warning :
            ()
          }
        }
        return errorCount
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
