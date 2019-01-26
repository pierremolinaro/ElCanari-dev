//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//
//  Created by Pierre Molinaro on 26/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// https://developer.github.com/v3/git/trees/
// https://developer.github.com/v4/object/commit/
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

 func phase2_readOrDownloadLibraryFileDictionary (_ inLogTextView : NSTextView,
                                                  _ inProxy : [String],
                                                  _ ioPossibleAlert : inout NSAlert?) -> [String : LibraryRepositoryFileDescriptor] {

//  let query = "node(oid:\(getRepositoryCommitSHA ()!)) { tree { entries { name type oid } } }"
//  if let dict = runGraphqlQuery (query, inProxy, inLogTextView) {
//    Swift.print ("\(dict)")
//  }
  let libraryFileDictionary : [String : LibraryRepositoryFileDescriptor]
  inLogTextView.appendMessageString ("Phase 2: get repository file list\n", color: NSColor.purple)
  if let repositoryCommitSHA = getRepositoryCommitSHA () {
    if let (sha, cacheArray) = getRepositoryContentsForCommitCache (), repositoryCommitSHA == sha {
      libraryFileDictionary = buildFromCacheArray (cacheArray, &ioPossibleAlert, inLogTextView)
    }else{ // No cache or invalid cache: retrieve from repository
      libraryFileDictionary = fetchFileListForCommitFromRepository (repositoryCommitSHA, &ioPossibleAlert, inProxy, inLogTextView)
    }
  }else{
    inLogTextView.appendErrorString ("  Repository commit SHA does not exist in preferences\n")
    ioPossibleAlert = NSAlert ()
    ioPossibleAlert?.messageText = "Internal error"
    ioPossibleAlert?.informativeText = "Repository commit SHA does not exist in preferences."
    libraryFileDictionary = [String : LibraryRepositoryFileDescriptor] ()
  }
//--- Print
  inLogTextView.appendMessageString ("  Repository contents [path — size — blobSHA]:\n")
  for (path, value) in libraryFileDictionary {
    inLogTextView.appendMessageString ("    [\(path) — \(value.mSizeInRepository) — \(value.mBlobSHA)]\n")
  }
  return libraryFileDictionary
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func buildFromCacheArray (_ inCacheArray: [[String : Any]],
                                      _ ioPossibleAlert : inout NSAlert?,
                                      _ inLogTextView : NSTextView) -> [String : LibraryRepositoryFileDescriptor] {
  inLogTextView.appendWarningString ("  Using cache\n")
  var libraryFileDictionary = [String : LibraryRepositoryFileDescriptor] ()
  for entry in inCacheArray {
    if let filePath = entry ["path"] as? String, let size = entry ["size"] as? Int, let sha = entry ["sha"] as? String {
      let descriptor = LibraryRepositoryFileDescriptor (
        blobSHA: sha,
        sizeInRepository: size
      )
      libraryFileDictionary [filePath] = descriptor
    }else{
      ioPossibleAlert = NSAlert ()
      ioPossibleAlert?.messageText = "Invalid Cache file"
    }
  }
  return libraryFileDictionary
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func fetchFileListForCommitFromRepository (_ repositoryCommitSHA : String,
                                      _ ioPossibleAlert : inout NSAlert?,
                                      _ inProxy : [String],
                                      _ inLogTextView : NSTextView) -> [String : LibraryRepositoryFileDescriptor] {
  inLogTextView.appendWarningString ("  Fetch from repository\n")
  var libraryFileDictionary = [String : LibraryRepositoryFileDescriptor] ()
  let arguments = [
    "-s", // Silent mode, do not show download progress
    "-L", // Follow redirections
    "https://api.github.com/repos/pierremolinaro/ElCanariLibrary/git/trees/\(repositoryCommitSHA)?recursive=1"
  ] + inProxy
  let response = runShellCommandAndGetDataOutput (CURL, arguments, inLogTextView)
  switch response {
  case .error (let errorCode) :
    if errorCode != 6 { // Error #6 is 'no network connection'
      ioPossibleAlert = NSAlert ()
      ioPossibleAlert?.messageText = "Cannot connect to the server"
      ioPossibleAlert?.informativeText = "Error code: \(errorCode)"
    }
  case .ok (let responseData) :
    do{
      var cacheArray = [[String : Any]] ()
      let jsonObject = try JSONSerialization.jsonObject (with: responseData) as! NSDictionary
      let treeEntry = get (jsonObject, "tree", #line)
      let extensions = Set <String> (["ElCanariFont", "ElCanariArtwork", "ElCanariSymbol", "ElCanariPackage", "ElCanariDevice"])
      if let fileDescriptionArray = treeEntry as? [[String : Any]] {
        // Swift.print ("fileDescriptionArray \(fileDescriptionArray)")
        for fileDescriptionDictionay in fileDescriptionArray {
          if let filePath = fileDescriptionDictionay ["path"] as? String, extensions.contains (filePath.pathExtension) {
            if let sizeInRepository = fileDescriptionDictionay ["size"] as? Int, let sha = fileDescriptionDictionay ["sha"] as? String {
              let entry : [String : Any] = [
                "path" : filePath,
                "size" : sizeInRepository,
                "sha" : sha
              ]
              cacheArray.append (entry)
              let descriptor = LibraryRepositoryFileDescriptor (
                blobSHA: sha,
                sizeInRepository: sizeInRepository
              )
              libraryFileDictionary [filePath] = descriptor
            }else{
              ioPossibleAlert = NSAlert ()
              ioPossibleAlert?.messageText = "Internal error"
            }
          }
        }
        storeRepositoryContentsForCommitCache (repositoryCommitSHA, cacheArray)
      }
    }catch let error {
      ioPossibleAlert = NSAlert (error: error)
    }
  }
  return libraryFileDictionary
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   get fromDictionary
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func get (_ inObject: Any?, _ key : String, _ line : Int) -> Any? {
  if let dictionary = inObject as? NSDictionary {
    if let r = dictionary [key] {
      return r
    }else{
      print ("line \(line) : no \(key) key in dictionary")
      return nil
    }
  }else{
    print ("line \(line) : object is not a dictionary")
    return nil
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct LibraryRepositoryFileDescriptor {

  //····················································································································
  //   Properties
  //····················································································································

  let mBlobSHA : String
  let mSizeInRepository : Int

  //····················································································································

  init (blobSHA inBlobSHA : String,
        sizeInRepository inSizeInRepository : Int) {
    mBlobSHA = inBlobSHA
    mSizeInRepository = inSizeInRepository
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
