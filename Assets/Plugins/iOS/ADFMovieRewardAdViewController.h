#import <UIKit/UIKit.h>

#import "ADFMovieRewardUnityAdapter.h"
#import <ADFMovieReward/ADFmyMovieReward.h>
//#import "ADFmyMovieReward.h"

@interface ADFMovieRewardAdViewController : UIViewController  <ADFMovieRewardUnityAdapterDelegate>

- (id)init;

+ (void)initializeMovieRewardWithAppID:(NSString*)app_id;
+ (void)playMovieReward:(NSString*)app_id;
+ (bool)isPreparedMovieReward:(NSString*)app_id;
+ (void)dispose_handle;
- (void)dealloc;

@end

