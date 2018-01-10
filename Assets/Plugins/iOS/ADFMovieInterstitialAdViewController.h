#import <UIKit/UIKit.h>

#import "ADFMovieInterstitialUnityAdapter.h"
#import <ADFMovieReward/ADFmyMovieInterstitial.h>

@interface ADFMovieInterstitialAdViewController : UIViewController  <ADFMovieInterstitialUnityAdapterDelegate>

- (id)init;

+ (void)initializeMovieRewardWithAppID:(NSString*)app_id;
+ (void)playMovieReward:(NSString*)app_id;
+ (bool)isPreparedMovieReward:(NSString*)app_id;
+ (void)dispose_handle;
- (void)dealloc;

@end
