# Login Feature – Implementation Notes

The login screen is ported from `ConferenceResearchApp/lib/features/login_screen` and rebuilt with
Clean Architecture, Cubit, Dio and get_it.

---

## 1. Files created / modified

### Created – Core (`lib/core/`)
| File | Purpose |
|---|---|
| `constants/app_colors.dart` | Colours from the Conference design (`darkBlue #1A1F8F`, `textHint #727279`, …) |
| `constants/app_assets.dart` | Asset paths (logos + Lottie loader) |
| `network/api_config.dart` | **Base URL, timeouts and endpoints – the only place to change API URLs** |
| `network/dio_client.dart` | Builds the shared `Dio` instance (base options + debug logging) |
| `network/result.dart` | `Result<T>` = `ResultSuccess` / `ResultFailure` (returned by repositories) |
| `error/exceptions.dart` | Data-layer exceptions (`NetworkException`, `ServerException`) + `DioException` mapping |
| `error/failures.dart` | Domain-level failures (`NetworkFailure`, `ServerFailure`, `UnexpectedFailure`) |
| `di/injection_container.dart` | get_it registrations (`sl`) |

### Created – Login feature (`lib/features/login/`)
| Layer | File | Purpose |
|---|---|---|
| Domain | `domain/entities/login_user.dart` | Pure entity used by the app |
| Domain | `domain/repositories/login_repository.dart` | Repository contract (interface) |
| Domain | `domain/usecases/login_usecase.dart` | Single login action |
| Data | `data/models/login_request_model.dart` | Request body (`toJson`) |
| Data | `data/models/login_response_model.dart` | Response parsing (`fromJson`) + `toEntity()` |
| Data | `data/datasources/login_remote_data_source.dart` | Dio POST call |
| Data | `data/repositories/login_repository_impl.dart` | Converts exceptions → `Result` |
| Presentation | `presentation/cubit/login_state.dart` | Initial / Loading / Success / Error |
| Presentation | `presentation/cubit/login_cubit.dart` | Calls use case, emits states |
| Presentation | `presentation/validators/login_validator.dart` | Form validation rules |
| Presentation | `presentation/pages/login_page.dart` | UI only (same design as the Conference app) |

### Created – Assets
`assets/images/top_logo.png`, `middle_logo.png`, `india_ahead.png`, `ic_loader.json` (copied from the Conference app).

### Modified
| File | Change |
|---|---|
| `pubspec.yaml` | Added `flutter_bloc`, `equatable`, `dio`, `get_it`, `flutter_screenutil`, `google_fonts`, `loader_overlay`, `lottie`; registered `assets/images/` |
| `lib/main.dart` | Init DI, portrait lock, ScreenUtil (360×690), fixed text scale, opens `LoginPage` |
| `android/app/src/main/AndroidManifest.xml` | Added `INTERNET` permission (needed for release builds); app label `AGIC` |
| `test/widget_test.dart` | Replaced default counter test with validator unit tests |

---

## 2. Architecture flow

```
LoginPage (UI)                 presentation  – widgets only, no API/business logic
   ↓ context.read<LoginCubit>().login(id)
LoginCubit                     presentation  – emits LoginState
   ↓
LoginUseCase                   domain        – trims input, calls repository
   ↓
LoginRepository (interface)    domain
   ↓ implemented by
LoginRepositoryImpl            data          – exceptions → Result<LoginUser>
   ↓
LoginRemoteDataSource          data          – Dio call, JSON → LoginResponseModel
   ↓
Dio  →  ApiConfig.baseUrl + ApiEndpoints.login
```

Dependencies point inwards: Domain knows nothing about Dio, Flutter or JSON.
All objects are wired in `injection_container.dart`; `LoginCubit` is a **factory** (new instance per screen),
everything else is a lazy singleton.

---

## 3. How the Login API works

1. User enters the ID and taps **Login** (or presses "done" on the keyboard).
2. The `Form` validates using `LoginValidator.clientId` – required, exactly 5 characters, letters/numbers only.
   Invalid input shows an error under the field and no API call is made.
3. `LoginRemoteDataSourceImpl` sends:
   ```
   POST {baseUrl}Login
   { "ClientId": "<id>" }
   ```
4. Response (placeholder contract, same shape as the Conference app):
   ```json
   { "response": true, "message": "…", "data": { … } }
   ```
5. Error handling:

| Situation | Data layer throws | Repository returns | User sees |
|---|---|---|---|
| No internet / connection error | `NetworkException` | `NetworkFailure` | "No internet connection…" |
| Connect / send / receive timeout | `NetworkException` | `NetworkFailure` | "Request timed out…" |
| HTTP 4xx / 5xx | `ServerException` (uses server `message` if present) | `ServerFailure` | server message or "Server error (code)…" |
| Body is not JSON object | `ServerException` | `ServerFailure` | "Invalid response from server." |
| `response == false` | – | `ServerFailure` | API `message` or "Login failed." |
| Any other error | – | `UnexpectedFailure` | "Something went wrong…" |

---

## 4. How the Cubit handles the states

| State | When | UI reaction |
|---|---|---|
| `LoginInitial` | Screen opened | Normal form |
| `LoginLoading` | API call started | White overlay with Lottie loader (same as Conference app); Login button disabled; duplicate taps ignored |
| `LoginSuccess(user)` | `ResultSuccess` | Overlay hidden, green "Login successful" SnackBar (navigation TODO, see below) |
| `LoginError(message)` | `ResultFailure` | Overlay hidden, red SnackBar with the message |

The UI uses a `BlocListener` for side effects (loader/snackbar) and `context.select` only to
enable/disable the button, so the page doesn't rebuild unnecessarily. The cubit checks `isClosed`
after the await so it never emits after the screen is disposed.

---

## 5. Replacing the placeholder API with the real API

1. **Base URL / endpoint** – edit `lib/core/network/api_config.dart`:
   ```dart
   static const String baseUrl = 'https://your-real-host/api/';
   static const String login = 'YourLoginEndpoint';
   ```
   (The Conference app uses `https://agic.motilaloswal.com/AGIC_MobileAPI/api/`.)
2. **Request body** – edit `toJson()` in `login_request_model.dart` (add fields such as password/device ID if needed;
   also add them to `LoginUseCase.call` / `LoginRepository.login`).
3. **Response** – edit `LoginResponseModel.fromJson` to the real keys, and add any fields you need
   to `LoginUser` + `toEntity()`.
4. **Headers / token** – add to `BaseOptions(headers: …)` or an `Interceptor` in `dio_client.dart`.
5. **HTTP method** – change `_dio.post` in `login_remote_data_source.dart` if the API is not POST.
6. **Navigation** – replace the `// TODO` in `LoginPage._onStateChanged` (`LoginSuccess` case) with navigation to the dashboard.

Nothing in the UI, Cubit or use case needs to change for steps 1–5.

### Adding another API later
Create `features/<name>/{data,domain,presentation}` with the same pattern, reuse the shared `Dio`,
`Result`, `AppException` and `Failure` classes, and register the new classes in `injection_container.dart`.

---

## Notes / differences from the Conference app
- Not ported (outside the login screen's scope): saving the client code in local storage,
  `BackButtonInterceptor` (the reference blocks the Back button on login), the dashboard navigation.
- Validation is stricter than the reference (which only checked empty input): exactly 5 alphanumeric characters.
- `google_fonts` (Tinos) downloads the font at runtime on first launch, same as the reference. To work fully offline,
  bundle the Tinos `.ttf` files under `assets/` and register them in `pubspec.yaml`.

## Verification
- `flutter analyze` → **No issues found**
- `flutter test` → 4/4 validator tests pass
- Not yet run on a device/emulator.
