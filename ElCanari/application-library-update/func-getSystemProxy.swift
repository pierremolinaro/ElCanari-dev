//
//  func-getSystemProxy.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/01/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import SystemConfiguration

//--------------------------------------------------------------------------------------------------
// https://stackoverflow.com/questions/13276195/mac-osx-how-can-i-grab-proxy-configuration-using-cocoa-or-even-pure-c-function
//--------------------------------------------------------------------------------------------------

extension Preferences {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   func getSystemProxy () -> [String] {
    var proxyOption = [String] ()
    if let proxies : [String : Any] = SCDynamicStoreCopyProxies (nil) as? [String : Any] {
      let possibleHTTPSProxy = proxies ["HTTPSProxy"]
      let possibleHTTPSEnable = proxies ["HTTPSEnable"]
      let possibleHTTPSPort = proxies ["HTTPSPort"]
      if let HTTPSEnable : Int = possibleHTTPSEnable as? Int, HTTPSEnable == 1, let HTTPSProxy = possibleHTTPSProxy {
        var proxySetting : String = "\(HTTPSProxy)"
        if let HTTPSPort = possibleHTTPSPort {
          proxySetting += ":" + "\(HTTPSPort)"
        }
        proxyOption = ["--proxy", proxySetting]
      }
    }else{
      self.mLibraryUpdateLogTextView.appendWarningString ("  SCDynamicStoreCopyProxies returns nil\n")
    }
    self.mLibraryUpdateLogTextView.appendSuccessString ("  Proxy \(proxyOption)\n")
    return proxyOption
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
