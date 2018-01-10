//
//  ADFmyMovieNativeAdView.h
//  ADFMovieReword
//
//  Created by Toru Furuya on 2017/02/23.
//  (c) 2017 ADFULLY Inc.
//

#import <UIKit/UIKit.h>

#import "ADFmyMovieNative.h"
#import "ADFMovieNativeAdInfo.h"

/**
 動画ネイティブ広告のレイアウトパターン

 - ADFMovieNativeAdLayoutPattern_Default: デフォルトのレイアウト
 */
typedef NS_ENUM(NSInteger, ADFMovieNativeAdLayoutPattern) {
    ADFMovieNativeAdLayoutPattern_Default = 1,
};

@protocol ADFmyMovieNativeAdViewDelegate;
@protocol ADFmyNativeAdViewVideoDelegate;
/**
 動画ネイティブView広告API
 */
@interface ADFmyMovieNativeAdView : NSObject
- (instancetype)init __unavailable;

/**
 広告の自動切り替えを管理するフラグ
 YESの場合は定期的に広告の内容を切り替えます
 デフォルトYES
 */
@property (nonatomic) BOOL autoLoad;


/**
 サポートされているOSのバージョンか確認

 @return サポートされているOSのバージョンか否か
 */
+ (BOOL)isSupportedOSVersion;

/**
 広告枠の情報をアドフリくんサーバから取得して動画ネイティブ広告の初期化

 @param appID 広告枠ID
 */
+ (void)configureWithAppID:(NSString *)appID;

/**
 動画ネイティブView広告の初期化

 @param appID 広告枠ID
 @param layoutPattern 広告のレイアウトパターン
 @return 動画ネイティブView広告のインスタンス
 */
- (instancetype)initWithAppID:(NSString *)appID layoutPattern:(ADFMovieNativeAdLayoutPattern)layoutPattern;

/**
 広告の取得リクエスト

 @param delegate ADFmyMovieNativeAdViewDelegateに準拠したデリゲート
 */
- (void)loadAndNotifyTo:(NSObject<ADFmyMovieNativeAdViewDelegate> *)delegate;


/**
 広告の再生状況を通知するデリゲートオブジェクトをセット

 @param delegate ADFmyNativeAdViewVideoDelegateに準拠したデリゲート
 */
- (void)setVideoDelegate:(id<ADFmyNativeAdViewVideoDelegate>)delegate;

/**
 動画ネイティブ広告のViewを取得
 このViewを自身のViewに追加して広告を表示してください

 @return 動画ネイティブ広告の広告View
 */
- (UIView *)getAdView;

/**
 動画広告の再生
 */
- (void)playVideo;

/**
 動画広告の一時停止
 */
- (void)pauseVideo;

@end


@protocol ADFmyMovieNativeAdViewDelegate <NSObject>
@optional
/**
 *  広告の取得成功
 */
- (void)onNativeMovieAdViewLoadFinish:(NSString *)appID;

/**
 *  広告の取得失敗
 */
- (void)onNativeMovieAdViewLoadError:(ADFMovieError *)error appID:(NSString *)appID;

@end

@protocol ADFmyNativeAdViewVideoDelegate <NSObject>
@optional

/**
 広告の再生開始

 @param appID 広告枠ID
 */
- (void)onNativeMovieAdViewPlayStart:(NSString *)appID;

/**
 広告の再生完了

 @param appID 広告枠ID
 @param isVideo 動画広告の場合YES、静止画広告の場合NO
 */
- (void)onNativeMovieAdViewPlayFinish:(NSString *)appID isVideo:(BOOL)isVideo;

/**
 広告の再生失敗

 @param appID 広告枠ID
 @param error 再生失敗した時のエラー
 */
- (void)onNativeMovieAdViewPlayFail:(NSString *)appID error:(ADFMovieError *)error;
@end


