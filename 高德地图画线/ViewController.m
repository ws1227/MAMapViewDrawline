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
#import <AMapLocationKit/AMapLocationKit.h>

@interface ViewController ()<MAMapViewDelegate,AMapGeoFenceManagerDelegate>
{
    /**获取经纬度数组*/
    CLLocationCoordinate2D * _coors;
}
@property (nonatomic, strong) MAUserLocation *currentUL;//当前位置
@property (nonatomic, strong) AMapGeoFenceManager *geoFenceManager;

@property(nonatomic,strong)NSMutableArray *pointArr;
@property(nonatomic,strong)MAMapView *mapView;
@property (nonatomic, strong) MAPolyline *routeLine;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pointArr = [NSMutableArray array];//存储轨迹的数组.
    [self setMapView];

    [self addGeoFencePolygonRegion];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)setMapView {
    
    
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
    
    [self configGeoFenceManager];

    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self drawLine];

    });
}


//初始化地理围栏manager
- (void)configGeoFenceManager {
    self.geoFenceManager = [[AMapGeoFenceManager alloc] init];
    self.geoFenceManager.delegate = self;
    self.geoFenceManager.activeAction = AMapGeoFenceActiveActionInside | AMapGeoFenceActiveActionOutside | AMapGeoFenceActiveActionStayed; //进入，离开，停留都要进行通知
    self.geoFenceManager.allowsBackgroundLocationUpdates = YES;  //允许后台定位
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
    
    if ([overlay isKindOfClass:[MAPolygon class]]) {
        MAPolygonRenderer *polylineRenderer = [[MAPolygonRenderer alloc] initWithPolygon:overlay];
        polylineRenderer.lineWidth = 3.0f;
        polylineRenderer.strokeColor = [UIColor orangeColor];
        
        return polylineRenderer;
    }
    return nil;
}

//添加地理围栏完成后的回调，成功与失败都会调用
- (void)amapGeoFenceManager:(AMapGeoFenceManager *)manager didAddRegionForMonitoringFinished:(NSArray<AMapGeoFenceRegion *> *)regions customID:(NSString *)customID error:(NSError *)error {
    
     if ([customID isEqualToString:@"polygon_1"]) {
        if (error) {
            NSLog(@"=======polygon error %@",error);
        } else {
            AMapGeoFencePolygonRegion *polygonRegion = (AMapGeoFencePolygonRegion *)regions.firstObject;
            MAPolygon *polygonOverlay = [self showPolygonInMap:polygonRegion.coordinates count:polygonRegion.count];
            [self.mapView setVisibleMapRect:polygonOverlay.boundingMapRect edgePadding:UIEdgeInsetsMake(20, 20, 20, 20) animated:YES];
        }

    }

}
//添加多边形围栏按钮点击
- (void)addGeoFencePolygonRegion {
    NSInteger count = 4;
    CLLocationCoordinate2D *coorArr = malloc(sizeof(CLLocationCoordinate2D) * count);
    
    coorArr[0] = CLLocationCoordinate2DMake(39.933921, 116.372927);     //平安里地铁站
    coorArr[1] = CLLocationCoordinate2DMake(39.907261, 116.376532);     //西单地铁站
    coorArr[2] = CLLocationCoordinate2DMake(39.900611, 116.418161);     //崇文门地铁站
    coorArr[3] = CLLocationCoordinate2DMake(39.941949, 116.435497);     //东直门地铁站
    
    [self doClear];
    [self.geoFenceManager addPolygonRegionForMonitoringWithCoordinates:coorArr count:count customID:@"polygon_1"];
    
    free(coorArr);
    coorArr = NULL;
}
    
    
//地图上显示多边形
- (MAPolygon *)showPolygonInMap:(CLLocationCoordinate2D *)coordinates count:(NSInteger)count {
        MAPolygon *polygonOverlay = [MAPolygon polygonWithCoordinates:coordinates count:count];
        [self.mapView addOverlay:polygonOverlay];
        return polygonOverlay;
}

// 清除上一次按钮点击创建的围栏
- (void)doClear {
    [self.mapView removeOverlays:self.mapView.overlays];  //把之前添加的Overlay都移除掉
    [self.geoFenceManager removeAllGeoFenceRegions];  //移除所有已经添加的围栏，如果有正在请求的围栏也会丢弃
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
