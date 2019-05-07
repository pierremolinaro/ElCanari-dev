//
//  NSObject+swizzling_NSDocumentController.m
//  ElCanari
//
//  Created by Pierre Molinaro on 07/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@interface NSDocumentController (MySwizzlingNSDocumentController)

@end

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@implementation NSDocumentController (MySwizzlingNSDocumentController)

  //····················································································································

  - (void) removeDocument_swizzling: (NSDocument *) document {
    NSLog (@"RemoveDocument: %@", self) ;
    [self removeDocument_swizzling: document] ;
  }

  //····················································································································

  + (void) load {
    NSLog (@"MySwizzlingNSDocumentController load") ;
    Method original = class_getInstanceMethod (self, @selector (removeDocument:));
    Method swizzled = class_getInstanceMethod (self, @selector (removeDocument_swizzling:));
    method_exchangeImplementations (original, swizzled) ;
  }

  //····················································································································

@end

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
