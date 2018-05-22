//
//  RCTMapboxARModule.m
//  RNLocateTest
//
//  Created by Dave Prukop on 4/18/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "RCTMapboxARModule.h"
#import <React/RCTLog.h>

#import "MapboxManager.h"

NSString * const SET_MAPBOX_TOKEN = @"You must set your Mapbox access token";

@implementation RCTMapboxARModule

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(setAccessToken:(NSString *)accessToken) {
//  Set in mapbox manager
  [[MapboxManager getInstance] setAccessToken:accessToken];
}

RCT_REMAP_METHOD(getAccessToken, getAccessTokenPromiseWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  NSString *accessToken = [MapboxManager getInstance].accessToken;
  if (accessToken != nil && ![accessToken isEqualToString:@""]) {
    resolve(accessToken);
  } else {
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:1 userInfo:nil];
    reject(@"accessToken_not_set", @"You must set your Mapbox access token", error);
  }
}

RCT_REMAP_METHOD(assertAccessToken, assertAccessTokenPromiseWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  MapboxManager *mapboxManager = [MapboxManager getInstance];
  if (mapboxManager == nil) {
    NSError *error = [NSError errorWithDomain:NSNetServicesErrorDomain code:-1 userInfo:nil];
    reject(@"-1", SET_MAPBOX_TOKEN, error);
  }
}

//RCT_REMAP_METHOD(getTerrainObjectUri, getTerrainObjectUriPromiseWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
//  TerrainService *terrainService = [[TerrainService alloc] initWithX:37.0 andY:119.0 andZoom:8 completion:^(NSDictionary *localObjectURLs) {
//    resolve(localObjectURLs);
//  }];
//}

  
//  set up background thread
//  resolve promise once the terrain object is complete and has a uri
//  dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
//    //Background Thread
//    NSString *URLString = [NSString stringWithFormat: @"https://api.mapbox.com/v4/mapbox.terrain-rgb/%@/%@/%@.pngraw?access_token=%@", @"8", @"44", @"98", @"pk.eyJ1IjoiZHBydWtvcCIsImEiOiJjajVoYTBwbmoxMWpiMnFtbjUyODB5ZjVjIn0.q13qDMBDowtdidGHTSIucQ"];
//    NSData *data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: URLString]];
//    UIImage *image = [UIImage imageWithData:data];
//
//    CGImageRef imageRef = [image CGImage];
//    NSUInteger width = CGImageGetWidth(imageRef);
//    NSUInteger height = CGImageGetHeight(imageRef);
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
//    NSUInteger bytesPerPixel = 4;
//    NSUInteger bytesPerRow = bytesPerPixel * width;
//    NSUInteger bitsPerComponent = 8;
//    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
//                                                 bitsPerComponent, bytesPerRow, colorSpace,
//                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
//    CGColorSpaceRelease(colorSpace);
//    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
//    CGContextRelease(context);
//
//    NSUInteger numPixels = width * height;
//
//    CGFloat maxElevation = CGFLOAT_MIN;
//    CGFloat minElevation = CGFLOAT_MAX;
//    NSMutableArray *elevation = [[NSMutableArray alloc] initWithCapacity:numPixels];
//
//    NSUInteger byteIndex = 0;
//    for (int i=0; i<numPixels; i++) {
//      CGFloat R   = (CGFloat) rawData[byteIndex];
//      CGFloat G = (CGFloat) rawData[byteIndex + 1];
//      CGFloat B  = (CGFloat) rawData[byteIndex + 2];
//      byteIndex += bytesPerPixel;
//
//      CGFloat curElevation = ((R * 256 * 256 + G * 256 + B) / 10) - 10000;
//      CGFloat elevationValue = [self scaleElevation:curElevation withZoomLevel:8];
//      [elevation addObject:[[NSNumber alloc] initWithFloat:elevationValue]];
//
//      if (curElevation < minElevation) {
//        minElevation = curElevation;
//      }
//
//      if (curElevation > maxElevation) {
//        maxElevation = curElevation;
//      }
//    }
//
//    dispatch_sync(dispatch_get_main_queue(), ^(void) {
////      resolve(URLString);
//      resolve([NSArray arrayWithArray:elevation]);
//    });
//  });

- (CGFloat)scaleElevation:(CGFloat)elevation withZoomLevel:(CGFloat)zoomLevel {
  CGFloat M_TO_PX_SCALAR = 40075000.0;
  return elevation / fabs(M_TO_PX_SCALAR * cos(M_PI / 180) / (pow(2.0, zoomLevel) * 256));
}

@end
