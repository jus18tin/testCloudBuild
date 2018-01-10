//
//  MovieNative6000.m(AppLovin)
//
//  (c) 2017 ADFULLY Inc.
//

#import "MovieNative6000.h"
#import "MovieReward6000.h"

typedef NS_OPTIONS(NSUInteger, ADFALAdLoadStatus) {
    ADFALAdLoadStatus_None           = 0,
    ADFALAdLoadStatus_ImagePrecached = 1 << 0,
    ADFALAdLoadStatus_VideoPrecached = 1 << 1,
};

@interface MovieNative6000()<ALNativeAdLoadDelegate, ALNativeAdPrecacheDelegate>
@property (atomic) BOOL requireMovie;
@property (atomic) ADFALAdLoadStatus loadStatus;
@end

@implementation MovieNative6000

- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"ALSdk");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: ALSdk");
        return NO;
    }
    return YES;
}

- (void)setData:(NSDictionary *)data {
    NSString * sdkKey = [data objectForKey:@"sdk_key"];
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    if (![infoDict objectForKey:@"AppLovinSdkKey"] ) {
        [infoDict setValue:sdkKey forKey:@"AppLovinSdkKey"];
    }
    NSString *submittedPackageName = [data objectForKey:@"package_name"];
    self.requireMovie = false;

    //バンドルIDが申請済のパッケージ名と異なると、正常に広告が返却されない可能性があります
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    if(submittedPackageName != nil &&
       ![[submittedPackageName lowercaseString] isEqualToString:[bundleId lowercaseString]]) {
        NSLog(@"[ADF][Applovin]アプリのバンドルIDが、申請されたものと異なります。");
    }
}

- (void)startAd {
    [MovieConfigure6000 configure];
    self.loadStatus = ADFALAdLoadStatus_None;
    ALSdk *sdk = [ALSdk shared];
    [sdk.nativeAdService loadNativeAdGroupOfCount:1 andNotify:self];
}

- (void)cancel {
}

- (BOOL)isPrecacheComplete:(ADFALAdLoadStatus)status {
    if ((status & ADFALAdLoadStatus_ImagePrecached) == ADFALAdLoadStatus_ImagePrecached &&
        (status & ADFALAdLoadStatus_VideoPrecached) == ADFALAdLoadStatus_VideoPrecached) {
        return YES;
    }
    return NO;
}

- (void)didPrecacheComplete:(ALNativeAd *)ad {
    if (self.requireMovie && ad.videoURL == nil) {
        [self.delegate onNativeMovieAdLoadError:self];
        return;
    }

    if ([self.delegate respondsToSelector:@selector(onNativeMovieAdLoadFinish:)]) {
        MovieNativeAdInfo6000 *info = [[MovieNativeAdInfo6000 alloc] initWithVideoUrl:ad.videoURL
                                                                                title:ad.title
                                                                          description:ad.descriptionText];
        info.adapter = self;
        info.ad = ad;
        info.imageUrl = ad.imageURL;
        self.adInfo = info;
        [self.delegate onNativeMovieAdLoadFinish:self.adInfo];
    }
}

#pragma mark - ALNativeAdLoadDelegate

- (void)nativeAdService:(ALNativeAdService *)service didLoadAds:(NSArray *)ads {
    [service precacheResourcesForNativeAd:ads.firstObject andNotify:self];
}

- (void)nativeAdService:(ALNativeAdService *)service didFailToLoadAdsWithError:(NSInteger)code {
    if ([self.delegate respondsToSelector:@selector(onNativeMovieAdLoadError:)]) {
        [self.delegate onNativeMovieAdLoadError:self];
    }
}

#pragma mark - ALNativeAdPrecacheDelegate

- (void)nativeAdService:(ALNativeAdService *)service didPrecacheImagesForAd:(ALNativeAd *)ad {
    self.loadStatus |= ADFALAdLoadStatus_ImagePrecached;
    if ([self isPrecacheComplete:self.loadStatus]) {
        self.isAdLoaded = YES;
        [self didPrecacheComplete:ad];
    }
}

- (void)nativeAdService:(ALNativeAdService *)service didPrecacheVideoForAd:(ALNativeAd *)ad {
    self.loadStatus |= ADFALAdLoadStatus_VideoPrecached;
    if ([self isPrecacheComplete:self.loadStatus]) {
        self.isAdLoaded = YES;
        [self didPrecacheComplete:ad];
    }

}

- (void)nativeAdService:(ALNativeAdService *)service didFailToPrecacheImagesForAd:(ALNativeAd *)ad withError:(NSInteger)errorCode {
    [self.delegate onNativeMovieAdLoadError:self];
}

- (void)nativeAdService:(ALNativeAdService *)service didFailToPrecacheVideoForAd:(ALNativeAd *)ad withError:(NSInteger)errorCode {
    [self.delegate onNativeMovieAdLoadError:self];
}

@end


@implementation MovieNativeAdInfo6000

- (void)trackImpression {
    if (!self.hasTrackedImpression) {
        [[ALSdk shared].postbackService dispatchPostbackAsync:self.ad.impressionTrackingURL andNotify:self];
    }
    [super trackImpression];
}

- (void)trackMovieStart {
    if (!self.hasTrackedMovieStart) {
        [[ALSdk shared].postbackService dispatchPostbackAsync:self.ad.videoStartTrackingURL andNotify:self];
    }
    [super trackMovieStart];
}

- (void)trackMovieFinish {
    if (!self.hasTrackedMovieFinish) {
        NSURL *url = [self.ad videoEndTrackingURL:100 firstPlay:YES];
        [[ALSdk shared].postbackService dispatchPostbackAsync:url andNotify:self];
    }
    [super trackMovieFinish];
}

- (void)launchClickTarget {
    [super launchClickTarget];
    [self.ad launchClickTarget];
}

#pragma mark - ALPostbackDelegate

- (void)postbackService:(ALPostbackService *)postbackService didExecutePostback:(NSURL *)postbackURL {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)postbackService:(ALPostbackService *)postbackService didFailToExecutePostback:(NSURL *)postbackURL errorCode:(NSInteger)errorCode {
    NSLog(@"Failed to track, errorCode=%li", (long)errorCode);
}

@end
