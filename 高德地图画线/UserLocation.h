//
//  UserLocation.h
//  高德地图画线
//
//  Created by panhongliu on 2017/7/27.
//  Copyright © 2017年 com.wangsen.demo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface UserLocation : NSObject
@property ( nonatomic, strong) CLLocation *location;

@property ( nonatomic, assign)CLLocationDegrees latitude;
@property ( nonatomic, assign)CLLocationDegrees longitude;


@end
