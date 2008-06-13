/**
 * \file PQPDFImageRep.h
 *
 * Copyright plasq LLC 2007. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

#import "PQImageRep.h"

/**
 * A wrapper for a PDF-based image representation
 *
 * \ingroup AppKit
 */
@interface PQPDFImageRep : PQImageRep <NSCoding> {

	NSURL*				_url;
}

@property (copy) NSURL* url;
@property CGPDFDocumentRef docRef;

- (id)initByReferencingURL:(NSURL *)url;
- (id)initWithContentsOfURL: (NSURL *)url;

@end
