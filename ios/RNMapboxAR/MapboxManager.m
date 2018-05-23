//
//  MapboxManager.m
//  RNLocateTest
//
//  Created by Dave Prukop on 4/30/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "MapboxManager.h"

@implementation MapboxManager

static MapboxManager *INSTANCE = nil;

@synthesize accessToken;

+ (MapboxManager *)getInstance
{
  if (INSTANCE == nil) {
    INSTANCE = [[MapboxManager alloc] init];
  }
  return INSTANCE;
}

@end
