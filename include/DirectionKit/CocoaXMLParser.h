/*
 Abstract: Subclass of XmlParseEngine that uses the Foundation framework's 
 NSXMLParser for parsing the XML data.
 */

#import <UIKit/UIKit.h>
#import "XmlParseEngine.h"

@interface CocoaXMLParser : XmlParseEngine {
@private
    NSMutableString *currentString;
    id currentItem;
    BOOL storingCharacters;
    NSDateFormatter *parseFormatter;
}

+ (CocoaXMLParser *)parserWithDelegate:(<XmlParseEngineDelegate>)target;

- (void)downloadAndParse:(NSURL *)url;

@end
