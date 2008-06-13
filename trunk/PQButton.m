//
//  PQButton.m
//  PQIBKit
//
//  Created by Mathieu Tozer on 23/06/07.
//  Copyright plasq 2007 . All rights reserved.
//

#import "PQButton.h"
#import "PQButtonBaseLayer.h"
#import "PQButtonPath.h"
#import "PQButtonState.h"
#import "PQButtonValueUnit.h"
#import "PQMousing.h"
#import <QuartzCore/QuartzCore.h>
#import <CocoaExtender/CocoaExtender.h>

static inline CGRect CGRectFromNSRect(NSRect nsRect) { return * (CGRect*)&nsRect; }

const NSString *kPQButtonMouseDown = @"Mouse Down";
const NSString *kPQButtonMouseUp = @"Mouse Up";
const NSString *kPQButtonMouseEntered = @"Mouse Entered";
const NSString *kPQButtonMouseExited = @"Mouse Exited";
const NSString *kPQButtonRightMouseDown = @"Right Mouse Down";
const NSString *kPQButtonScroll = @"Scroll Wheel";
const NSString *kPQButtonKeyDown = @"Key Down";
const NSString *kPQButtonDoubleClick = @"Double Click";
const NSString *kPQButtonShiftMouseDown = @"Shift Mouse Down";
const NSString *kPQButtonShiftMouseUp = @"Shift Mouse Up";
const NSString *kPQButtonMouseDragged = @"Mouse Dragged";

@implementation PQButton
//views
@synthesize drawBorder;
@synthesize color;
@synthesize currentState = _currentState;
@synthesize previousLayerSelection = _previousLayerSelection;
@synthesize nextStateID = _nextStateID;
@synthesize isPureLayerButton = _isPureLayerButton;
@synthesize isInInterfaceBuilder = _isInInterfaceBuilder;
@synthesize scaleTo = _scaleTo;
@synthesize isInsertingDuplicateLayer = _isInsertingDuplicateLayer;

+ (NSArray *)keypaths
{
	return [NSArray arrayWithObjects:@"states", @"paths", @"drawBorder", @"color", @"wantsLayer", @"nextStateID", @"isPureLayerButton", nil];
}

+ (NSArray *)attributeKeypaths
{
	return [NSArray arrayWithObjects:@"drawBorder", @"color", @"wantsLayer", @"nextStateID", @"isPureLayerButton", nil];
}

+ (NSArray *)toManyKeypaths
{
	return [NSArray arrayWithObjects:@"states", @"paths", nil];
}

- (NSArray *)humanReadableBounceOps
{
	return [NSArray arrayWithObjects:
			@"NiceBounce",
			nil];
}

- (id<PQButtonDrawingDelegate>)delegate
{
	return delegate;
}

//we use these as keys for activation. When you choose such an item. Then the methods are invoked, and the state is asked for it's rules, and depending on these rules, we perform the change or not, or postpone it etc.
- (NSArray *)humanReadableSelectorsForActions
{
	return [NSArray arrayWithObjects:
			kPQButtonMouseDown,
			kPQButtonMouseUp,
			kPQButtonMouseEntered,
			kPQButtonMouseExited,
			kPQButtonRightMouseDown,
			kPQButtonScroll,
			kPQButtonKeyDown,
			kPQButtonDoubleClick,
			kPQButtonShiftMouseDown,
			kPQButtonShiftMouseUp,
			kPQButtonMouseDragged,
			nil];
};

+ (SEL)selectorWithHumanReadableName:(NSString *)selectorName
{
	if ([selectorName isEqualToString:(NSString *)kPQButtonMouseDown]) {
		return @selector(mouseDown:);
	}
	if ([selectorName isEqualToString:(NSString *)kPQButtonMouseUp]) {
		return @selector(mouseUp:);
	}
	if ([selectorName isEqualToString:(NSString *)kPQButtonMouseEntered]) {
		return @selector(mouseEntered:);
	}
	if ([selectorName isEqualToString:(NSString *)kPQButtonMouseExited]) {
		return @selector(mouseExited:);
	}
	if ([selectorName isEqualToString:(NSString *)kPQButtonRightMouseDown]) {
		return @selector(rightMouseUp:);
	}
	if ([selectorName isEqualToString:(NSString *)kPQButtonScroll]) {
		return @selector(scrollWheel:);
	}
	if ([selectorName isEqualToString:(NSString *)kPQButtonDoubleClick]) {
		return @selector(doubleClick:);
	}
	if ([selectorName isEqualToString:(NSString *)kPQButtonShiftMouseDown]) {
		return @selector(shiftMouseDown:);
	}
	if ([selectorName isEqualToString:(NSString *)kPQButtonShiftMouseUp]) {
		return @selector(shiftMouseUp:);
	}
	if ([selectorName isEqualToString:(NSString *)kPQButtonMouseDragged]) {
		return @selector(mouseDraggingStarted:);
	}
	if ([selectorName isEqualToString:(NSString *)kPQButtonKeyDown]) {
		return @selector(keyDown:);
	}
	return nil;
}

- (NSArray *)allLayers
{
	//recurse through all layers and return an array of them
	return [(PQButtonBaseLayer *)self.layer allLayers];
}

#pragma mark tracking rects

- (NSRect)transformedRect:(NSRect)rect toReflect3DTransformsInUnit:(PQButtonValueUnit *)unit
{
	CATransform3D scale = CATransform3DMakeScale(unit.scaleSX, unit.scaleSY, unit.scaleSZ);
	CGAffineTransform affine;
	affine = CATransform3DGetAffineTransform(scale);
	CGRect transformedRect;
	
	transformedRect = CGRectApplyAffineTransform(CGRectFromNSRect(rect), affine);

	//and place the poor dear in the middle to make up for that dreary layer mid point.
	NSRect original = [unit frame];
	float midX = NSMidX(original);
	float midY = NSMidY(original);
	float x = (midX - transformedRect.size.width / 2) + (unit.transTX); //any pixel based translations
	float y = (midY - transformedRect.size.height / 2) + (unit.transTY);
	transformedRect.origin = CGPointMake(x, y);
	return NSRectFromCGRect(transformedRect);
}

//we're the only NSView so we must take care of this ourselves!
- (void)updateTrackingAreas
{
	//remove all the prevous
	for (NSTrackingArea *area in [self trackingAreas]) {
		[self removeTrackingArea:area];
	}
	
	//each layer which doesCreateTrackingArea gets one set up for its rect
	//this will send events back to us.
	for (PQButtonBaseLayer *layer in [self allLayers]) {
		//get the values from the model rather than from the actual frame of the layer
		if (!layer.isBaseLayer) {
			if (self.currentState) {
				PQButtonValueUnit *valUnit = [layer valueUnitForState:self.currentState];
				if (valUnit.hasTrackingArea) {
					NSTrackingArea *trackingArea = [[[[NSTrackingArea alloc] initWithRect:[self transformedRect:[valUnit frame] toReflect3DTransformsInUnit:valUnit]	options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways owner:self userInfo:nil] retain] autorelease];
					[self addTrackingArea:trackingArea];		
				}
			}	
		}
	}
	[self setNeedsDisplay:YES];
}

- (NSString *)uniqueStateID
{
	self.nextStateID++;
	return [NSString stringWithFormat:@"%d", self.nextStateID];
}

- (void)setupStates
{
	//set up the default states
	_states = [[[NSMutableArray alloc] init] retain];
	PQButtonState *inactiveState = [PQButtonState inactiveState];
	inactiveState.stateKey = [self uniqueStateID];
	PQButtonState *mouseOverState = [PQButtonState mouseOverState];
	mouseOverState.stateKey = [self uniqueStateID];
	PQButtonState *activeState = [PQButtonState activeState];
	activeState.stateKey = [self uniqueStateID];

	[self insertObject:activeState inStatesAtIndex:0];
	[self insertObject:mouseOverState inStatesAtIndex:0];
	[self insertObject:inactiveState inStatesAtIndex:0];
}

//We run this just to make sure there is one for each before we encodeWithCoder, so nothing pulls a blank at run time.
- (void)makeSureEachLayerHasAValueUnitForEachExistingState
{
	//loop through all the layers, and for all the states, create a valueUnit object and link it back to the state.
	for (PQButtonBaseLayer *layer in [self allLayers]) {
		for (PQButtonState *state in [self states]) {
			if (![layer hasValueObjectForState:(PQButtonState *)state]) {
				[layer createValueObjectForState:(PQButtonState *)state];
			}
		}
	}
}

//- (void)addLayersToView
//{
//	[self setWantsLayer:YES];
//	
//	//remove all sublayers for a fresh, ordered start
//	
//	NSArray *sublayers = [[self.layer sublayers] copy];
//	for (CALayer *oldLayer in sublayers) {
//		[oldLayer removeFromSuperlayer];
//	}
//	
//	for (CALayer *layer in [self allLayers]) {
//		[self.layer addSublayer:layer];
//	}
//}

- (void)bindLayersToButton
{
	//go through each of the layers in [self layers] and tell it to bind the layer to us
	for (PQButtonBaseLayer *layer in [self allLayers]) {
		layer.buttonBase = self;
	}
}

- (void)setupInitialLayers
{
	//set up the default layers
	PQButtonBaseLayer *baseView = [[[[PQButtonBaseLayer alloc] initWithButtonBase:self] retain] autorelease];
	baseView.layerName = @"Base View";
	[(PQButtonBaseLayer *)self.layer insertObject:baseView inLayersAtIndex:0];
	[self bindLayersToButton];
}

- (NSArray *)availableBezierPaths
{
	int pointCount = 5;
	float pointOffset = 0.0;
	NSRect initialRect = NSMakeRect(0.0, 0.0, 40.0, 40.0);
	float radius = 0.5;

	//SQUARE RECT
	NSMutableArray *paths = [[[[NSMutableArray alloc] init] retain] autorelease];
	PQButtonPath *path = [PQButtonPath pathWithBezierPath:[NSBezierPath bezierPathWithInsetSquareRect:initialRect radius:radius]];
	path.pointCount = pointCount;
	path.pointOffset = pointOffset;
	path.radius = radius;
	path.name = @"kSmartShapeTypeRectangle";
	[paths addObject:path];
	
	//TRIANGLE
	path = [PQButtonPath pathWithBezierPath:[NSBezierPath bezierPathWithTriangleInRect:initialRect]];
	path.name = @"kSmartShapeTypeTriangle";
	[paths addObject:path];

	//OVAL
	path = [PQButtonPath pathWithBezierPath:[NSBezierPath bezierPathWithOvalInRect:initialRect]];
	path.name = @"kSmartShapeTypeOval";
	[paths addObject:path];
	
	//Diamond
	path = [PQButtonPath pathWithBezierPath:[NSBezierPath bezierPathWithDiamondInRect:initialRect]];
	path.name = @"kSmartShapeTypeDiamond";
	[paths addObject:path];
	
	//HEDRON
	path = [PQButtonPath pathWithBezierPath:[NSBezierPath bezierPathWithHedronInRect:initialRect count:pointCount]];
	path.pointCount = pointCount;
	path.name = @"kSmartShapeTypeHedron";
	[paths addObject:path];	

	//SEMI OVAL
	path = [PQButtonPath pathWithBezierPath:[NSBezierPath bezierPathWithSemiOvalInRect:initialRect]];
	path.name = @"kSmartShapeTypeSemiOval";
	[paths addObject:path];	
	
//	@"kSmartShapeTypeRightTriangle,
//	@"kSmartShapeTypeArc,
//	@",
//	@"kSmartShapeTypeBulge,
//	@"kSmartShapeTypeTrapezoid,
//	
//	@"kSmartShapeTypeRounded,
//	@"kSmartShapeTypeInsetRounded,
//	@"kSmartShapeTypeBeveled,
//	@"kSmartShapeTypeInsetSquare,
//	@"kSmartShapeTypeSkewed,
//	
//	@"kSmartShapeTypeStar,
//	@"kSmartShapeTypeCog,
//	@"kSmartShapeTypeArrow,
//	@"kSmartShapeTypeDoubleArrow,
//	kSmartShapeTypeArrowHead,
//	
//	kSmartShapeTypeCloud,
//	kSmartShapeTypeExclaim,
//	kSmartShapeTypeExclaim2,
//	kSmartShapeTypeRough,
//	kSmartShapeTypeSpace,
	
	return [[[NSArray arrayWithArray:paths] retain] autorelease];
}
- (void)setupInitialPaths
{
	_paths = [[[NSMutableArray alloc] init] retain];
	//default path is just a rounded rect
	NSArray *pathsArray = [self availableBezierPaths];
	for (PQButtonPath *path in pathsArray) {
		[self insertObject:path inPathsAtIndex:0];
	}
}

- (void)makeSureEachValueUnitIsOwnedByUs
{
	NSMutableArray *valueUnits = [[[NSMutableArray alloc] init] autorelease];
	for (PQButtonBaseLayer *layer in [self allLayers]) {
		for (PQButtonState *state in [self states]) {
			[valueUnits addObject:[layer valueUnitForState:state]];
		}
	}
	for (PQButtonValueUnit *unit in valueUnits) {
		unit.owner = self;
	}
}


#pragma mark init
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		_isInsertingDuplicateLayer = NO;
		self.previousLayerSelection = nil;
		[self setWantsLayer:YES];
		self.nextStateID = 0;
		[self setupStates];
		PQButtonBaseLayer *base = [[[PQButtonBaseLayer alloc] initWithButtonBase:self] autorelease];
		base.isBaseLayer = YES;
		self.layer = base;
		self.layer.frame = CGRectMake(0.0, 0.0, [self frame].size.width, [self frame].size.height);

		[self setupInitialLayers];
		[self setupInitialPaths];
		[self makeSureEachLayerHasAValueUnitForEachExistingState];
		[self makeSureEachValueUnitIsOwnedByUs];
		self.drawBorder = NO;
		self.currentState = [[self states] objectAtIndex:0];
		[self updateTrackingAreas];
		self.isPureLayerButton = NO; //if this strategy works then YES
		self.isInInterfaceBuilder = NO; //assuming NO
		_isDragging = NO;
	}

    return self;
}

- (BOOL)isFlipped
{
	return NO;
}

- (void)drawRect:(NSRect)rect 
{
	if ([self drawBorder]) {
		[self.color set];
		[NSBezierPath strokeRect:[self bounds]];
		
		[[NSColor redColor] set];
		for (NSTrackingArea *area in [self trackingAreas]) {
			[NSBezierPath strokeRect:[area rect]];
		}
	}
}

- (id)initWithCoder:(NSCoder *)coder 
{	
    self = [super initWithCoder:coder];
    if ([coder allowsKeyedCoding]) {
		_isInsertingDuplicateLayer = NO;
		self.previousLayerSelection = nil;
		self.wantsLayer = YES;
		self.layer = [coder decodeObjectForKey:@"theBaseLayer"];
		self.drawBorder = [coder decodeBoolForKey:@"drawBorder"];
		_paths = [[[NSMutableArray alloc] init] retain];
		[_paths addObjectsFromArray:[coder decodeObjectForKey:@"paths"]];
		_states = [[[NSMutableArray alloc] init] retain];
		[_states addObjectsFromArray:[coder decodeObjectForKey:@"states"]];
		[self makeSureEachLayerHasAValueUnitForEachExistingState];
		[self bindLayersToButton];
		[self makeSureEachValueUnitIsOwnedByUs];
		self.nextStateID = [coder decodeIntForKey:@"nextStateID"];
		self.isPureLayerButton = [coder decodeBoolForKey:@"isPureLayerButton"];
	}
	
	self.isInInterfaceBuilder = NO; //assuming NO
	self.currentState = [[self states] objectAtIndex:0];
	[self updateTrackingAreas];
	_isDragging = NO;

    return self;
}


- (void)encodeWithCoder:(NSCoder *)coder 
{
    [super encodeWithCoder:coder];
	[coder encodeObject:self.layer forKey:@"theBaseLayer"];
	[coder encodeBool:self.drawBorder forKey:@"drawBorder"];
	[coder encodeObject:[self paths] forKey:@"paths"];
	[coder encodeObject:[self states] forKey:@"states"];
	[coder encodeInt:self.nextStateID forKey:@"nextStateID"];
	[coder encodeBool:self.isPureLayerButton forKey:@"isPureLayerButton"];
	return;
}

- (void)setDrawBorder:(BOOL)value
{
	drawBorder = value;
	[self setNeedsDisplay:YES];
}

- (void)customMouseDown:(NSEvent *)event
{
	//noop here
}

- (IBAction)zoomSliderDidChange
{
	
}

#pragma mark Paths

- (unsigned int)countOfPaths
{
	return [_paths count];
}

- (id)objectInPathsAtIndex:(unsigned int)index
{
	if (index >= [self countOfPaths])
        return nil;
	return [_paths objectAtIndex:index];
}

- (void)removeObjectFromPathsAtIndex:(unsigned int)index
{
	NSBezierPath *scene = [_paths objectAtIndex:index];
	[[[self undoManager] prepareWithInvocationTarget: self]
	 insertObject:scene inPathsAtIndex:index];
	[_paths removeObjectAtIndex:index];
}

- (void)insertObject:(id)anObject inPathsAtIndex:(unsigned int)index
{
	[[[self undoManager] prepareWithInvocationTarget: self]
	 removeObjectFromPathsAtIndex: index];    
	[_paths insertObject:anObject atIndex:index];
}

- (NSArray*)paths
{
    return [[_paths retain] autorelease];
}

- (void)setPaths:(NSArray *)paths
{
	if (_paths) [_paths release];
	_paths = [[[[NSMutableArray alloc] initWithArray:paths] retain] autorelease];
}

//some nasty glue methods to get events and messages back from the inspector into the button. Not used in production of course, only in design
- (void)handleDroppedPath:(NSBezierPath *)path
{
	PQButtonPath *pqPath = [[[[PQButtonPath alloc] init] retain] autorelease];
	[pqPath setName:@"name"];
	[pqPath setBezierPath:path];
	[self insertObject:pqPath inPathsAtIndex:0];
}


#pragma mark States

- (unsigned int)countOfStates
{
	return [_states count];
}

- (id)objectInStatesAtIndex:(unsigned int)index
{
	if (index >= [self countOfStates])
        return nil;
	return [_states objectAtIndex:index];
}

- (void)removeObjectFromStatesAtIndex:(unsigned int)index
{
	PQButtonState *state = [_states objectAtIndex:index];
	[[[self undoManager] prepareWithInvocationTarget: self]
	 insertObject:state inStatesAtIndex:index];
	[_states removeObjectAtIndex:index];
}

- (void)insertObject:(id)anObject inStatesAtIndex:(unsigned int)index
{
	[[[self undoManager] prepareWithInvocationTarget: self]
	 removeObjectFromStatesAtIndex: index];    
	[(PQButtonState *)anObject setStateKey:[self uniqueStateID]];
	[_states insertObject:anObject atIndex:index];
}

- (NSArray*)states
{
    return _states;
}

- (void)setStates:(NSArray *)states
{
	if (_states) [_states release];
	_states = [[[NSMutableArray alloc] initWithArray:states] retain];
}

- (void)viewDidMoveToWindow
{
//	[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(addLayersToView) userInfo:nil repeats:NO];
	[super viewDidMoveToWindow];
}

- (void)viewDidMoveToSuperview
{
//	[NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(addLayersToView) userInfo:nil repeats:NO];
	[super viewDidMoveToSuperview];
}

- (void)viewDidUnhide
{
	[self makeSureEachLayerHasAValueUnitForEachExistingState];
	[super viewDidUnhide];
}

#pragma mark Animating
//subclasses may implement
- (CAAnimation *)animationForActivatedState:(PQButtonState *)state onLayer:(PQButtonBaseLayer *)layer
{
	return nil;
}

- (void)animateStateChange
{
	PQButtonState *state = self.currentState;
	for (PQButtonBaseLayer *layer in [self allLayers]) {
		CAAnimation *animation = [self animationForActivatedState:state onLayer:layer];
		if (animation) [layer animateAnimation:animation];
	}
	
	//or are we going the animation for key way?
	//animation key layer state
	
	//so when mouse over is activated. The layer changes all it's properties, and asks for animations for all the keys.
	//set animation for keypath should change each time the state changes? AS well as non keypath animation for things like the bulging?
	//so things like 'apply animation for state activation might still be valid?
}

#pragma mark KVO observing

- (void)setLayersToCurrentState
{
	for (PQButtonBaseLayer *layer in [self allLayers]) {
		[layer setValuesToReflectCurrentState];
	}
}


- (void)aValueUnitChanged
{
	//simulate a current state change
	[self setLayersToCurrentState];
	[self updateTrackingAreas];	
}

- (void)setCurrentState:(PQButtonState *)state
{
	//this state is now currently active, and therefore any changes which occur to any of it's related value units
	//must be observed by the layers. 
	if (_currentState != state) {
		[_currentState release];
		_currentState = [state retain];
		[self setLayersToCurrentState];
		[self updateTrackingAreas];
		[self animateStateChange];
	}
}

- (PQButtonState *)stateWithName:(NSString *)name
{
	for (PQButtonState *state in [self states]) {
		if ([state.stateName isEqualToString:name]) {
			return [[state retain] autorelease];
		}
	}
	return [[self states] objectAtIndex:0];
}

- (PQButtonState *)stateWithKey:(NSString *)key
{
	for (PQButtonState *state in [self states]) {
		if ([state.stateKey isEqualToString:key]) {
			return [[state retain] autorelease];
		}
	}
	return [[self states] objectAtIndex:0];
}

- (PQButtonState *)stateWhichIsActivatedWithSelectorNamed:(NSString *)stateName
{
	NSMutableArray *candidateStates = [[[NSMutableArray alloc] init] autorelease];
	for (PQButtonState *state in [self states]) {
		if ([state.selectorToActivate isEqualToString:stateName]) {
			[candidateStates addObject:state];
		}
	}
	//now we have our candidates. If there's only one, then that's it.
	if ([candidateStates count] == 1) return [[[candidateStates objectAtIndex:0] retain] autorelease];
	//look at what is the current state, and choose the next one that is in the list. 
	//so if two or more states are invoked with mouseDown, then it will just cycle between them
	
	//we might just have a simple toggle, so remove the current state, and if we're left with only one other choice, then choose it.
	PQButtonState *curState = self.currentState;
	[candidateStates removeObject:curState];
	if ([candidateStates count] == 1) return [[[candidateStates objectAtIndex:0] retain] autorelease];
	
	//else we have a cyclic kind of thing that I haven't been bothered to implement yet but would be very handy! Think you coul dmake three or four state toggle buttons easily, and bind your code to their state, so you could make interesting tab views, well it would be quite versatile really!
	
/*	1 md <-
	2
	3 md
	4
	5
	6 md */
	//just choose the first one or nothing!
	if ([candidateStates count] >= 1) return [candidateStates objectAtIndex:0];
	return nil;
	
}


- (void)moveToStateAfterPause:(NSTimer *)timer
{
	PQButtonState *state = [timer userInfo];
	self.currentState = state;
}


- (void)wait:(NSTimeInterval)time thenDo:(NSArray *)direction
{
	if ([direction count] == 2) {
		if ([[direction objectAtIndex:0] isEqualToString:@"invoke"]) {
			PQButtonState *stateToMoveToAfterWait = [self stateWhichIsActivatedWithSelectorNamed:[direction objectAtIndex:1]];
			if (stateToMoveToAfterWait) {
				[NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(moveToStateAfterPause:) userInfo:stateToMoveToAfterWait repeats:NO];		
			}
			return;
		}
		
		if ([[direction objectAtIndex:0] isEqualToString:@"setState"]) {
			PQButtonState *stateToMoveToAfterWait = [self stateWithName:[direction objectAtIndex:1]];
			if (stateToMoveToAfterWait) {
				[NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(moveToStateAfterPause:) userInfo:stateToMoveToAfterWait repeats:NO];		
			}
			return;
		}
	}
}
- (void)followRules
{
	PQButtonState *current = self.currentState;
	NSString *rules = current.rules;
	if (rules) {
		//parse the rules string and if it is well formed, set up appropriate actions.
		//wait:1.0 then invoke:Mouse Exited; 
		NSArray *commands = [rules componentsSeparatedByString:@";"]; //wait:1.0, invoke:Mouse Exited; 
		for (NSString *command in commands) {
			NSArray *commandPairs = [command componentsSeparatedByString:@", "];
			if ([commandPairs count] == 2) { //must be key then value
				NSArray *directionKey = [[commandPairs objectAtIndex:0] componentsSeparatedByString:@":"]; //wait:1.0
				NSArray *directionValue = [[commandPairs objectAtIndex:1] componentsSeparatedByString:@":"]; //invoke:Mouse Exited
				if ([directionKey count] != 0 && [directionValue count] != 0) { //no nonsense
					if ([[directionKey objectAtIndex:0] isEqualToString:@"wait"]) {
						//set a timer to wait to do the second command
						[self wait:[[directionKey objectAtIndex:1] floatValue] thenDo:directionValue];
					}		
				}
			}
		}
	}
}

//must return YES if the state can change, else no
- (BOOL)followPreRulesOfState:(PQButtonState *)state
{
	//we're looking for things like ifnot:On which means that if the button is on, we don't activate this state.
	NSString *rules = state.rules;
	if (rules) {
		//parse the rules string and if it is well formed, set up appropriate actions.
		//wait:1.0 then invoke:Mouse Exited; 
		NSArray *commands = [rules componentsSeparatedByString:@";"]; //wait:1.0, invoke:Mouse Exited; 
		for (NSString *command in commands) {
			NSArray *commandPairs = [command componentsSeparatedByString:@", "];
			if ([commandPairs count] == 2) { //must be key then value
				NSArray *directionKey = [[commandPairs objectAtIndex:0] componentsSeparatedByString:@":"]; //wait:1.0
				NSArray *directionValue = [[commandPairs objectAtIndex:1] componentsSeparatedByString:@":"]; //invoke:Mouse Exited
				if ([directionKey count] != 0 && [directionValue count] != 0) { //no nonsense
					if ([[directionKey objectAtIndex:0] isEqualToString:@"wait"]) {
						//set a timer to wait to do the second command
						[self wait:[[directionKey objectAtIndex:1] floatValue] thenDo:directionValue];
					}
				}
			} else if ([commandPairs count] == 1){ 
				NSArray *directionKey = [[commandPairs objectAtIndex:0] componentsSeparatedByString:@":"]; //wait:1.0
				if ([[directionKey objectAtIndex:0] isEqualToString:@"ifnot"]) {
					if ([[directionKey objectAtIndex:1] isEqualToString:self.currentState.stateName]) {
						return NO;
					} else {
						return YES;
					}
				}					
				if ([[directionKey objectAtIndex:0] isEqualToString:@"setState"]) {
					//just force set the state from here. The state being set is a 'briding state' whose main purpose is to set another state immediately
					self.currentState = [self stateWithName:[directionKey objectAtIndex:1]];
					[self followRules];
					return NO;
				}					
			}
		}
	}
	return YES;
}

#pragma mark Mousing
- (PQButtonBaseLayer *)layerUnderPoint:(NSPoint)point
{
	NSRect aRect = NSZeroRect;
	//hit test to find if it's over our layer which has a tracking rect
	for (PQButtonBaseLayer *layer in [self allLayers]) {
		PQButtonValueUnit *valUnit = [layer valueUnitForState:self.currentState];
		if (valUnit.hasTrackingArea) {
			aRect = valUnit.frame;
			if ([self mouse:point inRect:aRect]) {
				return layer;
			}
		}
	}
	[self followRules];
	return nil;
}

- (void)mouseExited:(NSEvent *)event
{
	PQButtonState *stateToMoveTo = [self stateWhichIsActivatedWithSelectorNamed:(NSString *)kPQButtonMouseExited];
	if ([self followPreRulesOfState:stateToMoveTo]) {
		if (stateToMoveTo) {
			self.currentState = stateToMoveTo;
		}
		[self followRules];	
	}
}

- (void)mouseEntered:(NSEvent *)event
{
	PQButtonState *stateToMoveTo = [self stateWhichIsActivatedWithSelectorNamed:(NSString *)kPQButtonMouseEntered];
	if ([self followPreRulesOfState:stateToMoveTo]) {
		if (stateToMoveTo) {
			self.currentState = stateToMoveTo;
		}
		[self followRules];
	}
}


- (void)mouseDraggingStarted:(NSEvent *)event
{
	PQButtonState *stateToMoveTo = [self stateWhichIsActivatedWithSelectorNamed:(NSString *)kPQButtonMouseDragged];
	if (stateToMoveTo) {
		self.currentState = stateToMoveTo;
	}
	[self followRules];
}

- (void)doubleClick:(NSEvent *)event
{
	PQButtonState *stateToMoveTo = [self stateWhichIsActivatedWithSelectorNamed:(NSString *)kPQButtonDoubleClick];
	if (stateToMoveTo) {
		self.currentState = stateToMoveTo;
	}
	[self followRules];
}

- (void)basicMouseDown:(NSEvent *)event
{
	PQButtonState *stateToMoveTo = [self stateWhichIsActivatedWithSelectorNamed:(NSString *)kPQButtonMouseDown];
	if ([self followPreRulesOfState:stateToMoveTo]) {
		if (stateToMoveTo) {
			self.currentState = stateToMoveTo;
			[super mouseDown:event];
		}
		[self followRules];
	}
}

- (void)basicMouseUp:(NSEvent *)event
{
	PQButtonState *stateToMoveTo = [self stateWhichIsActivatedWithSelectorNamed:(NSString *)kPQButtonMouseUp];
	if (stateToMoveTo) {
		self.currentState = stateToMoveTo;
		_isDragging = NO;
		[super mouseUp:event];
	}
	[self followRules];
}

- (void)shiftMouseUp:(NSEvent *)event
{
	PQButtonState *stateToMoveTo = [self stateWhichIsActivatedWithSelectorNamed:(NSString *)kPQButtonShiftMouseUp];
	if (stateToMoveTo) {
		self.currentState = stateToMoveTo;
	}
	[self followRules];
}

- (void)shiftMouseDown:(NSEvent *)event
{
	PQButtonState *stateToMoveTo = [self stateWhichIsActivatedWithSelectorNamed:(NSString *)kPQButtonShiftMouseDown];
	if (stateToMoveTo) {
		self.currentState = stateToMoveTo;
	}
	[self followRules];
}

- (void)willDrag:(NSEvent *)event
{
	_isDragging = YES;
}

- (void)mouseDown:(NSEvent *)event
{
	_originalMouseEvent = event;
	NSPoint hitPoint = NSZeroPoint;
    hitPoint = [self convertPoint:[event locationInWindow]  
						 fromView:nil];
	PQButtonBaseLayer *layer = [self layerUnderPoint:hitPoint];
	if (layer) { //we don't really care which layer it is, only that there is one
		[self dispatchCorrectMouseDownActionForEvent:event toObject:self];
		
	}
}

- (void)mouseUp:(NSEvent *)event
{
	[self dispatchCorrectMouseUpActionForEvent:event toObject:self];
}

- (void)mouseDragged:(NSEvent *)event
{
	[super mouseDragged:event];
}


- (NSArray *)respondsToSelectors
{
	return [NSArray arrayWithObjects:@"mouseDown:", @"mouseUp:", @"mouseEntered:", @"mouseExited:", @"mouseDragged:", @"doubleClick:", @"keyPressed", nil];
}

- (PQButtonBaseLayer *)newLayer
{
	id object = [[[NSObject alloc] init] autorelease]; //it is discarded anyway
	[(PQButtonBaseLayer *)self.layer insertObject:object inLayersAtIndex:0];
	return [(PQButtonBaseLayer *)self.layer objectInLayersAtIndex:0];
}
			
- (void)forAllLayersSetObjectValue:(id)object forKey:(NSString *)key inState:(PQButtonState *)state
{
	NSArray *layers = [self allLayers];
	for (PQButtonBaseLayer *layer in layers) {
		PQButtonValueUnit *valUnit = [layer valueUnitForState:state];
		[valUnit setValue:object forKey:key];
	}
}

- (void)duplicateLayer:(PQButtonBaseLayer *)layer
{
	NSData *archivedLayer = [NSKeyedArchiver archivedDataWithRootObject:layer];
	_isInsertingDuplicateLayer = YES;
	if (archivedLayer) {
		[(PQButtonBaseLayer *)self.layer insertObject:[NSKeyedUnarchiver unarchiveObjectWithData:archivedLayer] inLayersAtIndex:0];
	}
	[self bindLayersToButton];
}


//- (void)onlyUseTrackingRectsFromLayer:(PQButtonBaseLayer *)layer
//{
//	NSArray *layers = [self allLayers];
//	for (PQButtonBaseLayer *alayer in layers) {
//		[alayer forAllStatesSetBoolValue:NO forKey:@"hasTrackingArea"];
//	}
//	[layer forAllStatesSetBoolValue:YES forKey:@"hasTrackingArea"];
//	[self updateTrackingAreas];
//}

- (int)indexOfLayer:(PQButtonBaseLayer *)layer
{
	return [[self allLayers] indexOfObject:layer];
}

- (void)removeAllLayersFromView
{
	for (CALayer *layer in [self.layer sublayers]) {
		[layer removeFromSuperlayer];
	}
}

- (void)moveLayerUp:(PQButtonBaseLayer *)layer
{
	int index = [self indexOfLayer:layer];
	[(PQButtonBaseLayer *)self.layer removeObjectFromLayersAtIndex:index];
	index--;
	if (index < 0) index = 0;
	//really just a bool to mean use the object instead of tossing it and making a new one
	_isInsertingDuplicateLayer = YES; 
	[(PQButtonBaseLayer *)self.layer insertObject:layer inLayersAtIndex:index];
	_isInsertingDuplicateLayer = NO;
}

- (void)moveLayerDown:(PQButtonBaseLayer *)layer
{
	int index = [self indexOfLayer:layer];
	[(PQButtonBaseLayer *)self.layer removeObjectFromLayersAtIndex:index];
	index++;
	if (index > ([[self allLayers] count])) index = [[self allLayers] count];
	//really just a bool to mean use the object instead of tossing it and making a new one
	_isInsertingDuplicateLayer = YES; 
	[(PQButtonBaseLayer *)self.layer insertObject:layer inLayersAtIndex:index];
	_isInsertingDuplicateLayer = NO;
}

#pragma mark Setting States
//set the current state with this exterior name
- (void)setStateCalled:(NSString *)stateName
{
	self.currentState = [self stateWithName:stateName];
}

- (void)setNSState:(int)nsState
{
	switch (nsState) {
		case NSOffState:
			break;
		case NSOnState:
			break;
		case NSMixedState:
			break;
		default:
			break;
	}
}

- (void)saveButtonArchiveToDesktop
{
	//put a keyed archive on the desktop of the current button
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
	[data writeToFile:[@"~/Desktop/button.pqbutton" stringByExpandingTildeInPath] options:NSAtomicWrite error:nil];
}

- (void)initialiseButtonWithData:(NSData *)data
{
//	PQButton *button = [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

+ (NSArray *)scalableKeypaths
{
	NSMutableArray *keypaths = [[[[NSMutableArray alloc] init] retain] autorelease];
	[keypaths addObjectsFromArray:[PQButtonBaseLayer scalableKeypaths]];
	return keypaths;	
}

- (void)scaleByPercent:(float)percent
{
	//this iterates through all the elements in the button and tells each state to increase each value by a certain percentage!
	//scale the width and height.
	NSRect frame = [self frame];
	float width = frame.size.width;
	float height = frame.size.height;
	width = width + (width * percent / 100);
	height = height + (height * percent /100);
	NSRect newFrame = NSMakeRect(frame.origin.x, frame.origin.y, width , height);
	[self setFrame:newFrame];
	NSArray *scalableKeypaths = [PQButton scalableKeypaths];
	NSArray *layers = [self allLayers];
	for (PQButtonBaseLayer *layer in layers) {
		NSArray *valueUnits = [[layer statesToValueUnits] allValues];
		for (PQButtonValueUnit *unit in valueUnits) {
			for (NSString *key in scalableKeypaths) {
				[unit scaleKeypath:key byPercentage:percent];
			}
		}
	}
	self.scaleTo = 0.0;
}

- (void) dealloc
{
	if (_paths) [_paths release];
	if (_states) [_states release];
	[super dealloc];
}

@end

//@implementation NSObject (debug)
//
//- (void)setValue:(id)value forUndefinedKey:(NSString *)key
//{
//	NSLog(@"%@, %@, %@", self, value, key);
//}
//
//@end
