//
//  ViewController.m
//  AdMob-Passback-Banner
//
//  Created by ryokosuge on 2020/03/06.
//  Copyright © 2020 ryokosuge. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

// fp引いている枠ID
static NSString *const kAdMobBannerFP100AdUnitID = @"ca-app-pub-3010029359415397/3199559314";
// テストID
static NSString *const kAdMobBannerNoAdUnitID = @"ca-app-pub-3940256099942544/2934735716";

// auto refreshをするinterval
static NSTimeInterval const kAutoRefreshTimeInterval = 30.0;

@interface ViewController () <GADBannerViewDelegate>
@property (nonatomic, nullable) GADBannerView *bannerView;
@property (nonatomic, nullable) NSTimer *autoRefreshTimer;
@end

@implementation ViewController

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 画面の表示前に読み込みを開始する
    [self loadBanner];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // 画面が見えなくなるタイミングでtimerを止める
    // 見えてないところでrequestをし過ぎるとAdMobさんに怒られる可能性あり
    [self stopAutoRefreshTimer];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // 中央表示
    self.bannerView.center = self.view.center;
}

#pragma mark - Load Banner

- (void)loadBanner {
    // 初回は必ずfloor priceを引いている枠からリクエストを始める
    [self loadBannerWithAdUnitID:kAdMobBannerFP100AdUnitID];
}

- (void)loadBannerWithAdUnitID:(NSString *)adUnitID {
    // 320x50のサイズ
    GADBannerView *bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    bannerView.adUnitID = adUnitID;
    bannerView.rootViewController = self;
    bannerView.delegate = self;

    // アプリ側でauto refreshするのでbannerView自体のauto refreshはoffにする
    bannerView.autoloadEnabled = NO;

    // すでに参照を持っていた場合は
    // removeする
    // 参照を持っていない場合はnilだから何も行われない
    [self.bannerView removeFromSuperview];

    // 参照を保持しておく
    self.bannerView = bannerView;
    [self.view addSubview:bannerView];

    // Request
    [bannerView loadRequest:[GADRequest request]];
}

#pragma mark - Auto Refresh Timer

// timerが作られていない場合はtimerを作成してrunする
- (void)startAutoRefreshTimerIfNeeded {
    if (self.autoRefreshTimer) {
        // すでにtimerは作動しているので
        // 何もしない
        return;
    }

    // timer止めておく
    [self stopAutoRefreshTimer];

    // main thread実行したく無いので、background threadで実行する
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSTimer *autoRefreshTimer = [NSTimer timerWithTimeInterval:kAutoRefreshTimeInterval
                                                            target:self
                                                          selector:@selector(refreshBanner)
                                                          userInfo:nil
                                                           repeats:YES];
        self.autoRefreshTimer = autoRefreshTimer;
        [[NSRunLoop currentRunLoop] addTimer:autoRefreshTimer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] run];
    });
}

// timerの時間が来たら実行される
- (void)refreshBanner {
    // backgroundでtimerは動作しているので
    // main threadでloadBannerをcallするようにする
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf loadBanner];
    });
}

// timerを止めて破棄する
- (void)stopAutoRefreshTimer {
    [self.autoRefreshTimer invalidate];
    self.autoRefreshTimer = nil;
}

#pragma mark - GADBannerViewDelegate

// 表示する広告が取得できた時のcallback
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    NSLog(@"%s  %@", __FUNCTION__, bannerView);
    NSLog(@"receive ad unit id: %@", bannerView.adUnitID);

    // auto refreshするためにtimerをstartさせる
    [self startAutoRefreshTimerIfNeeded];
}

// 広告の取得に失敗した時
- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"%s  %@", __FUNCTION__, bannerView);
    NSLog(@"errorCode:  %ld", (long)error.code);
    NSLog(@"error ad unit id: %@", bannerView.adUnitID);
    // エラーコードは以下のドキュメントを参照ください
    // https://developers.google.com/admob/ios/api/reference/Enums/GADErrorCode

    // NoFillのみの場合パスバックしています
    // リクエストのタイムアウトなどが起きた時もこのmethodをcallしてくれるので
    if (error.code == kGADErrorNoFill) {
        // fillを埋められなかった = 広告表示する在庫がない
        // floor priceを引いている枠で失敗した場合は
        // floor priceを引いてない枠（2番目に読み込む枠）へ再リクエストを行う
        if ([bannerView.adUnitID isEqualToString:kAdMobBannerFP100AdUnitID]) {
            // 次に読み込む枠のAdUnitIDを指定してload
            [self loadBannerWithAdUnitID:kAdMobBannerNoAdUnitID];
        }
    } else if (error.code == kGADErrorTimeout) {
        // timeoutの場合は時間をおいて再度リクエストする
        NSString *adUnitID = bannerView.adUnitID;
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [weakSelf loadBannerWithAdUnitID:adUnitID];
        });
    }

}

// 全画面広告が閉じられた後にcallされる
- (void)adViewDidDismissScreen:(GADBannerView *)bannerView {
}

// 全画面広告が閉じられる前にcallされる
- (void)adViewWillDismissScreen:(GADBannerView *)bannerView {
}

// 広告が新しく全画面広告を表示する前にcallされる
- (void)adViewWillPresentScreen:(GADBannerView *)bannerView {
}

// 広告のクリックによりあアプリ外へ遷移する時のcallされる
- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView {
}

@end
