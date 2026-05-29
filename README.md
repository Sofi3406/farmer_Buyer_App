# FarmConnect Marketplace

FarmConnect is a farmer-to-buyer marketplace with a Flutter client and a Node.js/Express backend. Buyers can browse products, place orders, upload payment receipts, and track delivery status. Farmers can create products, view incoming orders, and see buyer receipts for verification.

## Repository Structure

```text
farmer_Buyer_App/
	farmer_buyer_marketplace/   # Flutter app
	farmer_marketplace_backend/  # Express + MongoDB API
```

## Features

- Buyer and farmer authentication with role-based screens
- Product listing, cart, and checkout flow
- Order placement with delivery address and receipt upload
- Farmer order management with status updates
- Receipt image preview for farmers
- Product image upload support
- MongoDB-backed persistence

## Tech Stack

- Flutter
- Provider
- GoRouter
- Node.js
- Express
- MongoDB
- Mongoose
- Multer

## Prerequisites

- Flutter SDK
- Node.js 18+
- MongoDB running locally or a MongoDB Atlas connection string

## Setup

### 1. Backend

Change into the backend folder:

```bash
cd farmer_marketplace_backend
```

Install dependencies:

```bash
npm install
```

Create a `.env` file if needed:

```env
PORT=3000
MONGODB_URI=mongodb://localhost:27017/farmer_marketplace
```

Start the API:

```bash
npm run dev
```

The backend exposes routes under `/api`, for example:

- `/api/auth`
- `/api/products`
- `/api/orders`
- `/api/users`
- `/api/upload`

### 2. Flutter App

Change into the Flutter app folder:

```bash
cd farmer_buyer_marketplace
```

Install packages:

```bash
flutter pub get
```

The app points to the backend using `API_BASE_URL`. For local development, keep it aligned with the backend port:

```env
API_BASE_URL=http://10.0.2.2:3000/api
```

If you run on web or desktop, the app falls back to `http://localhost:3000/api` unless `API_BASE_URL` is overridden at build time.

Run the app:

```bash
flutter run
```

## Notes

- Buyers must upload a receipt image during checkout.
- Farmers can view the uploaded receipt from the orders screen.
- Product payment details are stored with each product and shown at checkout.
- If the app cannot reach the API, verify the backend is running, MongoDB is connected, and the port matches the Flutter base URL.

## Useful Commands

```bash
# Backend
npm run dev

# Flutter
flutter pub get
flutter run
```

## License

No license has been specified yet.