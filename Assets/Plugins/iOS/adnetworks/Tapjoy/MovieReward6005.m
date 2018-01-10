//
//  MovieReward6005.m (Tapjoy)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//
#import <UIKit/UIKit.h>
#import "MovieReward6005.h"

#import <Tapjoy/Tapjoy.h>

#define ADAPTER_CLASS_NAME NSStringFromClass(self.class)

@interface MovieReward6005()
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, assign)BOOL test_flg;
@property (nonatomic, strong)NSString* placement_id;
@property (nonatomic, strong)TJPlacement* p;
@property (nonatomic) BOOL isNeedStartAd;

@end

@implementation MovieReward6005

- (id)init{
    NSLog(@"%@ init", ADAPTER_CLASS_NAME);
    self = [super init];
    if (self) {
        [Tapjoy startSession];
        _p = nil;
        _isNeedStartAd = NO;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MovieReward6005 *newSelf = [super copyWithZone:zone];
    if (newSelf) {
        newSelf.p = self.p;
        newSelf.isNeedStartAd = self.isNeedStartAd;
    }
    return newSelf;
}

/**
 *  データの設定
 */
-(void)setData:(NSDictionary *)data
{
    self.viewController = [data objectForKey:@"displayViewController"];
    self.placement_id = [data objectForKey:@"placement_id"];

    BOOL testFlg = [[data objectForKey:@"test_flg"] boolValue];
    [Tapjoy setDebugEnabled:testFlg];

    NSString *sdkKey = [data objectForKey:@"sdk_key"];
    [self connect:sdkKey];
}

- (void)connect:(NSString *)sdkKey {
    NSLog(@"%@ connectSetting start", ADAPTER_CLASS_NAME);
    //Set up success and failure notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tjcConnectSuccess:)
                                                 name:TJC_CONNECT_SUCCESS
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tjcConnectFail:)
                                                 name:TJC_CONNECT_FAILED
                                               object:nil];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //The Tapjoy connect call
        [Tapjoy connect:sdkKey];
    });
    NSLog(@"%@ connectSetting end", ADAPTER_CLASS_NAME);
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd
{
    //NSLog(@"%@ startAd", ADAPTER_CLASS_NAME);
    if (!self.viewController) {
        return;
    }
    if (![Tapjoy isConnected]) {
        self.isNeedStartAd = YES;
        return;
    }

    MovieDelegate6005 *delegate = [MovieDelegate6005 sharedInstance];
    [delegate setMovieReward:self inZone:self.placement_id];
    [delegate setDelegate:self.delegate inZone:self.placement_id];
    
    _p = [TJPlacement placementWithName:_placement_id mediationAgent:@"adfully" mediationId:nil delegate:delegate];
    _p.videoDelegate = delegate;
    _p.adapterVersion = @"1.0.1";
    [_p requestContent];
}

-(BOOL)isPrepared{
    if (!_p) {
        return NO;
    }
    if ([_p isKindOfClass:[TJPlacement class]]) {
        return _p.isContentAvailable && _p.isContentReady && self.viewController;
    }
    return NO;
}

/**
 *  広告の表示を行う
 */
-(void)showAd
{
    NSLog(@"%@ showAd", ADAPTER_CLASS_NAME);
    if (_p.isContentAvailable && self.viewController) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            if (self.viewController.presentingViewController) {
                [_p showContentWithViewController:self.viewController.presentingViewController];
            } else {
                if (self.viewController.presentedViewController) {
                    [_p showContentWithViewController:self.viewController.presentedViewController];
                } else {
                    [_p showContentWithViewController:self.viewController];
                }
            }
        } else {
            if (self.viewController.navigationController) {
                [_p showContentWithViewController:self.viewController.navigationController];
            } else {
                if (self.viewController.presentedViewController) {
                    [_p showContentWithViewController:self.viewController.presentedViewController];
                } else {
                    [_p showContentWithViewController:self.viewController];
                }
            }
        }
    }
}


/**
 * 対象のクラスがあるかどうか？
 */
-(BOOL)isClassReference
{
    NSLog(@"%@ isClassReference", ADAPTER_CLASS_NAME);
    Class clazz = NSClassFromString(@"Tapjoy");
    if (clazz) {
        NSLog(@"found Class: Tapjoy");
    }
    else {
        NSLog(@"Not found Class: Tapjoy");
        return NO;
    }
    return YES;
}


/**
 *  広告の読み込みを中止
 */
-(void)cancel
{
    NSLog(@"%@ cancel", ADAPTER_CLASS_NAME);
    // Tapjoy には対象の処理が無いため何もしない
}

-(void)dealloc{
    if(_viewController != nil){
        _viewController = nil;
    }
    if(_p != nil){
        _p = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//-----------------AppDelegate内の処理を移動--------------------------------------
-(void)tjcConnectSuccess:(NSNotification*)notifyObj
{
    NSLog(@"%@ Tapjoy connect Succeeded", ADAPTER_CLASS_NAME);
    if (self.isNeedStartAd) {
        [self startAd];
    }
}

- (void)tjcConnectFail:(NSNotification*)notifyObj
{
    NSLog(@"%@ Tapjoy connect Failed", ADAPTER_CLASS_NAME);
}

@end


@interface MovieDelegate6005()
@end

@implementation MovieDelegate6005

#pragma mark - TJPlacementDelegate

// SDKがTapjoyのサーバーにコンタクトした際に呼ばれます。但し、必ずしもコンテンツを利用可能であることを意味する訳ではありません。
- (void)requestDidSucceed:(TJPlacement*)placement {
    NSLog(@"%@ requestDidSucceed", ADAPTER_CLASS_NAME);
    NSLog(@"isContentAvailable : %d", placement.isContentAvailable);
}

// Tapjoyのサーバーにコネクトする途中で問題が発生した際に呼ばれます。
- (void)requestDidFail:(TJPlacement*)placement error:(NSError*)error{
    NSLog(@"%@ requestDidFail", ADAPTER_CLASS_NAME);

    id delegate = [self getDelegateWithZone:placement.placementName];
    ADFmyMovieRewardInterface *movieReward = [self getMovieRewardWithZone:placement.placementName];
    if (delegate && movieReward) {
        if ([delegate respondsToSelector:@selector(AdsFetchError:)]) {
            [delegate AdsFetchError:movieReward];
        }
    }
}

// コンテンツが表示可能となった際に呼ばれます。
- (void)contentIsReady:(TJPlacement*)placement{
    NSLog(@"%@ contentIsReady", ADAPTER_CLASS_NAME);
    // 広告準備完了
    id delegate = [self getDelegateWithZone:placement.placementName];
    ADFmyMovieRewardInterface *movieReward = [self getMovieRewardWithZone:placement.placementName];
    if (delegate && movieReward) {
        if ([delegate respondsToSelector:@selector(AdsFetchCompleted:)]) {
            [delegate AdsFetchCompleted:movieReward];
        }
    }
}

// コンテンツが表示される際に呼ばれます。
- (void)contentDidAppear:(TJPlacement*)placement{
    NSLog(@"%@ contentDidAppear", ADAPTER_CLASS_NAME);

    id delegate = [self getDelegateWithZone:placement.placementName];
    ADFmyMovieRewardInterface *movieReward = [self getMovieRewardWithZone:placement.placementName];
    if(delegate && movieReward){
        if([delegate respondsToSelector:@selector(AdsDidShow:)]){
            [delegate AdsDidShow:movieReward];
        }
    }
}

// コンテンツが退去される際に呼ばれます。
- (void)contentDidDisappear:(TJPlacement*)placement{
    NSLog(@"%@ contentDidDisappear", ADAPTER_CLASS_NAME);

    id delegate = [self getDelegateWithZone:placement.placementName];
    ADFmyMovieRewardInterface *movieReward = [self getMovieRewardWithZone:placement.placementName];
    if (delegate && movieReward) {
        if ([delegate respondsToSelector:@selector(AdsDidHide:)]) {
            [delegate AdsDidHide:movieReward];
        }
    }
}

#pragma mark - TJPlacementVideoDelegate

- (void)videoDidStart:(TJPlacement *)placement {
    NSLog(@"%@ videoDidStart", ADAPTER_CLASS_NAME);
}

/** 動画を最後まで視聴した際に呼ばれます。 */
- (void)videoDidComplete:(TJPlacement *)placement {
    NSLog(@"%@ videoDidComplete", ADAPTER_CLASS_NAME);
    [Tapjoy getCurrencyBalance];

    id delegate = [self getDelegateWithZone:placement.placementName];
    ADFmyMovieRewardInterface *movieReward = [self getMovieRewardWithZone:placement.placementName];
    if (delegate && movieReward) {
        if ([delegate respondsToSelector:@selector(AdsDidCompleteShow:)]) {
            [delegate AdsDidCompleteShow:movieReward];
        }
    }
}

- (void)videoDidFail:(TJPlacement *)placement error:(NSString *)errorMsg {
    NSLog(@"TJCVideoAdDelegate::videoAdError %@", errorMsg);
    
    id delegate = [self getDelegateWithZone:placement.placementName];
    ADFmyMovieRewardInterface *movieReward = [self getMovieRewardWithZone:placement.placementName];
    if (delegate && movieReward) {
        if ([delegate respondsToSelector:@selector(AdsPlayFailed:)]) {
            [delegate AdsPlayFailed:movieReward];
        }
    }
}

@end
