//
//  PQPrettyView.m
//  PQIBKit
//
//  Created by Mathieu Tozer on 15/03/08.
//  Copyright 2008 plasq. All rights reserved.
//

#import "PQPrettyView.h"
#import "PQPrettyViewStateMachine.h"
#import "PQPrettyViewState.h"
#import "PQGradient.h"
#import "NSBezierPath+PQAdditions.h"
#import "Util.h"
#import "PQImage.h"
#import "GeomUtils.h"
#import <QuartzCore/QuartzCore.h>

@implementation PQPrettyView

@synthesize stateMachine = _stateMachine;
@synthesize initialState = _initialState;
@synthesize isFadingOut = _isFadingOut;
@synthesize icon = _icon;
@synthesize stateBeforeAnimation = _stateBeforeAnimation;

+ (void)initialize
{
	[self exposeBinding:@"icon"];
}

- (void)commonInit
{
	_timerForNextFade = nil;
	_isFadingOut = NO;
}

- (PQPrettyViewState *)firstState
{
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"isFirstState == YES"];
	return (PQPrettyViewState *)[[[[self stateMachine] states] filteredArrayUsingPredicate:pred] lastObject];
}

- (id) initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if (self != nil) {
		self.stateMachine = [[PQPrettyViewStateMachine alloc] initWithOwner:self];
	}
	[self setStateByName:[self firstState].stateName];
	return self;
}

+ (NSArray *)keypaths
{
	return [NSArray arrayWithObjects:@"stateMachine", @"initialState", nil];
}

- (id<PQPrettyViewDrawingDelegate>)delegate
{
	return delegate;
}

- (void)drawIcon:(PQPrettyViewState *)state
{
	//ask the delegate for an icon
	id del = [self delegate];
	if ([del respondsToSelector:@selector(drawIconInView:)]) {
		[del drawIconInView:self];
		return;
	}
	
	id icon = nil;
	NSString *iconName = state.iconName;
	if (iconName) {
		icon = (NSImage *)[NSImage imageNamed:iconName];
		NSRect imgRect = [self frame];
		imgRect.origin = NSZeroPoint;
		[(NSImage *)icon drawInRect:imgRect fromRect:NSZeroRect operation:state.iconCompositingOp fraction:1.0];
		return;
	}
	
	//check the icon binding
	id mainIcon = self.icon;
	NSRect mainIconRect = [self frame];
	mainIconRect.origin = NSMakePoint(state.iconOrigin.x, state.iconOrigin.y);
	if (mainIcon) {
		NSSize imageSize = [mainIcon size];
		NSRect fittedMainIconRect = PQFitRectInRect(NSMakeRect(0.0, 0.0, imageSize.width, imageSize.height), mainIconRect, NO);
		if (state.doesFloorIcon) fittedMainIconRect.origin.y = 0.0;
		
		if ([mainIcon class] == [PQImage class]) {			
			[(PQImage *)mainIcon drawInRect:fittedMainIconRect operation:state.iconCompositingOp fraction:1.0];
		} else if ([mainIcon class] == [NSImage class]) {
			[(NSImage *)mainIcon drawInRect:fittedMainIconRect fromRect:NSZeroRect operation:state.iconCompositingOp fraction:1.0];
		}
	}
	
	//nothing named that so look for an an icon NSImage
	(NSImage *)icon = (NSImage *)state.icon;
	if (icon) {
		NSSize imageSize = [icon size];
		NSRect fittedMainIconRect = PQFitRectInRect(NSMakeRect(state.iconOrigin.x,  state.iconOrigin.y, imageSize.width, imageSize.height), mainIconRect, NO);
		
		if (state.doesFloorIcon) fittedMainIconRect.origin.y = 0.0;
		[(NSImage *)icon drawInRect:fittedMainIconRect fromRect:NSZeroRect operation:state.iconCompositingOp fraction:1.0];
		return;
	}
	
}

- (PQPrettyViewState *)curState
{
	return (PQPrettyViewState*)self.stateMachine.currentState;
}

- (CATransform3D)transformsForState:(PQPrettyViewState *)state
{
	CATransform3D transform = CATransform3DMakeScale(state.scaleSX, state.scaleSY, state.scaleSZ);
	float radians = state.rotation * (M_PI / 180);
	transform = CATransform3DRotate(transform, radians, state.rotRX, state.rotRY, state.rotRZ);
	transform = CATransform3DTranslate(transform, state.transTX, state.transTY, state.transTZ);
	return transform;
}

#pragma mark Flipping

- (void)flipOverToShowView:(PQPrettyView *)aReverseView usingFlipStateNamed:(NSString *)stateName andTargetFlipStateNamed:(NSString *)targetFlipStateName;
{
	//first, make sure the views are in the right positions, on top of one another
	NSView *superView = [self superview];
	if ([aReverseView superview] != superView) {
		[aReverseView removeFromSuperview];
		[superView addSubview:reverseView positioned:NSWindowBelow relativeTo:self];		
	}
	[superView setWantsLayer:YES];
	//just set the value
	[self setStateByName:stateName];
	[reverseView setStateByName:targetFlipStateName];
}

- (IBAction)flipOverToShowReverseView:(id)sender
{
	//now we look at the pretty view states, and find ones that have the name flipToBack and flipToFront
	NSString *flipShowing= @"flipShowing";
	NSString *flipHidden = @"flipHidden";	
	[reverseView setFrame:self.frame];

	if (reverseView) {
		PQPrettyViewState *state = [self curState];
		if ([state.stateName isEqualToString:flipShowing]) {
			[self flipOverToShowView:reverseView usingFlipStateNamed:flipHidden andTargetFlipStateNamed:flipShowing];
		} else {
			[self flipOverToShowView:self usingFlipStateNamed:flipShowing andTargetFlipStateNamed:flipHidden];
		}
	}
}

// wait:1.0, sendLayer:bookLayer to:delegate, invokeState:trashBook

- (void)tileImage:(id)img inState:(PQPrettyViewState *)state
{
	NSRect bounds = [self bounds];
	//start at zeroPoint and move all the way up
	int x = 0;
	int y = 0;
	NSSize imgSize = [img size];
	
	for (y = 0; y <= bounds.size.height; y = y+imgSize.height) {
		for (x = 0; x <= bounds.size.width; x = x+imgSize.width) {
			NSRect drawRect = NSMakeRect(x, y, imgSize.width, imgSize.height);
			if ([img class] == [PQImage class]) {
				[(PQImage *)img drawInRect:drawRect operation:state.textureCompositingOp fraction:state.textureAlpha];	
			} else if ([img class] == [NSImage class]) {
				[(NSImage *)img drawInRect:drawRect fromRect:NSZeroRect operation:state.textureCompositingOp fraction:state.textureAlpha];
			}
		}
	}
}

- (void)drawTexture:(PQPrettyViewState *)state
{
	//we're using PQImages at the moment
	id img = nil;
	if (state.textureImageName) {
		 img = [PQImage imageNamed:state.textureImageName];	
		if (!img) { //try an NSImage
			img = [NSImage imageNamed:state.textureImageName];
		}
	} else if (state.textureImage) {
		img = state.textureImage;
	}
	if (img) {
		NSRect viewBounds = [self bounds];
		if ([img class] == [PQImage class]) {
			if (state.textureColor) {
				[self tileImage:[img colorizeWithColor:state.textureColor] inState:state];
			} else {
				[self tileImage:img inState:state];		
			}
		} else if ([img class] == [NSImage class]) {
			if (state.textureColor) {
				//colorise the NSImage
				NSImage *colorisedImg = [[[[NSImage alloc] initWithSize:[img size]] retain] autorelease];
				[colorisedImg lockFocus];
				[[state.textureColor colorWithAlphaComponent:state.textureAlpha] set];
				[NSBezierPath fillRect:viewBounds];
				NSRect destRect = NSMakeRect(0.0, 0.0, [img size].width, [img size].height);
				[(NSImage *)img drawInRect:destRect fromRect:NSZeroRect operation:NSCompositePlusDarker fraction:state.textureAlpha];
				[(NSImage *)img drawInRect:destRect fromRect:NSZeroRect operation:NSCompositeDestinationIn fraction:state.textureAlpha];
				[colorisedImg unlockFocus];
				[self tileImage:colorisedImg inState:state];
			}
			else {
				//just draw normally
				[self tileImage:img inState:state];
			}
		}
	}
	
}

- (void)resetColorisedColor
{
	PQPrettyViewState *currentState = (PQPrettyViewState*)self.stateMachine.currentState;
	currentState.textureColor = nil;
}


- (void)drawRect:(NSRect)rect
{
	PQPrettyViewState *currentState = (PQPrettyViewState*)self.stateMachine.currentState;
	id del = [self delegate];
	
	[self drawTexture:currentState];
	if (currentState.doesDrawGradient) {
		if ([del respondsToSelector:@selector(drawView:)]) {
			[del drawView:self];
		} else {
			NSBezierPath *path = nil;
			
			[[NSGraphicsContext currentContext] setCompositingOperation:currentState.compositingOp];
			if ([del respondsToSelector:@selector(bezierPathForView:)]) {
				path = [del bezierPathForView:self];
			} else {
				if (currentState.path == nil) {
					//see if we can get a path drawn using the values instead
					NSRect insetRect = NSOffsetRect(NSInsetRect(self.bounds, currentState.originX, currentState.originY), currentState.originX, currentState.originY);
					path = [NSBezierPath bezierPathWithType:currentState.pathType rect:insetRect radius:currentState.pathRadius pointCount:currentState.pathPointCount pointOffset:currentState.pathPointOffset];
				} else {
					path = [currentState.path bezierPath];	
				}	
			}
			
			//might have to scale to the right and current layer size?
			if (!path) {
				//this should never actually be the case anymore.
				path = [NSBezierPath bezierPathWithRoundedRect:self.bounds xRadius:currentState.cornerRadius yRadius:currentState.cornerRadius];	
			} else {
				NSRect insetRect = NSOffsetRect(NSInsetRect(self.bounds, currentState.originX, currentState.originY), currentState.originX, currentState.originY);
				
				NSAffineTransform *transform = [NSAffineTransform transformToFitPath:path toRect:insetRect];
				[transform translateXBy:currentState.sizeWidth yBy:currentState.sizeHeight];
				[path transformUsingAffineTransform:transform];
			}
			
			[currentState.gradient fillPath:path];		
		}		
	}
	//draw the icon 
	[self drawIcon:currentState];
}

- (void)applyRotations
{
	CALayer *layer = self.layer;
	if (layer) {
		PQPrettyViewState *state = (PQPrettyViewState*)self.stateMachine.currentState;
		[CATransaction begin];
		[CATransaction setValue:[NSNumber numberWithFloat:state.toDuration] forKey:kCATransactionAnimationDuration];

//		float scaleSX, scaleSY, scaleSZ;
//		float transTX, transTY, transTZ;
//		float rotRX, rotRY, rotRZ;
		
		CATransform3D transform = [self transformsForState:state];
		layer.transform = transform;
				
		CATransform3D perspectiveTransform = CATransform3DIdentity;
		if (state.distortionInNewmans)
			perspectiveTransform.m34 = 1.0 / state.distortionInNewmans;
		
		layer.superlayer.sublayerTransform = perspectiveTransform;
		
		[CATransaction commit];
		
	}
		
}
//convenience for users of the class.
- (void)setStateByName:(NSString *)stateName
{
	[self.stateMachine setStateByName:stateName];
}

//take the currentState and its properties 
- (void)reconfigureProperties
{	
	PQPrettyViewState *state = (PQPrettyViewState*)self.stateMachine.currentState;
	self.layer.hidden = state.hidden;
	self.layer.anchorPoint = [state cgAnchorPoint];	
	self.layer.zPosition = state.zPosition;
	self.layer.doubleSided = state.doubleSided;
	self.layer.position = state.cgPosition;
	NSRect frame = self.frame;
	self.layer.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
	[self applyRotations];
}

- (void)stateChangedTo:(PQState *)state
{
	//here is our notification of state change from the state machine. It might have come from another client too, so tell the state machine about it
	[self setNeedsDisplay:YES];
	[self reconfigureProperties];
}

- (void)someValueChanged
{
	//a notification send by the state machine to tell us essentually that we need to redraw.
	[self reconfigureProperties];
	[self setNeedsDisplay:YES];
}

- (id)initWithCoder:(NSCoder *)coder 
{	
    self = [super initWithCoder:coder];
    if ([coder allowsKeyedCoding]) {
		self.stateMachine = [coder decodeObjectForKey:@"stateMachine"];
		self.initialState = [coder decodeObjectForKey:@"initialState"];
		self.stateMachine.owner = self;
	}
	NSLog(@"Setting state to %@", [self firstState].stateName);
	[self setStateByName:[self firstState].stateName];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder 
{
    [super encodeWithCoder:coder];
	[coder encodeObject:self.stateMachine forKey:@"stateMachine"];
	[coder encodeObject:self.initialState forKey:@"initialState"];
	[self applyRotations];
	return;
}

#pragma mark Transitions

- (IBAction)moveToNextState:(id)sender
{
	[self.stateMachine moveToNextState];
}

- (void)startFadeToggleWithDuration:(NSTimer *)timer
{
	NSNumber *seconds = [timer userInfo];
	_isFadingOut = !_isFadingOut;
	NSLog(@"%@, %@", (_isFadingOut) ? @"fadingOut" : @"fadingIn", seconds);
	if ([self layer]) {
		[NSAnimationContext beginGrouping];
		PQPrettyViewState *state = (PQPrettyViewState *)self.stateMachine.currentState;
		float randomThreshold = state.fadeRandomThreshold;
		float sec = [seconds floatValue];
		randomThreshold = [Util percentage:randomThreshold of:sec];
		float randomisedDuration = [Util randomFloatFrom:sec - randomThreshold to:sec + randomThreshold];
		
		//change the state over if we are faded out
		if (!_isFadingOut) [self moveToNextState:self];
		NSLog(@"randomised duration: %f", randomisedDuration);
		[[NSAnimationContext currentContext] setDuration:randomisedDuration];
		float fadeAmount = (_isFadingOut) ? [Util randomFloatFrom:0.0 to:0.4] : [Util randomFloatFrom:0.6 to:1.0];
		if (fadeAmount > 1.0) fadeAmount = 1.0; if (fadeAmount < 0.0) fadeAmount = 0.0;
		NSLog(@"fadingTo: %f", fadeAmount);

		[[self animator] setAlphaValue:fadeAmount];
		[NSAnimationContext endGrouping];
		float randomisedDelay = [Util randomFloatFrom:sec - (sec - (randomThreshold / 100 * sec)) to:sec + (sec - (randomThreshold / 100 * sec))];
		if (_timerForNextFade) [_timerForNextFade invalidate]; [_timerForNextFade release]; _timerForNextFade = nil;
		_timerForNextFade = [[NSTimer scheduledTimerWithTimeInterval:randomisedDelay target:siblingView selector:@selector(startFadeToggleWithDuration:) userInfo:[NSNumber numberWithFloat:state.toDuration] repeats:NO] retain];
	}
}

//you must send stop animation to the view that you started the animation on.
- (IBAction)stopAnimationBetweenSiblingView:(id)sender
{
	if (!_timerForNextFade) {
		return; //prevents infinite looping	
	} else {
		[_timerForNextFade invalidate]; [_timerForNextFade release]; _timerForNextFade = nil;
		[siblingView stopAnimationBetweenSiblingView:sender];	
	}
}

- (IBAction)startAnimationBetweenSiblingView:(id)sender
{
	if (_timerForNextFade) [_timerForNextFade invalidate]; _timerForNextFade = nil;
	_isFadingOut = NO;
	//the sibling always starts fading out.
	PQPrettyViewState *state = (PQPrettyViewState *)self.stateMachine.currentState;
	[NSTimer scheduledTimerWithTimeInterval:0.0 target:siblingView selector:@selector(startFadeToggleWithDuration:) userInfo:[NSNumber numberWithFloat:state.toDuration] repeats:NO];
}

//This would allow the construction of movable animated views right within interface builder.



- (IBAction)logDrawingCode:(id)sender
{
	//go through the view and it's subviews, logging the drawing code for each one after the other, for their currently selected state (multiple states not supported!)
	PQPrettyViewState *state = (PQPrettyViewState*)self.stateMachine.currentState;
	
	//gradient
	PQGradient *gradient = state.gradient;
	
	NSData *gradData = [NSKeyedArchiver archivedDataWithRootObject:gradient];
	
	NSString *dataString = [NSString stringWithFormat:@"%@", gradData];
//	NSDictionary *gradDict = [gradient dictionary];
//	NSString *dictString = [gradDict descriptionInStringsFileFormat];
	
//	NSArray *objects = [gradDict allValues];
//	NSArray *keys = [gradDict allKeys];

//	NSLog(@"dictString %@", dictString);
	
//	NSMutableString *objectsAndKeys = [[NSMutableArray alloc] init];
	
//	NSArray *colorStops
//	for (NSString *key in keys) {
//		if ([key isEqualToString:@"GradientColorStops"]) {
//			//this is a dict too
//			NSDictionary *colorStop = [gradDict objectForKey:key];
//			for (NSDictionary *stop in colorStop
//			 *key
//		[objectsAndKeys appendString:@"%@, %@", key, [gradDict objectForKey:key]];
//			
//		}
//		[objectsAndKeys appendString:@"%@, %@", key, [gradDict objectForKey:key]];
//	}
	
	NSLog(@"data string : %@", dataString);
	
//	NSLog(@"- (PQGradient *)backgroundGradient \n{ \n static PQGradient *%@Gradient = nil; \nif (%@Gradient == nil) \n{ \nNSArray *objects = [NSArray arrayWithObjects:%@]; \nNSArray *keys = [NSArray arrayWithObjects:%@]; \n %@Gradient = [[PQGradient alloc] initWithDictionary: [[NSDictionary alloc] initWithObjects:objects forKeys:keys]]; \n}\n \n return %@gradient; \n \n})", state.stateName, state.stateName,  objects, keys, state.stateName, state.stateName);
	
	if (state.doesDrawGradient) {
		NSLog(@"//gradient \n NSBezierPath *path = myPath; \n [[NSGraphicsContext currentContext] setCompositingOperation:%i];\n NSRect insetRect = NSOffsetRect(NSInsetRect(NSRectFromString(@\"%@\"), %f, %f), %f, %f)", state.compositingOp,NSStringFromRect(self.bounds), state.originX, state.originY, state.originX, state.originY);
		
		NSLog(@"//pathtype\n path = [NSBezierPath bezierPathWithType:%i rect:insetRect radius:%f pointCount:%f pointOffset:%f];\n", state.pathType, state.pathRadius, state.pathPointCount, state.pathPointOffset);
		
		//if no path
		NSLog(@"if (!path) { \n //this should never actually be the case anymore. \n path = [NSBezierPath bezierPathWithRoundedRect:NSRectFromString(@\"%@\") xRadius:%f yRadius:%f];\n}", NSStringFromRect(self.bounds), state.cornerRadius, state.cornerRadius);	
		
		NSLog(@"//draw \n [self.%@gradient fillPath:path];", state.stateName);
	}
	NSArray *subviews = [self subviews];
	for (NSView *view in subviews) {
		if ([view class] == [PQPrettyView class]) {
			[(PQPrettyView *)view logDrawingCode:self];
		}
	}
}
@end
