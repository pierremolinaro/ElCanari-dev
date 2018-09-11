//
//  bz2-uncompress.c
//  eb-document-analyzer
//
//  Created by Pierre Molinaro on 08/07/2015.
//  Copyright © 2015 Pierre Molinaro. All rights reserved.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

#import "bz2-uncompress.h"
#include <bzlib.h>

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

// See http://www.bzip.org/1.0.3/html/libprog.html

// http://stackoverflow.com/questions/30815806/swift-2-ios-9-libz-dylib-not-found

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

NSData * bz2DecompressedData (NSData * inCompressedData) {
  const NSUInteger compressedDataLength = inCompressedData.length ;
  char * compressedDataPointer = (char *) inCompressedData.bytes ;
  NSUInteger estimedDecompressedDataLength = compressedDataLength * 10 ;
  NSInteger error ;
  UInt32 decompressedDataLength ;
  char * decompressedBuffer = NULL ;
  do{
    free (decompressedBuffer) ;
    //NSLog (@"estimedDecompressedDataLength %u", estimedDecompressedDataLength) ;
    decompressedBuffer = malloc (estimedDecompressedDataLength) ;
    decompressedDataLength = (UInt32) estimedDecompressedDataLength ;
    error = BZ2_bzBuffToBuffDecompress (decompressedBuffer, & decompressedDataLength,
                                        compressedDataPointer, (UInt32) compressedDataLength,
                                        0, 0) ;
    estimedDecompressedDataLength *= 2 ;
  }while (error == BZ_OUTBUFF_FULL) ;
  NSData * result = nil ;
  if (error == BZ_OK) {
    result = [NSData dataWithBytes:decompressedBuffer length:decompressedDataLength] ;
  }
/*  if (outErrorPtr != NULL) {
    * outErrorPtr = error ;
  } */
  free (decompressedBuffer) ; decompressedBuffer = NULL ;
  return result ;
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
