//
//  ADFMovieRewardAdapter.h
//  Unity-iPhone
//
//  Created by tsukui on 2015/08/25.
//
//

#import <Foundation/Foundation.h>
#import <ADFMovieReward/ADFmyMovieReward.h>
//#import "ADFmyMovieReward.h"

@protocol ADFMovieRewardUnityAdapterDelegate
@optional

/**< 広告の表示準備が終わった */
- (void)AdsFetchCompleted:(NSString *)appID isTestMode_inApp:(BOOL)isTestMode_inApp;
/**< 広告の表示が開始したか */
- (void)AdsDidShow:(NSString *)appID adnetworkKey:(NSString *)adnetworkKey;
/**< 広告の表示を最後まで終わったか */
- (void)AdsDidCompleteShow:(NSString *)appID;
/**< 動画広告再生エラー時のイベント */
- (void)AdsPlayFailed:(NSString *)appID;
/**< 広告を閉じた時のイベント */
- (void)AdsDidHide:(NSString *)appID;
@end

@interface ADFMovieRewardUnityAdapter : NSObject <ADFmyMovieRewardDelegate>
@property (nonatomic, strong) NSObject<ADFMovieRewardUnityAdapterDelegate> *delegate;

- (id)initWithAppID:(NSString *)appID;
- (ADFmyMovieReward *)getMovieReward;
- (void)dispose;

/**< 広告の表示準備が終わった時のイベント */
- (void)AdsFetchCompleted:(BOOL)isTestMode_inApp;
/**< 広告の表示が開始した時のイベント */
- (void)AdsDidShow:(NSString *)adnetworkKey;
/**< 広告の表示が最後まで終わった時のイベント */
- (void)AdsDidCompleteShow;
/**< 動画広告再生エラー時のイベント */
- (void)AdsPlayFailed;
/**< 広告を閉じた時のイベント */
- (void)AdsDidHide;
@end

