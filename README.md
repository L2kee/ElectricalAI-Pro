# ⚡ ElectricalAI Pro

> **An AI-powered assistant and professional toolkit for electricians.**

ElectricalAI Pro is a modern application designed to help electricians work faster and more accurately. It combines artificial intelligence with built-in electrical calculators to provide a powerful tool for troubleshooting, calculations, and project assistance.

This project is currently under active development.

---

# Current Features

## 🤖 AI Assistant

- Ask electrical questions
- Troubleshooting assistance
- Electrical theory explanations
- Material recommendations
- Learning support for apprentices

## ⚡ Electrical Calculators

### ✅ Completed

- Ohm's Law Calculator
- Voltage Drop Calculator
- Conduit Fill Calculator

### 🚧 In Progress

- Box Fill Calculator
- Wire Ampacity Calculator
- Material List Generator

---

# Technology Stack

## Backend

- Python 3
- FastAPI
- Uvicorn

## Artificial Intelligence

- Google Diffusion Gemma 26B
- NVIDIA Build API

## Development Tools

- Git
- GitHub
- Visual Studio Code

---

# Project Structure

```
ElectricalAI-Pro/
│
├── backend/
│   ├── ai/
│   ├── api/
│   ├── calculators/
│   ├── database/
│   ├── models/
│   ├── services/
│   ├── tests/
│   ├── requirements.txt
│   └── main.py
│
├── docs/
├── screenshots/
├── .env
├── .gitignore
└── README.md
```

---

# Installation

## 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/ElectricalAI-Pro.git
```

---

## 2. Enter the project

```bash
cd ElectricalAI-Pro
```

---

## 3. Create a virtual environment

```bash
python -m venv venv
```

---

## 4. Activate the virtual environment

### Windows

```bash
venv\Scripts\activate
```

---

## 5. Install dependencies

```bash
pip install -r backend/requirements.txt
```

---

## 6. Create a .env file

Example:

```env
NVIDIA_API_KEY=your_api_key_here
```

---

## 7. Start the backend

```bash
uvicorn backend.api.server:app --reload
```

---

## 8. Open Swagger

Open your browser and visit:

```
http://127.0.0.1:8000/docs
```

---

# Screenshots

Coming soon.

The following screenshots will be added during development:

- Home Screen
- AI Chat
- Electrical Calculators
- Swagger API
- Mobile Application

---

# Development Roadmap

## ✅ Completed

- Project architecture
- FastAPI backend
- AI Chat API
- Google Diffusion Gemma integration
- Ohm's Law Calculator
- Voltage Drop Calculator
- Conduit Fill Calculator

---

## 🚧 Version 1

- Box Fill Calculator
- Wire Ampacity Calculator
- Material List Generator
- Flutter Mobile Application
- Android Build
- iPhone Build
- Windows Desktop Build
- Version 1 Beta

---

# Project Goals

ElectricalAI Pro is being developed to become a practical everyday tool for electricians.

The primary goals are:

- Save time on calculations
- Improve troubleshooting
- Reduce jobsite errors
- Provide fast AI assistance
- Offer a professional mobile experience

---

# License

Copyright © 2026 ElectricalAI Pro

This project is currently under active development.