//
//  PQButtonTitleView.m
//  PlasqIBPalleteKit
//
//  Created by Mathieu Tozer on 27/07/07.
//  Copyright 2007 plasq. All rights reserved.
//

#import "PQButton.h"
#import "PQButtonBaseLayer.h"
#import "PQButtonTitleView.h"
#import <QuartzCore/QuartzCore.h> //this is were core animation comes from

@implementation PQButtonTitleView

//inactive
@synthesize inTitle;
@synthesize inOriginX, inOriginY, inToDuration;

// moused over
@synthesize moTitle;
@synthesize moOriginX, moOriginY, moToDuration;

// active - mouse down
@synthesize acTitle;
@synthesize acOriginX, acOriginY, acToDuration;

@synthesize rootButton;

+ (NSArray *)keypaths
{
	return [NSArray arrayWithObjects:
			@"inTitle", @"inOriginX", @"inOriginY", @"inToDuration",
			@"moTitle", @"moOriginX", @"moOriginY", @"moToDuration",
			@"acTitle", @"acOriginX", @"acOriginY", @"acToDuration",
			nil];
}

- (int)state
{
	return [[self.rootButton baseView] state];
}

- (void)registerToObserveState
{
	[self.rootButton addObserver:self forKeyPath:@"baseView.state" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
}

//used for setting the tracking rect

- (id)initWithCoder:(NSCoder *)coder 
{
    self = [super initWithCoder:coder];
    if ([coder allowsKeyedCoding]) {
		
		//inactive
		self.inTitle = [coder decodeObjectForKey:@"inTitle"];
		self.inOriginX = [coder decodeFloatForKey:@"inOriginX"];
		self.inOriginY = [coder decodeFloatForKey:@"inOriginY"];
		self.inToDuration = [coder decodeFloatForKey:@"inToDuration"];
		
		//mouse over
		self.moTitle = [coder decodeObjectForKey:@"moTitle"];
		self.moOriginX = [coder decodeFloatForKey:@"moOriginX"];
		self.moOriginY = [coder decodeFloatForKey:@"moOriginY"];
		self.moToDuration = [coder decodeFloatForKey:@"moToDuration"];
		
		//active
		self.acTitle = [coder decodeObjectForKey:@"acTitle"];
		self.acOriginX = [coder decodeFloatForKey:@"acOriginX"];
		self.acOriginY = [coder decodeFloatForKey:@"acOriginY"];
		self.acToDuration = [coder decodeFloatForKey:@"acToDuration"];
    }
	
	[self registerToObserveState];

	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder 
{
    [super encodeWithCoder:coder];
    if ([coder allowsKeyedCoding]) {
		//inactive
		[coder encodeFloat:self.inOriginX forKey:@"inOriginX"];
		[coder encodeFloat:self.inOriginY forKey:@"inOriginY"];
		[coder encodeObject:self.inTitle forKey:@"inTitle"];
		[coder encodeFloat:self.inToDuration forKey:@"inToDuration"];
		
		//mouse over
		[coder encodeFloat:self.moOriginX forKey:@"moOriginX"];
		[coder encodeFloat:self.moOriginY forKey:@"moOriginY"];
		[coder encodeObject:self.moTitle forKey:@"moTitle"];
		[coder encodeFloat:self.moToDuration forKey:@"moToDuration"];
		
		//active
		[coder encodeFloat:self.acOriginX forKey:@"acOriginX"];
		[coder encodeFloat:self.acOriginY forKey:@"acOriginY"];
		[coder encodeObject:self.acTitle forKey:@"acTitle"];
		[coder encodeFloat:self.acToDuration forKey:@"acToDuration"];
    }
	return;
}

//inactive
- (NSRect)inactiveRect
{
	NSAttributedString *str = self.inTitle;
	NSSize size = [str size];
	return NSMakeRect(self.inOriginX, self.inOriginY, size.width, size.height);
}

//mouse over
- (NSRect)mouseOverRect
{
	NSAttributedString *str = self.moTitle;
	NSSize size = [str size];
	return NSMakeRect(self.moOriginX, self.moOriginY, size.width, size.height);
}

//active
- (NSRect)activeRect
{
	NSAttributedString *str = self.acTitle;
	NSSize size = [str size];
	return NSMakeRect(self.acOriginX, self.acOriginY, size.width, size.height);
}

- (void)initialise
{
        // Initialization code here.
		self.inOriginX = 0.0;
		self.inOriginY = 0.0;
		self.inToDuration = 0.2;
		self.inTitle = [[NSAttributedString alloc] initWithString:@"inTitle"];
		
		self.moOriginX = 0.0;
		self.moOriginY = 0.0;
		self.moToDuration = 0.2;
		self.moTitle = [[NSAttributedString alloc] initWithString:@"moTitle"];
		
		self.acOriginX = 0.0;
		self.acOriginY = 0.0;
		self.acToDuration = 0.2;
		self.acTitle = [[NSAttributedString alloc] initWithString:@"acTitle"];
		
		self.bounds = CGRectMake(0.0, 0.0, 40.0, 40.0);
		self.needsDisplayOnBoundsChange = YES;
		self.truncationMode = kCATruncationStart;
		self.alignmentMode = kCAAlignmentCenter;
		[self registerToObserveState];
}

#pragma mark Drawing

static inline CGRect CGRectFromNSRect(NSRect nsRect) { return * (CGRect*)&nsRect; }


#pragma mark Inactive accessors

- (void)setInOriginX:(float)value
{
	inOriginX = value;
	self.frame = CGRectFromNSRect([self inactiveRect]);
}

- (void)setInOriginY:(float)value
{
//	self.state = kInactiveState;
	inOriginY = value;
	self.frame = CGRectFromNSRect([self inactiveRect]);
}

- (void)setInTitle:(NSAttributedString *)value
{
	if (inTitle != value) {
		[inTitle release];
		inTitle = [value retain];
	}
}

#pragma mark MouseOver accessors

- (void)setMoOriginX:(float)value
{
//	self.state = kMouseOverState;
	moOriginX = value;
	self.frame = CGRectFromNSRect([self mouseOverRect]);
}

- (void)setMoOriginY:(float)value
{
//	self.state = kMouseOverState;
	moOriginY = value;
	self.frame = CGRectFromNSRect([self mouseOverRect]);
}

- (void)setMoTitle:(NSAttributedString *)value
{
	if (moTitle != value) {
		[moTitle release];
		moTitle = [value retain];
	}
}

#pragma mark Active accessors

- (void)setAcOriginX:(float)value
{
//	self.state = kActiveState;
	acOriginX = value;
	self.frame = CGRectFromNSRect([self activeRect]);
}

- (void)setAcOriginY:(float)value
{
//	self.state = kActiveState;
	acOriginY = value;
	self.frame = CGRectFromNSRect([self activeRect]);
}

- (void)setAcTitle:(NSAttributedString *)value
{
	if (acTitle != value) {
		[acTitle release];
		acTitle = [value retain];
	}
}


static CGColorRef CGColorCreateFromNSColor (CGColorSpaceRef colorSpace, NSColor *color) {
	NSColor *deviceColor = [color colorUsingColorSpaceName:NSDeviceRGBColorSpace];
	
	float components[4];
	[deviceColor getRed: &components[0] green: &components[1] blue: &components[2] alpha: &components[3]];
	
	return CGColorCreate (colorSpace, components);
}

- (void)animateFrameChange
{
	[NSAnimationContext beginGrouping];
	if ([self state] == kInactiveState) {
		[[NSAnimationContext currentContext] setDuration:self.inToDuration];
		[self setFrame: CGRectFromNSRect(self.inactiveRect)];
	}
	if ([self state] == kMouseOverState) {
		[[NSAnimationContext currentContext] setDuration:self.moToDuration];
		[self setFrame: CGRectFromNSRect(self.mouseOverRect)];
	}
	if ([self state] == kActiveState) {
		[[NSAnimationContext currentContext] setDuration:self.acToDuration];
		[self setFrame: CGRectFromNSRect(self.activeRect)];
	}
	[NSAnimationContext endGrouping];
}

- (PQButtonBaseLayer *)baseView
{
	return [self.rootButton baseView];
}

#pragma mark Mousing
- (void)mouseDown:(NSEvent *)event
{
	[self.baseView mouseDown:event];
}

- (void)mouseUp:(NSEvent *)event
{
//	self.state = kInactiveState;
//	[self animateFrameChange];
	[self.baseView mouseUp:event];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	self.zPosition = 100; //make sure it's on top!
    if ([keyPath isEqualToString:@"baseView.state"]) {
		if ([self state] == kInactiveState) {
			self.string = self.inTitle;
			self.frame = CGRectFromNSRect([self inactiveRect]);
		}
		if ([self state] == kMouseOverState) {
			self.string = self.moTitle;
			self.frame = CGRectFromNSRect([self mouseOverRect]);
		}
		if ([self state] == kActiveState) {
			self.string = self.acTitle;
			self.frame = CGRectFromNSRect([self activeRect]);
		}
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

@end
