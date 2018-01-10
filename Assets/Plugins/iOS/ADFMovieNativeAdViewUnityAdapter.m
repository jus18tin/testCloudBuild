//
//  ADFMovieNativeAdViewUnityAdapter.m
//  Unity-iPhone
//
//  Created by Junhua Li on 2017/04/10.
//
//

#import "ADFMovieNativeAdViewUnityAdapter.h"

@interface ADFMovieNativeAdViewUnityAdapter()
@property (nonatomic) ADFmyMovieNativeAdView *nativeAdView;
@property (nonatomic, copy) NSString* appID;
@end

@implementation ADFMovieNativeAdViewUnityAdapter

- (instancetype)initWithAppID:(NSString *)appID {
    self = [super init];
    if (self) {
        _nativeAdView = [[ADFmyMovieNativeAdView alloc] initWithAppID:appID layoutPattern:ADFMovieNativeAdLayoutPattern_Default];
        _appID = [[NSString alloc] initWithString:appID];
    }
    return self;
}

- (ADFmyMovieNativeAdView *)getMovieNativeAdView {
    return self.nativeAdView;
}

@end
