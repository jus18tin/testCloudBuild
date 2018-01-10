#import "ADFMovieUtilForUnity.h"

@implementation ADFMovieUtilForUnity
/**
 文字をシリアライズ形式にする
 */
+ (const char *)convUnityParamFormat:(NSString * )stateName appID:(NSString *)appID adnetworkKey:(NSString *)adnetworkKey{
    NSString* str = [NSString stringWithFormat:@"stateName:%@;appID:%@", stateName, appID];
    if(adnetworkKey.length > 0){
        str = [str stringByAppendingString: [NSString stringWithFormat:@";adnetworkKey:%@", adnetworkKey]];
    }
    return (char*)[str UTF8String];
}
+ (const char *)convUnityParamFormat:(NSString * )stateName appID:(NSString *)appID {
    return [ADFMovieUtilForUnity convUnityParamFormat:stateName appID:appID adnetworkKey:@""];
}

+ (const char *)convUnityParamFormat:(NSString * )stateName appID:(NSString *)appID errCode:(NSString *)errCode{
    NSString* str = [NSString stringWithFormat:@"stateName:%@;appID:%@", stateName, appID];
    if(errCode.length > 0){
        str = [str stringByAppendingString: [NSString stringWithFormat:@";errCode:%@", errCode]];
    }
    return (char*)[str UTF8String];
}

+ (const char *)convUnityParamFormat:(NSString * )stateName appID:(NSString *)appID isVideo:(NSString *)isVideo{
    NSString* str = [NSString stringWithFormat:@"stateName:%@;appID:%@;isVideo:%@", stateName, appID, isVideo];
    return (char*)[str UTF8String];
}
@end
