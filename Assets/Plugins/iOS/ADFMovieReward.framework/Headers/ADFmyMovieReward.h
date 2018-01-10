//
//  ADFmyMovieReward.h
//  ADFMovieReword
//
//  (2.15.1)
//  Created by tsukui on 2016/05/28.
//  (c) 2015 ADFULLY Inc.
//  (ご利用になられる前に、必ずマニュアルにて実装方法をご参照ください。
// マニュアルに記述されている実装のみ利用可能です)

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ADFmyMovieRewardInterface.h"

@protocol ADFmyMovieRewardDelegate;

@interface ADFmyMovieReward : NSObject<ADFMovieRewardDelegate>

/** 常に存在するViewController */
@property (nonatomic, weak) UIViewController *displayViewController;
/** デリゲート */
@property (nonatomic, weak) NSObject<ADFmyMovieRewardDelegate> *delegate;

/**
 サポートされているOSのバージョンか？
 @return BOOL サポートされているOSのバージョンか否か
 */
+ (BOOL)isSupportedOSVersion;
/**
 イニシャライズ

 @param appID アドフリくんの広告枠ID
 @param viewController 常に存在するViewController
 */
+ (void)initWithAppID:(NSString *)appID viewController:(UIViewController*)viewController;

/**
 動画リワードのインスタンスを取得

 @param appID アドフリくんの広告枠ID
 @param delegate デリゲート
 @return 動画リワードのインスタンス
 */
+ (ADFmyMovieReward *)getInstance:(NSString *)appID delegate:(id<ADFmyMovieRewardDelegate>)delegate;

/**
 インスタンスの処理
 */
+ (void)disposeAll;

/**
 *  動画が準備完了しているか？
 *
 *  @return BOOL 動画が準備完了しているか否か
 */
-(BOOL)isPrepared;

/**
 *  動画を再生する
 */
-(void)play;


-(void)dispose;

@end

@protocol ADFmyMovieRewardDelegate
@optional
/**< 広告の表示準備が終わった時のイベント */
- (void)AdsFetchCompleted:(BOOL)isTestMode_inApp __deprecated_msg("Please use 'AdsFetchCompleted:isTestMode:' instead");
- (void)AdsFetchCompleted:(NSString *)appID isTestMode:(BOOL)isTestMode_inApp;

/**< 広告の表示が開始した時のイベント */
- (void)AdsDidShow:(NSString *)adnetworkKey __deprecated_msg("Please use 'AdsDidShow:adNetworkKey:' instead");
- (void)AdsDidShow:(NSString *)appID adNetworkKey:(NSString *)adNetworkKey;

/**< 広告の表示が最後まで終わった時のイベント */
- (void)AdsDidCompleteShow __deprecated_msg("Please use 'AdsDidCompleteShow:' instead");
- (void)AdsDidCompleteShow:(NSString *)appID;

/**< 動画広告再生エラー時のイベント */
- (void)AdsPlayFailed __deprecated_msg("Please use 'AdsPlayFailed:' instead");
- (void)AdsPlayFailed:(NSString *)appID;

/**< 広告を閉じた時のイベント */
- (void)AdsDidHide __deprecated_msg("Please use 'AdsDidHide:' instead");
- (void)AdsDidHide:(NSString *)appID;

@end
