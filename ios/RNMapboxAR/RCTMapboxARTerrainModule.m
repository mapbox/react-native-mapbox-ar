//
//  RCTMapboxARTerrainModule.m
//  RNLocateTest
//
//  Created by Dave Prukop on 5/14/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "RCTMapboxARTerrainModule.h"

#import "MapboxManager.h"
#import "TerrainService.h"

@implementation RCTMapboxARTerrainModule

RCT_EXPORT_MODULE();

RCT_REMAP_METHOD(createMesh, createMeshWithOptions:(NSDictionary *)options withResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  NSString *accessToken = [MapboxManager getInstance].accessToken;
  TerrainService *terrainService = [[TerrainService alloc] initWithOptions:options completion:^(NSDictionary *localObjectURLs) {
    resolve(localObjectURLs);
  }];
}

@end
