# Testing Checklist (Android)

Follow this checklist to verify the game's functionality on an Android device before release.

## 1. Initial Launch
- [ ] Splash screen displays correctly.
- [ ] Transition to Main Menu is smooth.
- [ ] Daily Reward popup appears if it's the first login of the day.

## 2. UI and Navigation
- [ ] All buttons in Main Menu navigate to correct scenes.
- [ ] "Back" buttons in all sub-menus return to the previous screen.
- [ ] UI scales correctly on the mobile screen (1280x720 viewport).
- [ ] Touch targets are easy to hit.

## 3. Gameplay (World Scene)
- [ ] Truck movement (Accelerate, Reverse, Turn) works via touch/on-screen controls.
- [ ] Horn button triggers the horn sound/effect.
- [ ] Fuel decreases over distance.
- [ ] Cargo pickup and delivery zones trigger correctly.
- [ ] Mission Complete popup displays "Rs." currency and correct rewards.
- [ ] Weather effects (Rain, Fog) are visually visible and impact physics.
- [ ] Day-Night cycle transitions smoothly.

## 4. Save/Load System
- [ ] Close the app during a mission and restart; verify money/XP/fuel are saved.
- [ ] Purchase a truck/upgrade, restart the app, and verify it's still owned/upgraded.
- [ ] Change truck skin, restart, and verify skin is persisted.
- [ ] Check if the daily reward streak increments correctly after 24 hours.

## 5. Company Management
- [ ] Hiring a driver correctly deducts Rs. 1000.
- [ ] Assigning a driver to a truck works and is saved.
- [ ] Taking a loan works and daily repayments are deducted.
- [ ] Daily Report popup shows accurate profit/loss details.

## 6. Garage and Customization
- [ ] Truck skin preview updates when selecting different skins.
- [ ] Upgrading stats (Speed, Fuel, etc.) correctly reflects in the UI bars.
- [ ] Repairing a truck works and resets condition to 100%.

## 7. Performance and Stability
- [ ] Game maintains a stable frame rate (target 30/60 FPS).
- [ ] No crashes during scene transitions.
- [ ] Audio volume sliders in Settings work as expected.
