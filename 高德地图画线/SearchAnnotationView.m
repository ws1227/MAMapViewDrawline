//
//  SearchAnnotationView.m
//  PinganBus
//
//  Created by panhongliu on 2017/7/28.
//  Copyright © 2017年 wangsen. All rights reserved.
//

#import "SearchAnnotationView.h"
#import "SearchPointAnnotation.h"

@implementation SearchAnnotationView
@synthesize imageView = _imageView;
@synthesize label = _label;


#define kWidth          29.f
#define kHeight         32.f
- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        [self setBounds:CGRectMake(0.f, 0.f, kWidth, kHeight)];
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 29, 32)];
      
//        self.label=[[UILabel alloc]initWithFrame:self.bounds];
//        self.imageView.image= [UIImage imageNamed:@"useParkCount"];
//
//        self.label.font=[UIFont systemFontOfSize:15];
//        self.label.textAlignment=NSTextAlignmentCenter;
//        self.label.textColor=[UIColor blackColor];
        [self addSubview:self.imageView];
//        [self addSubview:self.label];

    }
    
    return self;
}
- (void)updateImageView
{
    SearchPointAnnotation *animatedAnnotation = (SearchPointAnnotation *)self.annotation;
    self.imageView.image= [self createShareImage:@"useParkCount" Context:[NSString stringWithFormat:@"%ld",(long)animatedAnnotation.index]];
//    animatedAnnotation
    self.label.text=[NSString stringWithFormat:@"%ld",(long)animatedAnnotation.index];
 
}


#pragma mark - Override

- (void)setAnnotation:(id<MAAnnotation>)annotation
{
    [super setAnnotation:annotation];
    
    [self updateImageView];
}

// imageName 图片名字， text 需画的字体
- (UIImage *)createShareImage:(NSString *)imageName Context:(NSString *)text
{
    UIImage *sourceImage = [UIImage imageNamed:imageName];
    CGSize imageSize; //画的背景 大小
    imageSize = [sourceImage size];
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    [sourceImage drawAtPoint:CGPointMake(0, 0)];
    //获得 图形上下文
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextDrawPath(context, kCGPathStroke);
    CGFloat nameFont = 17.f;
    //画 自己想要画的内容
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:nameFont]};
    CGRect sizeToFit = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, nameFont) options:NSStringDrawingUsesDeviceMetrics attributes:attributes context:nil];
    NSLog(@"图片: %f %f",imageSize.width,imageSize.height);
    NSLog(@"sizeToFit: %f %f",sizeToFit.size.width,sizeToFit.size.height);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    [text drawAtPoint:CGPointMake((imageSize.width-sizeToFit.size.width)/2,0) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:nameFont]}];
    //返回绘制的新图形
    
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return newImage;
}


@end
