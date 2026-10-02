# Door-to-Door Shipping Ledger — Plan

## Goal
Phone-first internal app for a USA → overseas (e.g. Kumasi) door-to-door shipping yard. Yard staff and management track containers, packages, costs, and delivery status. **Not** a public marketplace in v1.

## Users & roles
| Role | Capabilities |
|------|----------------|
| **Staff** | Add/edit shipments, scan labels (OCR), attach photo/video, update status, assign to containers |
| **Management** | Everything staff can do, plus search across shipments, cost totals, reports, user roles |

## Core flow
1. **Add Shipment**
2. Pick or create a **container**
3. Capture **camera photo or short video** of the labeled box
4. **On-device OCR** extracts receiver name, phone, destination
5. User **confirms/edits** fields and enters **cost**
6. Save to DB with media attached

## Data model

### Container
- name / id
- carrier / forwarder
- tracking number and/or tracking link
- status
- cost total (sum of items or override)

### Item (shipment / package)
- receiver name
- phone
- destination
- package type: `box` | `barrel` | `sack` | `other` | `car`
- cost
- notes
- photo / video (Storage URLs)
- status
- container id (optional until assigned)
- carrier tracking # / link (optional at item level)

### User
- auth identity (Firebase Auth)
- role: `staff` | `management`
- display name, active flag

## Status pipeline
`received` → `in container` → `in transit` → `arrived` → `delivered`

## Tracking
Paste carrier + tracking number/link on the **container** (and optionally item). No custom GPS in v1. Rely on forwarder / ship company portals.

## Screens (v1)
1. Login
2. Home — containers list + Add
3. Container detail
4. Add shipment (camera → OCR confirm → cost → save)
5. Item detail
6. Search
7. Management dashboard (totals, reports)
8. Roles / user admin (management only)

## Tech stack
- **Client:** Flutter *or* React Native (phone-first)
- **OCR:** on-device — Apple Vision (iOS) / ML Kit (Android)
- **Backend:** Firebase Auth + Firestore + Storage

## Non-goals (v1)
- Public customer marketplace / self-service booking
- Custom GPS / live map tracking
- Payments processing
- Multi-tenant SaaS for other yards

## Open decisions
- [ ] Flutter vs React Native
- [ ] Exact Firestore collection layout & security rules
- [ ] Offline-first requirements for yard Wi‑Fi gaps
- [ ] Sample label formats to tune OCR (see attached label photos)

## Build order (suggested)
1. Firebase project, Auth, Firestore rules stub, Storage
2. Login + role seed
3. Containers CRUD + status
4. Add shipment with camera + media upload
5. On-device OCR → confirm/edit form
6. Item detail + status transitions
7. Search
8. Management dashboard + roles UI
