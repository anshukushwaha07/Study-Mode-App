# 📚 Study Mode App  

A distraction-free study environment on your Android device.  
This Flutter application helps you focus on your studies by temporarily blocking access to distracting apps of your choice.  

---

## 🌟 Key Features  

- **Dynamic App Selection**: Scans your device and displays a list of all installed applications.  
- **Custom Blocklists**: Use checkboxes to select exactly which apps you want to block during a study session.  
- **One-Tap Activation**: Easily toggle Study Mode on or off from the main screen with a single button.  
- **Effective Blocking**: When a blocked app is opened, a screen appears reminding you to get back to your studies, preventing access.  
- **Persistent Selection**: The app remembers your list of blocked apps, so you don't have to select them every time.  
- **Permissions Handling**: Guides the user to grant the necessary Android permissions for the app to function correctly.  

---

## 📸 Screenshots  

- **Main Screen (Study Mode OFF)**  
- **App Selection Screen**  
- **Main Screen (Study Mode ON)**  

### Main Screen (Study Mode OFF)
![Main Screen OFF](assets/Screenshot/2.png)

### App Selection Screen
![App Selection Screen](assets/Screenshot/4.png)

### Main Screen (Study Mode ON)
![Main Screen ON](assets/Screenshot/3.png)

---

## 🛠️ Technology Stack  

- **Framework**: Flutter  
- **Language**: Dart  
- **Platform**: Android  

**Key Packages**:  
- `device_apps`: To fetch the list of installed applications.  
- `shared_preferences`: To save the user's app selection.  

---

## 🚀 Getting Started  

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.  

### Prerequisites  
You need to have the **Flutter SDK** installed on your machine.  
For help getting started with Flutter, view the [official documentation](https://flutter.dev/docs).  

### Installation & Setup

```bash

flutter pub get

flutter run

```
