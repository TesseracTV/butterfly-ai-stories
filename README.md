# Butterfly AI Stories

iOS app that turns photos into AI-generated stories, plus AWS Lambda backend.

## Contents

- **Butterfly AI Stories/** — Xcode project and Swift/SwiftUI app (iOS 16+)
- **functions/** — AWS Lambda (Node.js): device registration, story generation
- **APP_SPEC.md** — App and API spec

## Quick start

1. Open `Butterfly AI Stories/Butterfly AI Stories.xcodeproj` in Xcode.
2. Build and run on a simulator or device. API URLs are in `ButterflyAIStories/Info.plist`.
3. Deploy the Lambdas in `functions/` to API Gateway (see `functions/README.md`).

## Requirements

- Xcode 15+, iOS 16+
- Node 18+ for Lambda (deploy to AWS)
