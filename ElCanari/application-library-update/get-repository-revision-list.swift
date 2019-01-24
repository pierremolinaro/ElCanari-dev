//
//  get-repository-revision-list.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 24/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func startLibraryRevisionListOperation (_ inLogTextView : NSTextView) {
  inLogTextView.appendMessageString ("Start getting library revision list\n", color: NSColor.blue)
//--- Disable update buttons
  g_Preferences?.mCheckForLibraryUpdatesButton?.isEnabled = false
  g_Preferences?.mUpDateLibraryMenuItemInCanariMenu?.isEnabled = false
//-------- Cleat log window
  inLogTextView.clear ()
//-------- ⓪ Get system proxy
  inLogTextView.appendMessageString ("Phase 0: Get proxy (if any)\n", color: NSColor.purple)
  let proxy = getSystemProxy (inLogTextView)
//-------- ① We start by checking if a repository did change using etag
  inLogTextView.appendMessageString ("Phase 1: asking for commit list?\n", color: NSColor.purple)
  let arguments = [
    "-s", // Silent mode, do not show download progress
    "-L", // Follow
    "https://api.github.com/repos/pierremolinaro/ElCanari-Library/commits"
  ] + proxy
  let responseCode = runShellCommandAndGetDataOutput (CURL, arguments, inLogTextView)
  var possibleAlert : NSAlert? = nil
  switch responseCode {
  case .error (let errorCode) :
    inLogTextView.appendErrorString ("  Result code means 'Cannot connect to the server'\n")
    possibleAlert = NSAlert ()
    possibleAlert?.messageText = "Cannot connect to the server"
    possibleAlert?.addButton (withTitle: "Ok")
    possibleAlert?.informativeText = (errorCode == 6)
      ? "No network connection"
      : "Server connection error"
  case .ok (let responseData) :
    inLogTextView.appendSuccessString ("  Result code means 'Ok'\n")
    do{
      let response = try JSONSerialization.jsonObject (with: responseData)
      var ok = true
      if let array = response as? [Any] {
        inLogTextView.appendMessageString ("  \(array.count) revisions\n")
        var revisions = [LibraryRevisionDescriptor] ()
        for commit in array {
          if let dictionary = commit as? [String : Any] {
            let possibleCommitURL = dictionary ["url"] as? String
            let commitDictionary = dictionary ["commit"] as? [String : Any]
            let possibleCommitMessage = commitDictionary? ["message"] as? String
            let committerDictionary = commitDictionary? ["committer"] as? [String : Any]
            let possibleCommitDateString = (committerDictionary? ["date"] as? String)
            let possibleCommitDate = iso8601StringToDate (possibleCommitDateString)
            if let commitDate = possibleCommitDate, let commitURL = possibleCommitURL, let commitMessage = possibleCommitMessage {
              let commitSHA = commitURL.lastPathComponent
              revisions.append (LibraryRevisionDescriptor (commitDate, commitSHA, commitMessage))
              inLogTextView.appendMessageString ("  Date \(commitDate), sha \(commitSHA), message \(commitMessage)\n")
            }else{
              inLogTextView.appendErrorString ("  Invalid commit format\n")
              ok = false
            }
          }else{
            ok = false
          }
        }
        if ok {
          displayRepositoryCommitList (revisions)
        }
      }else{
        ok = false
      }
      if !ok {
        possibleAlert = NSAlert ()
        possibleAlert?.messageText = "Cannot decode server response"
      }
    }catch let error {
      possibleAlert = NSAlert (error: error)
    }
  }
//--- Enable update buttons
  g_Preferences?.mCheckForLibraryUpdatesButton?.isEnabled = true
  g_Preferences?.mUpDateLibraryMenuItemInCanariMenu?.isEnabled = true
//--- Display alert ?
  if let alert = possibleAlert {
    _ = alert.runModal ()
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//https://stackoverflow.com/questions/39433852/parsing-a-iso8601-string-to-date-in-swift
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func iso8601StringToDate (_ inString : String?) -> Date? {
  var date : Date? = nil
  if let str = inString {
    let dateFormatter = DateFormatter ()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    date = dateFormatter.date (from: str)
  }
  return date
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class LibraryRevisionDescriptor {

  //····················································································································
  //   Properties
  //····················································································································

  let mDate : Date
  let mCommitSHA : String
  let mMessage : String

  //····················································································································
  //   init
  //····················································································································

  init (_ date : Date, _ commitSHA : String, _ message : String) {
    mDate = date
    mCommitSHA = commitSHA
    mMessage = message
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func displayRepositoryCommitList (_ revisions : [LibraryRevisionDescriptor]) {


}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

