//
//  BitmapUtils.m
//  RNLocateTest
//
//  Created by Dave Prukop on 5/17/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "BitmapUtils.h"

@implementation BitmapUtils

+ (UIImage *)getBitmapFromURL:(NSString *)url withOptions:(NSDictionary *)options
{
  NSData *data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: url]];
  UIImage *fullSizeImage = [UIImage imageWithData:data];
  CGImageRef imageRef = [fullSizeImage CGImage];
//  return [UIImage imageWithCGImage:imageRef];
  return [UIImage imageWithCGImage:imageRef scale:[[options objectForKey:@"sampleSize"] integerValue] orientation:UIImageOrientationUp];
}

@end
