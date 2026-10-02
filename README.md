# door-to-door-shipping

Internal yard ledger for USA → overseas door-to-door shipping (staff + management).

See [PLAN.md](./PLAN.md) for the product plan, data model, and build order.

## Status

Flutter scaffold is in place: empty screens, model stubs, Firebase placeholders.
**Firebase is not configured yet** — the app compiles without a real Firebase project (`google-services.json` / `GoogleService-Info.plist` not required for analyze).

## Stack

- Flutter (phone-first)
- Firebase Auth + Firestore + Storage (deps present, not wired)
- On-device OCR planned (Apple Vision / ML Kit) — not in this scaffold

## Screens

1. Login  
2. Home (containers list + Add)  
3. Container detail  
4. Add shipment (camera / OCR stub)  
5. Item detail  
6. Search  
7. Management dashboard  
8. Roles  

## Run

```bash
# Flutter SDK on PATH, then:
flutter pub get
flutter run
```

Or open the project in Android Studio / VS Code with the Flutter plugin.

## Next

1. Create a Firebase project and run `flutterfire configure`
2. Wire Auth + Firestore rules + Storage
3. Implement camera + OCR flow (see PLAN.md)
