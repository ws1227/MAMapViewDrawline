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
#import <AMapSearchKit/AMapSearchKit.h>
#import "SearchPointAnnotation.h"
#import "SearchAnnotationView.h"


#import "AnimatedAnnotation.h"
#import "AnimatedAnnotationView.h"


#define  WeakSelf(name,className)  __weak typeof(className)name=className;

@interface ViewController ()<MAMapViewDelegate,AMapGeoFenceManagerDelegate,AMapSearchDelegate>
{
    /**获取经纬度数组*/
    CLLocationCoordinate2D * _coors;
}
@property (nonatomic, strong) MAUserLocation *currentUL;//当前位置
@property (nonatomic, strong) AMapGeoFenceManager *geoFenceManager;

@property(nonatomic,strong)NSMutableArray *pointArr;
@property(nonatomic,strong)MAMapView *mapView;
@property (nonatomic, strong) MAPolyline *routeLine;
@property (nonatomic, strong) NSMutableArray *tips;
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) SearchPointAnnotation *searchAnnotation;

@property (nonatomic, strong) AnimatedAnnotation *animatedCarAnnotation;
@property (nonatomic, strong) AnimatedAnnotation *animatedTrainAnnotation;

@end

@implementation ViewController



@synthesize animatedCarAnnotation = _animatedCarAnnotation;
@synthesize animatedTrainAnnotation = _animatedTrainAnnotation;
@synthesize searchAnnotation = _searchAnnotation;




- (void)viewDidLoad {
    [super viewDidLoad];
    self.pointArr = [NSMutableArray array];//存储轨迹的数组.
    self.tips=@[].mutableCopy;
    
    [self setMapView];

    [self addGeoFencePolygonRegion];
    
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
  
    [self searchTipsWithKey:@"798"];
    
    
    
    [self addCarAnnotationWithCoordinate:CLLocationCoordinate2DMake(39.948691, 116.492479)];
    [self addTrainAnnotationWithCoordinate:CLLocationCoordinate2DMake(39.843349, 116.315633)];


    // Do any additional setup after loading the view, typically from a nib.
}




#pragma mark - Utility

-(void)addCarAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSMutableArray *carImages = [[NSMutableArray alloc] init];
    [carImages addObject:[UIImage imageNamed:@"animatedCar_1.png"]];
    [carImages addObject:[UIImage imageNamed:@"animatedCar_2.png"]];
    [carImages addObject:[UIImage imageNamed:@"animatedCar_3.png"]];
    [carImages addObject:[UIImage imageNamed:@"animatedCar_4.png"]];
    [carImages addObject:[UIImage imageNamed:@"animatedCar_3.png"]];
    [carImages addObject:[UIImage imageNamed:@"animatedCar_4.png"]];
    
    self.animatedCarAnnotation = [[AnimatedAnnotation alloc] initWithCoordinate:coordinate];
    self.animatedCarAnnotation.animatedImages   = carImages;
    self.animatedCarAnnotation.title            = @"AutoNavi";
    self.animatedCarAnnotation.subtitle         = [NSString stringWithFormat:@"Car: %lu images",(unsigned long)[self.animatedCarAnnotation.animatedImages count]];
    
    [self.mapView addAnnotation:self.animatedCarAnnotation];
}

-(void)addTrainAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSMutableArray *trainImages = [[NSMutableArray alloc] init];
    [trainImages addObject:[UIImage imageNamed:@"animatedTrain_1.png"]];
    [trainImages addObject:[UIImage imageNamed:@"animatedTrain_2.png"]];
    [trainImages addObject:[UIImage imageNamed:@"animatedTrain_3.png"]];
    [trainImages addObject:[UIImage imageNamed:@"animatedTrain_4.png"]];
    
    self.animatedTrainAnnotation = [[AnimatedAnnotation alloc] initWithCoordinate:coordinate];
    self.animatedTrainAnnotation.animatedImages = trainImages;
    self.animatedTrainAnnotation.title          = @"AutoNavi";
    self.animatedTrainAnnotation.subtitle       = [NSString stringWithFormat:@"Train: %lu images",(unsigned long)[self.animatedTrainAnnotation.animatedImages count]];
    
    [self.mapView addAnnotation:self.animatedTrainAnnotation];
//    [self.mapView selectAnnotation:self.animatedTrainAnnotation animated:YES];
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
    [_mapView setZoomLevel:14 animated:YES];
    
//    //防止系统自动杀掉定位 -- 后台定位
//    _mapView.pausesLocationUpdatesAutomatically = NO;
//    _mapView.allowsBackgroundLocationUpdates = YES;
    [self.view addSubview:self.mapView];
    
  

    //电子围栏  画线
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self configGeoFenceManager];
//        [self drawLine];
    });
}

/* 输入提示 搜索.*/
- (void)searchTipsWithKey:(NSString *)key
{
    if (key.length == 0)
    {
        return;
    }
    
    AMapInputTipsSearchRequest *tips = [[AMapInputTipsSearchRequest alloc] init];
    tips.keywords = key;
    tips.city = @"北京";
    //    tips.cityLimit = YES; 是否限制城市
    
    [self.search AMapInputTipsSearch:tips];
}
#pragma mark - AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    
    NSLog(@"请求失败%@",error);
}

/* 输入提示回调. *//*  搜索结果.*/

- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response
{
    if (response.count == 0)
    {
        
        return;
    }
    

    
    
    [self.tips setArray:response.tips];
    
    
   
    [self.tips enumerateObjectsUsingBlock:^( AMapTip *tip, NSUInteger idx, BOOL * _Nonnull stop) {
//        AMapTip *tip=self.tips[idx];
        
 

        
        
        self.searchAnnotation = [[SearchPointAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(tip.location
                                                                                                               .latitude, tip.location.longitude)];
        
        self.searchAnnotation.title = tip.name;
        
        self.searchAnnotation.subtitle = tip.address;
        self.searchAnnotation.index=idx+1;
        [self.mapView addAnnotation: self.searchAnnotation];
        

        if (idx==1) {
            [self.mapView selectAnnotation: self.searchAnnotation animated:YES];
            
        }
        
        
    }];
    
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

//添加大头针
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation {
  
    
    if ([annotation isMemberOfClass:[MAPointAnnotation class]]) {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil) {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorRed;
        return annotationView;
    }
   
    else if ([annotation isMemberOfClass:[SearchPointAnnotation class]])
    {
        static NSString *annotationIdentifier = @"searchPointAnnotationIdentifiersss";
        
        SearchAnnotationView *pointAnnotationView = (SearchAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        if (pointAnnotationView == nil)
        {
            pointAnnotationView = [[SearchAnnotationView alloc] initWithAnnotation:annotation
                                                                   reuseIdentifier:annotationIdentifier];
            pointAnnotationView.canShowCallout = YES;
            pointAnnotationView.draggable      = YES;
            

        }
        
              return pointAnnotationView;
        
    }
    if ([annotation isMemberOfClass:[AnimatedAnnotation class]])
    {
        static NSString *animatedAnnotationIdentifier = @"AnimatedAnnotationIdentifier";
        
        AnimatedAnnotationView *annotationView = (AnimatedAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:animatedAnnotationIdentifier];
        
        if (annotationView == nil)
        {
            annotationView = [[AnimatedAnnotationView alloc] initWithAnnotation:annotation
                                                                reuseIdentifier:animatedAnnotationIdentifier];
            
            annotationView.canShowCallout   = YES;
            annotationView.draggable        = YES;
        }
        
        return annotationView;
    }

    
    return nil;
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
