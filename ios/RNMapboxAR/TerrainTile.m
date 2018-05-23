//
//  TerrainTile.m
//  RNLocateTest
//
//  Created by Dave Prukop on 5/17/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "TerrainTile.h"
#import "MapboxManager.h"

@implementation TerrainTile

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
  self = [super init];
  if (self) {
    self.url = [dictionary objectForKey:@"url"];
    self.px = [[dictionary objectForKey:@"px"] intValue];
    self.py = [[dictionary objectForKey:@"py"] intValue];
    self.sampleSize = 1;
  }
  return self;
}

- (NSString *)getFormattedURL
{
  return [self.url stringByReplacingOccurrencesOfString:@"{ACCESS_TOKEN}" withString:[MapboxManager getInstance].accessToken];
}

- (int)getWidth
{
  CGImageRef imageRef = [self.bitmap CGImage];
  return (int) CGImageGetWidth(imageRef);
}

- (int)getHeight
{
  CGImageRef imageRef = [self.bitmap CGImage];
  return (int) CGImageGetHeight(imageRef);
}

//- (NSArray<NSNumber *> *)getPixels
//{
//  CGImageRef imageRef = [self.bitmap CGImage];
//  
//}
//
//- (int)getPixelWithX:(int)x andY:(int)y
//{
//  
//}

- (void)setBitmap:(UIImage *)bitmap withSampleSize:(int)sampleSize
{
  self.bitmap = bitmap;
  self.sampleSize = sampleSize;
}

@end
