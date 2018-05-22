//
//  BitmapUtils.h
//  RNLocateTest
//
//  Created by Dave Prukop on 5/17/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BitmapUtils : NSObject

+ (UIImage *)getBitmapFromURL:(NSString *)url withOptions:(NSDictionary *)options;

@end
