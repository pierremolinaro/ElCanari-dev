
import Cocoa
import Foundation
import SystemConfiguration
import ServiceManagement

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let LOG_LIBRARY_UPDATES = false

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    extension Preferences
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension Preferences {

  //····················································································································

  func beginDownloadRepositoryList () {
    gLibraryUpdateWindow?.makeKeyAndOrderFront (nil)
    mCheckForLibraryUpdatesButton?.isEnabled = false
    mUpDateLibraryMenuItemInCanariMenu?.action = nil
  }

  //····················································································································

  func cancelDownloadRepositoryList () {
    mCheckForLibraryUpdatesButton?.isEnabled = true
    mUpDateLibraryMenuItemInCanariMenu?.action = #selector(ApplicationDelegate.updateLibrary(_:))
  }

  //····················································································································

  func cancelDownloadElementFromRepository () {
    mLibraryUpdateWindow?.orderOut (nil)
    mCheckForLibraryUpdatesButton?.isEnabled = true
    mUpDateLibraryMenuItemInCanariMenu?.action = #selector(ApplicationDelegate.updateLibrary(_:))
  }

  //····················································································································

}


//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private var gLibraryUpdateWindow : EBWindow? = nil // nil if background search

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func performLibraryUpdate (_ inWindow : EBWindow?) {
  if LOG_LIBRARY_UPDATES {
    NSLog ("\(#function)")
  }
  gLibraryUpdateWindow = inWindow
  g_Preferences?.beginDownloadRepositoryList ()
//--- Download repository list
  let session = URLSession.shared 
  if let url = URL (string:"http://canarilibrary.rts-software.org/repositoryListV2.php") {
    let sessionTask = session.dataTask (with: url, completionHandler:downloadRepositoryListDidEnd)
    sessionTask.resume ()
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func downloadRepositoryListDidEnd (_ possibleData : Data?,
                                           response : URLResponse?,
                                           possibleError: Error?) {
  if LOG_LIBRARY_UPDATES {
    NSLog ("\(#function)")
  }
  if let error = possibleError {
    libraryDownloadDidEndWithError (error)
  }else if let data = possibleData { // ok
    var ok = true
    var localLibraryDictionary = [String : PMCanariLibraryFileDescriptor] ()
    var libraryPLIST = NSMutableDictionary ()
    do {
      let xmlDoc = try XMLDocument (data: data, options:0)
      (localLibraryDictionary, libraryPLIST) = try analyzeLocalLibrary ()
      try analyzeRepositoryXMLDocument (xmlDoc, localLibraryDictionary:&localLibraryDictionary)
      
    }catch let error {
      libraryDownloadDidEndWithError (error)
      ok = false
    }
    if ok {
      let (cumulativeSize, actionsToPerformArray) = evaluateUpdateActions (localLibraryDictionary)
      if actionsToPerformArray.count > 0 { // There are actions to perform for updating
        presentLibraryUpdateDialog (cumulativeSize, actionArray:actionsToPerformArray, libraryPLIST:libraryPLIST)
      }else if let window = gLibraryUpdateWindow { // Library is up to date
        let alert = NSAlert ()
        alert.messageText = "The library is up to date."
        alert.addButton (withTitle: "Ok")
        DispatchQueue.main.async  {
          alert.beginSheetModal (for: window, completionHandler: {(inReturnCode : NSModalResponse) in
            DispatchQueue.main.async  {
              window.orderOut (nil)
              g_Preferences?.mCheckForLibraryUpdatesButton?.isEnabled = true
              g_Preferences?.mUpDateLibraryMenuItemInCanariMenu?.action = #selector(ApplicationDelegate.updateLibrary(_:))
            }
          })
        }
      }else{
        g_Preferences?.cancelDownloadRepositoryList ()
      }
    }
  }else{
    g_Preferences?.cancelDownloadRepositoryList ()
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func libraryDownloadDidEndWithError (_ error : Error) {
  if LOG_LIBRARY_UPDATES {
    NSLog ("\(#function)")
  }
  DispatchQueue.main.async  {
    if let window = gLibraryUpdateWindow {
      let alert = NSAlert (error:error)
      alert.beginSheetModal (for: window, completionHandler: {(inReturnCode : NSModalResponse) in
        DispatchQueue.main.async  {
          window.orderOut (nil)
          g_Preferences?.cancelDownloadRepositoryList ()
        }
      })
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func throwError (_ message : String) throws {
  if LOG_LIBRARY_UPDATES {
    NSLog ("\(#function)")
  }
  throw NSError (
    domain:"CanariError",
    code:1,
    userInfo:[NSLocalizedDescriptionKey:message]
  )
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func analyzeLocalLibrary () throws -> ([String : PMCanariLibraryFileDescriptor], NSMutableDictionary) {
  if LOG_LIBRARY_UPDATES {
    NSLog ("\(#function)")
  }
  let fm = FileManager ()
//--- Get library files
  var currentLibraryContents = [String] ()
  if fm.fileExists (atPath: systemLibraryPath ()) {
    currentLibraryContents = try fm.subpathsOfDirectory (atPath: systemLibraryPath ())
  //--- Remove library-description.plist from list
    let possibleIndex = currentLibraryContents.index (of: libraryDescriptionPLISTfilename ())
    if let index = possibleIndex {
      currentLibraryContents.remove (at: index)
    }
  //--- Remove .DS_Store files
    var i = 0
    while i<currentLibraryContents.count {
      let s = currentLibraryContents [i]
      if (s as NSString).lastPathComponent == ".DS_Store" {
        currentLibraryContents.remove (at: i)
        i -= 1
      }
      i += 1
    }
  }
  if LOG_LIBRARY_UPDATES {
    NSLog ("currentLibraryContents %@", currentLibraryContents)
  }
//--- Get plist path
  let plistFilePath = systemLibraryPath () + "/" + libraryDescriptionPLISTfilename ()
  // NSLog ("plistFilePath %@", plistFilePath)
  var libraryPLIST : NSMutableDictionary
  if let dict = NSMutableDictionary (contentsOfFile:plistFilePath) {
    libraryPLIST = dict
  }else{
    libraryPLIST = NSMutableDictionary ()
  }
//--- Enumerate library files
  var localLibraryDictionary = [String : PMCanariLibraryFileDescriptor] ()
  for relativePath in currentLibraryContents {
    let fullPath = systemLibraryPath () + "/" + relativePath
    // NSLog ("fullPath in directory %@", fullPath)
    if let contents = fm.contents (atPath: fullPath) {  // Returns nil for a directory
      // NSLog ("read file %@", fullPath)
      let fileDescriptor : PMCanariLibraryFileDescriptor
      if let fd = localLibraryDictionary [relativePath] {
        fileDescriptor = fd
      }else{
        fileDescriptor = PMCanariLibraryFileDescriptor (relativePath:relativePath)
        localLibraryDictionary [relativePath] = fileDescriptor
      }
      let possibleElement : Any? = libraryPLIST.object (forKey: relativePath)
      if let element = possibleElement as? NSDictionary {
        if let rev = element.object (forKey: "revision") as? NSNumber {
          fileDescriptor.mLocalRevision = rev.intValue
        }else{
          try throwError ("invalid local revision")
        }
        if let localSHA1 = element.object (forKey: "sha1") as? Data {
          fileDescriptor.mLocalSHA1 = localSHA1
        }else{
          try throwError ("invalid local sha1")
        }
      }
      fileDescriptor.mActualSHA1 = sha1 (contents)
    }
  }
  // NSLog ("localLibraryDictionary %@", localLibraryDictionary)
  return (localLibraryDictionary, libraryPLIST)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func analyzeRepositoryXMLDocument (_ xmlDoc : XMLDocument,
                                           localLibraryDictionary ioLocalLibraryDictionary : inout [String : PMCanariLibraryFileDescriptor]) throws {
  if LOG_LIBRARY_UPDATES {
    NSLog ("\(#function)")
  }
  let rootElement : XMLElement? = xmlDoc.rootElement ()
  // NSLog ("rootElement \(rootElement)")
  let possibleEntries = try rootElement?.nodes (forXPath: "/lists/list/entry")
  if let entries = possibleEntries {
    for node in entries {
      let possibleKindValues : [XMLNode]? = try node.nodes (forXPath: "./@kind")
      let possibleNameValues : [XMLNode]? = try node.nodes (forXPath: "./name")
      let possibleSizeValues : [XMLNode]? = try node.nodes (forXPath: "./size")
      let possibleRevisionValues : [XMLNode]? = try node.nodes (forXPath: "./commit/@revision")
      if let kindValues = possibleKindValues,
        let nameValues = possibleNameValues,
        let sizeValues = possibleSizeValues,
        let revisionValues = possibleRevisionValues,
        let kind = kindValues [0].stringValue, kind == "file",
        let name = nameValues [0].stringValue,
        let fileSizeString = sizeValues [0].stringValue,
        let fileSize = Int64 (fileSizeString),
        let revisionInRepositoryString = revisionValues [0].stringValue,
        let revisionInRepository = Int (revisionInRepositoryString)
      {
        let fileDescriptor : PMCanariLibraryFileDescriptor
        if let fd = ioLocalLibraryDictionary [name] {
          fileDescriptor = fd
        }else{
          fileDescriptor = PMCanariLibraryFileDescriptor (relativePath:name)
          ioLocalLibraryDictionary [name] = fileDescriptor
        }
        fileDescriptor.mSizeInRepository = fileSize
        fileDescriptor.mRevisionInRepository = revisionInRepository
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let ACCESS_EQ_SIZE_FOR_PROGRESS_INDICATOR : Int64 = 100_000

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func evaluateUpdateActions (_ inLocalLibraryDictionary : [String : PMCanariLibraryFileDescriptor]) -> (Int64, [PMCanariLibraryFileDescriptor]) {
  if LOG_LIBRARY_UPDATES {
    NSLog ("\(#function)")
  }
//--- Evaluate actions to perform
  for descriptor in inLocalLibraryDictionary.values {
    descriptor.defineUpdateAction ()
  }
//--- Compute array of element with actions to perform
  var actionsToPerformArray = [PMCanariLibraryFileDescriptor] ()
  var cumulativeSize : Int64 = 0
  for descriptor in inLocalLibraryDictionary.values {
    switch descriptor.mEnumLibraryDownloadAction {
    case .kLibraryDownloadActionNone :
      break ;
    default :
      actionsToPerformArray.append (descriptor)
      cumulativeSize += descriptor.mSizeInRepository + ACCESS_EQ_SIZE_FOR_PROGRESS_INDICATOR
    }
  }
//--- Sort in decreasing size of file in repository
  actionsToPerformArray.sort (by: {$0.mSizeInRepository > $1.mSizeInRepository})
  // NSLog ("%@", actionsToPerformArray) ;
  return (cumulativeSize, actionsToPerformArray)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

enum EnumLibraryDownloadAction {
  case kLibraryDownloadActionNone
  case kLibraryDownloadActionUpdate
  case kLibraryDownloading
  case kLibraryDownloadActionDownloaded
  case kLibraryDownloadError
  case kLibraryDownloadActionDelete
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let kNoInfo = "—"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(PMCanariLibraryFileDescriptor)
class PMCanariLibraryFileDescriptor : NSObject, EBUserClassNameProtocol, URLSessionTaskDelegate {

  let mRelativePath : String
  var mLocalRevision : Int? = nil
  var mLocalSHA1 = Data ()
  var mActualSHA1 = Data ()
  var mSizeInRepository : Int64 = 0
  var mRevisionInRepository : Int? = nil
  var mEnumLibraryDownloadAction = EnumLibraryDownloadAction.kLibraryDownloadActionNone
  dynamic var mActionName = kNoInfo
  var mSession : Foundation.URLSession? = nil

  //····················································································································

  init (relativePath : String) {
    mRelativePath = relativePath
    super.init ()
    noteObjectAllocation (self)
  }
  
  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  func defineUpdateAction () {
    if let revisionInRepository = mRevisionInRepository {
      if (revisionInRepository != mLocalRevision) || (mLocalSHA1 != mActualSHA1) {
        mEnumLibraryDownloadAction = EnumLibraryDownloadAction.kLibraryDownloadActionUpdate
        let fm = FileManager ()
        let destinationPath = temporaryDownloadDirectory () + "/" + mRelativePath
        if fm.fileExists (atPath: destinationPath) {
          mEnumLibraryDownloadAction = .kLibraryDownloadActionDownloaded
        }
      }else{
        mEnumLibraryDownloadAction = EnumLibraryDownloadAction.kLibraryDownloadActionNone
      }
    }else{
      mEnumLibraryDownloadAction = EnumLibraryDownloadAction.kLibraryDownloadActionDelete
    }
  //---
    switch mEnumLibraryDownloadAction {
    case .kLibraryDownloadActionNone : mActionName = "None"
    case .kLibraryDownloadActionUpdate : mActionName = "Download, update"
    case .kLibraryDownloadActionDelete : mActionName = "Delete"
    case .kLibraryDownloadActionDownloaded : mActionName = "Downloaded, update"
    case .kLibraryDownloading : mActionName = "Downloading…"
    case .kLibraryDownloadError : mActionName = "Error"
    }
  }

  //····················································································································

  func repository () -> String {
    var s = kNoInfo
    if let revisionInRepository = mRevisionInRepository {
      if mSizeInRepository >= (1 << 10) {
        s = "\(mSizeInRepository / (1 << 10)) KiB"
      }else{
        s = "\(mSizeInRepository) B"
      }
      s = "Rev. \(revisionInRepository) — " + s
    }
    return s
  }
  
  //····················································································································

  func local () -> String {
    var s = kNoInfo
    if let localRevision = mLocalRevision {
      s = "Rev. \(localRevision)"
      if mLocalSHA1 != mActualSHA1 {
        s += " — modified"
      }
    }
    return s
  }
  
  //····················································································································

  func launchDownload () {
    if LOG_LIBRARY_UPDATES {
      NSLog ("\(#function)")
    }
    let remotePath = "http://canarilibrary.rts-software.org/svn/v2/" + mRelativePath
    // NSLog ("remotePath '%@'", remotePath)
    if let url = URL (string:remotePath) {
      let request = URLRequest (
        url: url,
        cachePolicy:.reloadIgnoringLocalCacheData,
        timeoutInterval:60.0
      )
      let sessionConfiguration = URLSessionConfiguration.default 
      let session = Foundation.URLSession (
        configuration:sessionConfiguration,
        delegate:self,
        delegateQueue:nil
      )
      mSession = session
      mEnumLibraryDownloadAction = .kLibraryDownloading
      let sessionTask = session.downloadTask (with: request)
      sessionTask.resume ()
    }
  }
  
  //····················································································································

  func urlSession (_ session: Foundation.URLSession, // NSURLSessionTaskDelegate method
                   task : URLSessionTask,
                   didReceive challenge: URLAuthenticationChallenge,
                   completionHandler: @escaping (Foundation.URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    if LOG_LIBRARY_UPDATES {
      NSLog ("\(#function)")
    }
    if challenge.previousFailureCount == 0 {
      let newCredential = URLCredential (
        user:"anonymous",
        password:"",
        persistence:URLCredential.Persistence.none
      )
      completionHandler (.useCredential, newCredential)
    }else{
      completionHandler (.cancelAuthenticationChallenge, nil)
    }
  }

  //····················································································································

  func urlSession (_ session: Foundation.URLSession,
                   task: URLSessionTask,
                   didCompleteWithError possibleError: Error?) {
    if LOG_LIBRARY_UPDATES {
      NSLog ("\(#function)")
    }
    if let error = possibleError {
      DispatchQueue.main.async  {
        self.mEnumLibraryDownloadAction = .kLibraryDownloadError
        launchElementDownload (error)
      }
    }
  }
  
  //····················································································································

  func urlSession (_ session: Foundation.URLSession,
                   didBecomeInvalidWithError possibleError: Error?) {
    if LOG_LIBRARY_UPDATES {
      NSLog ("\(#function)")
    }
    if let error = possibleError {
      DispatchQueue.main.async  {
        self.mEnumLibraryDownloadAction = .kLibraryDownloadError
        launchElementDownload (error)
      }
    }
  }
  
  //····················································································································

  func URLSession(_ session: Foundation.URLSession, // NSURLSessionConfiguration method
                  downloadTask: URLSessionDownloadTask,
                  didWriteData bytesWritten: Int64,
                  totalBytesWritten: Int64,
                  totalBytesExpectedToWrite: Int64) {
    if LOG_LIBRARY_UPDATES {
      NSLog ("totalBytesWritten \(totalBytesWritten) for \(mRelativePath)")
    }
    DispatchQueue.main.async  {
      self.mActionName = "Downloading — \((totalBytesWritten * 100) / self.mSizeInRepository)%"
    }
  }
  
  //····················································································································

  func URLSession (_ session: Foundation.URLSession,  // NSURLSessionConfiguration method
                   downloadTask: URLSessionDownloadTask,
                   didFinishDownloadingToURL location: URL) {
    if LOG_LIBRARY_UPDATES {
      NSLog ("\(#function)")
    }
    mSession?.finishTasksAndInvalidate ()
    mSession = nil
    switch mEnumLibraryDownloadAction {
    case .kLibraryDownloading :
      let fm = FileManager ()
      do{
        let temporaryURL = URL (fileURLWithPath:temporaryDownloadDirectory () + "/" + mRelativePath)
        let temporaryDirectoryURL = temporaryURL.deletingLastPathComponent ()
        if !fm.fileExists (atPath: temporaryDirectoryURL.path) {
          try fm.createDirectory (atPath: temporaryDirectoryURL.path, withIntermediateDirectories:true, attributes:nil)
        }
        try fm.moveItem (atPath:location.path, toPath:temporaryURL.path)
        DispatchQueue.main.async  {
          self.mEnumLibraryDownloadAction = .kLibraryDownloadActionDownloaded
          launchElementDownload (nil)
        }
      }catch let error {
        DispatchQueue.main.async  {
          self.mEnumLibraryDownloadAction = .kLibraryDownloadError
          launchElementDownload (error)
        }
      }
    default :
      break
    }
  }
  
  //····················································································································

  func cancelDownloading () {
    if let session = mSession {
      session.invalidateAndCancel ()
      mSession = nil
    }
  }
  
  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   P E R F O R M    L I B R A R Y    U P D A T E                                                                     *
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func presentLibraryUpdateDialog (_ cumulativeSize : Int64,
                                         actionArray : [PMCanariLibraryFileDescriptor],
                                         libraryPLIST : NSMutableDictionary) {
  if LOG_LIBRARY_UPDATES {
    NSLog ("\(#function)")
  }
  // NSLog ("%d actions", actionArray.count)
//--- Perform library update in main thread
  DispatchQueue.main.async  {
  //--- Hide library checking window
    gLibraryUpdateWindow?.orderOut (nil)
  //--- Configure informative text in library update window
    if actionArray.count == 1 {
      g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "1 element to update"
   }else{
      g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "\(actionArray.count) elements to update"
    }
  //--- Configure progress indicator in library update window
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.minValue = 0.0
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.maxValue = Double (cumulativeSize)
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.doubleValue = 0.0
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.isIndeterminate = false
  //--- Configure table view in library update window
    gCanariLibraryUpdateController = PMCanariLibraryUpdateController (
      actionArray:actionArray,
      libraryPLIST:libraryPLIST
    )
    gCanariLibraryUpdateController.bind ()
  //--- Enable update button
    g_Preferences?.mUpDateLibraryMenuItemInCanariMenu?.isEnabled = true
  //--- Show library update window
    g_Preferences?.mLibraryUpdateWindow?.makeKeyAndOrderFront (nil)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private var gCanariLibraryUpdateController = PMCanariLibraryUpdateController (
  actionArray : [PMCanariLibraryFileDescriptor] (),
  libraryPLIST : NSMutableDictionary ()
)

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class PMCanariLibraryUpdateController : NSObject, EBUserClassNameProtocol {
   let mPersistentActionArray : [PMCanariLibraryFileDescriptor]
   let mLibraryPLIST : NSMutableDictionary
   let mArrayController = NSArrayController ()

   var mCurrentActionArray : [PMCanariLibraryFileDescriptor]
   var mParallelActionCount = 0
   var mPossibleError : Error? = nil
  
  //····················································································································

  init (actionArray : [PMCanariLibraryFileDescriptor], libraryPLIST : NSMutableDictionary) {
    mCurrentActionArray = actionArray
    mPersistentActionArray = actionArray
    mLibraryPLIST = libraryPLIST
    super.init ()
    noteObjectAllocation (self)
  }
  
  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  func bind () {
    if let tableView = g_Preferences?.mTableViewInLibraryUpdateWindow {
      tableView.tableColumn(withIdentifier: "name")?.bind (
        "value",
        to:mArrayController,
        withKeyPath:"arrangedObjects.mRelativePath",
        options:nil
      )
      tableView.tableColumn(withIdentifier: "action")?.bind (
        "value",
        to:mArrayController,
        withKeyPath:"arrangedObjects.mActionName",
        options:nil
      )
      tableView.tableColumn(withIdentifier: "repository")?.bind (
        "value",
        to:mArrayController,
        withKeyPath:"arrangedObjects.repository",
        options:nil
      )
      tableView.tableColumn(withIdentifier: "local")?.bind (
        "value",
        to:mArrayController,
        withKeyPath:"arrangedObjects.local",
        options:nil
      )
      mArrayController.content = gCanariLibraryUpdateController.mCurrentActionArray
    }
  }
  
  //····················································································································

  func unbind () { //--- Remove bindings
    if let tableView = g_Preferences?.mTableViewInLibraryUpdateWindow {
      tableView.tableColumn(withIdentifier: "name")?.unbind ("value")
      tableView.tableColumn(withIdentifier: "action")?.unbind ("value")
      tableView.tableColumn(withIdentifier: "repository")?.unbind ("value")
      tableView.tableColumn(withIdentifier: "local")?.unbind ("value")
      mArrayController.content = nil
    }
  }

  //····················································································································
  // http://stackoverflow.com/questions/26291005/replacement-of-protocolprotocol-name-in-swift

  //····················································································································
  
//  func setAuthorization (_ authorization : AuthorizationRef) {
//    mPossibleAuthorization = authorization
//    connection.interruptionHandler = self.interruptionHandler
//    connection.invalidationHandler = self.invalidationHandler
//    connection.remoteObjectInterface = NSXPCInterface (with:PMLibraryUpdaterServerProtocol.self)
//    connection.exportedInterface = NSXPCInterface (with:PMLibraryUpdaterClientProtocol.self)
//    connection.exportedObject = self
//    connection.resume () ;
//    sendLibrary ()
//  }
 
  //····················································································································
 
//  func sendLibrary () {
//    if let proxy = mConnection?.remoteObjectProxy as? PMLibraryUpdaterServerProtocol {
//      proxy.defineLibraryPLIST (mLibraryPLIST)
//    }
//  }

  //····················································································································

  func interruptionHandler () {
    if LOG_LIBRARY_UPDATES {
      NSLog ("\(#function)")
    }
    sendTerminateToHelperTool ()
  }

  //····················································································································

  func invalidationHandler () {
    if LOG_LIBRARY_UPDATES {
      NSLog ("\(#function)")
    }
    sendTerminateToHelperTool ()
  }

  //····················································································································

  fileprivate func writeFile (sha1 inSHA1 : Data,
                              revisionInRepository inRevisionInRepository : Int,
                              fromTemporaryPath inTemporaryPath : String,
                              atRelativePath inRelativePath : String) {
     if LOG_LIBRARY_UPDATES {
      NSLog ("\(#function)")
    }
    if mPossibleError == nil {
      do{
        let fm = FileManager ()
        let destinationURL = URL (fileURLWithPath:systemLibraryPath () + "/" + inRelativePath)
        let destinationDirectoryURL = destinationURL.deletingLastPathComponent ()
        if !fm.fileExists(atPath: destinationDirectoryURL.path) {
          if LOG_LIBRARY_UPDATES {
            NSLog ("Create dir '\(destinationDirectoryURL.path)'")
          }
          try fm.createDirectory (atPath:destinationDirectoryURL.path, withIntermediateDirectories:true, attributes:nil)
        }else if fm.fileExists (atPath: destinationURL.path) {
          try fm.removeItem (atPath:destinationURL.path)
        }
        let sourceURL = URL (fileURLWithPath:inTemporaryPath)
        try fm.moveItem (atPath:sourceURL.path, toPath:destinationURL.path)
        let descriptorForLocalPlist : [String : AnyObject] = [
          "revision" : NSNumber (value:inRevisionInRepository),
          "sha1" : inSHA1 as AnyObject
        ]
        mLibraryPLIST.setObject (descriptorForLocalPlist, forKey:inRelativePath as NSCopying)
      }catch let error {
        mPossibleError = error
        if LOG_LIBRARY_UPDATES {
          NSLog ("ERROR")
        }
      }
    }
  }
  
  //····················································································································

  fileprivate func deleteFileAtRelativePath (_ inRelativePath : String) {
    if LOG_LIBRARY_UPDATES {
      NSLog ("\(#function)")
    }
    let destinationPath = systemLibraryPath () + "/" + inRelativePath
    let fm = FileManager ()
    do{
      try fm.removeItem (atPath: destinationPath)
      mLibraryPLIST.removeObject (forKey: inRelativePath)
    }catch let error {
      mPossibleError = error
    }
  }

  //····················································································································

  fileprivate func writePLISTFile () {
    if LOG_LIBRARY_UPDATES {
      NSLog ("\(#function)")
    }
    let plistFilePath = systemLibraryPath () + "/" + libraryDescriptionPLISTfilename ()
    let ok = mLibraryPLIST.write (toFile: plistFilePath, atomically: true)
    if (ok) {
      let possibleError = deleteOrphanDirectories ()
      if let error = possibleError {
        mPossibleError = error
      }
    }else{
      let dictionary = [
        NSLocalizedDescriptionKey : "Cannot write '\(libraryDescriptionPLISTfilename ())' file"
      ]
      let error = NSError (
        domain:"PMError",
        code:1,
        userInfo:dictionary
      )
      mPossibleError = error
    }
  }

  //····················································································································

  private func deleteOrphanDirectories () -> Error? {
    if LOG_LIBRARY_UPDATES {
      NSLog ("\(#function)")
    }
    let fm = FileManager ()
    var possibleError : Error? = nil
    do{
      let currentLibraryContents = try fm.subpathsOfDirectory (atPath: systemLibraryPath ())
      var directoryArray = [String] ()
      for relativePath in currentLibraryContents {
        let fullPath = systemLibraryPath () + "/" + relativePath
        var isDirectory : ObjCBool = false ;
        fm.fileExists (atPath: fullPath, isDirectory:&isDirectory)
        if (isDirectory.boolValue) {
          directoryArray.append (fullPath)
        }
      }
      directoryArray.sort ()
      if LOG_LIBRARY_UPDATES {
        NSLog ("directories to delete '\(directoryArray.description)")
      }
      var i=directoryArray.count-1
      while i>=0 {
        let fullPath = directoryArray [i]
        var currentDirectoryContents = try fm.contentsOfDirectory (atPath: fullPath)
      //--- Remove .DS_Store files
        var j=0
        while j<currentDirectoryContents.count {
          let s = currentDirectoryContents [j]
          if s == ".DS_Store" {
            currentDirectoryContents.remove (at: j)
            j -= 1
          }
          j += 1
        }
        if (currentDirectoryContents.count == 0) {
          if LOG_LIBRARY_UPDATES {
            NSLog ("delete orphean at '\(fullPath)")
          }
          try fm.removeItem (atPath: fullPath)
        }
        i -= 1
      }
    }catch let error {
      possibleError = error
    }
    return possibleError
  }

  //····················································································································

  func helperToolSendsError (_ inError : Error) {
    if LOG_LIBRARY_UPDATES {
      NSLog ("\(#function)")
    }
    mPossibleError = inError
    sendTerminateToHelperTool ()
  }

  //····················································································································

  func helperToolSendsJobCompleted () {
    if LOG_LIBRARY_UPDATES {
      NSLog ("\(#function)")
    }
    sendTerminateToHelperTool ()
  }

  //····················································································································

  func sendTerminateToHelperTool () {
    if LOG_LIBRARY_UPDATES {
      NSLog ("\(#function)")
    }
  }
  
  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func cleanLibraryUpdate () {
  if LOG_LIBRARY_UPDATES {
    NSLog ("\(#function)")
  }
//--- Hide library update window
  g_Preferences?.cancelDownloadElementFromRepository ()
//---
  gCanariLibraryUpdateController.unbind ()
  gCanariLibraryUpdateController = PMCanariLibraryUpdateController (
    actionArray : [PMCanariLibraryFileDescriptor] (),
    libraryPLIST : NSMutableDictionary ()
  )
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let parallelDownloadCount = 8

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func startLibraryUpdate () {
  if LOG_LIBRARY_UPDATES {
    NSLog ("\(#function)")
  }
//--- Update UI
  g_Preferences?.mUpDateButtonInLibraryUpdateWindow?.isEnabled = false
//--- Launch parallel downloads
  gCanariLibraryUpdateController.mParallelActionCount = parallelDownloadCount
  for _ in 1...parallelDownloadCount { // For Making downloads in parallel
    launchElementDownload (nil)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func launchElementDownload (_ possibleError : Error?) {
  if LOG_LIBRARY_UPDATES {
    NSLog ("\(#function)")
  }
//--- Error ?
  if let error = possibleError, gCanariLibraryUpdateController.mPossibleError == nil {
    gCanariLibraryUpdateController.mPossibleError = error
    cancelLibraryUpdate ()
  }
  
  var nothingToDo = true
  var i = 0
  while (i<gCanariLibraryUpdateController.mCurrentActionArray.count) && nothingToDo && (gCanariLibraryUpdateController.mPossibleError == nil) {
    let descriptor = gCanariLibraryUpdateController.mCurrentActionArray [i]
    // NSLog ("\(i) isDownloading \(descriptor.isDownloading ())")
    switch descriptor.mEnumLibraryDownloadAction {
    case .kLibraryDownloadActionUpdate :
      descriptor.launchDownload ()
      nothingToDo = false
    case .kLibraryDownloadError, .kLibraryDownloadActionDownloaded :
      gCanariLibraryUpdateController.mCurrentActionArray.remove (at: i)
      i -= 1
      gCanariLibraryUpdateController.mArrayController.content = gCanariLibraryUpdateController.mCurrentActionArray
      g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.doubleValue += Double (descriptor.mSizeInRepository + ACCESS_EQ_SIZE_FOR_PROGRESS_INDICATOR)
      if gCanariLibraryUpdateController.mCurrentActionArray.count == 1 {
        g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "1 element to update"
      }else{
        g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "\(gCanariLibraryUpdateController.mCurrentActionArray.count) elements to update"
      }
    default :
      break
    }
    i += 1
  }
  if nothingToDo {
    gCanariLibraryUpdateController.mParallelActionCount -= 1
  }
  if gCanariLibraryUpdateController.mParallelActionCount == 0 {
  //--- Error or ok ?
    if let error = gCanariLibraryUpdateController.mPossibleError {
      NSApp.presentError (error)
      cleanLibraryUpdate ()
    }else{
      commitUpdatesInFileSystem ()
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func cancelLibraryUpdate () {
  if LOG_LIBRARY_UPDATES {
    NSLog ("\(#function)")
  }
//--- The button is inactived during download
  if let button = g_Preferences?.mUpDateButtonInLibraryUpdateWindow, !button.isEnabled {
  //--- Cancel current downloadings
    for descriptor in gCanariLibraryUpdateController.mCurrentActionArray {
      descriptor.cancelDownloading ()
    }
  //--- Stop helper tool
    gCanariLibraryUpdateController.sendTerminateToHelperTool ()
  }else{ // Download is not started
    cleanLibraryUpdate ()
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   C O M M I T    U P D A T E S   I N   F I L E    S Y S T E M                                                       *
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func commitUpdatesInFileSystem () {
  if LOG_LIBRARY_UPDATES {
    NSLog ("\(#function), gCanariLibraryUpdateController.mPersistentActionArray \(gCanariLibraryUpdateController.mPersistentActionArray.count)")
  }
  g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "Commit updates…"
  
  let fm = FileManager ()
  for descriptor in gCanariLibraryUpdateController.mPersistentActionArray {
    switch descriptor.mEnumLibraryDownloadAction {
    case .kLibraryDownloadActionDelete :
      if LOG_LIBRARY_UPDATES {
        NSLog ("\(#function), deleteFileAtRelativePath '\(descriptor.mRelativePath)'")
      }
      gCanariLibraryUpdateController.deleteFileAtRelativePath (descriptor.mRelativePath)
    case .kLibraryDownloadActionUpdate, .kLibraryDownloadActionDownloaded :
      let temporaryPath = temporaryDownloadDirectory () + "/" + descriptor.mRelativePath
      let possibleContents : Data? = fm.contents (atPath: temporaryPath)
      if let contents = possibleContents {
        gCanariLibraryUpdateController.writeFile (
          sha1: sha1 (contents),
          revisionInRepository:descriptor.mRevisionInRepository!,
          fromTemporaryPath:temporaryPath,
          atRelativePath:descriptor.mRelativePath
        )
      }else{
        let error = canariError ("Cannot read file", informativeText: "File is " + temporaryPath)
        gCanariLibraryUpdateController.mPossibleError = error
      }
    default :
      break
    }
  }
//--- Error ?
  if let error = gCanariLibraryUpdateController.mPossibleError {
    NSApp.presentError (error)
    cleanLibraryUpdate ()
  }else{
    if LOG_LIBRARY_UPDATES {
      NSLog ("\(#function), copy PLIST '\(libraryDescriptionPLISTfilename ())'")
    }
    gCanariLibraryUpdateController.writePLISTFile ()
    if let window = g_Preferences?.mLibraryUpdateWindow {
      let alert = NSAlert ()
      alert.messageText = "Library has been updated."
      alert.beginSheetModal (for: window, completionHandler: { (NSModalResponse) in
        cleanLibraryUpdate ()
      })
    }else{
      cleanLibraryUpdate ()
    }
  }
//---
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// http://stackoverflow.com/questions/25761344/how-to-crypt-string-to-sha1-with-swift

private func sha1 (_ data : Data) -> Data {
  var digest = [UInt8] (repeating: 0, count:Int (CC_SHA1_DIGEST_LENGTH))
  data.withUnsafeBytes { _ = CC_SHA1 ($0, CC_LONG (data.count), &digest) }
  return Data (digest)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

