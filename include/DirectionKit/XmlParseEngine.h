#import <UIKit/UIKit.h>

#define XMLParserElementNameKey @"XMLParserElementNameKey"
#define XMLParserElementAttributesKey @"XMLParserElementAttributesKey"
#define XMLParserElementDepthKey @"XMLParserElementDepthKey"

typedef enum {
    XMLParserTypeAbstract = -1,
    XMLParserTypeNSXMLParser = 0,
    XMLParserTypeLibXMLParser
} XMLParserType;

@class XmlParseEngine;

// Protocol for the parser to communicate with its delegate.
@protocol XmlParseEngineDelegate <NSObject>

@optional
// Called to see if the parser should parse the element. Default is YES;
- (BOOL)parser:(XmlParseEngine *)parser isElementListItem:(NSString *)elementName;
// Called by the parser when parsing is finished.
- (void)parserDidEndParsingData:(XmlParseEngine *)parseEngine;
// Called by the parser in the case of an error.
- (void)parser:(XmlParseEngine *)parser didFailWithError:(NSError *)error;
// Called by the parser when one or more songs have been parsed. This method may be called multiple times.
- (void)parser:(XmlParseEngine *)parser didParseItems:(NSArray *)parsedXmlItems;

@end


@interface XmlParseEngine : NSObject {

@private
    id <XmlParseEngineDelegate> delegate;
    NSMutableArray *parsedItems;
    // This time interval is used to measure the overall time the parser takes to download and parse XML.
    NSTimeInterval startTimeReference;
    NSTimeInterval downloadStartTimeReference;
    double parseDuration;
    double downloadDuration;
    double totalDuration;

@protected
	Class itemClass;
}

@property (nonatomic, assign) id <XmlParseEngineDelegate> delegate;

+ (NSString *)parserName;
+ (XMLParserType)parserType;

- (void)start;

- (void)startWithURL:(NSURL *)url itemClass:(Class)classType;

- (Class)itemClass;

// Subclasses must implement this method. It will be invoked on a secondary thread to keep the application responsive.
// Although NSURLConnection is inherently asynchronous, the parsing can be quite CPU intensive on the device, so
// the user interface can be kept responsive by moving that work off the main thread. This does create additional
// complexity, as any code which interacts with the UI must then do so in a thread-safe manner.
- (void)downloadAndParse:(NSURL *)url;

// Subclasses should invoke these methods and let the superclass manage communication with the delegate.
// Each of these methods must be invoked on the main thread.
- (void)downloadStarted;
- (void)downloadEnded;
- (void)parseEnded;
- (void)parsedXmlItem:(id)item;
- (void)parseError:(NSError *)error;
- (void)addToParseDuration:(NSNumber *)duration;

- (BOOL)parseElementListItem:(NSString *)elementName;

@end
