//
//  ADFMovieRewardInterface.h
//
//
//  (c) 2015 ADFULLY Inc.
//
//

#import <Foundation/Foundation.h>

@protocol ADFMovieRewardDelegate;
@interface ADFmyMovieRewardInterface : NSObject<NSCopying>

@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSObject<ADFMovieRewardDelegate> *delegate;
/**< 設定データの送信 */
-(void)setData:(NSDictionary *)data;
/**< 広告が準備できているか？ */
-(BOOL)isPrepared;
/**< 広告の読み込み開始 */
-(void)startAd;
/**< 広告の表示 */
-(void)showAd;
/**< SDKが読み込まれているかどうか？ */
-(BOOL)isClassReference;
/**< 広告の読み込みを中止する処理 */
-(void)cancel;
/** アドネットワーク接続(特定のアドネットワーク) */
-(void)connectSetting:(NSDictionary*)keyDict;
@end

@protocol ADFMovieRewardDelegate
@optional

/**< 広告の表示準備が終わったか？ */
- (void)AdsFetchCompleted:(ADFmyMovieRewardInterface*)movieReward;
/**< 広告の表示準備が失敗 */
- (void)AdsFetchError:(ADFmyMovieRewardInterface*)movieReward;
/**< 広告の表示が開始したか */
- (void)AdsDidShow:(ADFmyMovieRewardInterface*)movieReward;
/**< 広告の表示を最後まで終わったか */
- (void)AdsDidCompleteShow:(ADFmyMovieRewardInterface*)movieReward;
/**< 広告がバックグラウンドに回ったか */
- (void)AdsDidHide:(ADFmyMovieRewardInterface*)movieReward;
/**< 動画広告再生エラー時のイベント */
- (void)AdsPlayFailed:(ADFmyMovieRewardInterface*)movieReward;

/** アドネットワーク接続後のイベント(特定のアドネットワーク用) */
- (void)AdsDidConnect:(ADFmyMovieRewardInterface*)movieReward;
@end
