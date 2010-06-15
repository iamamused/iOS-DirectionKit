#import "XmlParseEngine.h"

static NSUInteger kCountForNotification = 10;

// Class extension for private properties and methods.
@interface XmlParseEngine ()

@property (nonatomic, retain) NSMutableArray *parsedItems;
@property NSTimeInterval startTimeReference;
@property NSTimeInterval downloadStartTimeReference;
@property double parseDuration;
@property double downloadDuration;
@property double totalDuration;
@property Class itemClass;

@end

@implementation XmlParseEngine

@synthesize delegate, parsedItems, startTimeReference, downloadStartTimeReference, parseDuration, downloadDuration, totalDuration;
@synthesize itemClass;

- (Class)itemClass {
	return itemClass;
}

+ (NSString *)parserName {
    NSAssert((self != [XmlParseEngine class]), @"Class method parserName not valid for abstract base class XmlParseEngine");
    return @"Base Class";
}

+ (XMLParserType)parserType {
    NSAssert((self != [XmlParseEngine class]), @"Class method parserType not valid for abstract base class XmlParseEngine");
    return XMLParserTypeAbstract;
}

- (void)start {
    self.startTimeReference = [NSDate timeIntervalSinceReferenceDate];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.parsedItems = [NSMutableArray array];
    NSURL *url = [NSURL URLWithString:@"http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStore.woa/wpa/MRSS/newreleases/limit=300/rss.xml"];
    [NSThread detachNewThreadSelector:@selector(downloadAndParse:) toTarget:self withObject:url];
}

- (void)startWithURL:(NSURL *)url itemClass:(Class)classType {
	NSLog(@"XmlParseEngine: started with url %@", url);
	self.startTimeReference = [NSDate timeIntervalSinceReferenceDate];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.parsedItems = [NSMutableArray array];
	self.itemClass = classType;
    [NSThread detachNewThreadSelector:@selector(downloadAndParse:) toTarget:self withObject:url];
}



- (void)dealloc {
    [parsedItems release];
    [super dealloc];
}

- (void)downloadAndParse:(NSURL *)url {
    NSAssert([self isMemberOfClass:[XmlParseEngine class]] == NO, @"Object is of abstract base class XmlParseEngine");
}

- (void)downloadStarted {
	//NSLog(@"XmlParseEngine: Download Started" );
    NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
    self.downloadStartTimeReference = [NSDate timeIntervalSinceReferenceDate];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)downloadEnded {
    NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
    NSTimeInterval duration = [NSDate timeIntervalSinceReferenceDate] - self.downloadStartTimeReference;
    downloadDuration += duration;
	//NSLog(@"XmlParseEngine: Download Ended with duration %f", duration );
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)parseEnded {
    NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parser:didParseItems:)] && [parsedItems count] > 0) {
        [self.delegate parser:self didParseItems:parsedItems];
    }
    [self.parsedItems removeAllObjects];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parserDidEndParsingData:)]) {
        [self.delegate parserDidEndParsingData:self];
    }
    NSTimeInterval duration = [NSDate timeIntervalSinceReferenceDate] - self.startTimeReference;
    totalDuration = duration;
	//NSLog(@"XmlParseEngine: Parser ended with duration %f", totalDuration );

}

- (void)parsedXmlItem:(id)item {
    NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
    [self.parsedItems addObject:item];
    if (self.parsedItems.count > kCountForNotification) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parser:didParseItems:)]) {
            [self.delegate parser:self didParseItems:parsedItems];
        }
        [self.parsedItems removeAllObjects];
    }
}

- (BOOL)parseElementListItem:(NSString *)elementName {
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parser:isElementListItem:)]) {
		return [self.delegate parser:self isElementListItem:elementName];
	}
	return NO;
}

- (void)parseError:(NSError *)error {
    NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parser:didFailWithError:)]) {
        [self.delegate parser:self didFailWithError:error];
    }
}

- (void)addToParseDuration:(NSNumber *)duration {
    NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
    parseDuration += [duration doubleValue];
}

@end
