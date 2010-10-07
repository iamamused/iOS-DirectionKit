//
//  DKGoogleDirections.m
//  DirectionKit
//
//  The MIT License
//
//  Copyright (c) 2010 Jeffrey Sambells, TropicalPixels
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "DirectionKit.h"
#import "CJSONDeserializer.h"
#import <CommonCrypto/CommonDigest.h> // Need to import for CC_MD5 access

/* cache update interval in seconds */
const double DKURLCacheInterval = 86400.0;

@interface DKGoogleDirections (PrivateMethods)
- (void) doRequest:(NSURL *)url;
- (void) getFileModificationDate;
- (void) initCache;
- (void) _parseResponse:(NSData *)responseData;
- (NSString *)urlHash:(NSString *)source;
@end

@implementation DKGoogleDirections

@synthesize dataPath;
@synthesize filePath;
@synthesize fileDate;
@synthesize urlArray;
@synthesize connection;

- (id)initWithDelegate:(id<DKDirectionsDelegate>)delegate;
{
	if (self = [super init]) {
		_cancelled = NO;
		dirDelegate = delegate;
		
		/* turn off the NSURLCache shared cache */
		
		NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0
																diskCapacity:0
																	diskPath:nil];
		[NSURLCache setSharedURLCache:sharedCache];
		[sharedCache release];
		
		/* prepare to use our own on-disk cache */
		[self initCache];
		
		/* create and load the URL array using the strings stored in URLCache.plist */
		
		NSString *path = [[NSBundle mainBundle] pathForResource:@"URLCache" ofType:@"plist"];
		if (path) {
			NSArray *array = [[NSArray alloc] initWithContentsOfFile:path];
			self.urlArray = [NSMutableArray array];
			for (NSString *element in array) {
				[self.urlArray addObject:[NSURL URLWithString:element]];
			}
			[array release];
		}
		
		
	}
	return self;
}

- (void)loadDirectionsThroughWaypoints:(NSArray *)waypoints;
{
	
	[dirDelegate didStartWithWaypoints:waypoints];

	// position the waypoints.
	int pos = 0;
	for (DKWaypoint *wp in waypoints) {
		[wp setPosition:++pos];
	}
	
	_wp = [waypoints retain];
	
	DKWaypoint *o = [waypoints objectAtIndex:0];
	DKWaypoint *d = [waypoints lastObject];
	
	NSString *origin = [NSString stringWithFormat:@"%f,%f", o.coordinate.latitude, o.coordinate.longitude ];
	NSString *desitnation = [NSString stringWithFormat:@"%f,%f", d.coordinate.latitude, d.coordinate.longitude ];

	NSString *waypointList = @"";
	
	if ([waypoints count] > 2) {
		
		DKWaypoint *wp = [waypoints objectAtIndex:1];
		waypointList = [NSString stringWithFormat:@"%f,%f",wp.coordinate.latitude, wp.coordinate.longitude];
		for (int i = 2; i < [waypoints count] - 1; i++) {
			wp = [waypoints objectAtIndex:i];
			waypointList = [NSString stringWithFormat:@"%@|%f,%f",waypointList,wp.coordinate.latitude, wp.coordinate.longitude];
		}
	}
	
	NSString *assembled = [NSString stringWithFormat:
						   @"%@?origin=%@&destination=%@&waypoints=%@&sensor=false",
						   @"http://maps.google.com/maps/api/directions/json",
						   [origin stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
						   [desitnation stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
						   waypointList];
	
	
	NSString *escapedURL = [assembled stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	NSURL *url = [NSURL URLWithString:escapedURL];
	[self doRequest:url];
}

#pragma mark -
#pragma mark URLCacheConnectionDelegate methods

- (void) connectionDidFail:(DKURLCacheConnection *)theConnection
{

}


- (void) connectionDidFinish:(DKURLCacheConnection *)theConnection
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == YES) {
		
		/* apply the modified date policy */
		
		[self getFileModificationDate];
		NSComparisonResult result = [theConnection.lastModified compare:fileDate];
		if (result == NSOrderedDescending) {
			/* file is outdated, so remove it */
			if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
				//URLCacheAlertWithError(error);
			}
			
		}
	}
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == NO) {
		/* file doesn't exist, so create it */
		[[NSFileManager defaultManager] createFileAtPath:filePath
												contents:theConnection.receivedData
											  attributes:nil];
		
	}
	
	/* reset the file's modification date to indicate that the URL has been checked */
	
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSDate date], NSFileModificationDate, nil];
	if (![[NSFileManager defaultManager] setAttributes:dict ofItemAtPath:filePath error:&error]) {
		//URLCacheAlertWithError(error);
	}
	[dict release];
	
	[self _parseResponse:theConnection.receivedData];
}


#pragma mark -
#pragma mark TouchXML Parsing

-(void) doRequest:(NSURL *)url {
	
	if (_cancelled) return;
	
	
	/* get the path to the cached image */
	
	[filePath release]; /* release previous instance */
	NSString *hash = [self urlHash:[url absoluteString]];
	NSString *fileName = [hash stringByAppendingString:@".json"];
	filePath = [[dataPath stringByAppendingPathComponent:fileName] retain];
	
	/* apply daily time interval policy */
	
	/* In this program, "update" means to check the last modified date
	 of the image to see if we need to load a new version. */
	
	[self getFileModificationDate];
	/* get the elapsed time since last file update */
	NSTimeInterval time = fabs([fileDate timeIntervalSinceNow]);
	if (time > DKURLCacheInterval) {
		NSLog(@"New Query Google Directions API: %@", url);
		_connection = [[DKURLCacheConnection alloc] initWithURL:url delegate:self];
		// @todo call activity start
	} else {
		NSLog(@"Using cached Query for: %@", url);
		//[self getFileModificationDate];
		[self _parseResponse:[NSData dataWithContentsOfFile:filePath]];
	}
}


- (void) _parseResponse:(NSData *)responseData;
{
	
	NSString *jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	
	NSData *jsonData = [jsonString dataUsingEncoding:NSUTF32BigEndianStringEncoding];
	[jsonString release];
	
	NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
	
	NSMutableArray *routes = [NSMutableArray array];
	
	if ( !_cancelled && [[dictionary objectForKey:@"status"] isEqualToString:@"OK"]) {
		NSArray *dkRoutes = [dictionary objectForKey:@"routes"];
		for (NSDictionary *routeDict in dkRoutes) {
			DKRoute *route = [[DKRoute alloc] initWithDict:routeDict];
			[route setWaypoints:_wp];
			[routes addObject:route];
			[route release];
		}
	}
	
	if (!_cancelled) [dirDelegate didFinishWithRoutes:routes];
	
	[_wp release];

}


#pragma mark -
#pragma mark Cacheing


- (void) initCache
{
	/* create path to cache directory inside the application's Documents directory */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"URLCache"];
	
	/* check for existence of cache directory */
	if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
		return;
	}
	
	/* create a new cache directory */
	if (![[NSFileManager defaultManager] createDirectoryAtPath:dataPath
								   withIntermediateDirectories:NO
													attributes:nil
														 error:&error]) {
		//URLCacheAlertWithError(error);
		return;
	}
}


/* removes every file in the cache directory */

- (void) clearCache
{
	/* remove the cache directory and its contents */
	if (![[NSFileManager defaultManager] removeItemAtPath:dataPath error:&error]) {
		//URLCacheAlertWithError(error);
		return;
	}
	
	/* create a new cache directory */
	if (![[NSFileManager defaultManager] createDirectoryAtPath:dataPath
								   withIntermediateDirectories:NO
													attributes:nil
														 error:&error]) {
		//URLCacheAlertWithError(error);
		return;
	}
	
}


/* get modification date of the current cached image */

- (void) getFileModificationDate
{
	/* default date if file doesn't exist (not an error) */
	self.fileDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		/* retrieve file attributes */
		NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
		if (attributes != nil) {
			self.fileDate = [attributes fileModificationDate];
		} else {
			//URLCacheAlertWithError(error);
		}
	}
}

- (NSString *)urlHash:(NSString *)source {
	// MD5
	const char *src = [source UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(src, strlen(src), result);
    NSString *ret = [[[NSString alloc] initWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
					  result[0], result[1], result[2], result[3],
					  result[4], result[5], result[6], result[7],
					  result[8], result[9], result[10], result[11],
					  result[12], result[13], result[14], result[15]
					  ] autorelease];
    return [ret lowercaseString];
}


#pragma mark -
#pragma mark Cancelling
- (void)cancel;
{
	if (_connection != nil) {
		[_connection cancel];
	}
	_cancelled = YES;
}

#pragma mark -
#pragma Memory Management
- (void)dealloc {
	
	[dataPath release];
	[filePath release];
	[fileDate release];
	[urlArray release];
	[connection release];
	
	[_connection release];
	[super dealloc];
}
@end
