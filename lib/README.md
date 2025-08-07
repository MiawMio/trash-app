# Flutter Login App Structure

Aplikasi Flutter dengan halaman login yang terorganisir dengan baik menggunakan struktur folder yang terpisah.

## 📁 Struktur Folder

```
lib/
├── constants/          # Konstanta aplikasi
│   ├── app_colors.dart # Definisi warna tema
│   └── app_strings.dart # String/text constants
├── components/         # Komponen kecil (opsional)
├── widgets/           # Widget yang dapat digunakan kembali
│   ├── app_logo.dart  # Logo aplikasi
│   ├── custom_button.dart    # Tombol custom
│   └── custom_text_field.dart # Text field custom
├── screens/           # Halaman-halaman aplikasi
│   ├── login_screen.dart     # Halaman login
│   ├── register_screen.dart  # Halaman register
│   └── home_screen.dart      # Halaman dashboard
├── services/          # Service layer
│   └── auth_service.dart     # Service autentikasi Firebase
├── utils/            # Utility functions
│   └── validators.dart       # Validasi form
├── models/           # Model data (opsional)
└── main.dart         # Entry point aplikasi
```

## 🎨 Desain

- **Tema Warna**: Hijau (#78C98B) sebagai primary color
- **UI Style**: Modern dengan rounded corners dan shadows
- **Typography**: Font weight dan size yang konsisten
- **Layout**: Responsive dengan flex layout

## 🔧 Fitur

### Halaman Login
- Input field untuk nama/email dan password
- Validasi form
- Toggle visibility password
- Loading state saat login
- Error handling
- Link ke halaman register

### Halaman Register  
- Form lengkap dengan konfirmasi password
- Validasi input real-time
- Error handling yang proper
- Link kembali ke login

### Halaman Home/Dashboard
- Welcome message dengan email user
- Stats card dengan icon
- Logout functionality
- UI yang konsisten

## 🔐 Autentikasi

Menggunakan Firebase Authentication dengan:
- Email/password authentication
- Error handling yang komprehensif
- State management yang proper
- Secure logout

## 📱 Widget Reusable

### CustomTextField
```dart
CustomTextField(
  label: 'EMAIL',
  hintText: 'Enter your email',
  controller: emailController,
  validator: Validators.validateEmail,
)
```

### CustomButton
```dart
CustomButton(
  text: 'Login',
  onPressed: () => handleLogin(),
  isLoading: isLoading,
)
```

### AppLogo
```dart
AppLogo(size: 100)
```

## 🔍 Validasi

Utility class untuk validasi:
- Email format
- Password length
- Required fields
- Password confirmation

## 🚀 Cara Penggunaan

1. Clone project
2. Run `flutter pub get`
3. Setup Firebase (firebase_options.dart)
4. Run `flutter run`

## 📚 Dependencies

- `firebase_core`: Firebase initialization
- `firebase_auth`: Authentication
- `flutter/material.dart`: UI components

## 🎯 Best Practices

1. **Separation of Concerns**: Setiap folder memiliki tanggung jawab spesifik
2. **Reusable Components**: Widget yang dapat dipakai berulang
3. **Consistent Theming**: Warna dan style yang konsisten
4. **Proper Error Handling**: Error handling di setiap level
5. **Form Validation**: Validasi input yang komprehensif
6. **State Management**: Proper handling state loading dan error