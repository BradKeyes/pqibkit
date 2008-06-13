/**
 * \file PQTitlelessKeyWindow.h
 *
 * Copyright plasq LLC 2007. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

/**
 * A necessary subclass for titleless windows that can become key
 *
 * \ingroup Views
 */
@interface PQTitlelessKeyWindow : NSWindow {

}

// Ensures the window is entirely on screen and aligned with the view
- (void)displayNextToView:(NSView*)view;

@end

