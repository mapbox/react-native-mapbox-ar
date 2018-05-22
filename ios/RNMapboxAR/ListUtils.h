//
//  ListUtils.h
//  RNLocateTest
//
//  Created by Dave Prukop on 5/4/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ListUtils : NSObject

+ (NSString *)join:(NSArray<NSString *> *)list withDelimiter:(NSString *)delimiter;

@end
