//
//  ADFmyMovieInterstitial.h
//  ADFMovieReword
//
//  Created by Junhua Li on 2016/11/02.
//  (c) 2016 ADFULLY Inc.
//

#import "ADFmyMovieReward.h"

@interface ADFmyMovieInterstitial : NSObject<ADFMovieRewardDelegate>
@property (nonatomic, weak) UIViewController *displayViewController;
@property (nonatomic, weak) NSObject<ADFmyMovieRewardDelegate> *delegate;

-(BOOL)isPrepared;
-(void)play;
-(void)dispose;

+ (BOOL)isSupportedOSVersion;
+ (void)initWithAppID:(NSString *)appID viewController:(UIViewController*)viewController;
+ (ADFmyMovieInterstitial *)getInstance:(NSString *)appID delegate:(id<ADFmyMovieRewardDelegate>)delegate;
+ (void)disposeAll;

@end
