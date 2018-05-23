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

- (CGFloat)scaleElevation:(CGFloat)elevation withZoomLevel:(CGFloat)zoomLevel {
  CGFloat M_TO_PX_SCALAR = 40075000.0;
  return elevation / fabs(M_TO_PX_SCALAR * cos(M_PI / 180) / (pow(2.0, zoomLevel) * 256));
}

@end
