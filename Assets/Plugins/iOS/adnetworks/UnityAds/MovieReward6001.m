//
//  MovieReward6001.m(UnityAds)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//
#import <UIKit/UIKit.h>
#import "MovieReward6001.h"


@interface MovieReward6001()<UnityAdsDelegate>
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, strong)NSString *gameId;
@property (nonatomic, assign)BOOL isCompleted;
@end

@implementation MovieReward6001

/**
 *  データの設定
 */
-(void)setData:(NSDictionary *)data {
    self.viewController = [data objectForKey:@"displayViewController"];
    
    [UnityAds setDelegate:self];
    
    BOOL testFlg = [[data objectForKey:@"test_flg"] boolValue];
    if (!testFlg) {
        [UnityAds setDebugMode:testFlg];//詳細メッセージを出したい場合は、パラメータを有効にして下さい。
    }
    
    //NSLog(@"test developer_id:%@", [data objectForKey:@"developer_id"]);
//    [UnityAds setTestDeveloperId:[data objectForKey:@"developer_id"]]; // デベロッパーID
    self.gameId = [NSString stringWithFormat:@"%@",[data objectForKey:@"game_id"]];
    _isCompleted = NO;
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd {
    if (!_viewController) {
        return;
    }
    
    if ([UnityAds isInitialized]) {
        return;
    }
    
    // 初期化は1回のみ。1回のみになっているか？？
    [UnityAds initialize:self.gameId delegate:self];
}

-(BOOL)isPrepared{
    return [UnityAds isReady] && self.viewController;
}

/**
 *  広告の表示を行う
 */
-(void)showAd {
    if (self.isPrepared) {
        if (self.viewController.presentedViewController) {
            [UnityAds show:self.viewController.presentedViewController];
        } else {
            [UnityAds show:self.viewController];
        }
    }
}

/**
 * 対象のクラスがあるかどうか？
 */
-(BOOL)isClassReference {
    NSLog(@"MovieReward6001 isClassReference");
    Class clazz = NSClassFromString(@"UnityAds");
    if (clazz) {
        NSLog(@"found Class: UnityAds");
        return YES;
    }
    else {
        NSLog(@"Not found Class: UnityAds");
        return NO;
    }
}

/**
 *  広告の読み込みを中止
 */
-(void)cancel {
// 2.0で廃止  [UnityAds stopAll];
}


-(void)dealloc {
    _viewController = nil;
    _gameId = nil;
}

// ------------------------------ -----------------
// ここからはUnityAdsのDelegateを受け取る箇所

#pragma mark - UnityAdsDelegate

// 2.0で廃止
//// 動画の読み込み完了
//- (void)unityAdsFetchCompleted {
//    NSLog(@"unityAdsFetchCompleted");
//    
//    if (self.delegate) {
//        if ([self.delegate respondsToSelector:@selector(AdsFetchCompleted:)]) {
//            [self.delegate AdsFetchCompleted:self];
//        }
//    }
//}

// 動画の読み込み完了
// 1.5: (void)unityAdsFetchCompleted
- (void)unityAdsReady:(NSString *)placementId {
    NSLog(@"《 UnityAds Callback 》unityAdsReady");
    
    // 複数のplacementが登録されていると全ての状態を通知されるので、動画リワードのみを扱う
    if ([placementId isEqualToString:@"rewardedVideoZone"] || [placementId isEqualToString:@"rewardedVideo"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(AdsFetchCompleted:)]) {
            [self.delegate AdsFetchCompleted:self];
        }
    }
}

// 動画の読み込み完了
// 1.5: 該当なし
- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message {
    NSLog(@"《 UnityAds Callback 》unityAdsDidError");
}

// 2.0で廃止
//- (void)unityAdsFetchFailed
//{
//    NSLog(@"unityAdsFetchFailed");
//}

// 2.0で廃止
//// 動画表示直前
//- (void)unityAdsWillShow {
//    NSLog(@"unityAdsWillShow");
//}

// 2.0で廃止
//// 動画表示直後
//- (void)unityAdsDidShow {
//    NSLog(@"unityAdsDidShow");
//    if ( self.delegate ) {
//        if ([self.delegate respondsToSelector:@selector(AdsDidShow:)]) {
//            _isCompleted = NO;
//            [self.delegate AdsDidShow:self];
//        }
//    }
//}

// 動画の再生開始
// 1.5: (void)unityAdsWillShow, (void)unityAdsDidShow
- (void)unityAdsDidStart:(NSString *)placementId {
    NSLog(@"《 UnityAds Callback 》unityAdsDidStart");
    if (self.delegate && [self.delegate respondsToSelector:@selector(AdsDidShow:)]) {
        _isCompleted = NO;
        [self.delegate AdsDidShow:self]; //?? これは何のフラグ？
    }
}

// 2.0で廃止
//- (void)unityAdsWillHide {
//    NSLog(@"unityAdsWillHide");
//    //元の画面に戻る際に完了フラグが立っていなかったら、再生失敗のコールバックを返す
//    if(!_isCompleted){
//        if ( self.delegate ) {
//            if ([self.delegate respondsToSelector:@selector(AdsPlayFailed:)]) {
//                [self.delegate AdsPlayFailed:self];
//            }
//        }
//    }
//    _isCompleted = NO;
//}
//
//- (void)unityAdsDidHide {
//    NSLog(@"unityAdsDidHide");
//    if ( self.delegate ) {
//        if ([self.delegate respondsToSelector:@selector(AdsDidHide:)]) {
//            [self.delegate AdsDidHide:self];
//        }
//    }
//}

// 2.0で廃止
//- (void)unityAdsVideoCompleted:(NSString *)rewardItemKey skipped:(BOOL)skipped {
//    NSLog(@"unityAdsVideoCompleted:rewardItemKey:skipped -- key: %@ -- skipped: %@", rewardItemKey, skipped ? @"true" : @"false");
//    if ( !skipped ) {
//        // ちゃんと最後まで全てみた場合のみ。
//        if ( self.delegate ) {
//            if ([self.delegate respondsToSelector:@selector(AdsDidCompleteShow:)]) {
//                _isCompleted = YES;
//                [self.delegate AdsDidCompleteShow:self];
//            }
//        }
//    }else{
//        if ( self.delegate ) {
//            if ([self.delegate respondsToSelector:@selector(AdsPlayFailed:)]) {
//                [self.delegate AdsPlayFailed:self];
//            }
//        }
//    }
//}

// 広告を閉じる
// 1.5: (void)unityAdsVideoCompleted:skipped
- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state {
    NSLog(@"《 UnityAds Callback 》unityAdsDidFinish:withFinishState:");
    // 2.0から再生完了のコールバックが削除されたので、広告終了時に合わせて通知する
    switch (state) {
        // 視聴完了
        case kUnityAdsFinishStateCompleted:
            if (self.delegate && [self.delegate respondsToSelector:@selector(AdsDidCompleteShow:)]) {
                _isCompleted = YES;
                [self.delegate AdsDidCompleteShow:self];
            }
            break;
//        // 途中でスキップした
//        case kUnityAdsFinishStateSkipped:
//        // 何かしら再生エラー
//        case kUnityAdsFinishStateError:
        // 完了以外は全て失敗
        default:
            if (self.delegate && [self.delegate respondsToSelector:@selector(AdsPlayFailed:)]) {
                [self.delegate AdsPlayFailed:self];
            }
            break;
    }
    
    // 広告を閉じてアプリに戻る
    // 1.5: (void)unityAdsWillHide, (void)unityAdsDidHide
    if (self.delegate && [self.delegate respondsToSelector:@selector(AdsDidHide:)]) {
        [self.delegate AdsDidHide:self];
    }
}

@end
