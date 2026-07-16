# Laravel + Flutter — Aplicație de task-uri

Cod companion pentru seria-tutorial de pe [laravel.ro](https://laravel.ro): o
aplicație simplă de to-do, cu backend Laravel (API + autentificare Sanctum) și
client mobil Flutter. Fiecare utilizator autentificat își vede și gestionează
doar propriile task-uri.

## Seria de articole

1. [Partea 1 — API-ul Laravel și CRUD de task-uri](https://laravel.ro/articole/flutter-laravel-api-taskuri)
2. [Partea 2 — Autentificare cu Sanctum](https://laravel.ro/articole/flutter-laravel-autentificare-sanctum)
3. [Partea 3 — App-ul Flutter: login și token](https://laravel.ro/articole/flutter-laravel-app-login)
4. [Partea 4 — App-ul Flutter: CRUD de task-uri](https://laravel.ro/articole/flutter-laravel-app-crud)

## Structura repo-ului

```
laravel-flutter-tasks/
├── backend/   # API Laravel 13 + Sanctum (SQLite, zero config)
└── mobile/    # Client Flutter (http + shared_preferences)
```

## Backend (Laravel)

Cerințe: PHP 8.2+ și Composer.

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
touch database/database.sqlite
php artisan migrate
php artisan serve
```

API-ul rulează la `http://127.0.0.1:8000/api`. Endpointuri:

- `POST /api/register`, `POST /api/login` — întorc un token
- `POST /api/logout`, `GET /api/user` — necesită `Authorization: Bearer <token>`
- `GET|POST|PUT|DELETE /api/tasks[/{id}]` — CRUD, protejate cu `auth:sanctum`

## Mobile (Flutter)

Cerințe: Flutter SDK (3.x) și un emulator sau telefon.

Acest folder conține doar sursele (`lib/` + `pubspec.yaml`). Ca să generezi
folderele de platformă (android/ios/...), rulează o dată `flutter create .` în
`mobile/`, apoi pornește aplicația:

```bash
cd mobile
flutter create .
flutter pub get
flutter run
```

### Adresa backendului (important)

Setează `baseUrl` în `lib/api_service.dart` în funcție de unde rulezi backendul:

- Emulator Android: `http://10.0.2.2:8000/api` (10.0.2.2 = „localhost"-ul
  mașinii-gazdă, văzut din emulator) — valoarea implicită
- Simulator iOS: `http://127.0.0.1:8000/api`
- Telefon fizic: `http://<IP-ul-tău-din-LAN>:8000/api`, iar backendul pornit cu
  `php artisan serve --host=0.0.0.0`

## Licență

MIT — folosește-l liber, în scop educativ sau ca punct de plecare.
