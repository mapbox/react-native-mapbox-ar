//
//  TerrainTile.h
//  RNLocateTest
//
//  Created by Dave Prukop on 5/17/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TerrainTile : NSObject

@property (nonatomic, strong) NSString *url;
@property (assign) int px;
@property (assign) int py;
@property (assign) int sampleSize;
@property (nonatomic, strong) UIImage *bitmap;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSString *)getFormattedURL;
- (int)getWidth;
- (int)getHeight;
//- (NSArray<NSNumber *> *)getPixels;
//- (int)getPixelWithX:(int)x andY:(int)y;
- (void)setBitmap:(UIImage *)bitmap withSampleSize:(int)sampleSize;

@end
