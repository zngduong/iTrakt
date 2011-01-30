#import "Trakt.h"

@interface Helper : NSObject {
}

+ (NSString *)stringFromUTF8Data:(NSData *)data;

+ (BOOL)image:(UIImage *)image1 equalToImage:(UIImage *)image2;

@end

@implementation Helper

+ (NSString *)stringFromUTF8Data:(NSData *)data {
  NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (BOOL)image:(UIImage *)image1 equalToImage:(UIImage *)image2 {
  return [UIImagePNGRepresentation(image1) isEqualToData:UIImagePNGRepresentation(image2)];
}

@end


@interface Trakt (SpecHelper)

- (void)calendarWithNuBlock:(id)nuBlock;

- (void)loadImageFromURL:(NSURL *)URL nuBlock:(id)nuBlock;

@end

@implementation Trakt (SpecHelper)

- (void)calendarWithNuBlock:(id)nuBlock {
  [self calendar:^(NSArray *broadcastDates) {
    id args = [[NSArray arrayWithObject:broadcastDates] performSelector:@selector(list)];
    id context = [nuBlock performSelector:@selector(context)];
    [nuBlock performSelector:@selector(evalWithArguments:context:) withObject:args withObject:context];
  }];
}

- (void)loadImageFromURL:(NSURL *)URL nuBlock:(id)nuBlock {
  [self loadImageFromURL:URL block:^(UIImage *image, BOOL cached) {
    id args = [[NSArray arrayWithObjects:image, [NSNumber numberWithBool:cached], nil] performSelector:@selector(list)];
    id context = [nuBlock performSelector:@selector(context)];
    [nuBlock performSelector:@selector(evalWithArguments:context:) withObject:args withObject:context];
  }];
}

@end


@interface HTTPDownload (SpecHelper)

+ (id)downloadFromURL:(NSURL *)theURL nuBlock:(id)nuBlock;

@end

@implementation HTTPDownload (SpecHelper)

+ (id)downloadFromURL:(NSURL *)theURL nuBlock:(id)nuBlock {
  return [self downloadFromURL:theURL block:^(id response) {
    id args = [[NSArray arrayWithObject:response] performSelector:@selector(list)];
    id context = [nuBlock performSelector:@selector(context)];
    [nuBlock performSelector:@selector(evalWithArguments:context:) withObject:args withObject:context];
  }];
}

@end
