# pCloud Swift SDK

The official pCloud Swift SDK for iOS and macOS for integration with the [pCloud API](https://docs.pcloud.com/).
You can find the full documentation [here](https://pcloud.github.io/pcloud-sdk-swift).

---

## Table of Contents
* [Migration to v3](#migration-to-v3)
* [System requirements](#system-requirements)
* [Get started](#get-started)
  * [Register your application](#register-your-application)
  * [Set up your application](#set-up-your-application)
* [Install the SDK](#install-the-sdk)
  * [CocoaPods](#cocoapods)
  * [Carthage](#carthage)
  * [Swift Package Manager](#swift-package-manager)
* [Initializing the SDK](#initializing-the-sdk) 
  * [Using the authorization flow](#using-the-authorization-flow) 
  * [Manually creating a client](#manually-creating-a-client)
* [Making API requests](#making-api-requests)
  * [Working with the network tasks](#working-with-the-network-tasks)
  * [Handling API errors](#handling-api-errors)
* [Examples](#examples)
* [Documentation](#documentation)

---

## Migration to v3

For instructions on how to migrate to v3 of the SDK, please refer to the release notes of v3.0.0 in the source repository.

---

## System requirements

- iOS 9.0+
- macOS 10.11+
- Xcode 10.2+

---

## Get started

### Register your application

In order to use this SDK, you have to register your application in the [pCloud App Console](https://docs.pcloud.com/my_apps/). Take note of the app key in the main page of your application once you create it.

### Set up your application

The SDK uses an OAuth 2.0 access token to authorize requests to the pCloud API. You can obtain a token using the SDK's authorization flow. To allow the SDK to do that, find the 'Redirect URIs' section in your application configuration page and add a URI with the following format: `pclsdk-w-YOUR_APP_KEY://oauth2redirect` where `YOUR_APP_KEY` is the app key from your app console.

---

## Install the SDK

You can integrate the SDK into your project using any of the following methods:

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Swift and Objective-C Cocoa projects. If you do not already use CocoaPods, you can check out how to get started with it [here](http://guides.cocoapods.org/using/getting-started.html).

First you should install CocoaPods:

```bash
$ gem install cocoapods
```

Then navigate to your project root and run `pod init`. This will create a file called `Podfile`. Open it and add `pod 'PCloudSDKSwift'` to your target. Your Podfile should look something like this.

```ruby
use_frameworks!

target 'YOUR_TARGET_NAME' do
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



### Swift Package Manager

The pCloud SDK can be integrated into your project using the [Swift Package Manager](https://swift.org/package-manager/). **Currently, SPM support has only been added for the iOS platform**. To integrate the SDK into your project, you need to specify the repository's URL:

```bash
https://github.com/pCloud/pcloud-sdk-swift
```

For more information, please refer to [the official documentation](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

---

## Initializing the SDK

Once integrated into your project, the SDK needs to authenticate a user in order to make API calls.

### Using the authorization flow

The SDK has a pre-defined flow for obtaining a user. It attempts to authenticate the user via a `ASWebAuthenticationSession` if the current OS version allows it. Otherwise it opens a web view inside your app and loads the pCloud authorization page where the user can log in and authorize your app. To use the authorization flow:

#### Initialize the `PCloud` instance

In the app delegate:

##### iOS

```swift
import PCloudSDKSwift

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    PCloud.setUp(withAppKey: "YOUR_APP_KEY")
}
```

##### macOS

```swift
import PCloudSDKSwift

func applicationDidFinishLaunching(_ notification: Notification) {
    PCloud.setUp(withAppKey: "YOUR_APP_KEY")
}
```

---

#### Perform the authorization flow

To start the authorization flow, call `PCloud.authorize(with:_:)` and provide a view controller and a block to be invoked once authorization completes or is cancelled by the user. The view controller is automatically dismissed before the completion block is called.

From your view controller:

##### iOS

```swift
import PCloudSDKSwift

// Inside a UIViewController subclass.

func logInButtonTapped(_ sender: UIButton) {
    PCloud.authorize(with: self) { result in
        if case .success(_) = result {
            // You can make calls via the SDK.   
        }
    }
}
```

This will either attempt to authenticate using `ASWebAuthenticationSession` or will present a view controller with a web view from the view controller passed to the method.

##### macOS

```swift
import PCloudSDKSwift

// Inside an NSViewController subclass.

func logInButtonTapped(_ sender: NSButton) {
    PCloud.authorize(with: self) { result in
        if case .success(_) = result {
            // You can make calls via the SDK.   
        }
    }
}
```

This will either attempt to authenticate using `ASWebAuthenticationSession` or will present a view controller with a web view as a sheet from the view controller passed to the method.

---

Once `PCloud.authorize(with:_:)` finishes successfully, you can start making API calls via a global `PCloudClient` instance accessible via `PCloud.sharedClient`. Furthermore, your access token is stored in the device's keychain, so the next time your app is launched, the shared client instance will be initialized inside the `PCloud.setUp(withAppKey:)` call.

### Manually creating a client

This is a more flexible approach to using the SDK. However, it requires you to do a bit more work. **Using this approach also delegates management of the access token to you**.
You can manually create a `PCloudClient` instance with an access token. Manually managing the lifetime of this instance might be a lot more convenient for you in certain cases. To request an access token without automatically initializing the shared client instance:

```swift
OAuth.performAuthorizationFlow(with: anchor, appKey: "YOUR_APP_KEY") { result in
    if case .success(let user) = result {
        let client = PCloud.createClient(with: user)
        // Use the client.
    }
}
```

where `anchor` would be an instance of `UIWindow` on iOS or `NSWindow` on macOS. This method will attempt to authenticate via a `ASWebAuthenticationSession`, which is the recommended way of authenticating. It requires, however, iOS 13 / macOS 10.15. Another option is to use:

```swift
OAuth.performAuthorizationFlow(with: view, appKey: "YOUR_APP_KEY") { result in
    if case .success(let user) = result {
        let client = PCloud.createClient(with: user)
        // Use the client.
    }
}
```

where `view` would be an instance of `WebViewControllerPresenterMobile` on iOS or `WebViewControllerPresenterDesktop` on macOS. 

---

## Making API requests

Once you have an authorized client, you can try some API requests using the SDK. To begin, create a reference to your `PCloudClient` instance:

```swift
let client = PCloud.sharedClient // When using the authorization flow
```

### Working with the network tasks

The SDK comes with the most common API requests predefined and has exposed them through the `PCloudClient` instance as methods. Each method returns a non-running task object representing the API request. Once you have obtained a task, you can assign callback blocks to it and start it. Once a task completes it produces a `Result` value.

There are three types of tasks:

##### CallTask
Performs an RPC request. On success produces the pre-parsed response of the request. On failure, produces a `CallError` value.

```swift
import PCloudSDKSwift

client.createFolder(named: "Movies", inFolder: Folder.root)
    .addCompletionBlock { result in
        // Handle result
    }
    .start()
```

##### UploadTask
Performs an upload. On success produces the metadata of the uploaded file. On failure, produces a `CallError` value.

```swift
import PCloudSDKSwift

client.upload(fromFileAt: "file:///path/to/file", toFolder: Folder.root, asFileNamed: "song.mp3")
    .addProgressBlock { uploaded, total in
        // Handle progress
    }
    .addCompletionBlock { result in
        // Handle result
    }
    .start()
```

##### DownloadTask
Downloads a file. On success, produces the URL of the downloaded file. On failure, produces a `NetworkOperationError` value.

```swift
import PCloudSDKSwift

let link: FileLink.Metadata

client.downloadFile(from: link.address, downloadTag: link.downloadTag, to: { path in
    // Move the file
})
.addCompletionBlock { result in
    // Handle completion
}
.addProgressBlock { written, total in
    // Handle progress
}
.start()

```

Once started, a task can stop if it succeeds, fails or if it is cancelled. Since tasks are not reusable, once a task stops running in any way, it can no longer be started again.
The completion block of a task will only be called if a task fails or succeeds, **not** when it is cancelled. Also, all of a task's callback blocks are called on the main queue.
A task will be retained in memory **while it is running**, so there is no need to manually keep a reference to it, given that you start the task at the time of creation.

### Handling API errors

Upload and RPC call tasks fail with a `CallError`. This enum combines the possible errors from the networking layer and the PCloud API layer. One of the possible errors is `CallError<T>.methodError(T)` and the suberror there will depend on the API method being executed by the task. All API methods are defined in `PCloudAPI.swift` and each one has an `Error` enum defined in its namespace. So, for example, if you are executing a `ListFolder` API method, the task error would be defined as `CallError<ListFolder.Error>`. Some API methods (e.g. `UserInfo`) cannot fail with anything else than generic API errors so they will define their error as `NullError`. Such tasks can never fail with `CallError<T>.methodError(T)`.

---

## Examples

An example app can be found in the [Example_iOS](https://github.com/pcloud/pcloud-sdk-swift/tree/master/Example_iOS) folder. The example app demonstrates how to authenticate a user and how to list a user's files and folders.

---

## Documentation

* [pCloud Swift SDK](https://pcloud.github.io/pcloud-sdk-swift)
* [pCloud API](https://docs.pcloud.com/)
