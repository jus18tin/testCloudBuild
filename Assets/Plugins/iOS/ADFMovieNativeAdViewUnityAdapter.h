//
//  ADFMovieNativeAdViewUnityAdapter.h
//  Unity-iPhone
//
//  Created by Junhua Li on 2017/04/10.
//
//

#import <Foundation/Foundation.h>
#import <ADFMovieReward/ADFmyMovieNativeAdView.h>

@interface ADFMovieNativeAdViewUnityAdapter : NSObject<ADFmyMovieNativeAdViewDelegate>

- (instancetype)initWithAppID:(NSString *)appID;
- (ADFmyMovieNativeAdView *)getMovieNativeAdView;

@end
