import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct DataScanner {
  private var mData : NSData
  private var mTextView : NSTextView
  private var mReadIndex : Int = 0
  private var mReadOk : Bool = true
  private var mExpectedBytes : Array<UInt8> = []

  //····················································································································

  init (data: NSData, textView : NSTextView) {
    mData = data
    mTextView = textView
  }

  //····················································································································

  func printAddress () {
    mTextView.appendMessageString (String (format:"%04X %04X:", mReadIndex >> 16, mReadIndex & 0xFFFF))
  }

  //····················································································································

  mutating func ignoreBytes (inLengthToIgnore : Int) {
    if mReadOk {
      mReadIndex += inLengthToIgnore ;
    }
  }

  //····················································································································
  // http://stackoverflow.com/questions/24067085/pointers-pointer-arithmetic-and-raw-data-in-swift

  mutating func testAcceptByte (inByte : UInt8, comment : String) -> Bool {
    var result = mReadOk
    if result {
      if mReadIndex >= mData.length {
         NSLog ("Read beyond end of data")
         mReadOk = false
       }else{
        let byteAsData = mData.subdataWithRange (NSMakeRange(mReadIndex, sizeof(UInt8))).bytes
        let byte = UnsafePointer<UInt8> (byteAsData).memory
        result = byte == inByte
        if result {
          printAddress ()
          mTextView.appendByte (inByte)
          mTextView.appendMessageString (" | \(comment)\n")
          mReadIndex += 1
          mExpectedBytes = []
        }else{
          mExpectedBytes.append (inByte)
        }
      }
    }
    return result ;
  }

  //····················································································································

  mutating func testAcceptFromByte (lowerBound: UInt8,
                                    upperBound: UInt8,
                                    inout value:UInt8) -> Bool {
    var result = mReadOk
    if result {
      if mReadIndex >= mData.length {
         NSLog ("Read beyond end of data")
         mReadOk = false
       }else{
        let byteAsData = mData.subdataWithRange (NSMakeRange(mReadIndex, sizeof(UInt8))).bytes
        let byte = UnsafePointer<UInt8> (byteAsData).memory
        result = (byte >= lowerBound) && (byte <= upperBound) ;
        if (result) {
          value = byte
          mReadIndex += 1
          mExpectedBytes = []
        }else{
          for i in lowerBound ..< upperBound + 1 {
            mExpectedBytes.append (i)
          }
        }
      }
    }
    return result ;
  }

  //····················································································································

  mutating func acceptRequiredByte (inByte : UInt8,
                                    comment : String) {
    printAddress ()
    if mReadOk {
      if mReadIndex >= mData.length {
         NSLog ("Read beyond end of data")
         mReadOk = false
      }else{
        let byteAsData = mData.subdataWithRange (NSMakeRange(mReadIndex, sizeof(UInt8))).bytes
        let byte = UnsafePointer<UInt8> (byteAsData).memory
        mTextView.appendMessageString (String (format:" %02X", byte))
        mTextView.appendMessageString (" | \(comment)\n")
        if (byte == inByte) {
          mReadIndex += 1
          mExpectedBytes = []
        }else{
          var message = ""
          for b in mExpectedBytes {
            message += String (format:"0x%02hhx, ", b)
            mTextView.appendMessageString (" | \(comment)\n")
          }
          mTextView.appendErrorString (String (format:"invalid current byte (0x%02X): expected bytes:%@0x%02x\n", byte, message, inByte))
          mReadOk = false
        }
      }
    }
  }

  //····················································································································

  mutating func parseByte () -> UInt8 {
    var result : UInt8 = 0
    if mReadOk {
      if mReadIndex >= mData.length {
         NSLog ("Read beyond end of data")
         mReadOk = false
       }else{
        let byteAsData = mData.subdataWithRange (NSMakeRange(mReadIndex, sizeof(UInt8))).bytes
        result = UnsafePointer<UInt8> (byteAsData).memory
        mReadIndex += 1
      }
    }
    return result
  }

  //····················································································································

  mutating func parseAutosizedUnsignedInteger (comment : String) -> UInt {
    printAddress ()
    var result : UInt = 0
    var shift : UInt = 0
    var loop = true
    while loop && mReadOk {
      if mReadIndex >= mData.length {
         NSLog ("Read beyond end of data")
         mReadOk = false
      }else{
        let byteAsData = mData.subdataWithRange (NSMakeRange(mReadIndex, sizeof(UInt8))).bytes
        let byte = UnsafePointer<UInt8> (byteAsData).memory
        mTextView.appendByte (byte)
        let w : UInt = UInt (byte) & 0x7F
        result |= (w << shift)
        shift += 7
        loop = (byte & 0x80) != 0
        mReadIndex += 1
      }
    }
    mTextView.appendMessageString (" | \(comment) (\(result))\n")
    return result ;
  }

  //····················································································································

  mutating func parseAutosizedData (lengthComment : String, dataComment:String) -> NSData {
    var result = NSData ()
    if mReadOk {
      let dataLength : Int = Int (parseAutosizedUnsignedInteger (lengthComment))
      if (mReadIndex + dataLength) >= mData.length {
        NSLog ("Read beyond end of data")
        mReadOk = false
      }else{
        printAddress ()
        result = mData.subdataWithRange (NSMakeRange (mReadIndex, dataLength))
        mTextView.appendMessageString (" ... | \(dataComment) (\(dataLength) bytes)\n")
        mReadIndex += dataLength
      }
    }
    return result ;
  }

  //····················································································································

  mutating func parseAutosizedString (comment : String) -> String {
    printAddress ()
    var result : String = ""
    var ptr = UnsafePointer<UInt8> (mData.bytes)
    ptr += mReadIndex
    var stringLength = 0
    var loop = true
    while loop && mReadOk {
      if (mReadIndex + stringLength) >= mData.length {
         mTextView.appendErrorString ("Read beyond end of data")
         mReadOk = false
      }else{
        mTextView.appendByte (ptr.memory)
        loop = ptr.memory != 0
        ptr += 1
        stringLength += 1
      }
    }
    if (mReadOk) {
      let d = mData.subdataWithRange (NSMakeRange (mReadIndex, stringLength-1))
      result = NSString (data:d, encoding: NSUTF8StringEncoding) as! String
      mReadIndex += stringLength
      mTextView.appendMessageString (" | \"" + result + "\": \(comment)\n")
    }
    return result
  }

  //····················································································································

  func ok () -> Bool {
    return mReadOk
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
