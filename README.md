# door-to-door-shipping

Internal yard ledger for USA → overseas door-to-door shipping (staff + management).

See [PLAN.md](./PLAN.md) for the product plan, data model, and build order.

## Status

Flutter app with a local ledger (sqflite). Yard staff can create a container, photograph a label, run on-device OCR, confirm the fields, and save the shipment on the device. Home, container detail, item detail, and search read that local store.

**Firebase is not configured yet** — Auth, Firestore, and Storage are still stubs (`google-services.json` / `GoogleService-Info.plist` not required for analyze). Photos stay on the device as file paths. Login is a stub; staff vs management is a local role toggle.

## Stack

- Flutter (phone-first)
- sqflite + shared_preferences (local ledger and role)
- image_picker (camera or gallery) and google_mlkit_text_recognition (on-device OCR)
- Firebase Auth + Firestore + Storage (deps present, not wired)

OCR is heuristic (phone regex, destination keywords such as Kumasi/Accra/Ghana, first plausible name line). ML Kit only runs on a phone build; if it fails, the confirm screen still opens with empty fields.

## Screens

1. Login (stub)
2. Home (containers list + create + Add)
3. Container detail (items + cost total)
4. Add shipment (camera → OCR → confirm)
5. Confirm shipment
6. Item detail (edit + status)
7. Search
8. Management dashboard (local totals)
9. Roles (local staff / management toggle)

## Run

```bash
# Flutter SDK on PATH, then:
flutter pub get
flutter run
```

iOS deployment target is 15.5 (required by ML Kit). Android min SDK stays on the Flutter default (24).

## Next

1. Create a Firebase project and run `flutterfire configure`
2. Wire Auth + Firestore rules + Storage (upload the local photo)
3. Tune OCR against real label photos; short video capture is still out
