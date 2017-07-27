//
//  ViewController.m
//  高德地图画线
//
//  Created by panhongliu on 2017/7/27.
//  Copyright © 2017年 com.wangsen.demo. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>
#import "UserLocation.h"
#import <MAMapKit/MAPolylineRenderer.h>
@interface ViewController ()<MAMapViewDelegate>
{
    /**获取经纬度数组*/
    CLLocationCoordinate2D * _coors;
}
@property (nonatomic, strong) MAUserLocation *currentUL;//当前位置

@property(nonatomic,strong)NSMutableArray *pointArr;
@property(nonatomic,strong)MAMapView *mapView;
@property (nonatomic, strong) MAPolyline *routeLine;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pointArr = [NSMutableArray array];//存储轨迹的数组.
    [self setMapView];

    // Do any additional setup after loading the view, typically from a nib.
}- (void)setMapView {
    
    
    //地图初始化
    self.mapView = [[MAMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _mapView.backgroundColor = [UIColor whiteColor];
    self.mapView.delegate = self;
    //设置定位精度
    _mapView.desiredAccuracy = kCLLocationAccuracyBest;
    //设置定位距离
    _mapView.distanceFilter = 1.0f;
    //普通样式
    _mapView.mapType = MAMapTypeStandard;
    //地图跟着位置移动
    [_mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
    //设置成NO表示关闭指南针；YES表示显示指南针
    _mapView.showsCompass= YES;
    //设置指南针位置
    _mapView.compassOrigin= CGPointMake(_mapView.compassOrigin.x, 22);
    //设置成NO表示不显示比例尺；YES表示显示比例尺
    _mapView.showsScale= YES;
    //设置比例尺位置
    _mapView.scaleOrigin= CGPointMake(_mapView.scaleOrigin.x, 22);
    //开启定位
    _mapView.showsUserLocation = YES;
    //缩放等级
    [_mapView setZoomLevel:18 animated:YES];
    
//    //防止系统自动杀掉定位 -- 后台定位
//    _mapView.pausesLocationUpdatesAutomatically = NO;
//    _mapView.allowsBackgroundLocationUpdates = YES;
    [self.view addSubview:self.mapView];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self drawLine];

    });
}


//定位失败
- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    NSString *errorString = @"";
    switch([error code]) {
        case kCLErrorDenied:
            //Access denied by user
            errorString = @"Access to Location Services denied by user";
            break;
        case kCLErrorLocationUnknown:
            //Probably temporary...
            errorString = @"Location data unavailable";
            //Do something else...
            break;
        default:
            errorString = @"An unknown error has occurred";
            break;
    }
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    
    if (!updatingLocation && userLocation.coordinate.latitude>0&&userLocation.coordinate.longitude>0)
    {
    
        
        [UIView animateWithDuration:0.1 animations:^{
            
            
            UserLocation *u = [[UserLocation alloc] init];
            
            u.latitude= userLocation.location.coordinate.latitude;
            
            u.longitude = userLocation.location.coordinate.longitude;
            if (_pointArr.count == 0){
                [_pointArr addObject:u];
            }
            
            else
                
            {
                
                UserLocation *u11 = [_pointArr lastObject];
                
                MAMapPoint point1 = MAMapPointForCoordinate(CLLocationCoordinate2DMake(u11.latitude,u11.longitude));
                MAMapPoint point2 = MAMapPointForCoordinate(CLLocationCoordinate2DMake(u.latitude,u.longitude));
                CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
                //判断两个点的距离  大于等于2米时才画下一条路径
                if (distance >=2)
                    
                {
                    
                    [_pointArr addObject:u];
                    
                    UserLocation *u1 = [_pointArr objectAtIndex:_pointArr.count - 2];
                    
                 UserLocation *u2 = _pointArr.lastObject;CLLocationCoordinate2D commonPolylineCoords[2];commonPolylineCoords[0].latitude = u1.latitude;
                    commonPolylineCoords[0].longitude = u1.longitude;
                    commonPolylineCoords[1].latitude = u2.latitude;
                    commonPolylineCoords[1].longitude = u2.longitude;
                    
                    //构造折线对象
                    
                    MAPolyline *commonPolyline = [MAPolyline polylineWithCoordinates:commonPolylineCoords count:2];
                    
                    
                    [_mapView addOverlay: commonPolyline];
                    
                    //设置地图中心位置
                    
                    _mapView.centerCoordinate = userLocation.location.coordinate;;
                }
                
            }
        }];
        
        
    }
    
}



-(void)drawLine
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"point" ofType:@"plist"];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSMutableArray * locationArray = [dictionary objectForKey:@"location"];
    const int  Max  = (int)locationArray.count;
    
    _coors = (CLLocationCoordinate2D *)malloc(Max * sizeof(CLLocationCoordinate2D));
    
    for(int index = 0; index < Max; index++) {
            _coors[index].latitude = [[locationArray[index] objectForKey:@"lat"] doubleValue];
            //            points[0].latitude =39.9083017400;
            _coors[index].longitude = [[locationArray[index] objectForKey:@"lon"] doubleValue];

        }
    

    
    if (self.routeLine) {
        [self.mapView removeOverlay:self.routeLine];
    }
    [_mapView setCenterCoordinate:_coors[0]]; //起点作为地图中心

    self.routeLine = [MAPolyline polylineWithCoordinates:_coors count:Max];
    if (nil != self.routeLine) {
        //将折线绘制在地图底图标注和兴趣点图标之下
        [self.mapView addOverlay:self.routeLine];
    }

    
}

//画线方法
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
    //画线
{
if   ([overlay isKindOfClass:[MAPolyline class]])
{
    MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
     polylineRenderer.strokeColor = [UIColor blueColor];
     polylineRenderer.lineWidth   = 5.f;

        return polylineRenderer;
//    }
    }
    return nil;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
