
import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//
//---------------- ① Pour savoir si le repository a changé, on appelle :
//        curl -s -i -L https://api.github.com/repos/pierremolinaro/ElCanariLibrary/branches
// La réponse est :
//  ·······
//   Status: 200 OK
//  ·······
//   ETag: "22fc6b218e31128b7f802057f883393b"
//  ·······
//  [
//    {
//      "name": "master",
//      "commit": {
//        "sha": "20adfd48680e893e29a2e6bb94ebbbe88bb83e8f",
//        "url": "https://api.github.com/repos/pierremolinaro/ElCanariLibrary/commits/20adfd48680e893e29a2e6bb94ebbbe88bb83e8f"
//      }
//    }
//  ]
// Trois infos intéressantes dans la réponse :
//   - Status --> 200 : la requête s'est correctement déroulée
//   - commit / sha --> 20adfd48680e893e29a2e6bb94ebbbe88bb83e8f : valeur caractérisant le commit, utilisé dans les étapes suivantes
//   - Etag --> 22fc6b218e31128b7f802057f883393b : cette valeur permet d'interroger le serveur en lui indiquant 
// d'envoyer une réponse 304 si le repository n'a pas changé :
//        curl -s -i -L -H 'If-None-Match:"22fc6b218e31128b7f802057f883393b"' https://api.github.com/repos/pierremolinaro/ElCanariLibrary/branches
// On obtient alors la réponse suivante (sans donnée JSON)
//  ·······
//   Status: 304 Not Modified
//  ·······
// Si le contenu a changé, on obtient une réponse 200 comme précédemment, avec à la fin les données JSON.


//---------------- ② Pour obtenir la liste des fichiers du repository, on appelle :
// curl -s -L https://api.github.com/repos/pierremolinaro/ElCanariLibrary/git/trees/20adfd48680e893e29a2e6bb94ebbbe88bb83e8f?recursive=1
// La réponse est :
//{
//  "sha": "20adfd48680e893e29a2e6bb94ebbbe88bb83e8f",
//  "url": "https://api.github.com/repos/pierremolinaro/ElCanariLibrary/git/trees/20adfd48680e893e29a2e6bb94ebbbe88bb83e8f",
//  "tree": [
//  ·······
//    {
//      "path": "artworks",
//      "mode": "040000",
//      "type": "tree",
//      "sha": "aef45cfbb8a896426e0c49eda7ced76b5ce340c9",
//      "url": "https://api.github.com/repos/pierremolinaro/ElCanariLibrary/git/trees/aef45cfbb8a896426e0c49eda7ced76b5ce340c9"
//    },
//    {
//      "path": "artworks/electro_dragon.ElCanariArtwork",
//      "mode": "100644",
//      "type": "blob",
//      "sha": "e089e1c10538d15cda9de3e8a74b3bfd5ee1100a",
//      "size": 5850,
//      "url": "https://api.github.com/repos/pierremolinaro/ElCanariLibrary/git/blobs/e089e1c10538d15cda9de3e8a74b3bfd5ee1100a"
//    },
//  ·······
// Le champ "tree" est un tableau, un élément par fichier ou répertoire. Pour chaque fichier "size" contient sa taille ;
// Attention "sha" n'est pas le SHA du fichier, mais de son blob.

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let CURL = "/usr/bin/curl"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   LIBRARY UPDATE ENTRY POINT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func startLibraryUpdateOperation (_ inWindow : EBWindow?, _ inLogTextView : NSTextView) {
  inLogTextView.appendMessageString ("Start library update operation\n", color: NSColor.blue)
//--- Disable update buttons
  g_Preferences?.mCheckForLibraryUpdatesButton?.isEnabled = false
  g_Preferences?.mUpDateLibraryMenuItemInCanariMenu?.isEnabled = false
//-------- Cleat log window
  inLogTextView.clear ()
//-------- Show "Check for update" window
  inWindow?.makeKeyAndOrderFront (nil)
//-------- ⓪ Get system proxy
  inLogTextView.appendMessageString ("Phase 0: Get proxy (if any)\n", color: NSColor.purple)
  let proxy = getSystemProxy (inLogTextView)
//-------- ① We start by checking if a repository did change using etag
  inLogTextView.appendMessageString ("Phase 1: repository did change?\n", color: NSColor.purple)
  var possibleAlert : NSAlert? = nil
//  var needsToDownloadRepositoryFileList = true
  if let etag = getRepositoryCurrentETag (), let sha = getRepositoryCommitSHA () {
    inLogTextView.appendSuccessString ("  Current Etag: \(etag)\n")
    inLogTextView.appendSuccessString ("  Current commit SHA: \(sha)\n")
    queryServerLastCommitUsingEtag (etag, inLogTextView, proxy, &possibleAlert)
  }else{
    inLogTextView.appendWarningString ("  No current Etag and/or no current commit SHA\n")
    queryServerLastCommitWithNoEtag (inLogTextView, proxy, &possibleAlert)
  }
//-------- ② Repository ETAG and commit SHA have been successfully retrieve,
//            now read of download the file list corresponding to this commit
  let repositoryFileDictionary : [String : LibraryRepositoryFileDescriptor]
  if possibleAlert == nil {
    repositoryFileDictionary = phase2_readOrDownloadLibraryFileDictionary (inLogTextView, proxy, &possibleAlert)
  }else{
    repositoryFileDictionary = [String : LibraryRepositoryFileDescriptor] ()
  }
//-------- ③ Read library descriptor file
  let libraryDescriptorFileContents : [String : CanariLibraryFileDescriptor]
  if possibleAlert == nil {
    libraryDescriptorFileContents = phase3_readLibraryDescriptionFileContents (inLogTextView)
  }else{
    libraryDescriptorFileContents = [String : CanariLibraryFileDescriptor] ()
  }
//-------- ④ Repository contents has been successfully retrieved, then enumerate local system library
  let localFileSet : Set <String>
  if possibleAlert == nil {
    localFileSet = phase4_appendLocalFilesToLibraryFileDictionary (inLogTextView, &possibleAlert)
  }else{
    localFileSet = Set <String> ()
  }
//-------- ⑤ Build library operations
  let libraryOperations : [LibraryOperationElement]
  let newLocalDescription : [String : CanariLibraryFileDescriptor]
  if possibleAlert == nil {
    (libraryOperations, newLocalDescription) = phase5_buildLibraryOperations (repositoryFileDictionary, localFileSet, libraryDescriptorFileContents, inLogTextView, proxy)
  }else{
    libraryOperations = [LibraryOperationElement] ()
    newLocalDescription = [String : CanariLibraryFileDescriptor] ()
  }
//-------- ⑥ Order out "Check for update" window
  inLogTextView.appendMessageString ("Phase 6: library is up to date ?\n", color: NSColor.purple)
  let ok = possibleAlert == nil
  if let window = inWindow {
    if (possibleAlert == nil) && (libraryOperations.count == 0) {
      inLogTextView.appendSuccessString ("  The library is up to date\n")
      possibleAlert = NSAlert ()
      possibleAlert?.messageText = "The library is up to date"
    }
    if let alert = possibleAlert {
      alert.beginSheetModal (
        for: window,
        completionHandler: { (response : NSApplication.ModalResponse) in window.orderOut (nil) }
      )
    }else{
      window.orderOut (nil)
    }
  }
//-------- ⑦ If ok and there are update operations, perform library update
  if ok && (libraryOperations.count != 0) {
    phase7_performLibraryOperations (libraryOperations, newLocalDescription, inLogTextView)
  }else{
    if !ok {
      inLogTextView.appendWarningString ("  Not realized, due to previous errors\n")
    }
    enableItemsAfterCompletion ()
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func enableItemsAfterCompletion () {
  g_Preferences?.mCheckForLibraryUpdatesButton?.isEnabled = true
  g_Preferences?.mUpDateLibraryMenuItemInCanariMenu?.isEnabled = true
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func queryServerLastCommitUsingEtag (_ etag : String,
                                             _ inLogTextView : NSTextView,
                                             _ inProxy : [String],
//                                             _ outNeedsToDownloadRepositoryFileList : inout Bool,
                                             _ ioPossibleAlert : inout NSAlert?) {
  let arguments = [
    "-s", // Silent mode, do not show download progress
    "-i", // Add response header in output
    "-L", // Follow
    "-H", "If-None-Match:\"\(etag)\"",
    "https://api.github.com/repos/pierremolinaro/ElCanariLibrary/branches"
  ] + inProxy
  let responseCode = runShellCommandAndGetDataOutput (CURL, arguments, inLogTextView)
  switch responseCode {
  case .error (let errorCode) :
    inLogTextView.appendErrorString ("  Result code means 'Cannot connect to the server'\n")
    ioPossibleAlert = NSAlert ()
    ioPossibleAlert?.messageText = "Cannot connect to the server"
    ioPossibleAlert?.informativeText = (errorCode == 6)
      ? "No network connection"
      : "Server connection error"
  case .ok (let responseData) :
    inLogTextView.appendSuccessString ("  Result code means 'Ok'\n")
    if let response = String (data: responseData, encoding: .utf8) {
      // Swift.print ("\(response)")
      let c0 = response.components (separatedBy: "Status: ")
      let c1 = c0 [1].components (separatedBy: " ")
      //print ("C1 \(c1 [0])")
      if let status = Int (c1 [0]) {
        inLogTextView.appendMessageString ("  HTTP Status: \(status)\n", color: NSColor.black)
        if status == 304 { // Status 304 --> not modified, use current repository description file
          inLogTextView.appendMessageString ("  HTTP Status means 'no repository change, use current description file'\n", color: NSColor.black)
//          outNeedsToDownloadRepositoryFileList = false
        }else if status == 200 { // Status 200 --> Ok, modified
          inLogTextView.appendMessageString ("  HTTP Status means 'repository did change'\n", color: NSColor.black)
          storeRepositoryETagAndLastCommitSHA (withResponse: response, inLogTextView, &ioPossibleAlert)
//          outNeedsToDownloadRepositoryFileList = true
        }
      }else{
        inLogTextView.appendErrorString ("  Cannot extract HTTP status from downloaded data\n")
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func queryServerLastCommitWithNoEtag (_ inLogTextView : NSTextView,
                                              _ inProxy : [String],
                                              _ ioPossibleAlert : inout NSAlert?) {
  let arguments = [
    "-s", // Silent mode, do not show download progress
    "-i", // Add response header in output
    "-L", // Follow
    "https://api.github.com/repos/pierremolinaro/ElCanariLibrary/branches"
  ] + inProxy
  let response = runShellCommandAndGetDataOutput (CURL, arguments, inLogTextView)
  switch response {
  case .error (let errorCode) :
    inLogTextView.appendErrorString ("  Result code means 'Cannot connect to the server'\n")
    let alert = NSAlert ()
    alert.messageText = "Cannot connect to the server"
    alert.informativeText = (errorCode == 6)
      ? "No network connection"
      : "Server connection error"
  case .ok (let responseData) :
    inLogTextView.appendSuccessString ("  Result code means 'Ok'\n")
    if let response = String (data: responseData, encoding: .utf8) {
      storeRepositoryETagAndLastCommitSHA (withResponse: response, inLogTextView, &ioPossibleAlert)
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func storeRepositoryETagAndLastCommitSHA (withResponse inResponse : String,
                                                  _ inLogTextView : NSTextView,
                                                  _ ioPossibleAlert : inout NSAlert?) {
  let components = inResponse.components (separatedBy:"\r\n\r\n")
  if components.count >= 2 {
    let jsonData = components [components.count - 1].data (using: .utf8)!
    do{
      inLogTextView.appendErrorString ("  HTTP result, has \(components.count) lines\n")
    //--- Get commit sha
      let jsonArray = try JSONSerialization.jsonObject (with: jsonData) as! NSArray
      let jsonDictionary = jsonArray [0] as! NSDictionary
      let commitDict = jsonDictionary ["commit"]  as! NSDictionary
      let commitSHA = commitDict ["sha"]  as! String
      inLogTextView.appendSuccessString ("  Commit SHA: \(commitSHA) has been stored in preferences\n")
      storeRepositoryCommitSHA (commitSHA)
    //--- Get ETag
      let c1 = components [components.count - 2].components (separatedBy:"ETag: \"")
      let c2 = c1 [1].components (separatedBy:"\"")
      let etag = c2 [0]
      storeRepositoryCurrentETag (etag)
      inLogTextView.appendSuccessString ("  Etag: \(etag) has been stored in preferences\n")
    }catch let error {
      inLogTextView.appendErrorString ("  Error parsing JSON: \(error)\n")
      ioPossibleAlert = NSAlert (error: error)
    }
  }else{
    inLogTextView.appendErrorString ("  Invalid HTTP result, has \(components.count) line (should be ≥ 2)\n")
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
