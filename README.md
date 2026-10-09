# Perchseal

A backyard keeper scans each banded bird at lockup and seals the night so the perch matches the roster. A missing bird needs a photo of the empty perch before the roll can close. It is for small keepers who lose track of headcount after free-ranging, not a farm ledger of mash or eggs.

## Why a fold

The evening is one roll over the birds for a single daykey. The roll is an algebraic type with four states: Bare when nobody is active, Open before the first Present, Tallying once a known band or a weekly manual mark lands, and Sealed when Present plus Gap equals the active roster and every gap has a snap. Scanning a known band writes Present and folds Open into Tallying. An unknown payload writes StrayMark and offers a roster add. Peel drops the last Present, Gap, or ManualMark and reopens a sealed night. That fold is the product: the home screen is the live perch, not a list of records. One chart on disk is enough, because every mark is a step in that same fold.

## Why a keeper would pick this

Present-then-gap. Home is the live camera and the perch strip. Scan the wing band to mark a bird home. If the strip is still short, photograph the empty perch. Seal only when the counts match. A manual present is capped at once per bird per rolling week. Gap without a photo blocks the seal. Peel drops the last mark and reopens the night. The app never logs mash, feed conversion, or egg credits.

## How this differs

Other flock tools in this batch credit eggs, mash, or feed conversion. Perchseal closes the day with a band-scan census and a photo when someone is missing. Roster, the week, and settings cover that perch as sheets. There is no tab bar and no game.

## Art

Style: comic halftone pop art driven by photography. Ben-Day dots and a heavy printed contour sit on a real photographed subject. Subjects are solid and centered. Cutouts have transparent corners, a solid middle, and no square plate, hollow glass, or wire frame. Full-bleed pieces fill the canvas, with a quiet middle so type can sit on a plate. No lettering and no numerals in the artwork.

Shared cutout suffix for every asset that needs alpha: isolated solid opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine.

| Image set | Prompt |
| --- | --- |
| `psl_AppIcon` | A photographic close-up of a wing-band clasp on feathers, comic halftone, solid subject filling the square inside the middle area. No text, no numerals, no rounded mask, no alpha. |
| `psl_Splash` | A vertical photographic perch at lockup, comic halftone, filling the frame, with a calm uncluttered center band and no lettering. |
| `psl_Onboarding1` | A keeper's hands beside a perched bird at dusk, photographic comic halftone, solid subject centered, transparent corners. |
| `psl_Onboarding2` | A wing band held under a scan, mid gesture, photographic comic halftone, solid subject centered, transparent corners. |
| `psl_Onboarding3` | A full perch beside a sealed evening card, photographic comic halftone, solid subjects centered, transparent corners. |
| `psl_EmptyHome` | A solid wooden perch block with no bird, opaque subject, photographic comic halftone, transparent corners, calm and inviting. |
| `psl_EmptyList` | A closed folio waiting for a roll, solid covers, photographic comic halftone, transparent corners, not a hollow box. |
| `psl_CardBackdrop` | An abstract photographic field of coop boards in comic halftone, filling the canvas, quiet in the center so type stays readable, no lettering. |
| `psl_ControlFace` | The face of a solid metal seal stamp, photographic comic halftone, centered, not a ring and not an outline. |
| `psl_TwistHero` | One photographic still of a wing band and an empty perch together, comic halftone, solid subjects centered, transparent corners. |
| `psl_SuccessMark` | A solid filled seal of metal and wax, occupying the middle of the canvas, photographic comic halftone, not a thin outline and not a hollow ring. |
| `psl_HeaderDecor` | A wide photographic ornament of perch wood in comic halftone, solid band centered, transparent corners, no lettering. |

Cutout assets also use the shared suffix above. App icon, splash, and card backdrop fill the canvas and do not.

## Build

From this directory:

```bash
xcodegen generate
xcodebuild -scheme Perchseal -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
```

Signing flags belong on the command line only. The project keeps automatic signing so CI can embed a profile.
