# FlowSlideMenu-SWIFT

[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
)](https://developer.apple.com/swift)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
)](http://mit-license.org)

# A FlowSlideMenu like this

![Showcase](effect.gif)
####Hits
`0.1.7` is more smoothly for touch

####CocoaPods
```
pod 'FlowSlideMenu'
```

##Usage

###Setup

Add `import FlowSlideMenu` in your file

In your app delegate:

```swift

func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    // create viewController code...
        
    let slideMenu = LLFlowSlideMenuVC(mainViewController: mainvc, leftViewController: leftvc)
    self.window?.rootViewController = slideMenu
    self.window?.makeKeyAndVisible()    

    return true
}
```
## Inspired

[SlideMenuControllerSwift](https://github.com/dekatotoro/SlideMenuControllerSwift) 

## License

FlowSlideMenu is available under the MIT license. See the LICENSE file for more info.

## Requirement

iOS9

## Todo

* Support to iOS7

* Make code more better
 
* Support to 4 orientation

* Make doc 


## Hope

Guys,U can give me a star or submiting a issue for me~ I'will fix it soonly.  

