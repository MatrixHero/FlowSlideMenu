# FlowSlideMenu-SWIFT

[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
)](https://developer.apple.com/swift)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
)](http://mit-license.org)

# A FlowSlideMenu like this

![Showcase](effect.gif)

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
