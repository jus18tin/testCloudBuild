//
//  MovieReward6006.m(Vungle)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//
#import <UIKit/UIKit.h>
#import "MovieReward6006.h"

@interface MovieReward6006()<VungleSDKDelegate,VungleSDKLogger>
@property (nonatomic, strong)NSString* vungleAppID;
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, assign)BOOL isAdPlayable;

@end

@implementation MovieReward6006

- (id)init{
    //NSLog(@"MovieReward6006 init");
    self = [super init];
    if(self){
        _vungleAppID = @"";
        _isAdPlayable = NO;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MovieReward6006 *newSelf = [super copyWithZone:zone];
    if (newSelf) {
        newSelf.vungleAppID = self.vungleAppID;
        newSelf.isAdPlayable = self.isAdPlayable;
    }
    return newSelf;
}

/**
 *  データの設定
 */
-(void)setData:(NSDictionary *)data
{
    NSString* vungleAppID = [data objectForKey:@"application_id"];
    if(vungleAppID != nil){
        self.vungleAppID = [[NSString alloc] initWithString:vungleAppID];
    }
    self.viewController = [data objectForKey:@"displayViewController"];
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd
{
    if (self.viewController == nil) {
        return;
    }
    //NSLog(@"MovieReward6006 startAd");
    [[VungleSDK sharedSDK] startWithAppId:_vungleAppID];
    [[VungleSDK sharedSDK] setDelegate:self];
}

-(BOOL)isPrepared{
    //NSLog(@"MovieReward6006 isPrepared");
    //NSLog(@"_p.isContentAvailable : %d",_p.isContentAvailable);
    return _isAdPlayable && self.viewController;
}

/**
 *  広告の表示を行う
 */
-(void)showAd
{
    if(_viewController == nil){
        return;
    }
    
    VungleSDK* sdk = [VungleSDK sharedSDK];
    NSError* error;

    if (sdk.isAdPlayable && self.viewController) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            if (self.viewController.presentingViewController) {
                [sdk playAd:self.viewController.presentingViewController error:&error];
            } else {
                if (self.viewController.presentedViewController) {
                    [sdk playAd:self.viewController.presentedViewController error:&error];
                } else {
                    [sdk playAd:self.viewController error:&error];
                }
            }
        } else {
            if (self.viewController.navigationController) {
                [sdk playAd:self.viewController.navigationController error:&error];
            } else {
                if (self.viewController.presentedViewController) {
                    [sdk playAd:self.viewController.presentedViewController error:&error];
                } else {
                    [sdk playAd:self.viewController error:&error];
                }
            }
        }
    }

    if(error){
        NSLog(@"Error encountered playing ad : %@",error);
    }
}

/**
 * 対象のクラスがあるかどうか？
 */
-(BOOL)isClassReference
{
    NSLog(@"MovieReward6006 isClassReference");
    Class clazz = NSClassFromString(@"VungleSDK");
    if (clazz) {
        NSLog(@"found Class: Vungle");
    }
    else {
        NSLog(@"Not found Class: Vungle");
        return NO;
    }
    return YES;
}


/**
 *  広告の読み込みを中止
 */
-(void)cancel
{
    NSLog(@"MovieReward6006 cancel");
    // VungleSDK には対象の処理が無いため何もしない
}

// ------------------------------ -----------------
// ここからはVungleのDelegateを受け取る箇所

#pragma mark - Vungle delegate
//Vungle delegate
/** 広告準備完了 */
-(void)vungleSDKAdPlayableChanged:(BOOL)isAdPlayable{
    NSLog(@"vungleSDKAdPlayableChanged");
    //NSLog(@"isAdPlayable : %d",isAdPlayable);
    self.isAdPlayable = isAdPlayable;
    if(isAdPlayable){
        // 広告準備完了
        if ( self.delegate ) {
            if ([self.delegate respondsToSelector:@selector(AdsFetchCompleted:)]) {
                [self.delegate AdsFetchCompleted:self];
            }
        }
    }
}

/** 動画再生開始 */
-(void)vungleSDKwillShowAd{
    NSLog(@"vungleSDKwillShowAd");
    if(self.delegate){
        if([self.delegate respondsToSelector:@selector(AdsDidShow:)]){
            [self.delegate AdsDidShow:self];
        }
    }
}

/** 動画再生終了&エンドカード終了 */
-(void)vungleSDKwillCloseAdWithViewInfo:(NSDictionary *)viewInfo willPresentProductSheet:(BOOL)willPresentProductSheet{
    NSLog(@"vungleSDKwillCloseAdWithViewInfo");
    self.isAdPlayable = NO;
    //NSLog(@"viewInfo : %@",viewInfo);
    if([viewInfo objectForKey:@"completedView"] != nil){
        BOOL isCompleted = [[NSString stringWithFormat:@"%@", [viewInfo objectForKey:@"completedView"]] boolValue];
        //NSLog(@"willPresentProductSheet : %d",willPresentProductSheet);
        if ( self.delegate ) {
            if(isCompleted){
                if ([self.delegate respondsToSelector:@selector(AdsDidCompleteShow:)]) {
                    [self.delegate AdsDidCompleteShow:self];
                }
            }else{
                if ( self.delegate ) {
                    if ([self.delegate respondsToSelector:@selector(AdsPlayFailed:)]) {
                        [self.delegate AdsPlayFailed:self];
                    }
                }
            }
        }
    }
    if ( self.delegate ) {
        if ([self.delegate respondsToSelector:@selector(AdsDidHide:)]) {
            [self.delegate AdsDidHide:self];
        }
    }
}

/** AppStoreから戻った */
- (void)vungleSDKwillCloseProductSheet:(id)productSheet{
    NSLog(@"vungleSDKwillCloseProductSheet");
    //NSLog(@"productSheet : %@",productSheet);
}

//VungleLogger
-(void)vungleSDKLog:(NSString *)message{
    //NSLog(@"vungleSDKLog message : %@",message);
}

- (void)dealloc{
    if(_vungleAppID){
        _vungleAppID = nil;
    }
    if(_viewController != nil){
        _viewController = nil;
    }
    [[VungleSDK sharedSDK] setDelegate:nil];
}

@end
