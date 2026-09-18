# Changelog

All notable changes to **ElectricalAI Pro** will be documented in this file.

This project follows the principles of **Keep a Changelog**, with entries organized by release version to provide a clear history of new features, improvements, and fixes.

---

# [Unreleased]

## Added

- Motor Full-Load Current calculator: single- and three-phase FLC lookup by
  horsepower and system voltage, plus the 125% minimum branch-circuit
  conductor ampacity, in both Dart (on-device) and the FastAPI backend
  (`POST /motor-flc`)
- Transformer Sizing calculator: primary/secondary full-load amperes from
  rated kVA and voltage for single- and three-phase transformers, in both
  Dart (on-device) and the FastAPI backend (`POST /transformer-sizing`)

---

# [1.0.1] - 2026-08-28

Foundation pass: calculators that match field workflow, offline math in the
UI, a backend that can fail cleanly, and a Windows packaging path that
includes the API instead of only the Flutter shell.

## Added

- Voltage drop from wire size, material, one-way length, load, voltage, and 1φ/3φ
- Box fill counts for device yokes, internal clamps, and equipment grounds
- Conduit fill from EMT / PVC-40 / RMC trade size and THHN conductor count
- Copper and aluminum ampacity, plus typical small-conductor OCPD notes
- Circuit load continuous 125% and next standard breaker size
- In-app planning-aid disclaimer (toggled by Settings → Enable hints)
- Chat conversation history and structured material lists
- Backend and Flutter unit tests for every calculator
- `.env.example` and a `/health` endpoint

## Changed

- Calculators run in Dart on the device; FastAPI mirrors the same math
- Invalid calculator input now returns HTTP 400 instead of 200 + `error`
- NVIDIA chat uses a chat/instruct model at temperature 0.3
- `requirements.txt` is UTF-8 and lists only packages the API needs
- Installer and `build_release.py` ship launcher + backend + UI together
- Installer binaries are no longer committed

## Fixed

- Divide-by-zero and non-positive values in Ohm's law and circuit load
- Widget test looking for a title string the home screen does not show
- Settings “Enable hints” had no effect on the UI
- Prototype `app.py` left in the repo root

---

# [1.0.0] - 2026-07-17

## 🎉 Initial Public Release

Version **1.0.0** marks the first official release of ElectricalAI Pro.

This release establishes the foundation of the application by combining artificial intelligence, electrical calculators, and modern desktop technologies into a single Windows application designed for electricians, apprentices, students, and electrical professionals.

---

## ✨ Added

### 🤖 AI Assistant

- Integrated AI-powered Electrical Assistant
- Natural language electrical questions and answers
- NVIDIA Build API integration
- FastAPI backend communication

---

### ⚡ Electrical Calculators

Added six professional electrical calculators:

- Ohm's Law Calculator
- Voltage Drop Calculator
- Wire Ampacity Calculator
- Box Fill Calculator
- Conduit Fill Calculator
- Circuit Load Calculator

---

### 📋 Productivity

- Material Lists
- Persistent application settings
- Local preference storage
- Improved navigation

---

### 🖥️ Desktop Application

- Windows desktop application built with Flutter
- Responsive user interface
- Modern Material Design interface
- Multi-screen navigation

---

### 🔧 Backend

- FastAPI REST API
- Modular backend architecture
- Calculator API endpoints
- AI service integration
- Swagger API documentation

---

### 📚 Documentation

- Professional README
- Custom ElectricalAI Pro License
- Changelog
- Architecture documentation
- Installation guide
- Project roadmap

---

## 🚀 Improved

- Overall application architecture
- Modular code organization
- User interface consistency
- Error handling
- Calculator validation
- Backend communication
- API organization
- Project documentation

---

## 🐞 Fixed

- Calculator integration issues
- REST API communication
- Settings persistence
- Navigation improvements
- Various UI inconsistencies
- Backend startup improvements

---

## ⚠️ Known Limitations

Version 1.0.0 currently includes the following limitations:

- Windows desktop only
- Internet connection required for AI Assistant
- Mobile applications not yet available
- Material Lists provide foundational functionality only
- AI responses should always be verified against applicable electrical codes and local regulations

---

## 🔮 Planned for Future Releases

The following features are currently planned for future versions of ElectricalAI Pro:

- Android application
- iPhone (iOS) application
- Additional electrical calculators
- Saved calculations
- Favorites
- Project management tools
- PDF analysis improvements
- Cloud synchronization
- User accounts
- Team collaboration
- Expanded AI capabilities

---

## ❤️ Thank You

Thank you to everyone who has supported the development of ElectricalAI Pro.

Version **1.0.0** represents the completion of the first major milestone in a project that will continue evolving with new features, improvements, and expanded platform support.