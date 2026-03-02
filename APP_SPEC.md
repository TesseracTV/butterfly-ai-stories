# Butterfly AI Stories — App spec (from UI + backend)

Summary of how the app should look and work, based on your screenshots and AWS functions.

---

## Branding & copy

- **App name:** Butterfly AI Stories  
- **Tagline:** “The AI driven story teller. Transform Your Photos into Magical Stories with Butterfly Stories.”  
- **Quick Stories (result screen):** “Spend sometime with a good short story that you create with just a photo. Hit the heart on the top right to save to your favorites!”

---

## Screen 1: Main / generator

**Header**

- Title: **Butterfly AI Stories**
- **Points:** “1,150 points” with star icon
- Green pill button: **Get Points** (play icon)

**Content**

- **Photo area:** Large rectangle showing the selected image (camera or library).
- **Story type:** Teal dropdown with book icon.  
  Closed state: shows current type (e.g. “Children’s Story”) and chevron.  
  Open state options:
  - Children’s Story (default)
  - Adventure Tale
  - Fantasy Story
  - Poetry
  - Descriptive Story
- **Buttons:**
  - **Change Photo** — gallery/landscape icon (pick new image).
  - **Generate Story** — magic wand icon (primary action).

**Backend**

- **generateStory** is called with:
  - `image`: URL (or data URL) of the photo in the photo area.
  - `prompt`: Built from the selected story type (e.g. “Write a short children’s story about this image” for “Children’s Story”).
  - `device_id`: Stored device id.
  - Header `x-api-key`: From **deviceRegistration** (stored after first launch).

---

## Screen 2: Story result (Quick Stories)

**Header**

- **&lt; Back** (top left) — return to main/generator.
- **Heart icon** (top right, red) — “Save to your favorites.”

**Content**

- Same **photo** used for generation, full width.
- **Story:**
  - Bold **title** (e.g. “The Magical Heirloom Boat”).
  - Body text in one or more paragraphs (white on dark in your design).

**Backend**

- Story text and title come from **generateStory** response: `story` (you can parse title vs body in the app or ask the API to return structured JSON).
- **Favorites:** Not covered by the three Lambdas you shared; either local-only (e.g. UserDefaults/Keychain) or a separate “save favorite” API.

**Footer (dev)**

- Bottom bar can show “Test mode” in development.

---

## Flow

1. **First launch:** Call **deviceRegistration** with `device_id`, store returned `api_key` (e.g. Keychain). Use that for all later `x-api-key` headers.
2. **Main screen:** User selects photo and story type → taps **Generate Story** → call **generateStory** with image URL, prompt from story type, `device_id`, `x-api-key`.
3. **Result screen:** Show photo + story; **Back** to main; **Heart** to save to favorites (local or future API).
4. **Points:** “1,150 points” and **Get Points** imply a credits/usage system. **generateStory** returns `tokens_used`; points could be driven by that or by a separate usage/credits backend (no Lambda for that was provided).

---

## Story type → prompt (suggested)

Map each dropdown option to a prompt you send to **generateStory**:

| Story type       | Example prompt |
|------------------|----------------|
| Children’s Story | “Write a short, friendly children’s story based on this image. Include a title.” |
| Adventure Tale   | “Write a short adventure story inspired by this image. Include a title.” |
| Fantasy Story    | “Write a short fantasy story based on this image. Include a title.” |
| Poetry           | “Write a short poem inspired by this image. Give it a title.” |
| Descriptive Story | “Write a short descriptive narrative about this image. Include a title.” |

You can tune these; the backend only sees the final `prompt` string.

---

## What the three functions cover

| Feature           | In your Lambdas? | Notes |
|------------------|-------------------|--------|
| Device registration | ✅ deviceRegistration | Get and store `api_key` for `device_id`. |
| Generate story      | ✅ generateStory     | Image + prompt + auth → story (+ tokens_used). |
| Favorites           | ❌                   | Heart = save; needs app-side storage or new API. |
| Points / Get Points | ❌                   | UI only; could use `tokens_used` or a separate credits API. |
| getApiKey           | ⚠️                   | Returns secret to client; prefer not using for OpenAI key. |

---

## Assets

Your three screenshots are saved in the project for reference (story result, main screen, story-type picker). Use them when rebuilding the UI so layout, copy, and flows match.

---

Use this spec when rebuilding the app or adding new backend features so the UI and APIs stay aligned.
