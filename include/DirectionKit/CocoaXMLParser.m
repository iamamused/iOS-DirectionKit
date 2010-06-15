/*
 Abstract: Subclass of XmlParseEngine that uses the Foundation framework's 
 NSXMLParser for parsing the XML data.
*/

#import "CocoaXMLParser.h"

// Class extension for private properties and methods.
@interface CocoaXMLParser ()

@property (nonatomic, retain) NSMutableString *currentString;
@property (nonatomic, retain) id currentItem;
@property (nonatomic, retain) NSDateFormatter *parseFormatter;

@end

@implementation CocoaXMLParser

+ (CocoaXMLParser *)parserWithDelegate:(<XmlParseEngineDelegate>)target {
	CocoaXMLParser *parser = [[[CocoaXMLParser alloc] init] autorelease];
	parser.delegate = target;
	return parser;
}

+ (NSString *)parserName {
    return @"NSXMLParser";
}

+ (XMLParserType)parserType {
    return XMLParserTypeNSXMLParser;
}

@synthesize currentString, currentItem, parseFormatter;

- (void)downloadAndParse:(NSURL *)url {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    self.parseFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [parseFormatter setDateStyle:NSDateFormatterLongStyle];
    [parseFormatter setTimeStyle:NSDateFormatterNoStyle];
	
    // necessary because iTunes RSS feed is not localized, so if the device region has been set to other than US
    // the date formatter must be set to US locale in order to parse the dates
    [parseFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"US"] autorelease]];
    [self performSelectorOnMainThread:@selector(downloadStarted) withObject:nil waitUntilDone:NO];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [self performSelectorOnMainThread:@selector(downloadEnded) withObject:nil waitUntilDone:NO];
    parser.delegate = self;
    self.currentString = [[[NSMutableString alloc] initWithCapacity:32] autorelease];
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    [parser parse];
    NSTimeInterval duration = [NSDate timeIntervalSinceReferenceDate] - start;
    [self performSelectorOnMainThread:@selector(addToParseDuration:) withObject:[NSNumber numberWithDouble:duration] waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(parseEnded) withObject:nil waitUntilDone:NO];
    [parser release];
    self.parseFormatter = nil;
    self.currentString = nil;
    self.currentItem = nil;
    [pool release];
}

// Constants for the XML element names that will be considered during the parse. 
// Declaring these as static constants reduces the number of objects created during the run
// and is less prone to programmer error.
static NSString *kName_Item = @"item";

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *) qualifiedName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:kName_Item]) {
        self.currentItem = [[[itemClass alloc] init] autorelease];
    } else {
        [currentString setString:@""];
        storingCharacters = YES;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:kName_Item]) {
        [self performSelectorOnMainThread:@selector(parsedXmlItem:) withObject:currentItem waitUntilDone:NO];
        // performSelectorOnMainThread: will retain the object until the selector has been performed
        // setting the local reference to nil ensures that the local reference will be released
        self.currentItem = nil;
    } else {
		// use the elementName as the selector 
		NSArray *split = [elementName componentsSeparatedByString:@":"]; // for namespaces
		NSString *capElementName = [[split lastObject] stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[[split lastObject] substringToIndex:1] capitalizedString]];
		NSString *setterMethod = [NSString stringWithFormat:@"setXmlParseEngine%@:", capElementName ];
		NSString *value = [NSString stringWithString:currentString];
		SEL setter = NSSelectorFromString(setterMethod);
		
		if ( [currentItem respondsToSelector:setter] ) {
			NSMethodSignature *methodSignature = [currentItem methodSignatureForSelector:setter];			
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
			[invocation setTarget:currentItem];
			[invocation setSelector:setter];
			[invocation setArgument:&value atIndex:2];
			[invocation retainArguments];
			[invocation invoke];
		}
		
	} 

    storingCharacters = NO;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (storingCharacters) [currentString appendString:string];
}

/*
 A production application should include robust error handling as part of its parsing implementation.
 The specifics of how errors are handled depends on the application.
 */
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    // Handle errors as appropriate for your application.
}


@end
