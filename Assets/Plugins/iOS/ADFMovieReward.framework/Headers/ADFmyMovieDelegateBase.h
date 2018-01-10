//
//  ADFmyMovieDelegateBase.h
//  ADFMovieReword
//
//  Created by Toru Furuya on 2017/01/18.
//  (c) 2017 ADFULLY Inc.
//

#import <Foundation/Foundation.h>

#import "ADFmyMovieRewardInterface.h"

@interface ADFmyMovieDelegateBase : NSObject

+ (instancetype)sharedInstance;
- (void)setMovieReward:(ADFmyMovieRewardInterface *)movieReward inZone:(NSString *)zoneId;
- (void)setDelegate:(id<ADFMovieRewardDelegate>)delegate inZone:(NSString *)zoneId;

- (ADFmyMovieRewardInterface *)getMovieRewardWithZone:(NSString *)zoneId;
- (id<ADFMovieRewardDelegate>)getDelegateWithZone:(NSString *)zoneId;
    
@end
