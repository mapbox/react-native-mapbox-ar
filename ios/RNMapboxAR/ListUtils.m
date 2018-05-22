//
//  ListUtils.m
//  RNLocateTest
//
//  Created by Dave Prukop on 5/4/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "ListUtils.h"

@implementation ListUtils

+ (NSString *)join:(NSArray<NSString *> *)list withDelimiter:(NSString *)delimiter
{
  NSMutableString *builder = [[NSMutableString alloc] init];
  
  for (int i=0; i<[list count]; i++) {
    NSString *item = [list objectAtIndex:i];
    
    if (i == [list count] - 1) {
      [builder appendString:item];
    } else {
      [builder appendString:[NSString stringWithFormat:@"%@%@", item, delimiter]];
    }
  }
       
  return [NSString stringWithString:builder];
}

@end
