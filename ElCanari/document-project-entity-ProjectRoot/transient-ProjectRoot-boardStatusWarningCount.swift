//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func transient_ProjectRoot_boardStatusWarningCount (
       _ self_boardIssues : CanariIssueArray,                  
       _ self_unplacedPackages : StringTagArray
) -> Int {
//--- START OF USER ZONE 2
        var warningCount = self_unplacedPackages.count
        for issue in self_boardIssues {
          switch issue.kind {
          case .error :
            ()
          case .warning :
            warningCount += 1
          }
        }
        return warningCount
//--- END OF USER ZONE 2
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————