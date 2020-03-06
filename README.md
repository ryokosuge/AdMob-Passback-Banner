# AdMob Passback Banner

バナー枠のパスバック実装のサンプル

## env

```
Xcode: 10.3
CocoaPods: 1.8.4
```

### Libraries

```
Google-Mobile-Ads-SDK: 7.56.0
```

## setup

```
> pod install --repo-update
```

### AppIDの書き換え

`AdMob-Passback-Banner` > `Info.plist`の中の`GADApplicationIdentifier`をご自身のAppIDに書き換えてください

## Project

使用しているAdUnitIDとAppIDは全てテスト用のため、書き換えてご使用ください

```
.
├── AdMob-Passback-Banner
│   ├── AppDelegate.h
│   ├── AppDelegate.m
│   ├── Assets.xcassets
│   ├── Base.lproj
│   ├── Info.plist
│   ├── ViewController.h
│   ├── ViewController.m // このファイルにパスバッグ処理が全て書かれています
│   └── main.m
├── AdMob-Passback-Banner.xcodeproj
├── AdMob-Passback-Banner.xcworkspace
├── Podfile
├── Podfile.lock
├── Pods
└── README.md
```

## 動作ログ

```
2020-03-06 17:59:56.798809+0900 AdMob-Passback-Banner[12970:1240861] -[ViewController adView:didFailToReceiveAdWithError:]  <GADBannerView: 0x103a208e0; frame = (47 423; 320 50); clipsToBounds = YES; layer = <CALayer: 0x281fddbc0>>
2020-03-06 17:59:56.798876+0900 AdMob-Passback-Banner[12970:1240861] errorCode:  1
2020-03-06 17:59:56.798901+0900 AdMob-Passback-Banner[12970:1240861] error ad unit id: ca-app-pub-3010029359415397/3199559314
2020-03-06 17:59:57.346559+0900 AdMob-Passback-Banner[12970:1240861] -[ViewController adViewDidReceiveAd:]  <GADBannerView: 0x103806260; frame = (47 423; 320 50); clipsToBounds = YES; layer = <CALayer: 0x281ff57c0>>
2020-03-06 17:59:57.346586+0900 AdMob-Passback-Banner[12970:1240861] receive ad unit id: ca-app-pub-3940256099942544/2934735716
2020-03-06 18:00:27.761382+0900 AdMob-Passback-Banner[12970:1240861] -[ViewController adView:didFailToReceiveAdWithError:]  <GADBannerView: 0x103809d70; frame = (47 423; 320 50); clipsToBounds = YES; layer = <CALayer: 0x281ff4a40>>
2020-03-06 18:00:27.761525+0900 AdMob-Passback-Banner[12970:1240861] errorCode:  1
2020-03-06 18:00:27.761581+0900 AdMob-Passback-Banner[12970:1240861] error ad unit id: ca-app-pub-3010029359415397/3199559314
2020-03-06 18:00:28.377763+0900 AdMob-Passback-Banner[12970:1240861] -[ViewController adViewDidReceiveAd:]  <GADBannerView: 0x103707bc0; frame = (47 423; 320 50); clipsToBounds = YES; layer = <CALayer: 0x281ffa880>>
2020-03-06 18:00:28.377791+0900 AdMob-Passback-Banner[12970:1240861] receive ad unit id: ca-app-pub-3940256099942544/2934735716
```

上記のように30秒ごとに`ca-app-pub-3010029359415397/3199559314`からリクエストが送られているように動作します。
