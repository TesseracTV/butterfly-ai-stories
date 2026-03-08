# Build and Submit Butterfly AI Stories to the App Store

Follow these steps in **Xcode** on your Mac.

---

## 1. Open the project

- Open **Butterfly AI Stories.xcodeproj** in Xcode (from the `Butterfly AI Stories` folder).

## 2. Set the version and build (optional but recommended)

- Select the **Butterfly AI Stories** target in the project navigator.
- Open the **General** tab.
- **Version**: e.g. `2.1.6` (bump from whatever is currently in App Store Connect).
- **Build**: e.g. `1` or increment the last build number (must be higher than the last uploaded build for this version).

## 3. Choose a real device and sign the app

- At the top of Xcode, set the run destination to **Any iOS Device (arm64)** or a connected iPhone/iPad (not a simulator).
- Go to **Signing & Capabilities** for the Butterfly AI Stories target.
- Check **Automatically manage signing**.
- Select your **Team** (your Apple Developer account). If you don’t see it, add your Apple ID under Xcode → Settings → Accounts.

## 4. Create an archive

- Menu: **Product → Archive**.
- Wait for the build to finish. If it fails, fix the errors shown in the Issue navigator.
- When done, the **Organizer** window opens with your new archive selected.

## 5. Distribute to App Store Connect

- In Organizer, select the new archive and click **Distribute App**.
- Choose **App Store Connect** → **Next**.
- Choose **Upload** → **Next**.
- Leave options as default (e.g. upload symbols, manage version/build) → **Next**.
- Pick your **distribution certificate** and **provisioning profile** (or let Xcode manage them) → **Next**.
- Review the summary → **Upload**.
- Wait for the upload to complete.

## 6. Submit for review in App Store Connect

- Go to [App Store Connect](https://appstoreconnect.apple.com) and sign in.
- Open **My Apps** → **Butterfly AI Stories**.
- The new build should appear under the version you selected (or create a new version and select the new build).
- Fill in **What’s New in This Version** (e.g. “Bug fixes and improvements” or your release notes).
- Complete any required fields (screenshots, description, keywords, etc.) if they’re not already set.
- Click **Add for Review** / **Submit for Review**.

---

## Troubleshooting

| Issue | What to do |
|-------|------------|
| **Signing errors** | In Signing & Capabilities, ensure your Team is selected and “Automatically manage signing” is on. Fix any red errors about provisioning. |
| **Archive is disabled** | Set the run destination to a real device (or “Any iOS Device”), not a simulator. |
| **Build fails** | Read the error in the Issue navigator (⌘5). Common: missing file references, Swift errors, or package resolve (File → Packages → Resolve Package Versions). |
| **Upload fails** | Check your Apple ID and that the app’s bundle ID in Xcode matches the app in App Store Connect. Ensure you have the “App Manager” or “Admin” role. |

---

## Quick checklist before you submit

- [ ] Version and build numbers set and higher than previous upload
- [ ] Signed with your Apple Developer team
- [ ] Archive built with **Product → Archive**
- [ ] App Store Connect listing has correct build selected and all required metadata/screenshots
