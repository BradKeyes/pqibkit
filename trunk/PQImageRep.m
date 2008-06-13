//
//  PQImageRep.m
//  Comic Life
//
//  Created by Robert Grant on 9/6/07.
//  Copyright 2007 plasq LLC. All rights reserved.
//

#import "PQImageRep.h"
#import "PQLRUTable.h"


@implementation PQImageRep
@synthesize wantsPopOut = _wantsPopOut;

// We don't need a big caches for the images : elements content are already cached
// These one are only used during elements changes like resizing, so only the ones
// used by an elements need to be kept in memory
+ (PQLRUTable *)imagesCache
{
	static PQLRUTable* _cache = nil;
	if (_cache == nil) {
		_cache = [PQLRUTable LRUTableWithCapacity: 10];
	}
	return _cache;
}

+ (PQLRUTable *)imageSourcesCache
{
	static PQLRUTable* _cacheSource = nil;
	if (_cacheSource == nil) {
		_cacheSource = [PQLRUTable LRUTableWithCapacity: 32];
	}
	return _cacheSource;
}

// Normal images has no pop-out
- (BOOL)canPopOut
{
	return NO;
}

- (BOOL)isVector
{
	NSAssert(0, @"PQImageRep isVector");
	return NO;
}

- (NSSize)pointSize
{
	NSAssert(0, @"PQImageRep pointSize");
	return NSZeroSize;
}

- (NSSize)pixelSize
{
	NSAssert(0, @"PQImageRep pixelSize");
	return NSZeroSize;
}

- (void)drawInRect:(NSRect)rect
{
	NSAssert(0, @"PQImageRep drawInRect:");
}

- (void)drawPopOutInRect:(NSRect)rect
{
	NSAssert(0, @"PQImageRep drawPopOutInRect:");
}

- (void)tileWithRect:(NSRect)rect
{
	NSAssert(0, @"PQImageRep tileInRect:");
}

- (CIImage *)CIImageWithSize: (NSSize)size
{
	NSAssert(0, @"PQImageRep CIImageWithSize:");
	return nil;
}

- (CIImage *)CIPopOutImageWithSize: (NSSize)size
{
	NSAssert(0, @"PQImageRep CIPopOutImageWithSize:");
	return nil;
}

- (NSBezierPath *)popOutPathForRect:(NSRect)dstRect;
{
	NSAssert(0, @"PQImageRep popOutPathForRect:");
	return nil;
}

- (BOOL)pointIsInside: (NSPoint)point
{
	return YES;
}	
@end
