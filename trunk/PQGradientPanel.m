//
//  PQGradientPanel.m
//  Comic Life
//
//  Created by Robert Grant on 8/26/07.
//  Copyright 2007 plasq LLC. All rights reserved.
//

#import "PQGradientPanel.h"


static PQGradientPanel* sharedGradientPanel = nil;

@implementation PQGradientPanelAnchor

- (PQGradientPanel*)panel
{
	return _panel;
}

@end

@implementation PQGradientPanel

/** load the gradient panel if it's not already via the helper object */
+ (PQGradientPanel *)sharedGradientPanel
{
	if (!sharedGradientPanel) {
		PQGradientPanelAnchor* anchor = [[[[PQGradientPanelAnchor alloc] init] retain] autorelease];
		if (![NSBundle loadNibNamed: @"PQGradientPanel" owner: anchor]) {
			NSLog(@"can't load PQGradientPanel nib!");
		}
		sharedGradientPanel = [anchor panel];
	}
	return sharedGradientPanel;
}

- (void)setContinuous:(BOOL)flag
{
	_continuous = flag;
}

- (BOOL)isContinuous
{
	return _continuous;
}

- (void)setGradientWell:(PQGradientWell*)well
{
	// If we're already connected to a gradient well deactivate that one
	if (_gradientWell) {
		[_gradientWell removeObserver: self forKeyPath: @"gradient"];
		[_gradientWell deactivate];
	}
	_gradientWell = well;
	if (_gradientWell) {
		// Make sure our controls know about the new gradient
		[self setGradient: [_gradientWell gradient]];
		[_gradientWell addObserver: self forKeyPath: @"gradient" options: NSKeyValueObservingOptionNew context: nil];
	}
}

- (void)setGradient:(PQGradient*)gradient
{
	// If we're being told to set our gradient to our gradient - bail.
	if (gradient == _gradient) return;
	
	// Work with a copy of the gradient
	_gradient = [gradient copy];
	
	// Tell everyone about it - could possibly be redone with bindings?
	[_colorEditor setGradient: _gradient];
	[_positionEditor setGradient: _gradient];
	[_segmentCtrl setSelectedSegment: _gradient.type];
}

- (PQGradient*)gradient
{
	return _gradient;
}

- (void)setAction:(SEL)aSelector
{
	_action = aSelector;
}

- (void)setTarget:(id)anObject
{
	_target = anObject;
}

- (void)_updateTarget
{
	// Tell the configured target-action thatt the gradient has changed
	[_target performSelector: _action withObject: self];
}

- (void)gradientColorEditorDidChangeGradient:(PQGradientColorEditor*)editor
{
	// Keep positionEditor and target-action synced
	[_positionEditor setNeedsDisplay: YES];
	[self _updateTarget];
}

- (void)gradientPositionEditorDidChangeGradient:(PQGradientPositionEditor*)editor
{
	// Keep colorEditor and target-action synced
	[_colorEditor setNeedsDisplay: YES];
	[self _updateTarget];
}

- (IBAction)setType:(id)sender
{
	// User clicked on a different segment
	int type = [sender selectedSegment];
	_gradient.type = type;
	[_positionEditor setNeedsDisplay: YES];	
	[self _updateTarget];
}

- (void)close
{
	// If we get closed deactivate the connected well
	[self setGradientWell: nil];
	[super close];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString: @"gradient"]) {
		// the well got a new gradient - sync ourselves with it
		id newValue = [change objectForKey: NSKeyValueChangeNewKey];
		[self setGradient: newValue];
	}
}

// This feature will not be in the final app - it's purely to assist with creating gradients for the pop-up palette.
- (void)gradientSavePanelDidEnd:(NSSavePanel*)panel returnCode:(int)returnCode contextInfo:(void*)info
{
	if (returnCode == NSOKButton) {

		NSDictionary* plist = [self.gradient dictionary];
		NSURL* url = [panel URL];
		[plist writeToURL: url atomically: YES];

	}
}

- (IBAction)exportGradient:(id)sender
{
	NSSavePanel* savePanel = [NSSavePanel savePanel];
	[savePanel setRequiredFileType: @"gradient"];
	[savePanel beginSheetForDirectory: [[NSBundle mainBundle] bundlePath] file: @"New Gradient.gradient" modalForWindow: self modalDelegate: self didEndSelector: @selector(gradientSavePanelDidEnd:returnCode:contextInfo:) contextInfo: nil];
}

#pragma mark Toolbar support

static NSString* kGradientTypeItem = @"GradientTypeItem";
static NSString* kGradientSaveItem = @"GradientSaveItem";

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
	if ([itemIdentifier isEqualToString: kGradientTypeItem])
		return _typeCtrl;
	else if ([itemIdentifier isEqualToString: kGradientSaveItem])
		return _saveButton;
	return nil;
}

#pragma mark TODO - remove gradient saving from array before release.
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
	return [NSArray arrayWithObjects: kGradientTypeItem, NSToolbarFlexibleSpaceItemIdentifier, kGradientSaveItem, nil];
}

@end
