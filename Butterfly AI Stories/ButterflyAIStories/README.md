# Butterfly AI Stories (iOS)

Swift/SwiftUI app merged from your original project and the workspace structure. Uses your AWS Lambdas and matches the App Store design (Create + Saved tabs, onboarding, points, store).

## Requirements

- Xcode 15+
- iOS 16+
- **Info.plist** already contains your API URLs (device + story), RevenueCat key, and GAD identifier.

## Setup in Xcode

1. **Create a new iOS App**
   - File → New → Project → App
   - Product Name: **Butterfly AI Stories**
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Minimum Deployment: **iOS 16.0**

2. **Add the source files**
   - Delete the default `ContentView.swift` and `*App.swift` if Xcode created them.
   - Drag the **ButterflyAIStories** folder (with Models, Services, Views, Assets.xcassets, Info.plist) into the Xcode project. Ensure the app target is checked. Use “Copy items if needed” if you’re adding from outside the project.

3. **Info.plist**
   - Either set the project’s Info.plist to use `ButterflyAIStories/Info.plist`, or copy the keys from it into your target’s Info:
     - `API_BASE_URL_DEVICE_DEV`, `API_BASE_URL_DEVICE_PROD`
     - `API_BASE_URL_STORY_DEV`, `API_BASE_URL_STORY_PROD`
     - `NSPhotoLibraryUsageDescription`, `NSCameraUsageDescription`
     - `RevenueCatAPIKey`, `GADApplicationIdentifier`, `ITSAppUsesNonExemptEncryption`, `SKAdNetworkItems`, `NSAppTransportSecurity`

4. **Optional: RevenueCat (in-app purchases)**
   - Add the [RevenueCat](https://github.com/RevenueCat/purchases-ios) SDK via SPM or CocoaPods.
   - Without it, the app builds and runs; the Get Points / Store screen will show “No packages available.”

5. **Optional: Google Mobile Ads**
   - Your original project used AdMob. To re-enable, add the Google Mobile Ads SDK and init `GADMobileAds` in the app entry if desired.

6. **Build and run**
   - Select a simulator or device and run (⌘R).

## App flow

- **Launch:** Registers the device with `deviceRegistration` (AuthStore), stores API key in Keychain.
- **Create tab:** Points (PointManager), photo (camera or library), story type picker, Change Photo / Generate Story. Calls `generateStory` with resized image (224×224) as base64 data URL.
- **Story detail:** Back + heart to save/remove from favorites (StorageManager). Saved stories are stored on disk.
- **Saved tab:** List of saved stories (StorageManager); tap to open StoryDetailView; swipe to delete.
- **Get Points:** Opens StoreView (RevenueCat). Points start at 2,000; each story deducts by token usage.
- **Onboarding:** Shown until “Get Started” sets `hasCompletedOnboarding`.

## Project structure

- **ButterflyAIStoriesApp.swift** — App entry, TabView (Create, Saved), AuthStore, device registration on launch.
- **Models/** — `StoryType`, `Story` (saved stories, Codable).
- **Services/** — `Configuration` (dev/prod URLs), `APIConfig`, `APIService`, `APIError`, `KeychainService`, `AuthStore`, `StorageManager`, `PointManager`, `StoreManager`, `ImageResizer`.
- **Views/** — `ContentView`, `StoryDetailView`, `SavedStoriesView`, `StoreView`, `OnboardingView`, `ImagePicker`.

API base URLs are read from Info.plist via `Configuration`; no code changes needed if you only update the plist.
