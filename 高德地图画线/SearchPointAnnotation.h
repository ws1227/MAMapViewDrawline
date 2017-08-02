//
//  SearchPointAnnotation.h
//  PinganBus
//
//  Created by panhongliu on 2017/7/28.
//  Copyright © 2017年 wangsen. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

@interface SearchPointAnnotation : NSObject<MAAnnotation>

@property(nonatomic,assign)NSInteger index;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;


- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
