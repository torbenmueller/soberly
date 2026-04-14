# soberly

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase config in a public repository

Do not commit `android/app/google-services.json`.

If this file was tracked before, remove it from git tracking (it stays on disk):

```powershell
git rm --cached "android/app/google-services.json"
git add .gitignore android/.gitignore
git commit -m "Stop tracking Firebase config"
```

For GitHub Actions, this repo uses `GOOGLE_SERVICES_JSON_BASE64`.
Create the secret value from your local `google-services.json`:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android/app/google-services.json"))
```

Copy the output and save it as a repository secret named
`GOOGLE_SERVICES_JSON_BASE64` in GitHub.

Important: rotate exposed API keys and apply Android app/API restrictions in
Google Cloud Console.

