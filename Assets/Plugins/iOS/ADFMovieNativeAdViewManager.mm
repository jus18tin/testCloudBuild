//
//  ADFMovieNativeAdViewManager.m
//  Unity-iPhone
//
//  Created by Junhua Li on 2017/04/10.
//
//

#import "ADFMovieNativeAdViewManager.h"
#import "ADFMovieNativeAdViewUnityAdapter.h"
#import "ADFMovieUtilForUnity.h"

extern void UnitySendMessage(const char *, const char *, const char *);

extern "C" {
    void initializeMovieNativeAdViewIOS_(char* appID);
    void loadMovieNativeAdViewIOS_(char* appID);
    void showMovieNativeAdViewIOS_(char* appID, float x, float y , float width, float height, float screenW);
    void setMovieNativeAdViewFrameIOS_(char* appID, float x, float y , float width, float height, float screenW);
    void playMovieNativeAdViewIOS_(char* appID);
    void pauseMovieNativeAdViewIOS_(char* appID);
    void hideMovieNativeAdViewIOS_(char* appID);
    void stopMovieNativeAdViewAutoReloadIOS_(char* appID);
    void startMovieNativeAdViewAutoReloadIOS_(char* appID);
}
@interface ADFMovieNativeAdViewManager()<ADFmyNativeAdViewVideoDelegate, ADFmyMovieNativeAdViewDelegate>
@end

@implementation ADFMovieNativeAdViewManager

static id<ADFmyNativeAdViewVideoDelegate, ADFmyMovieNativeAdViewDelegate> instance = nil;
__strong static NSMutableDictionary* adMovieNativeAdList = nil;

static const char* UTILITY_GAMEOBJECT_NAME = "AdfurikunMovieNativeAdViewUtility";
static const char* UTILITY_FUNC_NAME = "MovieNativeAdViewCallback";

// こちら、NSLogを残したままご利用になられる方が多かったので、
// Debug の場合のみLogを表示するようにしています。
#define _ADF_DEBUG_ENABLE_
#ifdef _ADF_DEBUG_ENABLE_
#define adf_debug_NSLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define adf_debug_NSLog(format, ...)
#endif

- (id)init {
    self = [super init];
    if ( self ) {

    }
    return self;
}

+ (void)configureWithAppID:(NSString*)appId{
    if([appId length] < 1){return;}
    if ( instance == nil) {
        instance = [[ADFMovieNativeAdViewManager alloc] init];
    }

    if(adMovieNativeAdList == nil){
        adMovieNativeAdList = [@{} mutableCopy];
    }

    //iOSが対応バージョンなら、指定した広告枠で動画読み込みを開始
    if(![ADFmyMovieNativeAdView isSupportedOSVersion]){
        return;
    }
    [ADFmyMovieNativeAdView configureWithAppID:appId];

    //Unity用のアダプタークラスを生成
    ADFMovieNativeAdViewUnityAdapter* unityAdapter = [[ADFMovieNativeAdViewUnityAdapter alloc] initWithAppID:appId];
    //unityAdapter.delegate = instance;
    //アダプターをリストに保存
    [adMovieNativeAdList setObject:unityAdapter forKey:appId];
}

+ (ADFMovieNativeAdViewUnityAdapter *)getAdapter:(NSString *)appID{
    ADFMovieNativeAdViewUnityAdapter* adapter = (ADFMovieNativeAdViewUnityAdapter *)[adMovieNativeAdList objectForKey:appID];
    return (adapter != nil) ? adapter: nil;
}

+ (void)loadMovieNativeAdView:(NSString*)appId{
    adf_debug_NSLog(@"loadMovieNativeAdView");
    ADFMovieNativeAdViewUnityAdapter* adapter = [ADFMovieNativeAdViewManager getAdapter:appId];
    if(adapter != nil){
        ADFmyMovieNativeAdView *nativeAdView = [adapter getMovieNativeAdView];
        [nativeAdView loadAndNotifyTo:instance];
        [nativeAdView setVideoDelegate:instance];
    }
}

+ (void)showMovieNativeAdView:(NSString*)appId x:(float)x y:(float)y width:(float)width height:(float)height{
    adf_debug_NSLog(@"showMovieNativeAdView");
    ADFMovieNativeAdViewUnityAdapter* adapter = [ADFMovieNativeAdViewManager getAdapter:appId];
    if(adapter != nil){
        UIView* unityView = UnityGetGLView();
        ADFmyMovieNativeAdView *nativeAdView = [adapter getMovieNativeAdView];
        [unityView addSubview:[nativeAdView getAdView]];
        [nativeAdView getAdView].frame = CGRectMake(x, y, width, height);
    }
}

+ (void)setMovieNativeAdViewFrame:(NSString*)appId x:(float)x y:(float)y width:(float)w height:(float)h {
    adf_debug_NSLog(@"setMovieNativeAdView");
    ADFMovieNativeAdViewUnityAdapter* adapter = [ADFMovieNativeAdViewManager getAdapter:appId];
    if (adapter) {
        ADFmyMovieNativeAdView *native = [adapter getMovieNativeAdView];
        [native getAdView].frame = CGRectMake(x, y, w, h);
    }
}

+ (void)playMovieNativeAdView:(NSString*)appId{
    adf_debug_NSLog(@"playMovieNativeAdView");
    ADFMovieNativeAdViewUnityAdapter* adapter = [ADFMovieNativeAdViewManager getAdapter:appId];
    if(adapter != nil){
        ADFmyMovieNativeAdView *nativeAdView = [adapter getMovieNativeAdView];
        [nativeAdView playVideo];
    }
}

+ (void)pauseMovieNativeAdView:(NSString*)appId{
    adf_debug_NSLog(@"pauseMovieNativeAdView");
    ADFMovieNativeAdViewUnityAdapter* adapter = [ADFMovieNativeAdViewManager getAdapter:appId];
    if(adapter != nil){
        ADFmyMovieNativeAdView *nativeAdView = [adapter getMovieNativeAdView];
        [nativeAdView pauseVideo];
    }
}

+ (void)hideMovieNativeAdView:(NSString*)appId{
    adf_debug_NSLog(@"hideMovieNativeAdView");
    ADFMovieNativeAdViewUnityAdapter* adapter = [ADFMovieNativeAdViewManager getAdapter:appId];
    if(adapter != nil){
        ADFmyMovieNativeAdView *nativeAdView = [adapter getMovieNativeAdView];
        [nativeAdView pauseVideo];
        [[nativeAdView getAdView] removeFromSuperview];
    }
}

+ (void)stopMovieNativeAdViewAutoReload:(NSString*)appId{
    adf_debug_NSLog(@"stopMovieNativeAdViewAutoReload");
    [ADFMovieNativeAdViewManager setMovieNativeAdViewAutoReload:appId flag:NO];
}

+ (void)startMovieNativeAdViewAutoReload:(NSString*)appId{
    adf_debug_NSLog(@"startMovieNativeAdViewAutoReload");
    [ADFMovieNativeAdViewManager setMovieNativeAdViewAutoReload:appId flag:YES];
}

+ (void)setMovieNativeAdViewAutoReload:(NSString*)appId flag:(BOOL)shouldAutoLoad{
    ADFMovieNativeAdViewUnityAdapter* adapter = [ADFMovieNativeAdViewManager getAdapter:appId];
    if(adapter != nil){
        ADFmyMovieNativeAdView *nativeAdView = [adapter getMovieNativeAdView];
        nativeAdView.autoLoad = shouldAutoLoad;
    }
}

#pragma mark - ADFmyMovieNativeAdViewDelegate

//ネイティブ広告の読み込み成功
- (void)onNativeMovieAdViewLoadFinish:(NSString *)appID {
    adf_debug_NSLog(@"onNativeMovieAdViewLoadFinish");
    UnitySendMessage( UTILITY_GAMEOBJECT_NAME, UTILITY_FUNC_NAME,
                     [ADFMovieUtilForUnity convUnityParamFormat:@"LoadFinish" appID:appID ]
                     );
}

//ネイティブ広告の読み込み失敗
- (void)onNativeMovieAdViewLoadError:(ADFMovieError *)error appID:(NSString *)appID {
    adf_debug_NSLog(@"onNativeMovieAdViewLoadError");
    UnitySendMessage( UTILITY_GAMEOBJECT_NAME, UTILITY_FUNC_NAME,
                     [ADFMovieUtilForUnity convUnityParamFormat:@"LoadError" appID:appID errCode:[NSString stringWithFormat:@"%ld", (long)error.errorCode]]
                     );
}
//ネイティブ広告の再生開始
- (void)onNativeMovieAdViewPlayStart:(NSString *)appID {
    adf_debug_NSLog(@"onNativeMovieAdViewPlayStart");
    UnitySendMessage( UTILITY_GAMEOBJECT_NAME, UTILITY_FUNC_NAME,
                     [ADFMovieUtilForUnity convUnityParamFormat:@"PlayStart" appID:appID ]
                     );
}
//ネイティブ広告の再生完了
- (void)onNativeMovieAdViewPlayFinish:(NSString *)appID isVideo:(BOOL)isVideo {
    adf_debug_NSLog(@"onNativeMovieAdViewPlayFinish");
    UnitySendMessage( UTILITY_GAMEOBJECT_NAME, UTILITY_FUNC_NAME,
                     [ADFMovieUtilForUnity convUnityParamFormat:@"PlayFinish" appID:appID isVideo:[NSString stringWithFormat:@"%d", isVideo]]
                     );
}
//ネイティブ広告の再生失敗
- (void)onNativeMovieAdViewPlayFail:(NSString *)appID error:(ADFMovieError *)error {
    adf_debug_NSLog(@"onNativeMovieAdViewLoadError");
    UnitySendMessage( UTILITY_GAMEOBJECT_NAME, UTILITY_FUNC_NAME,
                     [ADFMovieUtilForUnity convUnityParamFormat:@"PlayError" appID:appID errCode:[NSString stringWithFormat:@"%ld", (long)error.errorCode]]
                     );
}

@end

void initializeMovieNativeAdViewIOS_(char* appID){
    [ADFMovieNativeAdViewManager configureWithAppID:[NSString stringWithCString:appID encoding:NSUTF8StringEncoding]];
}

void loadMovieNativeAdViewIOS_(char* appID){
    [ADFMovieNativeAdViewManager loadMovieNativeAdView:[NSString stringWithCString:appID encoding:NSUTF8StringEncoding]];
}

void showMovieNativeAdViewIOS_(char* appID, float x, float y, float width, float height, float screenW) {
    float scale = UIScreen.mainScreen.bounds.size.width / screenW;
    float _w = width * scale;
    float _h = height * scale;
    float _x = x * scale;
    float _y = y * scale;

    NSString *_appID = [NSString stringWithCString:appID encoding:NSUTF8StringEncoding];
    [ADFMovieNativeAdViewManager showMovieNativeAdView:_appID x:_x y:_y width:_w height:_h];
}

void setMovieNativeAdViewFrameIOS_(char* appID, float x, float y, float width, float height, float screenW) {
    float scale = UIScreen.mainScreen.bounds.size.width / screenW;
    float _w = width * scale;
    float _h = height * scale;
    float _x = x * scale;
    float _y = y * scale;

    NSString *_appID = [NSString stringWithCString:appID encoding:NSUTF8StringEncoding];
    [ADFMovieNativeAdViewManager setMovieNativeAdViewFrame:_appID x:_x y:_y width:_w height:_h];
}

void playMovieNativeAdViewIOS_(char* appID){
    [ADFMovieNativeAdViewManager playMovieNativeAdView:[NSString stringWithCString:appID encoding:NSUTF8StringEncoding]];
}

void pauseMovieNativeAdViewIOS_(char* appID){
    [ADFMovieNativeAdViewManager pauseMovieNativeAdView:[NSString stringWithCString:appID encoding:NSUTF8StringEncoding]];
}

void hideMovieNativeAdViewIOS_(char* appID){
    [ADFMovieNativeAdViewManager hideMovieNativeAdView:[NSString stringWithCString:appID encoding:NSUTF8StringEncoding]];
}

void stopMovieNativeAdViewAutoReloadIOS_(char* appID){
    [ADFMovieNativeAdViewManager stopMovieNativeAdViewAutoReload:[NSString stringWithCString:appID encoding:NSUTF8StringEncoding]];
}

void startMovieNativeAdViewAutoReloadIOS_(char* appID){
    [ADFMovieNativeAdViewManager startMovieNativeAdViewAutoReload:[NSString stringWithCString:appID encoding:NSUTF8StringEncoding]];
}
