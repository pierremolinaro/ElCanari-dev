//
//  NSView-swizzling.m
//  ElCanari
//
//  Created by Pierre Molinaro on 22/04/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@interface NSView (MySwizzlingNSView)

@end

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@implementation NSView (MySwizzlingNSView)

  //····················································································································

  - (void) setNeedsDisplay_swizzling: (BOOL) needsDisplay {
    if (![[NSThread currentThread] isMainThread]) {
      NSLog (@"setNeedsDisplay NOT in main thread for %@", self) ;
    }
    [self setNeedsDisplay_swizzling: needsDisplay] ;
  }

  //····················································································································

  - (void) setNeedsDisplayInRect_swizzling: (NSRect) rect {
    if (![[NSThread currentThread] isMainThread]) {
      NSLog (@"setNeedsDisplayInRect NOT in main thread for %@", self) ;
    }
    [self setNeedsDisplayInRect_swizzling: rect] ;
  }

  //····················································································································

  + (void) load {
    NSLog (@"MySwizzlingNSView load") ;
    Method original = class_getInstanceMethod (self, @selector (setNeedsDisplay:));
    Method swizzled = class_getInstanceMethod (self, @selector (setNeedsDisplay_swizzling:));
    method_exchangeImplementations (original, swizzled) ;
    original = class_getInstanceMethod (self, @selector (setNeedsDisplayInRect:));
    swizzled = class_getInstanceMethod (self, @selector (setNeedsDisplayInRect_swizzling:));
    method_exchangeImplementations (original, swizzled) ;
  }

  //····················································································································

@end

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
