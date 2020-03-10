//
//  ChangeColorImage.m
//  ChangeBackground
//
//  Created by 孙树港 on 2020/2/29.
//  Copyright © 2020 ClassroomM. All rights reserved.
//

#import "ChangeColorImage.h"
#include <stack>

using namespace std;

NSMutableArray *revokeArray;
@interface ChangeColorImage ()

//@property (nonatomic, strong)

@end

@implementation ChangeColorImage

- (ChangeColorImage *)changeColor
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // 获取当前的image指针
    CGImageRef imageRef = [self CGImage];
    
    NSUInteger imageWidth = CGImageGetWidth(imageRef);
    NSUInteger imageHeight = CGImageGetHeight(imageRef);
    
    // 每个像素多少字节
    NSUInteger bytesPerPixel = CGImageGetBitsPerPixel(imageRef) / 8;//bitsPerPixel：每个像素的字节数
    NSUInteger bytesPerRow = CGImageGetBytesPerRow(imageRef);//bytesPerRow：每一行占用的字节数，注意这里的单位是字节
    NSUInteger bitsPerComponent = CGImageGetBitsPerComponent(imageRef);//bitsPerComponent：每个颜色的比特数，例如在rgba-32模式下为8
    
    // 创建保存图片数据的载体
    unsigned char *imageData = (unsigned char *)malloc(imageWidth * imageHeight * bytesPerPixel);
    
    // 存储空间所有位 都置0
    memset(imageData, 0, imageWidth * imageHeight * bytesPerPixel);
    
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    if (kCGImageAlphaLast == (uint32_t)bitmapInfo ||
        kCGImageAlphaFirst == (uint32_t)bitmapInfo)
    {
        bitmapInfo = (uint32_t)kCGImageAlphaPremultipliedLast;
    }
    
    // 开启绘图的上下文
    CGContextRef context = CGBitmapContextCreate(imageData, imageWidth, imageHeight, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo);
    
    // 关闭颜色空间
    CGColorSpaceRelease(colorSpace);
    
    // 绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), imageRef);
    
    /* 获取点击点的颜色 */
    NSUInteger byteIndex = (bytesPerRow * roundf(self.startPoint.y)) + bytesPerPixel * roundf(self.startPoint.x);
    NSUInteger oldColorCode = getColorCode(byteIndex, imageData);//需要被覆盖颜色
    
    // 如果是点击了边框 直接返回
    NSUInteger blackColor = getColorCodeFromUIColor([UIColor blackColor], bitmapInfo&kCGBitmapByteOrderMask);
    if (compareColor(oldColorCode, blackColor, 10)) {
        //传出image
        CGImageRef newCGImage = CGBitmapContextCreateImage(context);
        ChangeColorImage *result = (ChangeColorImage *)[UIImage imageWithCGImage:newCGImage scale:1.f orientation:UIImageOrientationUp];
        CGImageRelease(newCGImage);
        CGContextRelease(context);
        free(imageData);
        
        return result;
    }
    
    // 如果新的颜色与本来旧的颜色一样 直接返回
    if (compareColor(oldColorCode, getColorCodeFromUIColor(self.MyNewColor, bitmapInfo & kCGBitmapByteOrderMask), self.tolorance)) {
        //传出image
        CGImageRef newCGImage = CGBitmapContextCreateImage(context);
        ChangeColorImage *result = (ChangeColorImage *)[UIImage imageWithCGImage:newCGImage scale:1.f orientation:UIImageOrientationUp];
        CGImageRelease(newCGImage);
        CGContextRelease(context);
        free(imageData);
        
        return result;
    }
    
    NSInteger newRed, newGreen, newBlue, newAlpha;
    NSUInteger newColorCode = getColorCodeFromUIColor(self.MyNewColor, bitmapInfo & kCGBitmapByteOrderMask);
    
    newRed = ((0xff000000 & newColorCode) >> 24);
    newGreen = ((0x00ff0000 & newColorCode) >> 16);
    newBlue = ((0x0000ff00 & newColorCode) >> 8);
    newAlpha = (0x000000ff & newColorCode);
    
    //现在开发进行
    //搞出一个栈，依次把右边的像素压入，直到颜色相差太高了
    //出栈，更改颜色
    //把左边的像素压入栈，直到颜色相差太高了
    //出栈，更改颜色
    //现在是上下左右都可以跳
    //入栈的起始点会改变的
    BOOL south = false, east = false, north = false,west = false;//优先级为顺时针方向
    
    stack<CGPoint> mystack;
    do {
        CGPoint screenPoint;
        NSUInteger screenColor;
        //先入栈北方的像素
        north = true;
        if (mystack.empty()) {
            screenPoint = CGPointMake(roundf(self.startPoint.x), roundf(self.startPoint.y));
        } else {
            screenPoint = CGPointMake(roundf(mystack.top().x), roundf(mystack.top().y));
        }
        do {
            //得到下一个点的颜色
            NSUInteger bitMapIndex = (bytesPerRow * roundf(--screenPoint.y)) + bytesPerPixel * roundf(screenPoint.x);
            screenColor = getColorCode(bitMapIndex, imageData);
            //进行匹配是否与当前颜色相同
            if (compareColor(screenColor, oldColorCode, self.tolorance)) {
                //替换颜色并且入栈
                // 改变imageData里面的当前像素的颜色数值
                NSUInteger screenIndex = (bytesPerRow * roundf(screenPoint.y)) + bytesPerPixel * roundf(screenPoint.x);
                imageData[screenIndex + 0] = newRed;
                imageData[screenIndex + 1] = newGreen;
                imageData[screenIndex + 2] = newBlue;
                imageData[screenIndex + 3] = newAlpha;
                mystack.push(screenPoint);
//                screenPoint.y--;
            } else {
                north = false;
                screenPoint.y++;
            }
        } while (north);
        
        //向东移动一个像素
//        screenPoint = CGPointMake(roundf(mystack.top().x++), roundf(mystack.top().y));
        //得到下一个点的颜色
        NSUInteger bitMapIndex = (bytesPerRow * roundf(screenPoint.y)) + bytesPerPixel * roundf(++screenPoint.x);
        screenColor = getColorCode(bitMapIndex, imageData);
        //进行匹配是否与当前颜色相同
        if (compareColor(screenColor, oldColorCode, self.tolorance)) {
            //替换颜色并且入栈
            // 改变imageData里面的当前像素的颜色数值
            NSUInteger screenIndex = (bytesPerRow * roundf(screenPoint.y)) + bytesPerPixel * roundf(screenPoint.x);
            imageData[screenIndex + 0] = newRed;
            imageData[screenIndex + 1] = newGreen;
            imageData[screenIndex + 2] = newBlue;
            imageData[screenIndex + 3] = newAlpha;
            mystack.push(screenPoint);
//            screenPoint.x ++;
            east = true;
        } else {
            east = false;
            screenPoint.x--;
        }
        
        //替换南方的像素
        south = true;
        do {
//            screenPoint = CGPointMake(roundf(mystack.top().x), roundf(mystack.top().y));
            //得到下一个点的颜色
            NSUInteger bitMapIndex = (bytesPerRow * roundf(++screenPoint.y)) + bytesPerPixel * roundf(screenPoint.x);
            screenColor = getColorCode(bitMapIndex, imageData);
            //进行匹配是否与当前颜色相同
            if (compareColor(screenColor, oldColorCode, self.tolorance)) {
                //替换颜色并且入栈
                // 改变imageData里面的当前像素的颜色数值
                NSUInteger screenIndex = (bytesPerRow * roundf(screenPoint.y)) + bytesPerPixel * roundf(screenPoint.x);
                imageData[screenIndex + 0] = newRed;
                imageData[screenIndex + 1] = newGreen;
                imageData[screenIndex + 2] = newBlue;
                imageData[screenIndex + 3] = newAlpha;
                mystack.push(screenPoint);
                
            } else {
                south = false;
                screenPoint.y--;
            }
            
        } while (south);
        
        //向西移动一个像素
//        screenPoint = CGPointMake(roundf(mystack.top().x), roundf(mystack.top().y));
        //得到下一个点的颜色
        bitMapIndex = (bytesPerRow * roundf(screenPoint.y)) + bytesPerPixel * roundf(--screenPoint.x);
        screenColor = getColorCode(bitMapIndex, imageData);
        //进行匹配是否与当前颜色相同
        if (compareColor(screenColor, oldColorCode, self.tolorance)) {
            //替换颜色并且入栈
            // 改变imageData里面的当前像素的颜色数值
            NSUInteger screenIndex = (bytesPerRow * roundf(screenPoint.y)) + bytesPerPixel * roundf(screenPoint.x);
            imageData[screenIndex + 0] = newRed;
            imageData[screenIndex + 1] = newGreen;
            imageData[screenIndex + 2] = newBlue;
            imageData[screenIndex + 3] = newAlpha;
            mystack.push(screenPoint);
//            screenPoint.x --;
            west = true;
        } else {
            west = false;
            screenPoint.x ++;
        }
        
        //如果栈不为空，四个方向都为fasle，则进行出栈（出一个元素）
        if (!mystack.empty() && !north && !south && !east && !west) {
            if (!mystack.empty()) {
                mystack.pop();
            }
        }
        
    } while ((!(mystack.empty()) || north || south || east || west));
    
    //传出image
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    ChangeColorImage *result = (ChangeColorImage *)[UIImage imageWithCGImage:newCGImage scale:1.f orientation:UIImageOrientationUp];
    CGImageRelease(newCGImage);
    CGContextRelease(context);
    free(imageData);
    
    return result;
}

- (ChangeColorImage *)changePonitColor
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // 获取当前的image指针
    CGImageRef imageRef = [self CGImage];
    
    NSUInteger imageWidth = CGImageGetWidth(imageRef);
    NSUInteger imageHeight = CGImageGetHeight(imageRef);
    
    // 每个像素多少字节
    NSUInteger bytesPerPixel = CGImageGetBitsPerPixel(imageRef) / 8;//bitsPerPixel：每个像素的字节数
    NSUInteger bytesPerRow = CGImageGetBytesPerRow(imageRef);//bytesPerRow：每一行占用的字节数，注意这里的单位是字节
    NSUInteger bitsPerComponent = CGImageGetBitsPerComponent(imageRef);//bitsPerComponent：每个颜色的比特数，例如在rgba-32模式下为8
    
    // 创建保存图片数据的载体
    unsigned char *imageData = (unsigned char *)malloc(imageWidth * imageHeight * bytesPerPixel);
    
    // 存储空间所有位 都置0
    memset(imageData, 0, imageWidth * imageHeight * bytesPerPixel);
    
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    if (kCGImageAlphaLast == (uint32_t)bitmapInfo ||
        kCGImageAlphaFirst == (uint32_t)bitmapInfo)
    {
        bitmapInfo = (uint32_t)kCGImageAlphaPremultipliedLast;
    }
    
    // 开启绘图的上下文
    CGContextRef context = CGBitmapContextCreate(imageData, imageWidth, imageHeight, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo);
    
    // 关闭颜色空间
    CGColorSpaceRelease(colorSpace);
    
    NSInteger newRed, newGreen, newBlue, newAlpha;
    NSUInteger newColorCode = getColorCodeFromUIColor(self.MyNewColor, bitmapInfo & kCGBitmapByteOrderMask);
    
    newRed = ((0xff000000 & newColorCode) >> 24);
    newGreen = ((0x00ff0000 & newColorCode) >> 16);
    newBlue = ((0x0000ff00 & newColorCode) >> 8);
    newAlpha = (0x000000ff & newColorCode);
    // 绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), imageRef);
    
    //组成一个9*9的矩阵
    //嵌套两个循环，一个是x，一个是y
    //先把点转移到左上角
    CGPoint movePoint = CGPointMake(roundf(self.startPoint.x), roundf(self.startPoint.y));
    --movePoint.x;
    --movePoint.y;
    for (int y = 0; y <= 2; y ++) {
        for (int x = 0; x <= 2; x ++) {
            NSUInteger screenIndex = (bytesPerRow * roundf(movePoint.y)) + bytesPerPixel * roundf(movePoint.x);
            imageData[screenIndex + 0] = newRed;
            imageData[screenIndex + 1] = newGreen;
            imageData[screenIndex + 2] = newBlue;
            imageData[screenIndex + 3] = newAlpha;
            movePoint.x ++;
        }
        movePoint.x -= 3;
        movePoint.y ++;
    }
    
    
    //传出image
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    ChangeColorImage *result = (ChangeColorImage *)[UIImage imageWithCGImage:newCGImage scale:1.f orientation:UIImageOrientationUp];
    CGImageRelease(newCGImage);
    CGContextRelease(context);
    free(imageData);
    
    return result;
}

+(void)redoImage:(ChangeColorImage *)result
{
    if (!revokeArray) {
        revokeArray = [NSMutableArray array];
    }
    [revokeArray addObject:result];
}

+ (ChangeColorImage *)revokeLastImage
{
    [revokeArray removeLastObject];
    ChangeColorImage *image = [[revokeArray lastObject] copy];
    return image;
}


#pragma mark - Privated Method

/*  颜色的数值 eg:0xffaabbcc
 *  转为连续的数
 */
NSUInteger getColorCode (NSUInteger byteIndex, unsigned char *imageData) {
    
    NSUInteger red = imageData[byteIndex];
    NSUInteger green = imageData[byteIndex + 1];
    NSUInteger blue = imageData[byteIndex + 2];
    NSUInteger alpha = imageData[byteIndex + 3];
    
    return (red << 24) | (green << 16) | (blue << 8) | alpha;
}

/*
 *  UIColor 转为颜色的数值
 */
NSUInteger getColorCodeFromUIColor (UIColor *color, CGBitmapInfo orderMask) {
    NSInteger newRed, newGreen, newBlue, newAlpha;
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    if (CGColorGetNumberOfComponents(color.CGColor) == 2) {
        // 只有黑白灰的种类
        /* (这里*255,eg: 0.1*255=>0x19) */
        newRed = newGreen = newBlue = components[0] * 255;
        newAlpha = components[1] * 255;
    } else if (CGColorGetNumberOfComponents(color.CGColor) == 4) {
        // RGBA彩色种类
        /* 小端 */
        if (orderMask == kCGBitmapByteOrder32Little) {
            newRed = components[2] * 255;
            newGreen = components[1] * 255;
            newBlue = components[0] * 255;
            newAlpha = 255;
        } else {
            newRed = components[0] * 255;
            newGreen = components[1] * 255;
            newBlue = components[2] * 255;
            newAlpha = 255;
        }
    } else {
        newRed = newGreen = newBlue = 0;
        newAlpha = 255;
    }
    
    NSUInteger newColor = (newRed << 24) | (newGreen << 16) | (newBlue << 8) | newAlpha;
    return newColor;
}

/*  对比颜色
 *  容差之内返回true，相差太大返回false
 */
bool compareColor (NSUInteger colorA, NSUInteger colorB, NSInteger tolorance) {
    if (colorA == colorB) {
        return true;
    }
    
    NSInteger redA = ((0xff000000 & colorA) >> 24);
    NSInteger greenA = ((0x00ff0000 & colorA) >> 16);
    NSInteger blueA = ((0x0000ff00 & colorA) >> 8);
    NSInteger alphaA = (0x000000ff & colorA);
    
    NSInteger redB = ((0xff000000 & colorB) >> 24);
    NSInteger greenB = ((0x00ff0000 & colorB) >> 16);
    NSInteger blueB = ((0x0000ff00 & colorB) >> 8);
    NSInteger alphaB = (0x000000ff & colorB);
    
    // labs()绝对值
    NSInteger distanceRed = labs(redB - redA);
    NSInteger distanceGreen = labs(greenB - greenA);
    NSInteger distanceBlue = labs(blueB - blueA);
    NSInteger distanceAlpha = labs(alphaB - alphaA);
    
    if (distanceRed > tolorance || distanceGreen > tolorance || distanceBlue > tolorance || distanceAlpha > tolorance) {
        return false;
    }
    
    return true;
}

#pragma mark getter

@end

