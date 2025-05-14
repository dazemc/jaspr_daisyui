# 🌬️ TailwindCSS v4 + DaisyUI v5 Integration for Jaspr

[TailwindCSS](https://tailwindcss.com/) is a utility-first CSS framework to rapidly build modern websites, and [DaisyUI](https://daisyui.com/) provides component classes for Tailwind.

This package is a first-class Tailwind integration for [Jaspr](https://github.com/schultek/jaspr), specifically supporting **TailwindCSS v4** and **DaisyUI v5**.

---

## 🔧 Prerequisites

Install the standalone TailwindCSS v4 CLI:

```sh
curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-<your-platform>
chmod +x tailwindcss-<your-platform>
mv tailwindcss-<your-platform> /usr/local/bin/tailwindcss
```

Confirm installation:

```sh
tailwindcss -h
```

---

## 📦 Setup

1. Add the `jaspr_daisui` dev dependency:

```sh
dart pub add jaspr_daisui --dev
```

2. Download DaisyUI v5 plugin files in your `web/` directory:

```sh
curl -sLO https://github.com/saadeghi/daisyui/releases/latest/download/daisyui.js
curl -sLO https://github.com/saadeghi/daisyui/releases/latest/download/daisyui-theme.js
```

3. Create a `styles.tw.css` file in your `web/` directory:

```css
@import "tailwindcss";
@plugin "./daisyui.js";

/* Optional: add custom themes */
@plugin "./daisyui-theme.js" {
  /* your custom theme config */
}
```

---

## 🖇️ Link Styles in Your App

### In **static** or **server** mode:

```dart
import 'package:jaspr/server.dart';
import './app.dart';

void main() {
  runApp(Document(
    title: 'My Tailwind Site',
    head: [
      link(href: 'styles.css', rel: 'stylesheet'),
    ],
    body: App(),
  ));
}
```

### In **client** mode:

```html
<!-- web/index.html -->
<html>
  <head>
    <link href="styles.css" rel="stylesheet" />
  </head>
</html>
```

All `.tw.css` files in the `web/` directory will be compiled into corresponding `.css` files.

---

## 🧪 Usage

Use Tailwind and DaisyUI classes directly in Jaspr components:

```dart
import 'package:jaspr/jaspr.dart';

class SimpleCard extends StatelessComponent {
  const SimpleCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'card bg-base-100 shadow-xl p-4', [
      div(classes: 'card-title text-xl font-bold', [text(title)]),
      div(classes: 'text-content', [text(message)]),
    ]);
  }
}
```

---

## ⚙️ Configuration (Optional)

You can customize your Tailwind setup by adding `tailwind.config.js` in your root:

```js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./{lib,web}/**/*.dart'],
  theme: {
    extend: {},
  },
  plugins: [],
}
```

> ℹ️ Note: Automatic recompilation only triggers on `.dart` file changes. If you change your config, re-run the build manually.
