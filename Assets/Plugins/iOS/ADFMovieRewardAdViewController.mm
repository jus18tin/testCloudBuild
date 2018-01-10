#import "ADFMovieRewardAdViewController.h"
#import "ADFMovieUtilForUnity.h"

//
// Unity出力の設定を呼び出しています。
// classes/iPhone_view.mm にて取得できるメソッドが確認できますので、適宜必要な情報を取得してください。
extern UIViewController* UnityGetGLViewController();

// こちらは、UnityのAdfurikunMovieRewardUtiliityに値を返す為の関数になります。
extern void UnitySendMessage(const char *, const char *, const char *);

// こちらは、Unityから呼び出せるようにするための記述です。
// Cでの関数を追加した際には追加するようにしましょう。
extern "C" {
    void initializeMovieRewardIOS_(char* appID);
    void playMovieRewardIOS_(char* appID);
    bool isPreparedMovieRewardIOS_(char* appID);
    void disposeIOS_();
}

@implementation ADFMovieRewardAdViewController

static ADFMovieRewardAdViewController *instance = nil; // クラス自身のインスタンス
__strong static NSMutableDictionary* adMovieRewardList = nil;//動画リワードのインスタンスを格納する為の配列

static const char* UTILITY_GAMEOBJECT_NAME = "AdfurikunMovieRewardUtility";
static const char* UTILITY_FUNC_NAME = "MovieRewardCallback";

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

- (void)dealloc {
	[self dispose];
}

/**
 動画リワードのインスタンスの初期化を、広告枠ごとに行います
 */
+ (void)initializeMovieRewardWithAppID:(NSString*)app_id{
    if([app_id length] < 1){return;}
    if ( instance == nil) {
        instance = [[ADFMovieRewardAdViewController alloc] init];
    }
    if(adMovieRewardList == nil){
        adMovieRewardList = [@{} mutableCopy];
    }

    //iOSが対応バージョンなら、指定した広告枠で動画読み込みを開始
    if(![ADFmyMovieReward isSupportedOSVersion]){
        return;
    }
    UIViewController *displayViewController = UnityGetGLViewController();
    [ADFmyMovieReward initWithAppID:app_id viewController:displayViewController];
    //Unity用のアダプタークラスを生成
    ADFMovieRewardUnityAdapter* unityAdapter =
    [[ADFMovieRewardUnityAdapter alloc] initWithAppID:app_id];
    unityAdapter.delegate = instance;
    //アダプターをリストに保存
    [adMovieRewardList setObject:unityAdapter forKey:app_id];
}

+ (bool)isPreparedMovieReward:(NSString*)app_id{
    adf_debug_NSLog(@"isPreparedMovieReward");
    ADFMovieRewardUnityAdapter* adapter = [ADFMovieRewardAdViewController getAdapter:app_id];
    if(adapter != nil){
        return [[adapter getMovieReward] isPrepared];
    }
    return false;
}

+ (void)playMovieReward:(NSString*)app_id{
    adf_debug_NSLog(@"playMovieReward");
    ADFMovieRewardUnityAdapter* adapter = [ADFMovieRewardAdViewController getAdapter:app_id];
    if(adapter != nil){
        [UnityGetGLViewController() addChildViewController:instance];
        [[adapter getMovieReward] play];
    }
}

/**< 広告の表示準備が終わった */
- (void)AdsFetchCompleted:(NSString *)appID isTestMode_inApp:(BOOL)isTestMode_inApp{
    NSLog(@"AdsFetchCompleted:-");
    UnitySendMessage( UTILITY_GAMEOBJECT_NAME, UTILITY_FUNC_NAME,
                     [ADFMovieUtilForUnity convUnityParamFormat:@"PrepareSuccess" appID:appID]
                     );
}

/**< 広告の表示が開始したか */
- (void)AdsDidShow:(NSString *)appID adnetworkKey:(NSString *)adNetworkKey{
    NSLog(@"AdsDidShow:-");
    UnitySendMessage( UTILITY_GAMEOBJECT_NAME, UTILITY_FUNC_NAME,
                     [ADFMovieUtilForUnity convUnityParamFormat:@"StartPlaying" appID:appID adnetworkKey:adNetworkKey]
                     );
}

/**< 広告の表示を最後まで終わったか */
- (void)AdsDidCompleteShow:(NSString *)appID{
    NSLog(@"AdsDidCompleteShow:-");
    //[UnityGetGLViewController() dismissViewControllerAnimated:NO completion:nil];
    UnitySendMessage( UTILITY_GAMEOBJECT_NAME, UTILITY_FUNC_NAME,
                     [ADFMovieUtilForUnity convUnityParamFormat:@"FinishedPlaying" appID:appID ]
                     );
}
/**< 動画広告再生エラー時のイベント */
- (void)AdsPlayFailed:(NSString *)appID{
    NSLog(@"AdsPlayFailed:-");
    UnitySendMessage( UTILITY_GAMEOBJECT_NAME, UTILITY_FUNC_NAME,
                     [ADFMovieUtilForUnity convUnityParamFormat:@"FailedPlaying" appID:appID ]
                     );
}

- (void)AdsDidHide:(NSString *)appID{
    NSLog(@"AdsDidHide:-");
    [instance removeFromParentViewController];
    [UnityGetGLViewController() dismissViewControllerAnimated:NO completion:nil];
    UnitySendMessage( UTILITY_GAMEOBJECT_NAME, UTILITY_FUNC_NAME,
                     [ADFMovieUtilForUnity convUnityParamFormat:@"AdClose" appID:appID ]
                     );
}

+ (ADFMovieRewardUnityAdapter *)getAdapter:(NSString *)appID{
    ADFMovieRewardUnityAdapter* adapter = (ADFMovieRewardUnityAdapter *)[adMovieRewardList objectForKey:appID];
    return (adapter != nil) ? adapter: nil;
}

- (void)dispose{
    if(adMovieRewardList != nil) {
        [ADFmyMovieReward disposeAll];
        for (id key in [adMovieRewardList keyEnumerator]) {
            ADFMovieRewardUnityAdapter* o = (ADFMovieRewardUnityAdapter*)[adMovieRewardList valueForKey:key];
            if(o != nil) {
                [o dispose];
                o = nil;
                //[o release];
            }
        }
        [adMovieRewardList removeAllObjects];
        adMovieRewardList = nil;
    }
    instance = nil;
}

+ (void)dispose_handle{
    if(instance != nil){
    	[instance dispose];
    }
}

@end

// ココからはUnity から呼び出すための関数を指定しています。
// 機能を追加して、Unityから呼び出す際にはココに書いてください。
void initializeMovieRewardIOS_(char* appID){
    [ADFMovieRewardAdViewController initializeMovieRewardWithAppID:[NSString stringWithCString:appID encoding:NSUTF8StringEncoding]];
}

void playMovieRewardIOS_(char* appID){
    if([adMovieRewardList count] > 0){
        [ADFMovieRewardAdViewController playMovieReward:[NSString stringWithCString:appID encoding:NSUTF8StringEncoding]];
    }
}

bool isPreparedMovieRewardIOS_(char* appID){
    if([adMovieRewardList count] > 0){
        return [ADFMovieRewardAdViewController isPreparedMovieReward:[NSString stringWithCString:appID encoding:NSUTF8StringEncoding]];
    }
    return false;
}

void disposeIOS_(){
	[ADFMovieRewardAdViewController dispose_handle];
}
