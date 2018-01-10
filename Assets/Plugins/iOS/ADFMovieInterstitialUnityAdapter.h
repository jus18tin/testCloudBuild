#import <Foundation/Foundation.h>
#import <ADFMovieReward/ADFmyMovieInterstitial.h>

@protocol ADFMovieInterstitialUnityAdapterDelegate
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

@interface ADFMovieInterstitialUnityAdapter : NSObject <ADFmyMovieRewardDelegate>
@property (nonatomic, strong) NSObject<ADFMovieInterstitialUnityAdapterDelegate> *delegate;

- (id)initWithAppID:(NSString *)appID;
- (ADFmyMovieInterstitial *)getMovieInterstitial;
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
