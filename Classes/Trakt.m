#import "EGOCache.h"
#import "HTTPDownload.h"
#import <CommonCrypto/CommonDigest.h>

#import "Trakt.h"
#import "BroadcastDate.h"

#import "Show.h"
#import "Episode.h"

@implementation Trakt

static Trakt *sharedTrakt = nil;

+ (Trakt *)sharedInstance{
  if (sharedTrakt == nil) {
    sharedTrakt = [[Trakt alloc] init];
    sharedTrakt.baseURL = BASE_URL;
  }
  return sharedTrakt;
}

@synthesize baseURL;

@synthesize apiUser;
@synthesize apiPasswordHash;

- (void)setApiPassword:(NSString *)password {
  const char *cstr = [password cStringUsingEncoding:NSUTF8StringEncoding];
  NSData *data = [NSData dataWithBytes:cstr length:[password length]];

  uint8_t digest[CC_SHA1_DIGEST_LENGTH];
  CC_SHA1([data bytes], [data length], digest);

  NSMutableString* result = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
  for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
    [result appendFormat:@"%02x", digest[i]];
  }
  apiPasswordHash = [[result copy] retain];
}

- (NSURL *)calendarURL {
  return [NSURL URLWithString:[NSString stringWithFormat:@"%@/users/calendar.json?name=%@", self.baseURL, self.apiUser, nil]];
}

- (void)calendar:(void (^)(NSArray *broadcastDates))block {
  //NSLog(@"[!] Start download of calendar data");
  [JSONDownload downloadFromURL:[self calendarURL] block:^(id response) {
    //NSLog(@"[!] Finished download of calendar data");
    NSMutableArray *dates = [NSMutableArray array];
    for(NSDictionary *episodeDict in (NSArray *)response) {
      BroadcastDate *d = [[BroadcastDate alloc] initWithDictionary:episodeDict];
      [dates addObject:d];
      [d release];
    }
    block([[dates copy] autorelease]);
  }];
}

- (NSURL *)libraryURL {
  return [NSURL URLWithString:[NSString stringWithFormat:@"%@/users/library.json?name=%@", self.baseURL, self.apiUser, nil]];
}

- (void)library:(void (^)(NSArray *shows))block {
  //NSLog(@"[!] Start download of calendar data from: %@", [self libraryURL]);
  [JSONDownload downloadFromURL:[self libraryURL] block:^(id response) {
    //NSLog(@"[!] Finished download of calendar data");
    NSMutableArray *shows = [NSMutableArray array];
    for(NSDictionary *showDict in (NSArray *)response) {
      Show *s = [[Show alloc] initWithDictionary:showDict];
      [shows addObject:s];
      [s release];
    }
    block([[shows copy] autorelease]);
  }];
}

- (NSURL *)trendingURL {
  return [NSURL URLWithString:[NSString stringWithFormat:@"%@/shows/trending.json", self.baseURL, nil]];
}

- (void)trending:(void (^)(NSArray *shows))block {
  //NSLog(@"[!] Start download of calendar data from: %@", [self libraryURL]);
  [JSONDownload downloadFromURL:[self trendingURL] block:^(id response) {
    //NSLog(@"[!] Finished download of calendar data");
    NSMutableArray *shows = [NSMutableArray array];
    for(NSDictionary *showDict in (NSArray *)response) {
      Show *s = [[Show alloc] initWithDictionary:showDict];
      [shows addObject:s];
      [s release];
    }
    block([[shows copy] autorelease]);
  }];
}


- (NSURL *)seasonsURL:(NSString *)tvdb_id {
  return [NSURL URLWithString:[NSString stringWithFormat:@"%@/shows/%@/seasons_with_episodes?name=%@", self.baseURL, tvdb_id, self.apiUser, nil]];
}

- (void)seasons:(NSString *)tvdb_id block:(void (^)(NSArray *seasons))block {
  // NSLog(@"[!] Start download of season data from: %@", tvdb_id);
  [JSONDownload downloadFromURL:[self seasonsURL:tvdb_id] block:^(id response) {
    // NSLog(@"[!] Finished download of season data");
    NSMutableArray *seasons = [NSMutableArray array];
    for(NSDictionary *seasonDict in (NSArray *)response) {
      // NSLog([response description]);
      [seasons addObject:seasonDict];
    }
    block([[seasons copy] autorelease]);
  }];
}


- (UIImage *)cachedShowPosterForURL:(NSURL *)posterURL {
  return [self cachedImageForURL:posterURL scaledTo:CGSizeMake(44.0, 66.0)];
}

- (void)showPosterForURL:(NSURL *)posterURL block:(void (^)(UIImage *poster, BOOL cached))block {
  [self loadImageFromURL:posterURL scaledTo:CGSizeMake(44.0, 66.0) block:block];
}

- (void)showThumbForURL:(NSURL *)thumbURL block:(void (^)(UIImage *thumb, BOOL cached))block {
  [self loadImageFromURL:thumbURL block:block];
}


# pragma The abstracted methods that deal with the API

- (NSURL *)URLForImageURL:(NSURL *)URL scaledTo:(CGSize)scaledTo {
  NSURL *_URL = URL;
  if (!CGSizeEqualToSize(scaledTo, CGSizeZero)) {
    NSString *filename = [NSString stringWithFormat:@"%dx%d-%@", (int)scaledTo.width, (int)scaledTo.height, [_URL lastPathComponent]];
    _URL = [[_URL URLByDeletingLastPathComponent] URLByAppendingPathComponent:filename];
  }
  return _URL;
}

- (UIImage *)cachedImageForURL:(NSURL *)URL {
  return [self cachedImageForURL:URL scaledTo:CGSizeZero];
}

- (UIImage *)cachedImageForURL:(NSURL *)URL scaledTo:(CGSize)scaledTo {
  NSURL *_URL = [self URLForImageURL:URL scaledTo:scaledTo];
  NSString *filename = [_URL lastPathComponent];
  //NSLog(@"Cache key: %@", filename);
  if ([[EGOCache currentCache] hasCacheForKey:filename]) {
     return [UIImage imageWithData:[[EGOCache currentCache] dataForKey:filename]];
  } else {
    return nil;
  }
}

- (void)removeCachedImageForURL:(NSURL *)URL {
  [[EGOCache currentCache] removeCacheForKey:[URL lastPathComponent]];
}

- (void)removeCachedImageForURL:(NSURL *)URL scaledTo:(CGSize)scaledTo {
  [self removeCachedImageForURL:[self URLForImageURL:URL scaledTo:scaledTo]];
}

- (void)loadImageFromURL:(NSURL *)URL block:(void (^)(UIImage *image, BOOL cached))block {
  [self loadImageFromURL:URL scaledTo:CGSizeZero block:block];
}

- (void)loadImageFromURL:(NSURL *)URL scaledTo:(CGSize)scaledTo block:(void (^)(UIImage *image, BOOL cached))block {
  NSURL *_URL = [self URLForImageURL:URL scaledTo:scaledTo];

  UIImage *cachedImage = [self cachedImageForURL:_URL];
  //UIImage *cachedImage = nil; // Force download for debugging purposes.
  if (cachedImage) {
    block(cachedImage, YES);
  } else {
    // download from the actual URL, not the scaled down identifier
    [ImageDownload downloadFromURL:URL resizeTo:scaledTo block:^(id image) {
      [[EGOCache currentCache] setImage:image forKey:[_URL lastPathComponent]];
      block(image, NO);
    }];
  }
}


@end
