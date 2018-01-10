@interface ADFMovieUtilForUnity : NSObject
+ (const char *)convUnityParamFormat:(NSString * )stateName appID:(NSString *)appID adnetworkKey:(NSString *)adnetworkKey;
+ (const char *)convUnityParamFormat:(NSString * )stateName appID:(NSString *)appID errCode:(NSString *)errCode;
+ (const char *)convUnityParamFormat:(NSString * )stateName appID:(NSString *)appID;
+ (const char *)convUnityParamFormat:(NSString * )stateName appID:(NSString *)appID isVideo:(NSString *)isVideo;
@end
