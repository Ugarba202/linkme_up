🚀 Project Overview

LinkMeUp is a mobile-first social connection app that allows users to share all their social media profiles using one QR code or one link.

This project is built intentionally using:

Clean Architecture

Riverpod for state management

Firebase for backend & auth

⚠️ This repo is not just about shipping fast.
It is about learning industry-standard product engineering.

🎯 Core Product Principle (VERY IMPORTANT)

One core action:
“Show my QR so someone can scan and connect with me.”

Every screen, feature, and line of code must support this.

If it doesn’t → we don’t build it (yet).

🧠 Why This Architecture?
Why Clean Architecture?

Because:

UI changes often

Business rules should not

Firebase should be replaceable later

Testing becomes possible

Scaling becomes easier

Clean Architecture helps you think like a senior engineer, not just write code.

## 🚀 Deployment (Static/Web)

For the most reliable web experience, we use **Firebase Hosting**.

### One-Time Setup:
1. Install [Firebase CLI](https://firebase.google.com/docs/cli).
2. Run `firebase login`.
3. Run `firebase init hosting` and select your project (or use the one in `.firebaserc`).
   - What do you want to use as your public directory? **`build/web`**
   - Configure as a single-page app? **Yes**

### How to Deploy:
Run the following script whenever you want to push updates:
```bash
./scripts/deploy-firebase.sh
```
This script will build the Flutter Web app and push it to Firebase instantly.