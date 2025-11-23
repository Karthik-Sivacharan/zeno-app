# Font Setup Checklist for Zeno

## ✅ Step 1: Remove Fonts from Project
- [ ] Select all font files in Project Navigator
- [ ] Right-click → Delete → "Remove Reference"
- [ ] Fonts removed from project (but still in folder)

## ✅ Step 2: Re-add Fonts via Xcode
- [ ] Right-click `Zeno` folder → "Add Files to 'Zeno'..."
- [ ] Navigate to `Zeno/Resources/Fonts/`
- [ ] Select ALL `.ttf` files:
  - SpaceGrotesk-Bold.ttf
  - SpaceGrotesk-Light.ttf
  - SpaceGrotesk-Medium.ttf
  - SpaceGrotesk-Regular.ttf
  - SpaceGrotesk-SemiBold.ttf
  - SpaceMono-Bold.ttf
  - SpaceMono-BoldItalic.ttf
  - SpaceMono-Italic.ttf
  - SpaceMono-Regular.ttf
  - Syne-Bold.ttf
  - Syne-ExtraBold.ttf
  - Syne-Medium.ttf
  - Syne-Regular.ttf
  - Syne-SemiBold.ttf
- [ ] Check "Add to targets: Zeno"
- [ ] UNCHECK "Copy items if needed"
- [ ] Click "Add"

## ✅ Step 3: Verify Target Membership
- [ ] Select any font file in Project Navigator
- [ ] Open File Inspector (right sidebar, first tab)
- [ ] Under "Target Membership", verify "Zeno" is checked
- [ ] Check 2-3 more fonts to confirm

## ✅ Step 4: Verify Build Phases
- [ ] Select "Zeno" project (blue icon)
- [ ] Select "Zeno" target under TARGETS
- [ ] Click "Build Phases" tab
- [ ] Expand "Copy Bundle Resources"
- [ ] Verify all 14 font files are listed
- [ ] If missing, click "+" and add them

## ✅ Step 5: Check Info.plist (via Info Tab)
- [ ] With "Zeno" target selected, go to "Info" tab
- [ ] Look for "Fonts provided by application" (UIAppFonts)
- [ ] Should show array with 14 entries (just filenames, no paths):
  - SpaceGrotesk-Bold.ttf
  - SpaceGrotesk-Light.ttf
  - SpaceGrotesk-Medium.ttf
  - SpaceGrotesk-Regular.ttf
  - SpaceGrotesk-SemiBold.ttf
  - SpaceMono-Bold.ttf
  - SpaceMono-BoldItalic.ttf
  - SpaceMono-Italic.ttf
  - SpaceMono-Regular.ttf
  - Syne-Bold.ttf
  - Syne-ExtraBold.ttf
  - Syne-Medium.ttf
  - Syne-Regular.ttf
  - Syne-SemiBold.ttf

If missing, add it:
- [ ] Click "+" button in Info tab
- [ ] Type: `Fonts provided by application`
- [ ] Add each font filename (just the name, not full path) as a new row

## ✅ Step 6: Clean Build
- [ ] Product → Clean Build Folder (Shift + Cmd + K)
- [ ] Wait for cleanup to complete

## ✅ Step 7: Build and Run
- [ ] Product → Build (Cmd + B)
- [ ] Check for errors (should be none)
- [ ] Product → Run (Cmd + R)
- [ ] Open Console (bottom panel)
- [ ] Look for debug output showing available fonts

## ✅ Step 8: Verify Fonts in Console
- [ ] Check console output for "🔍 All available font families"
- [ ] Look for fonts containing "Space" or "Syne"
- [ ] Note the exact PostScript names shown
- [ ] Share console output if fonts still don't work

---

**Important Notes:**
- You do NOT need to install fonts on your Mac
- Fonts should be bundled with the app automatically
- The 'A' or '?' indicators in Xcode don't always reflect runtime availability
- Console output will show the actual font names iOS recognizes

