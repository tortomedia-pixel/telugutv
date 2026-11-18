# TeluguTV News App

A Telugu short-news app for TeluguTV. Stories appear as swipeable cards of about 60 words, with categories, district news, the TeluguTV YouTube videos and live stream, saving, sharing and push notifications.

## What's in this folder

| Folder / file | What it is |
|---|---|
| `lib/` | The Android app (Flutter) |
| `lib/config.dart` | **The only file you need to edit:** YouTube link and Firebase keys |
| `assets/` | TeluguTV logo and app icon |
| `admin/index.html` | Web panel where reporters log in and publish stories |
| `functions/` | Sends a push notification to all users when a story is published |
| `firestore.rules`, `storage.rules` | Security: only your admins can publish |
| `.github/workflows/build-apk.yml` | Builds the APK automatically on GitHub |

---

## Step 1 — Get a test APK (no Firebase needed yet)

The app runs in **demo mode** with sample stories until you add Firebase keys. The Video tab already shows your real YouTube channel.

1. Create a free account on **github.com** and make a new **private** repository called `telugutv-app`.
2. Click **"uploading an existing file"** and drag in **everything** from this folder, including the hidden `.github` folder. (Or use GitHub Desktop.)
3. Open the **Actions** tab. The "Build TeluguTV APK" job starts on its own and takes about 8–10 minutes.
4. When it shows a green tick, open it and download **TeluguTV-apk** at the bottom. Unzip it, copy `app-release.apk` to an Android phone and install it.

## Who can post news

Normal users **cannot post**. The app has no Post button for them.

Reporters post in one of two ways:
- **Inside the app:** **long-press the TeluguTV logo** at the top for about 1 second, then log in. A gold **➕ పోస్ట్** button appears on the news screen. They can take a photo with the camera or pick one from the gallery. Logout is on the Post screen.
- **Admin panel website** (`admin/index.html`), from a computer or phone browser.

Only accounts that you create **and** add to the `admins` list (Step 2, point 4) can log in to post. Anyone else gets "ఈ ఖాతాకు అనుమతి లేదు" (no permission). Firebase's security rules check this on the server, so the app can't be tricked. To remove a reporter, delete their document from `admins` or disable their login in Firebase Authentication.

## Step 2 — Connect Firebase (real news + notifications)

1. Go to **console.firebase.google.com** → *Add project* → name it `telugutv`.
2. **Build → Firestore Database** → Create database → location **asia-south1 (Mumbai)** → production mode.
3. **Build → Authentication** → Get started → enable **Email/Password**. Under *Users*, add an account for each reporter or editor.
4. **Make them admins:** in Firestore, create a collection called `admins`. Add one document per admin: the **Document ID = that user's UID** (copy it from the Authentication → Users list). Add any field, for example `name: "Rama"`.
5. **Project settings → Your apps → Add app → Android.** Package name: `com.telugutv.telugutv_news`. Copy the values into `lib/config.dart`:
   - `firebaseApiKey` = *Web API Key* / `current_key`
   - `firebaseAppId` = *App ID* (`1:xxxx:android:xxxx`)
   - `firebaseMessagingSenderId` = *Project number*
   - `firebaseProjectId` = *Project ID*
   - `firebaseStorageBucket` = `telugutv-xxxx.appspot.com` (or `.firebasestorage.app`)
6. **Project settings → Your apps → Add app → Web.** Copy the `firebaseConfig` it shows into `admin/index.html` (near the top of the script).
7. Upload the changed `config.dart` to GitHub. A new APK builds automatically.

## Step 3 — Publish the admin panel, rules and notifications

Install Node.js on a computer, then in this folder run:

```
npm install -g firebase-tools
firebase login
firebase use --add            (pick your telugutv project)
firebase deploy --only firestore,storage,hosting
```

Your admin panel will be live at `https://<project-id>.web.app`. Reporters log in there and publish.

**Photos and push notifications** need Firebase's **Blaze** (pay-as-you-go) plan. For a news app of this size it usually stays inside the free monthly allowance, but set a budget alert. After upgrading:

```
firebase deploy --only functions,storage
```

## Step 4 — Play Store

1. Create a Google Play Developer account (one-time US$25 fee).
2. Play Store needs an **AAB file signed with your own upload key**, not the test APK. Ask your developer (or Claude) to add signing to the workflow and switch the build command to `flutter build appbundle`.
3. You'll need: a privacy policy URL, 512×512 icon (`assets/icon/icon.png` can be resized), screenshots, and the News app declaration in Play Console.

## Where to change things

- **Categories or districts:** `lib/data/news.dart`. Keep the same list, in the same order, in `admin/index.html`.
- **Colours:** `lib/theme.dart`
- **Share message footer** (add your Play Store link later): `lib/config.dart`
- **Remove the demo stories:** they disappear automatically once Firebase is connected.
