# Patify – Mobile Animal Welfare Platform

Patify is a cross-platform mobile application developed as a graduation project. It aims to connect pet owners, animal shelters, veterinary clinics, and animal lovers on a single digital platform.

## Features

- User registration and login
- Veterinary clinic and animal shelter listings
- Clinic and shelter detail pages
- Map-based discovery with Google Maps
- Veterinary appointment management
- Lost animal report creation and map display
- Profile management
- Informative pet care cards
- AI-supported assistance
- REST API integration with backend services

## Technologies

- Flutter & Dart
- Java Spring Boot
- PostgreSQL
- RESTful APIs
- JWT Authentication
- BCrypt Password Hashing
- Google Maps API
- Flyway
- Spring Data JPA

## Running the Project

### Backend

```bash
cd backend
mvn spring-boot:run

The backend runs on:

http://localhost:8080
Mobile App
flutter pub get
flutter run

For physical device testing, update the API base URL with your computer's local IP address.

Example:

const String baseUrl = "http://192.x.x.x:8080";
Project Modules
Authentication: User registration, login, and token-based access
Clinics & Shelters: Listing, detail viewing, and map display
Appointments: Appointment request and cancellation flows
Lost Animals: Lost animal report creation and location-based visibility
Profile: User profile viewing and editing
AI Assistance: Supportive pet-related information and guidance
Contributors
İrem Şimşek
Merve Nair
Sinem Söner
Status

Graduation project – actively developed and improved.

License

This project is developed for academic purposes.
