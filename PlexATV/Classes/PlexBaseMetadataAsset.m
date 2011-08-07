//
//  PlexBaseMetadataAsset.m
//  atvTwo
//
//  Created by Frank Bauer on 27.10.10.
//  Modified by Bob Jelica & ccjensen
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
#import "PlexBaseMetadataAsset.h"
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexMediaContainer.h>
#import <plex-oss/PlexRequest.h>
#import <plex-oss/Machine.h>
#import <plex-oss/PlexImage.h>

@interface BRThemeInfo (PlexExtentions)
- (id)storeRentalPlaceholderImage;
@end

@implementation PlexBaseMetadataAsset
@synthesize mediaObject;

#pragma mark -
#pragma mark Object/Class Lifecycle
- (id)initWithURL:(NSURL*)u mediaProvider:(id)mediaProvider mediaObject:(PlexMediaObject*)o {
	self = [super initWithMediaProvider:mediaProvider];
	if (self != nil) {
		self.mediaObject = o;
	}
	return self;
}

- (void)dealloc {
    self.mediaObject = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark BRMediaAsset
//- (void *)createMovieWithProperties:(void *)properties count:(long)count {
//	
//}

- (id)artist {
	if ([self.mediaObject.attributes objectForKey:@"artist"])
		return [self.mediaObject.attributes objectForKey:@"artist"];
	else
		return [self.mediaObject.mediaContainer.attributes valueForKey:@"title1"];
}

- (id)artistCollection {
	return nil;
}

- (id)artistForSorting {
	return self.artist;
}

- (id)assetID {
	return self.mediaObject.key;
}

- (id)authorName {
	return nil;
}

- (unsigned int)bookmarkTimeInSeconds {
	return 0;
}

- (void)setBookmarkTimeInSeconds:(unsigned int)fp8 {}

- (unsigned int)bookmarkTimeInMS {
	return 0;
}

- (void)setBookmarkTimeInMS:(unsigned int)fp8 {}

- (id)broadcaster {
	return [self.mediaObject.attributes valueForKey:@"studio"];
}

- (BOOL)canBePlayedInShuffle {
	return YES;
}

- (id)cast {
	NSString *result = [self.mediaObject listSubObjects:@"Role" usingKey:@"tag"];
	return [result componentsSeparatedByString:@", "];
}

- (id)category {
	return nil;
}

- (void)cleanUpPlaybackContext {}

- (BOOL)closedCaptioned {
    //TODO: return correct value
	return NO;
}

- (id)collections {
	return nil;
}

- (id)composer {
	return [self authorName];
}

- (id)composerForSorting {
	return [self authorName];
}

- (id)copyright {
	return nil;
}

- (id)coverArt {
    return [BRImage imageWithURL:[[self imageProxy] url]];
}

- (NSString *)coverArtURL {
    return [[[self imageProxy] url] absoluteString];
}

- (id)dateAcquired {
	return self.mediaObject.originallyAvailableAt;
}

- (id)dateAcquiredString {
    NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormat setDateStyle:NSDateFormatterShortStyle];
    return [dateFormat stringFromDate:[self dateAcquired]];
}

- (id)dateCreated {
	return self.mediaObject.originallyAvailableAt;
}

- (id)dateCreatedString {
    NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormat setDateStyle:NSDateFormatterShortStyle];
    return [dateFormat stringFromDate:[self dateCreated]];
}

- (id)datePublished {
	return self.mediaObject.originallyAvailableAt;
}

- (id)datePublishedString {
    NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormat setDateStyle:NSDateFormatterShortStyle];
    return [dateFormat stringFromDate:[self datePublished]];
}

- (id)directors {
	NSString *result = [self.mediaObject listSubObjects:@"Director" usingKey:@"tag"];
	return [result componentsSeparatedByString:@", "];
}

- (BOOL)dolbyDigital {
    //TODO: return correct value
	return YES;
}

-(long int)duration {
	return [self.mediaObject.attributes integerForKey:@"duration"]/1000;
}

- (unsigned)episode {
	return [self.mediaObject.attributes integerForKey:@"index"];
}

- (id)episodeNumber {
	return [NSString stringWithFormat:@"%d", [self episode]];
}

- (BOOL)forceHDCPProtection {
	return NO;
}

- (id)genres {
	NSString *result = [self.mediaObject listSubObjects:@"Genre" usingKey:@"tag"];
	return [result componentsSeparatedByString:@", "];
}

- (int)grFormat {
	return 1;
}

- (BOOL)hasBeenPlayed {
    //TODO: return correct value
	return YES;
}

- (void)setHasBeenPlayed:(BOOL)fp8 {
	return;
}

- (BOOL)hasCoverArt {
	return self.mediaObject.art.hasImage || self.mediaObject.thumb.hasImage;
}

- (BOOL)hasVideoContent {
	return (self.mediaObject.hasMedia || [@"Video" isEqualToString:self.mediaObject.containerType]);
}

- (id)imageProxy {
    NSURLRequest *request = [self URLRequestForCoverArt];
    NSDictionary *headerFields = [request allHTTPHeaderFields];
    BRURLImageProxy *aImageProxy = [BRURLImageProxy proxyWithURL:[request URL] headerFields:headerFields];
    //aImageProxy.writeToDisk = YES;
	return aImageProxy;
}

- (id)imageProxyWithBookMarkTimeInMS:(unsigned int)fp8 {
	return nil;
}

- (void)incrementPerformanceCount {
	return;
}

- (void)incrementPerformanceOrSkipCount:(unsigned)count {
	return;
}

- (BOOL)isAvailable {
	return YES;
}

- (BOOL)isCheckedOut {
	return YES;
}

- (BOOL)isDisabled {
	return NO;
}

- (BOOL)isExplicit {
    //TODO: return correct value
	return NO;
}

- (BOOL)isHD{
	int videoResolution = [[self.mediaObject listSubObjects:@"Media" usingKey:@"videoResolution"] intValue];
	return videoResolution >= 720;
}

- (BOOL)isInappropriate {
    //TODO: return correct value
	return NO;
}

- (BOOL)isLocal {
	return NO;
}

- (BOOL)isPlaying {
	return [super isPlaying];
}

- (BOOL)isPlayingOrPaused {
	return [super isPlayingOrPaused];
}

- (BOOL)isProtectedContent {
	return NO;
}

- (BOOL)isWidescreen {
    //TODO: return correct value
	return YES;
}

- (id)keywords {
	return [NSArray arrayWithObject:@"keyword"];
}

- (id)lastPlayed {
    //TODO: return correct value
	return nil;
}

- (void)setLastPlayed:(id)fp8 {
	return;
}

- (id)mediaDescription {
	return self.mediaObject.summary;
}

- (id)mediaSummary {
	if (![self.mediaObject.summary empty])
		return self.mediaObject.summary;
	else if (self.mediaObject.mediaContainer != nil)
		return [self.mediaObject.mediaContainer.attributes valueForKey:@"summary"];
	
	return nil;
}

- (id)mediaType {	
	NSString *plexMediaType = [self.mediaObject.attributes valueForKey:@"type"];
	BRMediaType *mediaType = nil;
	if ([@"track" isEqualToString:plexMediaType])
		mediaType = [BRMediaType song];
    else if ([PlexMediaObjectTypeShow isEqualToString:plexMediaType])
		mediaType = [BRMediaType movie];
    else if ([PlexMediaObjectTypeSeason isEqualToString:plexMediaType])
		mediaType = [BRMediaType TVShow];
	else if ([PlexMediaObjectTypeEpisode isEqualToString:plexMediaType])
		mediaType = [BRMediaType TVShow];
	else if ([PlexMediaObjectTypeMovie isEqualToString:plexMediaType])
		mediaType = [BRMediaType movie];
	return mediaType;
}

- (long)parentalControlRatingRank {
	return 1;
}

- (long)parentalControlRatingSystemID {
	return 1;
}

- (long)performanceCount {
    //TODO: return correct value
	return 0;
}

- (int)physicalMediaID {
	return 0;
}

- (BOOL)playable {
	return YES;
}

-(id)playbackMetadata {
	DLog(@"Metadata");
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithLong:self.duration], @"duration",
			self.mediaURL, @"mediaURL",
			self.assetID, @"id",
			self.mediaSummary, @"mediaSummary",
			self.mediaDescription, @"mediaDescription",
			self.rating, @"rating",
			[NSNumber numberWithFloat:self.starRating], @"starRating",
            [NSNumber numberWithBool:self.dolbyDigital], @"dolbyDigital",
			nil];
}

- (void)setPlaybackMetadataValue:(id)value forKey:(id)key {}

- (id)playbackRightsOwner {
	return [self.mediaObject.attributes valueForKey:@"studio"];
}

- (void)preparePlaybackContext {}

- (id)previewURL {
	//[super previewURL];
    DLog(@"preview URL");
	return nil;//[[NSURL fileURLWithPath:[self.mediaObject.thumb imagePath]] absoluteString];
}

- (int)primaryCollectionOrder {
	return 0;
}

- (id)primaryCollectionTitle {
	if ([self.mediaObject.attributes objectForKey:@"album"] != nil)
		return [self.mediaObject.attributes objectForKey:@"album"];
	else
		return [self.mediaObject.mediaContainer.attributes valueForKey:@"title2"];
}

- (id)primaryCollectionTitleForSorting {
	return self.primaryCollectionTitle;
}

- (id)primaryGenre {
	NSArray *allGenres = [self genres];
	BRGenre *result = nil;
	if ([allGenres count] > 0) {
		result = [[[BRGenre alloc] initWithString:[allGenres objectAtIndex:0]] autorelease];
	}
	return result;
}

- (id)producers {
	NSString *result = [self.mediaObject listSubObjects:@"Producer" usingKey:@"tag"];
	return [result componentsSeparatedByString:@", "];
}

- (id)provider {
	return nil;
}

- (id)publisher {
	return [self broadcaster];
}

- (id)rating {
	NSString *rating;
	BRMediaType *mediaType = [self mediaType];
	if ([mediaType isEqual:[BRMediaType TVShow]]) {
		rating = [self.mediaObject.mediaContainer.attributes objectForKey:@"grandparentContentRating"];
	} else {
		rating = [self.mediaObject.attributes objectForKey:@"contentRating"];
	}
	return rating;
}

- (id)resolution {
	return [self.mediaObject listSubObjects:@"Media" usingKey:@"videoResolution"];
}

- (unsigned)season {
	int season;
	if ([self.mediaObject.attributes objectForKey:@"parentIndex"] == nil) {
		season = [self.mediaObject.mediaContainer.attributes integerForKey:@"parentIndex"];
	} else {
		season = [self.mediaObject.attributes integerForKey:@"parentIndex"];
	}
	return season;
}

- (id)seriesName {
    //grandparentTitle is usually populated for episodes when coming from dynamic views like "Recently added"
    //whereas mediacontainer.backTitle is used in "All shows->Futurama-Season 1->Episode 4"
	if ([self.mediaObject.attributes objectForKey:@"grandparentTitle"] != nil) {
		return [self.mediaObject.attributes objectForKey:@"grandparentTitle"];    
	} else {
		return self.mediaObject.mediaContainer.backTitle;
    }
}

- (id)seriesNameForSorting {
	return self.seriesName;
}

- (void)skip {}

- (id)sourceID {
	return nil;
}

- (float)starRating {
	//multiply your rating by 2, then round using Math.Round(rating, MidpointRounding.AwayFromZero), then divide that value by 2.
	float rating = [[self.mediaObject.attributes valueForKey:@"rating"] floatValue];
	if (rating > 0) {
		rating = rating / 2; //plex uses 10 based system, atv uses 5 stars
		rating = round(rating * 2.0) / 2.0; //atv supports half stars, so round to nearest half
	}
	return rating;
}

- (unsigned)startTimeInMS {
    return [[self.mediaObject.attributes valueForKey:@"viewOffset"] intValue];
}

- (unsigned)startTimeInSeconds {
	return [[self.mediaObject.attributes valueForKey:@"viewOffset"] intValue] / 1000;
}

- (unsigned)stopTimeInMS {
    //TODO: return correct value
	return 0;
}

- (unsigned)stopTimeInSeconds {
    //TODO: return correct value
	return 0;
}

-(id)title {
	NSString *agentAttr = [self.mediaObject.attributes valueForKey:@"agent"];
	if (agentAttr != nil)
		return nil;
	else
		return self.mediaObject.name;
}

- (id)titleForSorting {
	return [self title];
}

- (id)trickPlayURL {
	return nil;
}

- (void)setUserStarRating:(float)fp8 {}

- (float)userStarRating {
	return [self starRating];
}

- (id)viewCount {
    //TODO: return correct value
	return nil;
}

- (void)willBeDeleted {}


#pragma mark -
#pragma mark Additional Metadata Methods
- (NSURLRequest *)URLRequestForCoverArt {
    return [self URLRequestForCoverArtOfMaxSize:CGSizeMake(512, 512)];
}

- (NSURLRequest *)URLRequestForCoverArtOfMaxSize:(CGSize)imageSize {
    PlexImage *image = nil;
    if (self.mediaObject.thumb.hasImage) {
        image = self.mediaObject.thumb;
    } else if (self.mediaObject.art.hasImage) {
        image = self.mediaObject.art;
    }
    
    image.maxImageSize = imageSize;
    
    return [image imageURLRequest];
}

- (BRImage *)defaultImage {
    return [[[BRThemeInfo sharedTheme] storeRentalPlaceholderImage] autorelease];
}

- (NSURL *)fanartUrl {
    NSURL* fanartUrl = nil;
    
    NSString *artPath = nil;
    if ([self.mediaObject.attributes valueForKey:@"art"]) {
        //movie
        artPath = [self.mediaObject.attributes valueForKey:@"art"];
    } else {
        //tv show
        artPath = [self.mediaObject.mediaContainer.attributes valueForKey:@"art"];
    }
    
    if (artPath) {
		NSString *backgroundImagePath = [NSString stringWithFormat:@"%@%@",self.mediaObject.request.base, artPath];
        fanartUrl = [self.mediaObject.request pathForScaledImage:backgroundImagePath ofSize:[BRWindow interfaceFrame].size];
	}
	return fanartUrl;
}

- (BOOL)hasClosedCaptioning {
	return YES;
}

- (BOOL)hasDolbyDigitalAudioTrack {
	return YES;
}

- (NSString *)mediaURL{
	return nil;
}

- (BRImage *)starRatingImage {
	BRImage *result = nil;
	float starRating = [self starRating];
	if (1.0 == starRating) {
		result = [[SMFThemeInfo sharedTheme] oneStar];
		
	} else if (1.5 == starRating) {
		result = [[SMFThemeInfo sharedTheme] onePointFiveStars];
		
	} else if (2 == starRating) {
		result = [[SMFThemeInfo sharedTheme] twoStars];
		
	} else if (2.5 == starRating) {
		result = [[SMFThemeInfo sharedTheme] twoPointFiveStars];
		
	} else if (3 == starRating) {
		result = [[SMFThemeInfo sharedTheme] threeStar];
		
	} else if (3.5 == starRating) {
		result = [[SMFThemeInfo sharedTheme] threePointFiveStars];
		
	} else if (4 == starRating) {
		result = [[SMFThemeInfo sharedTheme] fourStar];
		
	} else if (4.5 == starRating) {
		result = [[SMFThemeInfo sharedTheme] fourPointFiveStars];
		
	} else if (5 == starRating) {
		result = [[SMFThemeInfo sharedTheme] fiveStars];
	}
	return result;
}

- (NSArray *)writers {
	NSString *result = [self.mediaObject listSubObjects:@"Writer" usingKey:@"tag"];
	return [result componentsSeparatedByString:@", "];
}

- (NSString *)year {
    NSString *year;
	BRMediaType *mediaType = [self mediaType];
	if ([mediaType isEqual:[BRMediaType movie]]) {
        year = [self.mediaObject.attributes valueForKey:@"year"];
    } else {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy"];
        
        NSDate *date = self.mediaObject.originallyAvailableAt;
        year = [dateFormat stringFromDate:date];
        [dateFormat release];
    }
	return year;
}

//-(NSDictionary *)orderedDictionary {
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    
//    [dict setObject:[self title] forKey:METADATA_TITLE];
//    [dict setObject:[self mediaDescription] forKey:METADATA_SUMMARY];
//    [dict setObject:[NSArray arrayWithObjects:@"Genre", @"Released", @"Length", nil] forKey:METADATA_CUSTOM_KEYS];
//    [dict setObject:[NSArray arrayWithObjects:@"test1", @"test2", @"test3", nil] forKey:METADATA_CUSTOM_OBJECTS];
//    DLog(@"dict: %@", dict);
//    return dict;
//}

@end