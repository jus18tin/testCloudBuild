//
//  MovieInterstitial6008.m(Five)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import "MovieInterstitial6008.h"
#import <FiveAd/FiveAd.h>

@interface MovieInterstitial6008()<FADDelegate>

@property (nonatomic)FADInterstitial *interstitial;
@property (nonatomic, strong)NSString *fiveAppId;
@property (nonatomic, strong)NSString *fiveSlotId;
@property (nonatomic, strong)NSString* submittedPackageName;
@property (nonatomic)BOOL testFlg;

@property (nonatomic)BOOL isReplay;

@end

@implementation MovieInterstitial6008

-(id)init
{
    self = [super init];
    return self;
}


/**
 *  データの設定
 *
 */
-(void)setData:(NSDictionary *)data
{
    self.fiveAppId = [NSString stringWithFormat:@"%@", [data objectForKey:@"app_id"]];
    self.fiveSlotId = [NSString stringWithFormat:@"%@", [data objectForKey:@"slot_id"]];
    self.testFlg = [[data objectForKey:@"test_flg"] boolValue];
    self.submittedPackageName = [data objectForKey:@"package_name"];
}

-(BOOL)isPrepared{
    //申請済のバンドルIDと異なる場合のメッセージ
    //(バンドルIDが申請済のものと異なると、正常に広告が返却されない可能性があります)
    if(![self.submittedPackageName isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
        //表示を消したい場合は、こちらをコメントアウトして下さい。
        NSLog(@"[ADF][Five]アプリのバンドルIDが、申請されたものと異なります。");
    }
    
    if (self.interstitial) {
        return self.interstitial.state == kFADStateLoaded;
    }
    return NO;
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd
{
    if (self.interstitial && self.interstitial.state == kFADStateShowing) {
        return;
    }

    static dispatch_once_t adfFiveOnceToken;
    
    if ([self.fiveAppId length] > 0 && [self.fiveSlotId length] > 0) {
        dispatch_once(&adfFiveOnceToken, ^{
            FADConfig *config = [[FADConfig alloc] initWithAppId:self.fiveAppId];
            config.fiveAdFormat =
            [NSSet setWithObjects:
             [NSNumber numberWithInt:kFADFormatInterstitialPortrait],
             [NSNumber numberWithInt:kFADFormatInterstitialLandscape],
             nil];
            
            if (self.testFlg) {
                config.isTest =  YES;
            }
            [FADSettings registerConfig:config];
            
            // 広告の取得を許可します。広告の取得はバックグラウンドで行われます。
            // 初期状態では広告の取得は自動的には開始しませんので、
            // 取得を開始したいタイミングで必ず呼んでください。
            [FADSettings enableLoading:YES];
        });
        
        self.interstitial = [[FADInterstitial alloc] initWithSlotId:self.fiveSlotId];
        self.interstitial.delegate = self;
        
        [self.interstitial loadAd];
    }
}

/**
 *  広告の表示を行う
 */
-(void)showAd
{
    BOOL res = [self.interstitial show];
    if (!res) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(AdsPlayFailed:)]) {
            [self.delegate AdsPlayFailed:self];
        }
    }
}


/**
 * 対象のクラスがあるかどうか？
 *
 */
-(BOOL)isClassReference
{
    Class clazz = NSClassFromString(@"FADInterstitial");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: FiveAd");
        return NO;
    }
    return YES;
}

-(void)dealloc{
}
/**
 *  広告の読み込みを中止
 *
 */
-(void)cancel
{
}


// ------------------------------ -----------------
// ここからはFiveのDelegateを受け取る箇所
#pragma mark -  FiveDelegate
- (void)fiveAdDidLoad:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(AdsFetchCompleted:)]) {
        [self.delegate AdsFetchCompleted:self];
    }
    
}

- (void)fiveAd:(id<FADAdInterface>)ad didFailedToReceiveAdWithError:(FADErrorCode) errorCode {
    NSLog(@"%s", __func__);
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(AdsFetchError:)]) {
        [self.delegate AdsFetchError:self];
    }
}

- (void)fiveAdDidClick:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
}

- (void)fiveAdDidClose:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(AdsDidHide:)]) {
        [self.delegate AdsDidHide:self];
    }
}

- (void)fiveAdDidStart:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
    
    self.isReplay = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(AdsDidShow:)]) {
        [self.delegate AdsDidShow:self];
    }
}

- (void)fiveAdDidPause:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
}

- (void)fiveAdDidResume:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
}

- (void)fiveAdDidViewThrough:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
    
    if (self.delegate && !self.isReplay && [self.delegate respondsToSelector:@selector(AdsDidCompleteShow:)]) {
        [self.delegate AdsDidCompleteShow:self];
    }
}

- (void)fiveAdDidReplay:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
    
    self.isReplay = YES;
}

@end
