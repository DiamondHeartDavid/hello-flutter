# flutter_application_17

A new Flutter project.

Note: For Android builds, this project is configured to use Java 21 (LTS).
Make sure JDK 21 is installed and configured on your machine before building the Android app.

Admin/testing notes:
- In debug builds, the login page contains two dev-only helpers to create or sign into an admin account for testing.
	- "Create Admin (Dev)" will create an authentication user and a Firestore user document with role "administrator".
	- "Sign in as Admin (Dev)" will sign in using the entered credentials and ensure the Firestore role is set to "administrator".
	- These debug buttons are only visible when running in debug mode.
	- There's also a debug-only button in the `Profile` page to promote the current signed-in user to an `Administrator` role for testing and to reset the role back to `User`.
- Alternatively you can create users in Firebase Console and set the `users/<uid>/role` to `administrator`.

Seeding an admin user (server-side, recommended)
- For production or secure environments, create admin accounts with the Firebase Admin SDK or Firebase Console.
- You can also use the helper script included in this repo to create or update an admin account using the Firebase Admin SDK:

	```powershell
	# On Windows PowerShell, set the GOOGLE_APPLICATION_CREDENTIALS env var pointing to a service account key
	# 
	# Option A (Recommended): use the convenience PowerShell helper included in this repo
	# This will copy your service account JSON into the repo's .secrets folder and run the script.
	.\scripts\seed-admin.ps1 -KeyPath 'C:\path\to\serviceAccountKey.json' -Email 'admin@example.com' -Password 'admin' -First 'Admin' -Last 'User' -Username 'admin'

	# Option B: set the variable yourself and run the npm script
	$env:GOOGLE_APPLICATION_CREDENTIALS = "C:\path\to\serviceAccountKey.json"
	npm run seed-admin -- --email admin@example.com --password admin --first Admin --last User --username admin
	```

	Or on macOS/Linux:
	```bash
	export GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccountKey.json
	npm run seed-admin -- --email admin@example.com --password admin --first Admin --last User --username admin
	```
