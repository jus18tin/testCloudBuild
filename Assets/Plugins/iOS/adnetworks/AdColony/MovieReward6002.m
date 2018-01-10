//
//  MovieReward6002.m(AdColony)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import "MovieReward6002.h"

@interface MovieReward6002()

@property (nonatomic, strong) NSString *adColonyAppId;
@property (nonatomic, strong) NSArray *adColonyAllZones;
@property (nonatomic, strong) NSString *adShowZoneId;
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, weak) UIViewController* appViewController;
@property (nonatomic) AdColonyInterstitial *ad;

@end

@implementation MovieReward6002

-(id)init
{
    self = [super init];
    
    if (self) {
        _appViewController = nil;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MovieReward6002 *newSelf = [super copyWithZone:zone];
    if (newSelf) {
        newSelf.appViewController = self.appViewController;
    }
    return newSelf;
}

/**
 *  データの設定
 */
-(void)setData:(NSDictionary *)data
{
    NSString *colonyAppId = [NSString stringWithFormat:@"%@", [data objectForKey:@"app_id"]];
    NSString *colonyZoneId = [NSString stringWithFormat:@"%@", [data objectForKey:@"zone_id"]];
    NSArray *colonyAllZones = [data objectForKey:@"all_zones"];
    _viewController = [data objectForKey:@"displayViewController"];

    _adColonyAppId = colonyAppId;
    _adShowZoneId = colonyZoneId;
    
    _adColonyAllZones = colonyAllZones;
    if (_adColonyAllZones == nil) {
        _adColonyAllZones = @[colonyZoneId];
    }
}

-(BOOL)isPrepared
{
    if (_ad && _ad.expired == NO && _viewController != nil) {
        return YES;
    }
    return NO;
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd
{
    // AdColonyの初期化は一度だけしか行わない
    // 初期化が失敗した場合はAdColonyが自分でリトライする
    static BOOL hasConfigured = NO;
    static dispatch_once_t adfAdColonyOnceToken;
    dispatch_once(&adfAdColonyOnceToken, ^{
        [AdColony configureWithAppID:_adColonyAppId zoneIDs:_adColonyAllZones options:nil completion:^(NSArray<AdColonyZone *> * _Nonnull zones) {
            hasConfigured = YES;
            [self requestInterstitial];
        }];
    });

    // 初期化に成功したら以降はインタースティシャルのリクエストのみ行う
    if (hasConfigured) {
        [self requestInterstitial];
    }
}

- (void)requestInterstitial {
    if(_viewController == nil){
        NSLog(@"Request was skipped");
        return;
    }
    [AdColony requestInterstitialInZone:_adShowZoneId options:nil

        // Handler for successful ad requests
        success:^(AdColonyInterstitial * _Nonnull ad) {
            [self onAdFetchCompleted];

            ad.open = ^{
                [self onAdStarted];
            };
            ad.close = ^{
                [self onAdFinished];
            };
            ad.expire = ^{
                _ad = nil;
            };

            _ad = ad;
        }

        // Handler for failed ad requests
        failure:^(AdColonyAdRequestError * _Nonnull error) {
            [self onAdFetchFailed];
            NSLog(@"Request failed with error: %@ and suggestion: %@", [error localizedDescription], [error localizedRecoverySuggestion]);
        }
    ];
}

/**
 *  広告の表示を行う
 */
-(void)showAd
{
    // 表示を呼び出す
     if ([self isPrepared]) {
         [_ad showWithPresentingViewController:_viewController];
     }
}

/**
 * 対象のクラスがあるかどうか？
 */
-(BOOL)isClassReference
{
    Class clazz = NSClassFromString(@"AdColony");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: AdColony");
        return NO;
    }
    return YES;
}

-(void)dealloc
{
    if (_adColonyAppId != nil){
        _adColonyAppId = nil;
    }
    if (_adColonyAllZones != nil){
        _adColonyAllZones = nil;
    }
    if (_adShowZoneId != nil){
        _adShowZoneId = nil;
    }
    if (_appViewController != nil){
        _appViewController = nil;
    }
    if (_viewController != nil){
      _viewController = nil;
    }
}

/**
 *    広告の読み込みを中止
 */
-(void)cancel
{
    if (_ad) {
        [_ad cancel];
    }
}

- (void)onAdFetchCompleted
{
    NSLog(@"onAdColonyAdAvailabilityChange");
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsFetchCompleted:)]) {
            [self.delegate AdsFetchCompleted:self];
        }
    }
}

- (void)onAdFetchFailed
{
    NSLog(@"onAdColonyAdFetchedError");
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsFetchError:)]) {
            [self.delegate AdsFetchError:self];
        }
    }
}

- (void)onAdStarted
{
    NSLog(@"onAdColonyAdStarted");
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsDidShow:)]) {
            [self.delegate AdsDidShow:self];
        }
    }
}

- (void)onAdFinished
{
    NSLog(@"onAdColonyAdFinished");
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsDidCompleteShow:)]) {
            [self.delegate AdsDidCompleteShow:self];
        }
        if ([self.delegate respondsToSelector:@selector(AdsDidHide:)]) {
            [self.delegate AdsDidHide:self];
        }
    }
}
@end
