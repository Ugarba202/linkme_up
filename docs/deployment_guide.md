# Vercel Deployment Guide for LinkMeUp

To ensure your web version stays synchronized with the latest mobile branding, you must configure your Vercel project with the following settings.

## ⚙️ Project Settings

In your Vercel Dashboard, go to **Settings > Build & Development** and set these values:

| Setting | Value |
| :--- | :--- |
| **Framework Preset** | `Other` |
| **Build Command** | `flutter build web --release` |
| **Output Directory** | `build/web` |
| **Install Command** | `flutter pub get` (Optional, usually handled automatically) |

## 🛠️ Root Directory Note
Ensure Vercel is set to build from the **root** of the repository (`/`), as the `vercel.json` and `pubspec.yaml` are located there.

## 🚀 Why this is important
Without these settings, Vercel might serve an old static build or a cached version of the previous "LinkQR" project. Setting the build command to `flutter build web` ensures the latest "Midnight Indigo" branding is compiled every time you push to GitHub.
