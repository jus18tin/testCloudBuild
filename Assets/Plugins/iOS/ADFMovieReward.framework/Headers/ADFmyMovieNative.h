//
//  ADFmyMovieNative.h
//  ADFMovieReword
//
//  Created by Toru Furuya on 2017/02/21.
//  (c) 2017 ADFULLY Inc.
//

#import <Foundation/Foundation.h>

#import "ADFMovieNativeAdInfo.h"
#import "ADFMovieError.h"

@protocol ADFmyMovieNativeDelegate;
/**
 動画ネイティブ広告API
 */
@interface ADFmyMovieNative : NSObject

- (instancetype)init __unavailable;

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
 動画ネイティブ広告のインスタンスの取得

 @param appID 広告枠ID
 @return 動画ネイティブ広告のインスタンス
 */
+ (ADFmyMovieNative *)getInstance:(NSString *)appID;

/**
 広告の取得リクエスト

 @param delegate ADFmyMovieNativeDelegateに準拠したデリゲート
 */
- (void)loadAndNotifyTo:(id<ADFmyMovieNativeDelegate>)delegate;

@end


@protocol ADFmyMovieNativeDelegate <NSObject>
@required

/**
 広告の取得成功

 @param info 動画ネイティブ広告の情報を格納したオブジェクト
 @param appID 対象の広告枠ID
 */
- (void)onNativeMovieAdLoadFinish:(ADFMovieNativeAdInfo *)info appID:(NSString *)appID;

@optional

/**
 広告の取得失敗

 @param error エラーの情報を格納したオブジェクト
 @param appID 対象の広告枠ID
 */
- (void)onNativeMovieAdLoadError:(ADFMovieError *)error appID:(NSString *)appID;
@end
