# Bank Employee Details Application

Flutter frontend with a Django REST API and PostgreSQL database. The existing Flutter screens manage customer and bank-account records, so the API stores those same 13 fields and uses the entered `customer_id` as the record ID.

## Backend setup (Windows)

1. Create a PostgreSQL database named `bank_employee_details` in pgAdmin or `psql`. The configured database user must have permission to connect and create tables.
2. Copy `Backend/.env.example` to `Backend/.env`. Set `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_HOST`, and `DB_PORT` to match your PostgreSQL installation. Replace the development `DJANGO_SECRET_KEY` as well. `.env` is git-ignored; do not commit database credentials.
3. Install the backend and apply the database migration:

   ```powershell
   cd Backend
   py -m venv .venv
   .\.venv\Scripts\Activate.ps1
   python -m pip install -r requirements.txt
   python manage.py migrate
   ```

4. Start Django:

   ```powershell
   python manage.py runserver
   ```

   The health endpoint is `http://127.0.0.1:8000/api/health/`. It reports whether both Django and PostgreSQL are reachable.

## API

| Method | Endpoint | Behavior |
|---|---|---|
| `GET` | `/api/customers/` | List saved customers |
| `POST` | `/api/customers/` | Save a customer JSON record |
| `GET` | `/api/customers/{customer_id}/` | Retrieve one customer by its ID |
| `GET` | `/api/health/` | Check API and database connectivity |

The JSON keys match the Flutter `Customer.toJson()` model: `customer_id`, `full_name`, `date_of_birth`, `email`, `phone`, `address`, `account_number`, `account_type`, `branch_name`, `branch_code`, `account_opening_date`, `account_balance`, and `account_status`. Customer IDs and account numbers must be unique. The API returns validation errors rather than silently accepting invalid records.

## Run the Flutter app

For local Flutter Web, Windows, and desktop, the default API URL is `http://127.0.0.1:8000/api`. Start the backend before using Add Customer, Search, or the directory.

For the Android emulator, use its host-machine alias:

```powershell
cd Frontend
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

For a physical Android device, use the computer's LAN IP address for `API_BASE_URL`, add that address to `DJANGO_ALLOWED_HOSTS` in `Backend/.env`, and start Django with `python manage.py runserver 0.0.0.0:8000`. This exposes the development server on the local network; only do so on a trusted network. The debug Android manifest allows cleartext HTTP only for local development; deploy behind HTTPS for production.

## Deploy Flutter Web to GitHub Pages

The repository-root workflow at `.github/workflows/deploy-pages.yml` builds and deploys the Flutter web frontend when frontend files change on `main` or when manually triggered. In the repository's **Settings → Pages**, set the build and deployment source to **GitHub Actions**. Add a repository Actions variable named `API_BASE_URL` with the HTTPS base URL of the deployed Django API, ending in `/api` (for example, `https://api.example.com/api`). The workflow intentionally fails until a real HTTPS API URL is configured; GitHub Pages does not host the Django backend or PostgreSQL database. For the production API, set `DJANGO_DEBUG=false`, `DJANGO_ALLOWED_HOSTS` to the API host, and `CORS_ALLOWED_ORIGINS` to the GitHub Pages origin (for this repository, `https://ramdenimanojkumar.github.io`). Configure API authentication before exposing customer data to users.

## Tests

Backend API tests use SQLite so they do not need a running PostgreSQL server:

```powershell
cd Backend
.\.venv\Scripts\Activate.ps1
$env:DJANGO_DB_ENGINE = "sqlite"
python manage.py test
Remove-Item Env:DJANGO_DB_ENGINE
```

Run the Flutter tests with `cd Frontend; flutter test`.

## Production security

The development configuration enables open CORS and unauthenticated API access only while `DJANGO_DEBUG=true`. Before exposing the API to users, set `DJANGO_DEBUG=false`, configure HTTPS and permitted hosts, and implement an authentication flow for Flutter users. Do not use the local development server as a production server.
