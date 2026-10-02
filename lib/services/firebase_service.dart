/// Firebase placeholders.
///
/// TODO: Run `flutterfire configure` and wire a real Firebase project.
/// Until then this service compiles without google-services.json /
/// GoogleService-Info.plist and does not call Firebase.initializeApp().
class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// No-op until Firebase is configured.
  Future<void> initialize() async {
    // TODO: await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // TODO: Auth, Firestore, Storage setup
    _initialized = false;
  }

  // --- Auth stubs ---
  Future<void> signIn({required String email, required String password}) async {
    // TODO: FirebaseAuth.instance.signInWithEmailAndPassword(...)
    throw UnimplementedError('Firebase Auth not configured yet');
  }

  Future<void> signOut() async {
    // TODO: FirebaseAuth.instance.signOut()
  }

  // --- Firestore stubs ---
  // TODO: CollectionReference for containers, items, users

  // --- Storage stubs ---
  // TODO: upload photo/video for OCR pipeline
}
