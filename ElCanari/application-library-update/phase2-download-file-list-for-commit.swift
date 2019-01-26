//
//  phase2-get-.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 26/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func downloadRepositoryFileList (forCommit inSHA : String, _ inLogTextView : NSTextView) {
  inLogTextView.appendMessageString ("Phase 2: get repository file list\n", color: NSColor.purple)
  var repositoryFileDictionary = [String : CanariLibraryFileDescriptor] ()
  if possibleAlert == nil {
    readOrDownloadLibraryFileDictionary (&repositoryFileDictionary, inLogTextView, proxy, needsToDownloadRepositoryFileList, &possibleAlert)
  }else{
    inLogTextView.appendWarningString ("  Not realized, due to previous errors\n")
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
