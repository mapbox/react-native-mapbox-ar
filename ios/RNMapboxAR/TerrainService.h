//
//  TerrainService.h
//  RNLocateTest
//
//  Created by Dave Prukop on 5/1/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TerrainService : NSObject

- (instancetype)initWithX:(float)x andY:(float)y andZoom:(float)zoom completion:(void (^)(NSDictionary *localObjectURLs))callback;
- (instancetype)initWithOptions:(NSDictionary *)options completion:(void (^)(NSDictionary *localObjectURLs))callback;

@end
