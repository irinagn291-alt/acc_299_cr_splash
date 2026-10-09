<!-- gf-brief source=a1307bbd7bb401a6c2d27ca5b858b8b385de31aeb6b0b744f8edb87daca87352 written=2026-10-09T12:39:35+03:00 -->
# Perchseal

## What it is
Perchseal is an evening lockup book for backyard keepers who lose track of headcount after free-ranging. Each night you mark every banded bird home, photograph an empty perch if someone is missing, and seal when the perch matches the birds you still keep. It is a personal census, not a farm ledger of mash or eggs.

## Launch and onboarding
A cold launch shows a dark system launch screen with no words, then a brief empty wait.

On a physical device with no flock yet, four onboarding pages follow. Each page shows a page count, **Skip**, an illustration, a title, a line, and a bottom button.

1. **1 of 4**. Title **Lock up the flock**. Line **Each evening the perch should match the birds you still keep.** Button **Next**.
2. **2 of 4**. Title **Scan the band**. Line **A known wing band marks that bird home. One manual mark is allowed each week.** Button **Next**.
3. **3 of 4**. Title **Photograph the gap**. Line **If someone is missing, photograph the empty perch before you seal.** Button **Next**.
4. **4 of 4**. Title **Seal the night**. Line **Seal when every bird is counted, or the empty perch has a photo.** Button **Continue**.

**Skip** on any page, or **Continue** on the last page, finishes onboarding and opens Tonight. Later launches skip these pages and open Tonight.

On the Simulator, the first launch skips these pages and opens Tonight with the seeded flock below.

## Screens

There is no tab bar. Tonight stays on screen. **Birds**, **This week**, and **Settings** rise as sheets. Each sheet has a Close control (an X; spoken as **Close**) and a drag indicator.

### Tonight
Title **Tonight**. This is the home screen after onboarding.

When no active birds are on the roster:
- Headline **No flock yet**, line **Add the birds first**, button **Band a bird** (opens Birds).
- If the roll failed to load: headline **The roll did not load**, the recovery line, **Try again**, and **Band a bird**. Only **Settings** is available in the corner.

When birds are on the roster, a live perch preview fills the background and a strip sits over it.

Header card:
- **Tonight**
- The job line, one of:
  - **{name} is still out. Scan {name}, or photograph the empty perch.**
  - **Counts match. Seal the night.**
  - **Tonight is sealed. Reopen if a count needs to change.**
- Count **{counted} of {total} on the perch** (device number format)

Icon buttons:
- **Birds** — opens the Birds sheet
- **This week** — opens the This week sheet
- **Settings** — opens the Settings sheet

Camera card (shown until the live perch is running):
- **Starting the perch camera.** while the camera starts
- **The perch camera reads the wing band and photographs an empty spot.** plus **Continue** the first time the camera has not been asked. **Continue** presents the system camera dialog.
- **The camera is off. Open Settings to use the live perch, or type the code on the strip.** plus **Open Settings** if the camera was denied or restricted. **Open Settings** opens iOS Settings.
- **This device has no camera. Type the code on the strip.** if the device has no camera

Perch chips, one per active bird. Each shows the bird’s name and one of **Counted**, **Still out**, or **Photo**. Tap a **Still out** chip to try a manual mark (once per bird each rolling week). VoiceOver: **Count {name}** or **{name}, counted**.

Fields and actions on the strip (while the night is open):
- **Gap note** — shown while someone is still out. Default text **Empty perch**. Keyboard **Done**.
- **Wing code** — type a band. Letters capitalize. Keyboard **Done**.
- Status line under the fields (only after an action):
  - **Too early. Finish the shortfall, then seal.**
  - **The gap needs a photo. Photograph the empty perch.**
  - **Tonight is sealed.**
  - **That code is not on the roster.**
  - **Last mark dropped. The night is open again.**
  - **Gap filed with a photo.**
  - **Tonight is sealed. Reopen if a count needs to change.**
  - **That bird is not on the active roster. Band a bird first.**
  - **Manual mark already used this week. Scan the band.**
  - **Tonight is already sealed.**
  - **That bird is already counted. Photograph the gap, or seal.**
  - **Counts already match. Seal the night.**
  - **Nothing to reopen. Scan, or photograph the empty perch.**
- Primary **Scan {name}** (first bird still out) or **Scan** (if a wing code is typed). With a typed code, that code is used. With no typed code, the first still-out bird is marked counted. A matching live scan does the same.
- **Photograph the gap** — files a photo of the empty perch with the gap note.
- **Seal** — seals the night when every bird is counted or covered by a photo. A seal stamp flashes briefly on success. The button stays tappable while birds are still out; the night does not close until the shortfall is filled.
- When the camera is not live, a row of buttons named with each still-out bird. Tapping one marks that bird counted. Spoken as **Scan {name}**.

After a seal, the strip shows **Reopen** instead of Scan / Photograph / Seal. **Reopen** drops the last count, photo, or manual mark and opens the night again. The live perch can still read a code; the strip then says **Tonight is sealed. Reopen if a count needs to change.**

Unknown scan alert:
- Title **Unknown code**
- **That code is not on the roster. Add the bird, then scan again.**
- **Add to roster** — adds a bird named **New bird** with that code. The bird is not counted until you scan again.
- **Leave it** — dismisses

If a save is in trouble while birds are on screen, the recovery line appears on a small plate above the strip.

### Birds
Sheet title **Birds**.

Empty:
- **No birds yet** / **Add a name and a wing code.**
- If the roster failed to load: **Birds could not be read** plus the recovery line
- Fields **Name** and **Wing code**
- **Band a bird** — disabled until both fields have text. Adds the bird and clears the fields.

Filled list:
- Each bird: name, and either the wing code or **Retired**
- **Retire {name}** on an active bird
- The same **Name**, **Wing code**, and **Band a bird** fields at the bottom

Retire dialog:
- **Retire this bird?**
- **A retired bird leaves the active headcount. Tonight's earlier marks stay in the roll.**
- **Retire {name}** — the bird leaves tonight’s headcount and shows **Retired**
- **Keep on the roster**

Close with typed-but-unbanded fields:
- **Leave without saving?**
- **The name and wing code you typed will be dropped.**
- **Leave** / **Keep editing**
- Swipe-to-dismiss is blocked until you Leave or clear the fields

Keyboard **Done**. Close (X) spoken as **Close**.

### This week
Sheet title **This week**.

Empty (no night has been marked yet):
- **No nights yet** / **Seal a night on the perch and the week will show up here.** / **Back to tonight**
- If the week failed to load: **This week did not load** plus the recovery line and **Try again**

Filled (after the first count, photo, or seal):
- Title, one of:
  - **{name} is still out**
  - **{name}, {name} are still out**
  - **Tonight matches the birds you keep**
- Figure **{n} still out**
- Line, one of:
  - **Scan {name}, or photograph the empty perch.**
  - **Scan each bird still out, or photograph the empty perch.**
  - **Close this week. Seal tonight on the perch if the count is still open.**
- Button **Scan {name}** when exactly one bird is still out, otherwise **Back to tonight**. Both only close the sheet and return to Tonight. **Scan {name}** here does not count the bird.
- **Gap rate** — a percent over the last seven nights that have marks, or **None yet**
- **Health** — a whole number (100 on this census)
- **No mash on this census**
- **No egg count on this census**

Close (X) spoken as **Close**.

### Settings
Sheet title **Settings**.

When nothing is stored:
- **Nothing stored yet** / **Band the flock on the perch. Export appears after the first seal.**
- If a save failed: **Settings hit a bad save** plus the recovery line and **Try again**
- **Replay onboarding**, **Reset all data**, **Contact Perchseal**

When birds or sealed nights exist, a form:
- Recovery line and **Try again**, if a save is in trouble
- Section **Sealed rolls**
  - **{n} sealed**
  - **Export roll CSV** after at least one seal — opens the system share sheet with a table headed `Date,Counted,Photographed,Hand,Birds`
  - **Seal a night before export.** when the sealed count is 0
- **Replay onboarding** — closes Settings and shows the four onboarding pages again. **Skip** or **Continue** returns to Tonight. The flock is unchanged.
- **Reset all data**
- **Contact Perchseal** — opens the support page

Reset dialog:
- **Reset the whole flock?**
- **This removes every bird, tonight's roll, and gap photos from this device.**
- **Reset birds and rolls** / **Keep the flock**

After a reset, Settings can show **Nothing stored yet**. Closing the sheet runs onboarding again.

Close (X) spoken as **Close**.

## Features
- Band a bird with a **Name** and **Wing code**
- Retire a bird from the active headcount
- Live perch camera that reads a wing-band code and photographs an empty perch
- Type a **Wing code** when the camera is off
- Scan a known band to mark that bird **Counted**
- One manual mark per bird each week by tapping a **Still out** chip
- **Photograph the gap** with a **Gap note** when someone is still out
- **Seal** the night when counts match
- **Reopen** to drop the last mark and open the night again
- Unknown-code alert with **Add to roster**
- **Tonight** perch strip and headcount
- **This week**: still out, **Gap rate**, **Health**
- **Export roll CSV** of sealed nights
- **Replay onboarding**
- **Reset all data**
- **Contact Perchseal**

## Behaviours that can look like bugs
- **Band a bird** stays disabled until both **Name** and **Wing code** have text. Type both.
- Tonight shows **No flock yet** until an active bird is banded. Retired-only rosters look empty on Tonight even though Birds still lists them as **Retired**. Band a new bird, or wait until you have an active bird.
- **Scan** / **Scan {name}** on Tonight marks the first still-out bird when **Wing code** is empty. That is intended. Type a code to scan a different band.
- **Scan {name}** on This week only returns to Tonight. It does not count the bird. Count from Tonight.
- **Photograph the gap** stays disabled when nobody is still out, the night is sealed, or a photo is in progress.
- **Seal** while birds are still out does not close the night. The strip says **Too early. Finish the shortfall, then seal.** Scan or photograph until the job line is **Counts match. Seal the night.**
- **Seal** after a failed photo does not close the night. The strip says **The gap needs a photo. Photograph the empty perch.**
- Tapping a **Counted** chip says **That bird is already counted. Photograph the gap, or seal.**
- Tapping a **Photo** chip, or scanning a remaining bird after the gap is filled, says **Counts already match. Seal the night.**
- Tapping a **Still out** chip a second time in the same rolling week says **Manual mark already used this week. Scan the band.** Scan that bird instead.
- After a seal, Scan and Photograph are gone. The strip says **Tonight is sealed. Reopen if a count needs to change.** Tap **Reopen**, or leave the night sealed.
- **Reopen** drops only the last count, photo, or manual mark, not the whole night.
- **Add to roster** from **Unknown code** names the bird **New bird** and does not count it. Scan that code again.
- The same code scanned twice in about a second and a half is ignored.
- **Continue** on the camera card does not turn the camera on by itself. The system dialog is the grant. If you deny, use **Open Settings**, or type the **Wing code**, or tap a still-out name when the camera is not live.
- On a device with no camera, or with the camera off, **Photograph the gap** still files a photo and can say **Gap filed with a photo.**
- A failed photo save shows **The gap photo could not be saved. Photograph the empty perch again.** Photograph again.
- Birds will not swipe away while **Name** or **Wing code** has text. Use **Leave** or clear the fields.
- **Export roll CSV** is missing until a night is sealed. The form says **Seal a night before export.**
- **This week** stays on **No nights yet** until the first count, photo, or seal, even if birds are already banded. Mark Tonight, then open This week again.
- **Replay onboarding** and a full reset both return you to the four onboarding pages on purpose.
- A new calendar day starts a new Tonight. Yesterday’s seal stays in **This week** and in the export.
- Recovery lines (**The saved roll was damaged. Perchseal restored the last good copy.** / **The saved roll could not be read. Perchseal started from an empty roster.** / **Tonight's roll is on screen, and the last save did not finish. It will try again.** / **Reset cleared the roll, but a photo file could not be removed.**) stay until **Try again** or a later successful save.

## Starter content and resume
On the Simulator, the first launch already has four birds: **Maple** (`PSL-MAPLE`), **Brass** (`PSL-BRASS`), **Cinder** (`PSL-CINDER`), and **Pebble** (`PSL-PEBBLE`). Maple, Brass, and Cinder are **Counted**. Pebble is **Still out**. The job line is **Pebble is still out. Scan Pebble, or photograph the empty perch.** The count is **3 of 4 on the perch**. Onboarding is already complete.

On a physical device there is no seeded flock.

Unfinished Tonight work is kept and comes back after you leave the app. **Reopen** resumes a sealed night by dropping the last mark. A new day is a new night. **Reset birds and rolls** clears the flock.

## Permissions
Camera only. Asked the first time Tonight has birds and you tap **Continue** on **The perch camera reads the wing band and photographs an empty spot.** The system usage string is: **Perchseal uses the camera to read a wing band at lockup and to photograph an empty perch when a bird is missing.** Denied or restricted: **The camera is off. Open Settings to use the live perch, or type the code on the strip.** plus **Open Settings**.

## Absent
Login or accounts, in-app purchase, ads, analytics, shared user-generated content, an account deletion flow, and the App Tracking Transparency prompt are absent.

## Data and support
Bird names, wing codes, tonight’s roll, sealed nights, and gap photos stay on this device. **Contact Perchseal** in Settings opens the support page. **Reset all data** removes the flock from this device after confirmation.

## Scanning and health
The camera reads QR codes on wing bands. It expects the same wing code typed when the bird was banded (matching ignores case and extra spaces). A typed **Wing code** works the same way. Any other QR shows **Unknown code**. It does not scan product barcodes.

This week shows a **Health** figure (100 on this census), **No mash on this census**, and **No egg count on this census**. There is no medical advice and no citations.

## Platform
The words are English. Counts and percents follow the device locale. Tonight is the local calendar day. There is no country lock. Portrait only, full screen, on iPhone and iPad. Dark appearance. Minimum iOS 17.0. Not for Mac or Apple Vision.

## Category
Lifestyle
