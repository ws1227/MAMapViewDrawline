//
//  SearchPointAnnotation.m
//  PinganBus
//
//  Created by panhongliu on 2017/7/28.
//  Copyright © 2017年 wangsen. All rights reserved.
//

#import "SearchPointAnnotation.h"

@implementation SearchPointAnnotation

@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize coordinate = _coordinate;
@synthesize index = _index;


#pragma mark - life cycle

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (self = [super init])
    {
        self.coordinate = coordinate;
    }
    return self;
}

@end
