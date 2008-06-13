//
//  PQIBInspector.m
//  PlasqIBPalleteKit
//
//  Created by Mathieu Tozer on 15/03/08.
//  Copyright 2008 plasq. All rights reserved.
//

#import "PQIBInspector.h"
#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@implementation PQIBInspector

- (NSArray *)humanReadableCompositingOps
{
	return [NSArray arrayWithObjects:
			@"NSCompositeClear",
			@"NSCompositeCopy",
			@"NSCompositeSourceOver",
			@"NSCompositeSourceIn",
			@"NSCompositeSourceOut",
			@"NSCompositeSourceAtop",
			@"NSCompositeDestinationOver",
			@"NSCompositeDestinationIn",
			@"NSCompositeDestinationOut",
			@"NSCompositeDestinationAtop",
			@"NSCompositeXOR",
			@"NSCompositePlusDarker",
			@"NSCompositeHighlight",
			@"NSCompositePlusLighter",
			nil];
}

- (NSArray *)humanReadableShapeNames
{
	return [NSArray arrayWithObjects:
			@"kSmartShapeTypeRectangle",
			@"kSmartShapeTypeOval",
			@"kSmartShapeTypeDiamond",
			@"kSmartShapeTypeTriangle",
			@"kSmartShapeTypeHedron",
			@"kSmartShapeTypeRightTriangle",
			@"kSmartShapeTypeArc",
			@"kSmartShapeTypeSemiOval",
			@"kSmartShapeTypeBulge",
			@"kSmartShapeTypeTrapezoid",
			@"kSmartShapeTypeRounded",
			@"kSmartShapeTypeInsetRounded",
			@"kSmartShapeTypeBeveled",
			@"kSmartShapeTypeInsetSquare",
			@"kSmartShapeTypeSkewed",
			@"kSmartShapeTypeStar",
			@"kSmartShapeTypeCog",
			@"kSmartShapeTypeArrow",
			@"kSmartShapeTypeDoubleArrow",
			@"kSmartShapeTypeArrowHead",
			@"kSmartShapeTypeExclaim",
			@"kSmartShapeTypeExclaim2",
			@"kSmartShapeTypeRough",
			@"kSmartShapeTypeSpace",
			nil];
}

- (NSArray *)humanReadableAlignmentModes
{
	return [NSArray arrayWithObjects:
			kCAAlignmentNatural,
			kCAAlignmentLeft,
			kCAAlignmentRight,
			kCAAlignmentCenter,
			kCAAlignmentJustified,
			nil];
}

- (NSArray *)humanReadableTruncationModes
{
	return [NSArray arrayWithObjects:
			kCATruncationNone,
			kCATruncationStart,
			kCATruncationEnd,
			kCATruncationMiddle,
			nil];
}

@end
