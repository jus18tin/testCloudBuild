//
//  ADFmyMovieNativeInterface.h
//  ADFMovieReword
//
//  Created by Toru Furuya on 2017/02/21.
//  (c) 2017 ADFULLY Inc.
//

#import <Foundation/Foundation.h>
#import "ADFMovieError.h"

@protocol ADFMovieNativeDelegate;
@class ADFMovieNativeAdInfo;

@interface ADFmyMovieNativeInterface : NSObject<NSCopying>

@property (nonatomic, weak) NSObject<ADFMovieNativeDelegate> *delegate;
@property (nonatomic) ADFMovieNativeAdInfo *adInfo;
@property (atomic) BOOL isAdLoaded;

- (BOOL)isClassReference;
- (void)setData:(NSDictionary *)data;
- (BOOL)isPrepared;
- (void)startAd;
- (void)cancel;

- (void)onImpression;
- (void)onMovieStart;
- (void)onMovieFinish;
- (void)onClick;

@end


@class ADFMovieNativeAdInfo;
@protocol ADFMovieNativeDelegate

@required
- (void)onNativeMovieAdImpression:(ADFmyMovieNativeInterface *)adapter;

@optional
- (void)onNativeMovieAdLoadFinish:(ADFMovieNativeAdInfo *)info;
- (void)onNativeMovieAdLoadError:(ADFmyMovieNativeInterface *)adapter;

- (void)onNativeMovieAdPlaybackStart:(ADFmyMovieNativeInterface *)adapter;
- (void)onNativeMovieAdPlaybackFinish:(ADFmyMovieNativeInterface *)adapter;
- (void)onNativeMovieAdClick:(ADFmyMovieNativeInterface *)adapter;

@end
