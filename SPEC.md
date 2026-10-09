# Perchseal — Build Specification

> Portfolio app 168, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Scan wing bands at lockup, note missing birds with a photo, and seal tonight's headcount against your roster.

| Field | Value |
| --- | --- |
| Product name | Perchseal |
| Bundle identifier | `com.perchseal.lockup` |
| Domain | https://perchseal-lockup.pro |
| Contact URL | https://perchseal-lockup.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Dark |
| Asset prefix | `psl_` |
| User-Agent | `Perchseal/1.0 (iOS; +https://perchseal-lockup.pro)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Perchseal -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A backyard keeper scans each banded bird at lockup and seals tonight's roll so the active headcount always matches the roster, with a photo when someone is missing.

### 2.1 User flow

1. Scan the last unmarked bird's wing-band QR on the perch strip to write Present.
2. When the strip shows one roster shortfall, tap Gap and snap the empty perch in the preview shutter to file GapMark.
3. Tap Seal on the strip when Present plus Gap equals the active roster count.
4. Open the Roster sheet to band a new bird or retire a cull.
5. Open Analytics to read seven-day gap rate and headcount drift against roster.
6. Export roll CSV from Settings.

### 2.2 Essential behaviour

- Active roster with band codes and retire dates
- Evening perch strip with live run preview header
- Band QR scan resolves to bird and writes Present
- Gap snap attaches a local photo and note before Seal
- Roll history by daykey with Present, Gap, and Manual marks
- Headcount drift and gap-rate analytics
- CSV export of sealed rolls
- Local-only storage, no marketplace or cloud sync

---

## 3. Uniqueness assignment for Perchseal

| Axis | Assigned value |
| --- | --- |
| Architecture | **Band-scan roll ADT fold (Open | Tallying | Sealed); the roll is a fold over Birds for the daykey; Scan of a known Band writes Present and folds Open to Tallying; Tap Present without Scan writes ManualMark then Present when that Bird has no ManualMark in the rolling seven-day window; Gap opens while Present plus Gap is below active roster; Snap writes GapMark with local photo; Seal writes RollMark when counts match roster; Seal with unfilled Gap writes HollowMark; Peel drops the last Present, Gap, or ManualMark; Scan of unknown payload writes StrayMark; empty roster writes Bare** |
| UI approach | **SwiftUI AVFoundation preview layer representable · material** |
| Naming convention | **Wingband / coop-census lexicon (Bird, Band, Present, GapMark, RollMark, Roster, Snap, ManualMark, StrayMark, HollowMark)** |
| File organization | **By roll role (Bird, Band, Present, GapMark, RollMark, Roster, Snap, ManualMark) · 440acc6b60** |
| Dependency strategy | **None (zero external dependencies) · no SPM entry, no CocoaPods, no vendored source; UIKit, Core Graphics, AVFoundation and URLSession only** |
| Design direction | **spotify · tray-plus-canvas · branded** |
| Typography | **Bodoni 72** |
| Navigation pattern | **Run-locked chrome (the preview header and perch strip never leave; Roster and Analytics arrive as sheets; scan, present, gap snap, and seal fuse on the strip; Settings from the gear; no tab bar)** |
| AI art style | **Comic halftone pop art · photography-driven** |
| Functional twist | **Present-then-gap (scan band writes Present; roster shortfall requires Snap before Seal; ManualMark caps at once per bird per week; Peel reopens the roll)** |
| Persistence | **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — flock_ledger

**Core** — A backyard keeper scans each banded bird at lockup and seals tonight's roll so the active headcount always matches the roster, with a photo when someone is missing.

**Audience** — Small keepers who lose track of headcount after free-ranging, not a farm ERP.

**User flow**

1. Scan the last unmarked bird's wing-band QR on the perch strip to write Present.
2. When the strip shows one roster shortfall, tap Gap and snap the empty perch in the preview shutter to file GapMark.
3. Tap Seal on the strip when Present plus Gap equals the active roster count.
4. Open the Roster sheet to band a new bird or retire a cull.
5. Open Analytics to read seven-day gap rate and headcount drift against roster.
6. Export roll CSV from Settings.

**Essential features**

- Active roster with band codes and retire dates
- Evening perch strip with live run preview header
- Band QR scan resolves to bird and writes Present
- Gap snap attaches a local photo and note before Seal
- Roll history by daykey with Present, Gap, and Manual marks
- Headcount drift and gap-rate analytics
- CSV export of sealed rolls
- Local-only storage, no marketplace or cloud sync

**Twist** — Present-then-gap. Home is the run preview and horizontal perch strip. Scan of a known Band writes Present on that Bird. Tap Present on a Bird without a scan writes ManualMark once per bird per week and still writes Present. When Present plus Gap is below active roster, Gap mode opens; Snap in the preview layer writes GapMark with a local photo; Gap without Snap writes HollowMark and refuses Seal. Seal writes RollMark when counts match roster; early Seal writes EarlyMark. Peel drops the last Present, Gap, or ManualMark. Scan of an unknown payload writes StrayMark and offers roster add. Seed already writes Present on all but one active bird so the opening gesture is Snap-the-gap or scan the last band then Seal. Home verb: scan-the-band — not credit-the-hen and not log-a-basket. No mash, FCR, or egg qty.

**Why this is not a repeat** — Clutchkeep's home verb credits eggs onto hens for yield, mash cost, and FCR. This product closes the day with a band-scan census and photo-backed gap marks when headcount falls short; it never logs grams, slots, or egg credits.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: KPI tiles + Production / Feed / Health pager.
- Invariant: costPerUnit = Σfeed.cost / Σqty. FCR = ΣfeedKg / Σqty. healthScore = clamp(100 − mortality×140 − min(20, notes)).
- Never: No Nest mini-game tab.
- Taste DNA is section 7.6. Do not invent a second look.
- A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.
- Mini-ref `HenTrack`: steal eggs/hen, 7-day predict, flock vs eggs empty states, CSV. Never Alamofire WebContentView, OneSignal, AppsFlyer, ContactUsWebView. New types and layout — do not reskin.

### 3.1 Architecture contract

The roll is a fold over Birds for a daykey, an ADT with states Bare, Open, Tallying, and Sealed. Scan of a known Band writes Present and folds Open to Tallying, and a Present tap with no scan writes ManualMark then Present only when that Bird has no ManualMark in the rolling seven daykeys. Gap stays available while Present plus Gap is below the active roster; Snap writes GapMark with a local photo, and Gap without Snap writes HollowMark. Seal writes RollMark when Present plus Gap equals the active roster and every Gap has a Snap; Seal before the counts match writes EarlyMark, and Seal with an unfilled Gap writes HollowMark and does not seal. Peel drops the last Present, Gap, or ManualMark and reopens a sealed roll; an unknown scan writes StrayMark and offers a roster add; an empty roster is Bare. Daykey is an Int YYYYMMDD taken from Calendar.current.startOfDay, and the family invariant is unit-tested as costPerUnit = feedCost / qty, FCR = feedKg / qty, and healthScore = clamp(100 - mortality * 140 - min(20, notes)), with both quotients nil when this census has no mash and no egg qty.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

The home canvas is one UIViewRepresentable hosting an AVCaptureVideoPreviewLayer, edge to edge, with the perch strip as a dense tray in a material bar along the bottom of that preview. SwiftUI owns every other control. The live verb wears accent through a ButtonStyle with default, pressed, disabled, and loading states, and Retire uses a destructive style. Strip chips, Snap, Present, and Seal are native buttons with contentShape and at least a 44 point hit, and icon-only controls carry VoiceOver labels. Perch chips stagger in at 40 to 60 milliseconds, capped at 360 milliseconds; Reduce Motion fades the group in at once. Colour, type, space, and the single 28 and 14 point radius pair each come from one accessor. The preview fills the safe area. A bare roster is a full-page empty state with the headline No flock yet, the line Add the birds first, and a full-width Band a bird control at the bottom.

### 3.3 Naming contract

Convention: Wingband / coop-census lexicon (Bird, Band, Present, GapMark, RollMark, Roster, Snap, ManualMark, StrayMark, HollowMark).

Examples to follow: `Bird`, `GapMark`, `RollMark`, `writePresent(band:)`

### 3.4 Dependency contract

Zero external dependencies. No Swift Package Manager entry, no CocoaPods, and no vendored source. The binary uses SwiftUI plus UIKit, Core Graphics, AVFoundation, and URLSession only. Band matching is local, so URLSession is unused and there is no remote catalog call. Gap photos are written with AVFoundation and FileManager.

### 3.5 Navigation contract

Chrome is run-locked. The preview header and the perch strip stay on Flock, and scan, Present, Gap snap, and Seal fuse on that strip. Roster, Analytics, and Settings cover Flock as sheets. The gear opens Settings. Launch arguments are read once from ProcessInfo after onboarding: today opens Flock, log opens Roster, and goals opens Analytics. A further settings key opens Settings. Onboarding uses a full-width Continue at the bottom.

### 3.6 Screen composition contract

Preview fused perch roll (Run holds the preview header and perch strip with fused scan, present, gap snap, and seal; Roster and Analytics arrive as sheets; Settings as sheet; no TabView)

Physical screens: Flock, Roster, Analytics, Settings. Flock is the run-locked home and holds the preview header and the perch strip, with scan, Present, Gap snap, and Seal fused on that strip. Roster bands a new bird or retires a cull. Analytics reads seven-day gap rate and headcount drift against the roster. Settings holds CSV export of sealed rolls, reset, onboarding replay, and the contact link. These four are destinations. Roster, Analytics, and Settings cover Flock as sheets. Onboarding is a full-page gate with Continue at the bottom, skipped on Simulator after the seed. Launch key today opens Flock, log opens Roster, and goals opens Analytics.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

---

## 4. Target file organization

Scheme: **By roll role (Bird, Band, Present, GapMark, RollMark, Roster, Snap, ManualMark) · 440acc6b60**

```
Perchseal/
  Bird/
  Bird.swift
Band/
  Band.swift
  StrayMark.swift
Present/
  Present.swift
  PresentTap.swift
GapMark/
  GapMark.swift
  GapPhoto.swift
RollMark/
  RollFold.swift
  RollMark.swift
  HollowMark.swift
  EarlyMark.swift
  Peel.swift
Roster/
  Roster.swift
  RosterView.swift
  PerchChart.swift
  SettingsView.swift
Snap/
  PreviewLayer.swift
  Snap.swift
  PerchStrip.swift
  FlockView.swift
ManualMark/
  ManualMark.swift
  ManualWindow.swift
RollMark/AnalyticsView.swift
DesignTokens.swift
ReviewLaunch.swift
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Flock
A first-class screen for **Flock**. Must render empty, populated and error states.

### 5.3 Analytics
A first-class screen for **Analytics**. Must render empty, populated and error states.

### 5.4 Settings
A first-class screen for **Settings**. Must render empty, populated and error states.

### 5.5 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.6 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **Flock** — named per this app's convention.
- **Production** — named per this app's convention.
- **Feed** — named per this app's convention.
- **HealthEvent** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **spotify · tray-plus-canvas · branded**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#000000` | Screen background |
| `surface` | `#1E1E1E` | Cards, rows, sheets |
| `ink` | `#FFFFFF` | Primary text and icons |
| `accent` | `#FFA42B` | Primary action, key figure, progress fill |
| `muted` | `#A5A5A5` | Secondary text, dividers, disabled |

The scaffold already wrote these exact values to `Perchseal/DesignTokens.swift`
(`DesignTokens.bg`, `.surface`, `.ink`, `.accent`, `.muted`, plus
`DesignTokens.fontFamily`). Reach every colour through `DesignTokens` — a
typed accessor on top of it is fine. Keep the file and its hex values; do not
move them into `Assets.xcassets` and never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **Bodoni 72**

Bodoni 72 is the display step only, the one serif, set with Font.custom and a ScaledMetric size so the headcount figure scales. Title, headline, body, caption, and micro stay the system UI face behind the same six-step accessor. No step exceeds 34pt, body sits on the 17pt step, and nothing uses a fixed size that ignores Dynamic Type. Roster counts, gap rate, and drift go through NumberFormatter with monospaced digits. At the largest accessibility size a long Bodoni line may fall back to New York so hairline serifs stay readable. Day edges pass through Calendar.current.startOfDay before they become a YYYYMMDD int.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **28pt** for cards, sheets and primary surfaces; **14pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **material** — SwiftUI `Material` (`.regularMaterial` / `.thinMaterial`), reused everywhere a surface sits above another.

Primary control: **soft card** — primary actions live inside a rounded card using the radius below, not a flat row with no fill.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

### 7.5 Custom rendering scope

This app's `ui` axis is **SwiftUI AVFoundation preview layer representable · material**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **SwiftUI AVFoundation preview layer representable · material** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

### 7.6 Taste DNA

Aesthetic: **dark** (Dark-tech: void surfaces, one glow or jewel, sparse chrome.)

Reference system: **spotify** — steal rhythm and restraint, not their colours or logos.

Mood: **Music streaming. Vibrant green on dark, bold type, album-art-driven.**.

Home rhythm (`tray-plus-canvas`, dense): Tray of materials, canvas of the work.

Dark-tech: void surfaces, one glow or jewel, sparse chrome. Layout `tray-plus-canvas`, density dense. Kit 28/14, material, soft card. Palette recipe `branded`. Grouped reveals step 40-60ms, cap 360ms total. Last item must not arrive late. Reduce Motion: the group appears at once. Reduce Motion: fade only. Do not invent a second radius or a second accent.

Type move: Serif display once; body stays the UI face. Reference type feel: dark.

Motion (`stagger`): Grouped reveals step 40-60ms, cap 360ms total. Last item must not arrive late. Reduce Motion: the group appears at once.

Voice (`warm`): Human and brief. Empty states invite. Errors stay calm and useful.

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- The app is portrait-only on iPhone. Lock it in the Info settings and do not
  write rotation-dependent layout.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Sibling cards, images and titles never overlap. Each cell owns its frame;
  `scaledToFill` is clipped to that cell. A chopped headline or two canvases
  in one slot is a defect, not a collage.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Pick one base spacing unit and use only multiples of it. No arbitrary values.

**Keyboard**

- The grams field uses `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with `NumberFormatter`, never string interpolation. Group
  separators and decimal separators must follow the locale.
- Energy is shown as a whole number of kcal. Macros are shown with at most one
  decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown macro values render as a dash or the word "unknown", never as 0.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- Animations are short (0.2 to 0.35 s) and use a single shared easing curve.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.


---

## 10. Persistence engineering

Chosen technology: **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark**

UserDefaults holds one Codable Chart root, PerchChart, under the single key psl.chart.v1. Birds are its islands, the Roster its books, each daykey roll a session, the perch tally the run, and Present, GapMark, ManualMark, RollMark, StrayMark, HollowMark, and EarlyMark its rhumbs. Each mark debounces a save of that one record. A GapMark stores a file name, and the JPEG lives in Application Support so the photo survives a force-quit. Daykey values are Ints in YYYYMMDD form from Calendar.current.startOfDay. Views use one store seam. resetAllData, reached from Settings, deletes the key and the photo folder. Simulator seed runs once behind psl.demo.v1, marks onboarding complete, and writes Present on every active Bird except one.

This app persists to **files on disk**. The following are mandatory.

- Write atomically. Either `Data.write(to:options: .atomic)` or write to a
  temporary file and `FileManager.replaceItemAt`. A non-atomic write that is
  interrupted leaves a truncated file and the app will not launch.
- Create the containing directory with
  `withIntermediateDirectories: true` before the first write.
- Every document carries a `schemaVersion` field from version 1, and the decoder
  switches on it.
- Decoding failure must be recoverable: keep the previous good file as a
  `.backup`, fall back to it, and if that also fails start from empty state and
  tell the user. Never crash on a corrupt file.
- All file IO happens off the main thread. The main thread never blocks on disk.
- Debounce writes during rapid edits, but force a flush when `scenePhase`
  becomes `.inactive` or `.background`, and after any destructive action.
- Exclude caches from backup with `URLResourceValues.isExcludedFromBackup` where
  appropriate; user data belongs in Application Support and should be backed up.
- Keep an explicit in-memory source of truth and treat the file as a projection
  of it, so a failed write never leaves the UI showing data that does not exist.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Perchseal/1.0 (iOS; +https://perchseal-lockup.pro)` on every request. Never reuse another app's string.
No required remote catalog. Network only if this product actually needs it.

---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- Portrait only, iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


### First minute on a clean install (Guideline 2.1)

A reviewer judges completeness (Guideline 2.1) in the first minute on a clean
install. The loop must finish there without knowing the app's rules. Long form:
`docs/REVIEW-LESSONS-2026-09-25.md`.

- The home verb writes a visible object on the first tap of a clean install:
  a row, a card, a mark on the dial. No second screen needed to see it.
- Never leave the home control disabled until an unexplained condition holds
  ("two links first", "long press first", "add a volume first"). Accept the
  first input with sane defaults and show the rule afterwards.
- The twist fires after a successful write, as a visible consequence (a highlight,
  a caption, a next step), never instead of the write.
- A refusal is allowed only after the first success, and it must name the next
  tap that works.
- Nothing in the first session waits for midnight, a second day, a second item or
  a streak. A screen that can only fill later shows its action, not a wait.
- Every empty state names one action, and that action completes on the spot.
- Next to home there is at least one more screen that works on a clean install.
- The subtitle and the first description line name an everyday action a stranger
  understands. Coined words may decorate labels; each primary button still says
  what it does.
- A failed network lookup falls back to local data or typed input with a message;
  the loop still finishes offline.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.lifestyle`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Dark
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.lifestyle
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Present-then-gap (scan band writes Present; roster shortfall requires Snap before Seal; ManualMark caps at once per bird per week; Peel reopens the roll)

Home is the live run preview and the horizontal perch strip, and the verb on that strip is scan the band. A known Band writes Present, a roster shortfall opens Gap, and Seal waits until Snap has filed a GapMark with a local photo. Gap without Snap writes HollowMark and blocks Seal, while an early Seal writes EarlyMark and leaves the roll unsealed. ManualMark is allowed once per Bird in a rolling seven daykey window and still writes Present. Peel drops the last Present, Gap, or ManualMark and reopens the roll. The versioned simulator seed writes Present on every active Bird except one, so the opening gesture is Snap or the last band scan, then Seal, and the book never stores mash, FCR inputs, or egg qty.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **Comic halftone pop art · photography-driven**


Base prompt, reused and extended for every asset:

```
Comic halftone pop art driven by photography. Ben-Day dots and a heavy printed contour sit on a real photographed subject. Subjects are solid and centered. Cutouts have transparent corners, a solid middle, and no square plate, hollow glass, or wire frame. Full-bleed pieces fill the canvas, with a quiet middle so type can sit on a plate. No lettering and no numerals in the artwork.
```

All 12 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `psl_` prefix.

### 13.1 App icon rules (strict)

The icon is rejected by App Store Connect if any of these are wrong:

- Exactly **1024 x 1024 px**.
- **No alpha channel.**
- sRGB colour profile, 8 bits per channel, PNG.
- **No text and no words** in the artwork.
- **No rounded corners and no built-in mask.**
- The subject stays inside the middle 80%.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `psl_AppIcon` | 1024x1024 | **NO** | App Store icon. NO alpha channel, NO transparency, NO text, NO rounded corners, NO drop shadow outside the canvas. |
| 2 | `psl_Splash` | 1290x2796 | fill | Launch background. The middle third must stay quiet so the wordmark reads on top. |
| 3 | `psl_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 4 | `psl_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 5 | `psl_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 6 | `psl_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 7 | `psl_EmptyList` | 1024x1024 | **required cutout** | Empty state: a secondary list has no rows. |
| 8 | `psl_CardBackdrop` | 1200x800 | fill | Backdrop art for a primary card. Low contrast so text stays readable. |
| 9 | `psl_ControlFace` | 512x512 | **required cutout** | Custom control artwork used for the primary interactive element. |
| 10 | `psl_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Present-then-gap (scan band writes Present; roster shortfall requires Snap before Seal; ManualMark caps at once per bird per week; Peel reopens the roll)' feature screen. |
| 11 | `psl_SuccessMark` | 512x512 | **required cutout** | Shown briefly when the primary action succeeds. |
| 12 | `psl_HeaderDecor` | 1200x600 | **required cutout** | Decorative header accent on the main screen. |

### Prompt per asset

**`psl_AppIcon`** — 1024x1024

```
A photographic close-up of a wing-band clasp on feathers, comic halftone, solid subject filling the square inside the middle area. No text, no numerals, no rounded mask, no alpha.
```

**`psl_Splash`** — 1290x2796

```
A vertical photographic perch at lockup, comic halftone, filling the frame, with a calm uncluttered center band and no lettering.
```

**`psl_Onboarding1`** — 1024x1536

```
A keeper's hands beside a perched bird at dusk, photographic comic halftone, solid subject centered, transparent corners.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`psl_Onboarding2`** — 1024x1536

```
A wing band held under a scan, mid gesture, photographic comic halftone, solid subject centered, transparent corners.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`psl_Onboarding3`** — 1024x1536

```
A full perch beside a sealed evening card, photographic comic halftone, solid subjects centered, transparent corners.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`psl_EmptyHome`** — 1024x1024

```
A solid wooden perch block with no bird, opaque subject, photographic comic halftone, transparent corners, calm and inviting.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`psl_EmptyList`** — 1024x1024

```
A closed folio waiting for a roll, solid covers, photographic comic halftone, transparent corners, not a hollow box.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`psl_CardBackdrop`** — 1200x800

```
An abstract photographic field of coop boards in comic halftone, filling the canvas, quiet in the center so type stays readable, no lettering.
```

**`psl_ControlFace`** — 512x512

```
The face of a solid metal seal stamp, photographic comic halftone, centered, not a ring and not an outline.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`psl_TwistHero`** — 1024x1024

```
One photographic still of a wing band and an empty perch together, comic halftone, solid subjects centered, transparent corners.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`psl_SuccessMark`** — 512x512

```
A solid filled seal of metal and wax, occupying the middle of the canvas, photographic comic halftone, not a thin outline and not a hollow ring.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`psl_HeaderDecor`** — 1200x600

```
A wide photographic ornament of perch wood in comic halftone, solid band centered, transparent corners, no lettering.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated SOLID opaque subject in the center, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail. A hollow glass box or wire frame with a transparent center is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`psl.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.
- A `TabView` with exactly three tabs. That is the factory stamp — two or
  four-to-five destinations, or a different chrome. ReviewScreen keys are
  not tabs.


---

## 17. Tests

Add a unit test target `PerchsealTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. `Perchseal/ReviewLaunch.swift` (scaffold, keep it) parses `ProcessInfo.processInfo.arguments`.
   Read `ReviewLaunch.screen` once after onboarding:
   `-ReviewScreen today|log|goals` switches the running app's live navigation. Extra cover slugs open those screens.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Perchseal -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.

**Uniqueness**
- [ ] Architecture matches **Band-scan roll ADT fold (Open | Tallying | Sealed); the roll is a fold over Birds for the daykey; Scan of a known Band writes Present and folds Open to Tallying; Tap Present without Scan writes ManualMark then Present when that Bird has no ManualMark in the rolling seven-day window; Gap opens while Present plus Gap is below active roster; Snap writes GapMark with local photo; Seal writes RollMark when counts match roster; Seal with unfilled Gap writes HollowMark; Peel drops the last Present, Gap, or ManualMark; Scan of unknown payload writes StrayMark; empty roster writes Bare** with no leakage across layers.
- [ ] UI approach matches **SwiftUI AVFoundation preview layer representable · material**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Run-locked chrome (the preview header and perch strip never leave; Roster and Analytics arrive as sheets; scan, present, gap snap, and seal fuse on the strip; Settings from the gear; no tab bar)**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **Bodoni 72** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Perchseal
xcodegen generate
xcodebuild build-for-testing -scheme Perchseal -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.perchseal.lockup/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
xcodebuild -scheme Perchseal -destination 'generic/platform=iOS' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.perchseal.lockup/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
xcrun simctl list devices available
xcodebuild test-without-building -scheme Perchseal -destination 'platform=iOS Simulator,id=<UDID>' -jobs 4 -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.perchseal.lockup/DerivedData'
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY, DEVELOPMENT_TEAM, SWIFT_TREAT_WARNINGS_AS_ERRORS or -derivedDataPath in project.yml — they are command-line only. CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
