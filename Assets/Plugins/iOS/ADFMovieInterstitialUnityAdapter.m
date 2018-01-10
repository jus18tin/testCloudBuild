#import "ADFMovieInterstitialUnityAdapter.h"

@interface ADFMovieInterstitialUnityAdapter()
@property (nonatomic, strong) ADFmyMovieInterstitial* movieInterstitial;
@property (nonatomic, strong) NSString* appID;
@end

@implementation ADFMovieInterstitialUnityAdapter


- (id)initWithAppID:(NSString *)appID{
    self = [super init];
    if (self) {
        ADFmyMovieInterstitial* interstitial = [ADFmyMovieInterstitial getInstance:appID delegate:self];
        if(interstitial != nil){
            self.movieInterstitial = interstitial;
        }
        self.appID = [[NSString alloc] initWithString:appID];
    }
    return self;
}

- (ADFmyMovieInterstitial *)getMovieInterstitial{
    return self.movieInterstitial;
}

/**< 広告を閉じた時のイベント */
- (void)AdsDidHide{
    if ( self.delegate ) {
        if ([self.delegate respondsToSelector:@selector(AdsDidHide:)]) {
            [self.delegate AdsDidHide:self.appID];
        }
    }
}

/**< 広告の表示準備が終わった時のイベント */
- (void)AdsFetchCompleted:(BOOL)isTestMode_inApp{
    if ( self.delegate ) {
        if ([self.delegate respondsToSelector:@selector(AdsFetchCompleted:isTestMode_inApp:)]) {
            //NSLog(@"AdsFetchCompleted:");
            [self.delegate AdsFetchCompleted:self.appID isTestMode_inApp:isTestMode_inApp];
        }
    }
}

/**< 広告の表示が開始した時のイベント */
- (void)AdsDidShow:(NSString *)adnetworkKey{
    if ( self.delegate ) {
        if ([self.delegate respondsToSelector:@selector(AdsDidShow:adnetworkKey:)]) {
            [self.delegate AdsDidShow:self.appID adnetworkKey:adnetworkKey];
        }
    }
}
/**< 広告の表示を最後まで終わったか */
- (void)AdsDidCompleteShow{
    if ( self.delegate ) {
        if ([self.delegate respondsToSelector:@selector(AdsDidCompleteShow:)]) {
            [self.delegate AdsDidCompleteShow:self.appID];
        }
    }
}
/**< 動画広告再生エラー時のイベント */
- (void)AdsPlayFailed{
    if ( self.delegate ) {
        if ([self.delegate respondsToSelector:@selector(AdsPlayFailed:)]) {
            [self.delegate AdsPlayFailed:self.appID];
        }
    }
}

- (void)dispose{
    _appID = @"";
    self.delegate = nil;
    if(_movieInterstitial != nil){
        _movieInterstitial= nil;
    }
}

- (void) dealloc{
    [self dispose];
}
@end
