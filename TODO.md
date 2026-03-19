# SpotIt Phase 1 Implementation TODO

## Phase 1: Security & Core Fixes (Approved)

**Step 1: [PENDING] Create firestore.rules**
- User-only own reports access

**Step 2: [PENDING] Create storage.rules** 
- Public read, auth write for images

**Step 3: [✅ DONE] Update functions/index.js**
- Rate limiting, image attachment, 3x retry, rich HTML, district support, admin link

**Step 4: [✅ DONE] Update lib/services/firestore_service.dart**
- Added district, lat, lng, updatedAt to submitReport signature + data

**Step 5: [✅ DONE] Update lib/screens/submit_report_screen.dart**
- Validation, lat/lng parsing, district dropdown UI, error handling (compile fixed)

**Step 6: [🚀 READY] Deploy & Test**
- `firebase deploy --only firestore:rules,storage:rules,functions`
- Test submit → email attachment → security rules

