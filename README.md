<img src="https://user-images.githubusercontent.com/30125790/212157461-58bdc714-2f89-44c2-8e4d-d42bee74854e.png#gh-dark-mode-only" width="200">
<img src="https://user-images.githubusercontent.com/30125790/212157486-bfd08c5d-9337-4b78-be6f-230dc63838ba.png#gh-light-mode-only" width="200">

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
# Veryfi Lens Flutter
Veryfi Lens is code (a framework) with UI for your mobile app to give it document capture superpowers in minutes.

Let Veryfi handle the complexities of frame processing, asset preprocessing, edge routing, and machine vision challenges in document capture. We have been at this for a long time and understand the intricate nature of mobile capture. That’s why we built Lens. Veryfi Lens is built by developers for developers; making the whole process of integrating Lens into your app fast and easy with as few lines as possible.

Veryfi Lens is a Framework: a self-contained, reusable chunks of code and resources you can import into you app.

Lens is built in native code and optimized for fast performance, clean user experience and low memory usage.

You can read further about Lens in Veryfi's dedicated page: https://www.veryfi.com/lens/

You can watch our video:
[![Veryfi Lens](https://img.youtube.com/vi/TUV5SXpKN48/maxresdefault.jpg)](http://www.youtube.com/watch?v=TUV5SXpKN48 "Veryfi Lens Features")

## Table of content
1. [Configuration](#configuration)
2. [iOS Localization](#localization)
3. [Other platforms](#other_platforms)
4. [Get in contact with our team](#contact)

### Configuration <a name="configuration"></a>
- Go to Lens: Maven (Android) section and generate your access credentials [here](https://hub.veryfi.com/api/settings/keys/#package-managers-container).
- Add your Maven credentials to your system environment. Replace [USERNAME] and [PASSWORD] with the credentials that were set up in the previous step.
```
export MAVEN_VERYFI_USERNAME=[USERNAME]
export MAVEN_VERYFI_PASSWORD=[PASSWORD]
```

- Clone this repository
- Go to Lens: Flutter (iOS + Android) section and generate your access credentials [here](https://hub.veryfi.com/api/settings/keys/#package-managers-container).
- Go `pubspec.yml` and go to the `veryfi` on the dependencies section:
- Find the line `https://[USERNAME]:[PASSWORD]@repo.veryfi.com/shared/lens/flutter-plugin-veryfi-lens.git`
- Replace [USERNAME] and [PASSWORD] with the credentials that were set up in the previous step.
- Clean the project (**IMPORTANT: Always clean the project after updating the Veryfi Lens Flutter plugin version**, otherwise, the project might not compile):
```
flutter clean
```
- Fetch the dependencies using your IDE or run:
```
flutter pub get
```
- Note: The wrapper supports the following Flutter SDK versions:
```
flutter: ">=3.19.3"
```


- Replace credentials in `main.dart` with yours
```
Map<String, dynamic> credentials = {
  'clientId': 'XXXX', //Replace with your clientId
  'userName': 'XXXX', //Replace with your username
  'apiKey': 'XXXX', //Replace with your apiKey
  'url': 'XXXX' //Replace with your url
};
```

We are using [flutter_dotenv](https://pub.dev/packages/flutter_dotenv), that means that you need to create a [.env] file in the root of your flutter 
project if you want keep safe your credentials in your personal project, if not, please remove the next declaration inside the [pubspec.yml].

```
# To add assets to your application, add an assets section, like this:
  assets:
    - .env
```



### iOS Localization (Optional) <a name="localization"></a>
- In order to be able to enable iOS Lens native localization you need to enable a supported language on the project file:
![Step 1](https://github.com/user-attachments/assets/8408ef50-0a47-459d-b89b-3b0208322b62)

- Generate  localization files for the desired language (for example in storyboard):
![Step 2](https://github.com/user-attachments/assets/e44ee792-e8ce-4524-a7e9-c328ef466ceb)

- At the end you should have at least 1 file localized for each language that you want to enable localization, see example:
![Step 3](https://github.com/user-attachments/assets/698ab01a-416c-47f2-8789-e02fac3d0b7e)

### Other platforms <a name="other_platforms"></a>
We also support the following wrappers for native and hybrid frameworks:
- [Cordova](https://hub.veryfi.com/lens/docs/cordova/)
- [Capacitor](https://hub.veryfi.com/lens/docs/capacitor/)
- [Flutter](https://hub.veryfi.com/lens/docs/flutter/)
- [Xamarin](https://hub.veryfi.com/lens/docs/xamarin/)
- [iOS](https://hub.veryfi.com/lens/docs/ios/)
- [Android](https://hub.veryfi.com/lens/docs/android/)

If you don't have access to our Hub, please contact our sales team, you can find the contact bellow.

### Get in contact with our sales team <a name="contact"></a>
Contact sales@veryfi.com to learn more about Veryfi's awesome products.
