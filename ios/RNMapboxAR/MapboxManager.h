//
//  MapboxManager.h
//  RNLocateTest
//
//  Created by Dave Prukop on 4/30/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapboxManager : NSObject

+ (MapboxManager *)getInstance;

@property (nonatomic, strong) NSString *accessToken;

@end
