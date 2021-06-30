//
//  load-repository-current-commit.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 02/02/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CanariLibraryEntry {

  //····················································································································

  @objc internal func loadRepositorCurrentCommitAction (_ inSender : Any?) {
    _ = self.loadRepositorCurrentCommit ()
  }

  //····················································································································

  internal func loadRepositorCurrentCommit () -> Int? {
    let response = readRemoteFile ("lastCommit.txt", url: self.mLibraryRepositoryURL, userPwd: self.mUserAndPasswordTag)
    let result : Int?
    switch response {
    case .error (let status) :
      g_Preferences?.mLibraryRepositoryCurrentReleaseTextField?.stringValue = "Error \(status)"
      result = nil
    case .ok (let data) :
      if let s = String (data: data, encoding: .utf8), let currentCommit = Int (s) {
        g_Preferences?.mLibraryRepositoryCurrentReleaseTextField?.stringValue = "\(currentCommit)"
        result = currentCommit
      }else{
        g_Preferences?.mLibraryRepositoryCurrentReleaseTextField?.stringValue = "invalid value"
        result = nil
      }
    }
    return result
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
