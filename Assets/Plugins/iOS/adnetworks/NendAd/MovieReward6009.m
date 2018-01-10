//
//  MovieReward6009.m(NendAd)
//
//  Copyright © 2017年 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import "MovieReward6009.h"
#import <NendAd/NendAd.h>

@interface MovieReward6009()<NADRewardedVideoDelegate>

@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, strong) NSString *nendKey;
@property (nonatomic, strong) NSString *nendAdspotId;
@property (nonatomic) BOOL didInit;

@property (nonatomic) NADRewardedVideo *rewardedVideo;

@end

@implementation MovieReward6009

#pragma mark - ADFmyMovieRewardInterface
/**< 設定データの送信 */
-(void)setData:(NSDictionary *)data {
    self.viewController = [data objectForKey:@"displayViewController"];
    self.nendKey = [NSString stringWithFormat:@"%@", [data objectForKey:@"api_key"]];
    self.nendAdspotId = [NSString stringWithFormat:@"%@", [data objectForKey:@"adspot_id"]];
}

/**< 広告が準備できているか？ */
-(BOOL)isPrepared {
    return self.rewardedVideo.isReady && self.viewController;
}

/**< 広告の読み込み開始 */
-(void)startAd {
    
    if (!self.didInit) {
        self.rewardedVideo = [[NADRewardedVideo alloc] initWithSpotId:self.nendAdspotId apiKey:self.nendKey];
        self.rewardedVideo.mediationName = @"adfurikun";
        self.rewardedVideo.isOutputLog = YES;
        self.rewardedVideo.delegate = self;
        self.didInit = YES;
    }
    
    if (self.viewController) {
        [self.rewardedVideo loadAd];
    }
}

/**< 広告の表示 */
-(void)showAd {
    if (self.isPrepared) {
        if (self.viewController.presentedViewController) {
            [self.rewardedVideo showAdFromViewController:self.viewController.presentedViewController];
        } else {
            [self.rewardedVideo showAdFromViewController:self.viewController];
        }
    }
}

/**< SDKが読み込まれているかどうか？ */
-(BOOL)isClassReference {
    // Nend:iOS 8.1以上が動作保障対象となります。それ以外のOSおよび端末では正常に動作しない場合があります。
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_1) {
        return NO;
    }
    
    Class clazz = NSClassFromString(@"NADRewardedVideo");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: NendAd");
        return NO;
    }
    return YES;
}

/**< 広告の読み込みを中止する処理 */
-(void)cancel {
    
}

/** アドネットワーク接続(特定のアドネットワーク) */
-(void)connectSetting:(NSDictionary*)keyDict {
    
}

-(void)dealloc{
    [self.rewardedVideo releaseVideoAd];
    self.didInit = NO;
}

#pragma mark - NADRewardedVideoDelegate
- (void)nadRewardVideoAd:(NADRewardedVideo *)nadRewardedVideoAd didReward:(NADReward *)reward {
    NSLog(@"%s", __FUNCTION__);
}

- (void)nadRewardVideoAdDidReceiveAd:(NADRewardedVideo *)nadRewardedVideoAd{
    NSLog(@"%s", __FUNCTION__);
}

- (void)nadRewardVideoAd:(NADRewardedVideo *)nadRewardedVideoAd didFailToLoadWithError:(NSError *)error {
    NSLog(@"%s error: %@", __FUNCTION__, error);
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsFetchError:)]) {
            [self.delegate AdsFetchError:self];
        }
    }
}

- (void)nadRewardVideoAdDidFailedToPlay:(NADRewardedVideo *)nadRewardedVideoAd {
    NSLog(@"%s", __FUNCTION__);
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsPlayFailed:)]) {
            [self.delegate AdsPlayFailed:self];
        }
    }
}

- (void)nadRewardVideoAdDidOpen:(NADRewardedVideo *)nadRewardedVideoAd {
    NSLog(@"%s", __FUNCTION__);
}

- (void)nadRewardVideoAdDidClose:(NADRewardedVideo *)nadRewardedVideoAd {
    NSLog(@"%s", __FUNCTION__);
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsDidHide:)]) {
            [self.delegate AdsDidHide:self];
        }
    }
}

- (void)nadRewardVideoAdDidStartPlaying:(NADRewardedVideo *)nadRewardedVideoAd {
    NSLog(@"%s", __FUNCTION__);
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsDidShow:)]) {
            [self.delegate AdsDidShow:self];
        }
    }
}

- (void)nadRewardVideoAdDidStopPlaying:(NADRewardedVideo *)nadRewardedVideoAd {
    NSLog(@"%s", __FUNCTION__);
}

- (void)nadRewardVideoAdDidCompletePlaying:(NADRewardedVideo *)nadRewardedVideoAd {
    NSLog(@"%s", __FUNCTION__);
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsDidCompleteShow:)]) {
            [self.delegate AdsDidCompleteShow:self];
        }
    }
}

- (void)nadRewardVideoAdDidClickAd:(NADRewardedVideo *)nadRewardedVideoAd {
    NSLog(@"%s", __FUNCTION__);
}

- (void)nadRewardVideoAdDidClickInformation:(NADRewardedVideo *)nadRewardedVideoAd {
    NSLog(@"%s", __FUNCTION__);
    
}


@end
