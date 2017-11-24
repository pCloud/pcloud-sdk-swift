# pCloud Swift SDK

The official pCloud Swift SDK for iOS and macOS for integration with the [pCloud API](https://docs.pcloud.com/).
You can find the full documentation [here](https://pcloud.github.io/pcloud-sdk-swift).

---

## Table of Contents
* [System requirements](#system-requirements)
* [Get started](#get-started)
  * [Register your application](#register-your-application)
  * [Set up your application](#set-up-your-application)
* [Install the SDK](#install-the-sdk)
  * [CocoaPods](#cocoapods)
    * [Carthage](#carthage)
* [Initializing the SDK](#initializing-the-sdk) 
    * [Using the authorization flow](#using-the-authorization-flow) 
    * [Manually creating a client](#manually-creating-a-client)
* [Making API requests](#making-api-requests)
    * [Working with the network tasks](#working-with-the-network-tasks)
    * [Handling API errors](#handling-api-errors)
* [Examples](#examples)
* [Documentation](#documentation)

---

## System requirements

- iOS 9.0+
- macOS 10.11+
- Xcode 9.0+

---

## Get started

### Register your application

In order to use this SDK, you have to register your application in the [pCloud App Console](https://docs.pcloud.com/my_apps/). Take note of the app key in the main page of your application once you create it.

### Set up your application

The SDK uses an OAuth 2.0 access token to authorize requests to the pCloud API. You can obtain a token using the SDK's authorization flow. To allow the SDK to do that, find the 'Redirect URIs' section in your application configuration page and add a URI with the following format: `pclsdk-w-<YOUR_APP_KEY>://oauth2redirect`.

---

## Install the SDK

You can integrate the SDK into your project using any of the following methods:

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Swift and Objective-C Cocoa projects. If you do not already use CocoaPods, you can check out how to get started with it [here](http://guides.cocoapods.org/using/getting-started.html).

First you should install CocoaPods:

```bash
$ gem install cocoapods
```

Then navigate to your project root and run `pod init`. This will create a file called `Podfile`. Open it and add `pod 'PCloudSDKSwift'` to your target. Make sure it also contains `use_frameworks!`. Your Podfile should look something like this.

```ruby
use_frameworks!

target '<YOUR_TARGET_NAME>' do
    pod 'PCloudSDKSwift'
end
```

Then run the following command to install the SDK and integrate it into your project:

```bash
pod install
```

Once the SDK is integrated into your project, you can pull SDK updates using the following command:

```bash
pod update
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a simple, decentralized dependency manager for Cocoa. If you don't already use Carthage, you can check out how you can install it [here](https://github.com/Carthage/Carthage#installing-carthage).

To install the pCloud Swift SDK via Carthage, you need to create a `Cartfile` in your project (This file lists the frameworks you’d like to use in your project.) with the following contents:

```
github "https://github.com/pcloud/pcloud-sdk-swift"
```

Then, run the following command (This will fetch dependencies into a `Carthage/Checkouts` folder and build each one):


##### iOS

```bash
carthage update --platform iOS
```

In the Project Navigator in Xcode, select your project, then select your target, then navigate to **General** > **Linked Frameworks and Libraries**, and drag and drop `PCloudSDKSwift.framework` from `Carthage/Build/iOS`.

Then, on your application targets’ **Build Phases** settings tab, click the **+** button and choose **New Run Script Phase**. In the newly-created **Run Script** section, add the following code to the script body area:

```bash
/usr/local/bin/carthage copy-frameworks
```

Then navigate to the **Input Files** section and add the path to the framework:

```bash
$(SRCROOT)/Carthage/Build/iOS/PCloudSDKSwift.framework
```


##### macOS

```bash
carthage update --platform Mac
```

In the Project Navigator in Xcode, select your project, and then navigate to **General** > **Linked Frameworks and Libraries**, then drag and drop `PCloudSDKSwift.framework` from `Carthage/Build/Mac`.

Then, on your application target’s **Build Phases** settings tab, click the **+** icon and choose **New Copy Files Phase**. In the newly-created **Copy Files** section, click the **Destination** drop-down menu and select **Products Director**, then drag and drop `PCloudSDKSwift.framework.dSYM` from `Carthage/Build/Mac`.


---

## Initializing the SDK

Once integrated into your project, the SDK needs an access token in order to make API calls.

### Using the authorization flow

The SDK has a pre-defined flow for obtaining an access token. It opens a web view inside your app and loads the pCloud authorization page where the user can login and authorize your app. To use the authorization flow:

#### Initialize the `PCloud` instance

In the app delegate:

##### iOS

```swift
import PCloudSDKSwift

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    PCloud.setup(appKey: "<YOUR_APP_KEY>")
}
```

##### macOS

```swift
import PCloudSDKSwift

func applicationDidFinishLaunching(_ notification: Notification) {
    PCloud.setup(appKey: "<YOUR_APP_KEY>")
}
```

---

#### Perform the authorization flow

To start the authorization flow, call `PCloud.authorize(controller:_:)` and provide a view controller and a block to be invoked once authorization completes or is cancelled by the user. The view controller is automatically dismissed before the completion block is called.

From your view controller:

##### iOS

```swift
import PCloudSDKSwift

// Inside a UIViewController subclass.

func loginButtonTapped(sender: UIButton) {
    PCloud.authorize(controller: self) { result in
        if case .success(_) = result {
            // You can make calls via the SDK.   
        }
    }
}
```

This will present a view controller with a web view from `self`.

##### macOS

```swift
import PCloudSDKSwift

// Inside an NSViewController subclass.

func loginButtonTapped(sender: NSButton) {
    PCloud.authorize(controller: self) { result in
        if case .success(_) = result {
            // You can make calls via the SDK.   
        }
    }
}
```

This will present a view controller with a web view from `self` as a sheet.

---

Once `PCloud.authorize(controller:_:)` finishes successfully, you can start making API calls via a global `PCloudClient` instance accessible via `PCloud.sharedClient`. Furthermore, your access token is stored in the device's keychain, so the next time your app is launched, the shared client instance will be initialized inside the `PCloud.setup(appKey:)` call.

### Manually creating a client

This is a more flexible approach to using the SDK. However, it requires you to do a bit more work. **Using this approach also delegates management of the access token to you**.
You can manually create a `PCloudClient` instance with an access token. Manually managing the lifetime of this instance might be a lot more convenient for you in certain cases. To request an access token without automatically initializing the shared client instance:

```swift
OAuth.performAuthorizationFlow(view: view,
                               appKey: "<YOUR_APP_KEY>",
                               storeToken: { accessToken, userId in 
                                   // Store the token in a persistent storage. Or not.
                               },
                               completionBlock: { result in
                                   if case .success(let token, _) = result {
                                       let client = PCloud.createClient(accessToken: token)
                                       // Use the client.
                                   }
                               })
```

where `view` would be an instance of `WebViewControllerPresenterMobile` on iOS or `WebViewControllerPresenterDesktop` on macOS. 

---

## Making API requests

Once you have an authorized client, you can try some API requests using the SDK. To begin, create a reference to your `PCloudClient` instance:

```swift
let client = PCloud.sharedClient // When using the authorization flow
```

### Working with the network tasks

The SDK comes with the most common API requests predefined and has exposed them through the `PCloudClient` instance as methods. Each method returns a non-running task object representing the API request. Once you have obtained a task, you can assign callback blocks to it and start it. Once a task completes it produces a result object defined like this:

```swift
enum Result<T> {
  case success(T)
  case failure(Error)
}
```

There are three types of tasks:

##### CallTask
Performs an RPC request. On success produces the pre-parsed response of the request. On failure, either an API error or an `NSError` object from the underlying `NSURLSessionTask`.

```swift
import PCloudSDKSwift

client.createFolder(named: "Movies", inFolder: Folder.root)
    .setCompletionBlock { result in
        // Handle result
    }
    .start()
```

##### UploadTask
Performs an upload. On success produces the metadata of the uploaded file. On failure, either an API error or an `NSError` object from the underlying `NSURLSessionTask`.

```swift
import PCloudSDKSwift

client.upload(fromFileAt: "file:///path/to/file", toFolder: Folder.root, asFileNamed: "song.mp3")
    .setProgressBlock { uploaded, total in
        // Handle progress
    }
    .setCompletionBlock { result in
        // Handle result
    }
    .start()
```

##### DownloadTask
Downloads a file. On success, produces the URL of the downloaded file. On failure, produces an `NSError` either from the underlying `NSURLSessionTask`, or a file system related error from the `NSFileManager`.

```swift
import PCloudSDKSwift

client.downloadFile(aFileId, to: { destinationUrl })
    .setProgressBlock { downloaded, total in
        // Handle progress
    }
    .setCompletionBlock { result in
        // Handle result
    }
    .start()
```

Once started, a task can stop if it succeeds, fails or if it is cancelled. Since tasks are not reusable, once a task stops running in any way, it can no longer be started again.
The completion block of a task will only be called if a task fails or succeeds, **not** when it is cancelled. Also, all of a task's callback blocks are called on the main queue.
A task will be retained in memory **while it is running**, so there is no need to manually keep a reference to it, given that you start the task at the time of creation.

### Handling API errors

Each API method in the SDK is defined in the `PCloudApi` namespace as a separate struct. And each method defines its errors within its own namespace. Apart from its own errors a method can fail with a common API error defined in `PCloudApi.Error`, or a `PCloudApi.RawError` for any other undefined (within the SDK) error.

---

## Examples

An example app can be found in the [Example_iOS](https://github.com/pcloud/pcloud-sdk-swift/tree/master/Example_iOS) folder. The example app demonstrates how to authenticate a user and how to list a user`s files and folders.

---

## Documentation

* [pCloud Swift SDK](https://pcloud.github.io/pcloud-sdk-swift)
* [pCloud API](https://docs.pcloud.com/)
