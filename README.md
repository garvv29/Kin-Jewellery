# Kin - Elegant Jewellery Ordering Application

A feature-rich Flutter application for ordering exquisite jewellery with integrated payment gateway, user authentication, and analytics.

## Features

### 🔐 Authentication
- **Google Sign-In** using Firebase Authentication
- User profile picture and name fetching
- Secure logout functionality
- Profile management

### 💎 Product Management
- Browse jewellery items from FakeStore API
- Detailed product pages with images and descriptions
- Star ratings and customer reviews
- Product search and filtering
- Horizontal and vertical scrollable product lists

### 🛒 Shopping Cart
- Add/Remove products from cart
- Adjust quantities
- Real-time cart updates with badge count
- Persistent cart storage using SharedPreferences
- Subtotal, tax, and total calculations (8% tax)

### 📊 Sales Analytics
- Beautiful bar charts showing product sales
- Sales overview on the home page
- Historical order data visualization
- Real-time sales metrics

### 💳 Payment Integration
- **Razorpay** payment gateway (test mode ready)
- Support for cards, UPI, wallets, and bank transfers
- Order confirmation after successful payment
- Payment failure handling

### 👤 User Profile
- Display user information from Google account
- Profile photo management
- Order history (coming soon)
- Settings and preferences
- Help & Support section

### 🎨 UI/UX
- Minimal and elegant design
- Gold (#D4AF37) and dark theme (#2C2C2C)
- Responsive layouts
- Smooth animations
- Clean card-based product display
- Professional splash screen

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
│   ├── product_model.dart
│   ├── cart_model.dart
│   └── order_model.dart
├── services/                 # Business logic
│   ├── product_service.dart
│   ├── cart_service.dart
│   ├── order_service.dart
│   └── auth_service.dart
├── controllers/              # GetX state management
│   ├── product_controller.dart
│   ├── cart_controller.dart
│   └── auth_controller.dart
├── screens/                  # UI Screens
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── product_detail_screen.dart
│   ├── cart_screen.dart
│   ├── checkout_screen.dart
│   └── profile_screen.dart
└── widgets/                  # Reusable components
    └── product_card.dart
```

## Technologies Used

- **Flutter**: Cross-platform mobile framework
- **Firebase**: Authentication and backend services
- **GetX**: State management
- **Razorpay**: Payment gateway integration
- **Fl_Chart**: Data visualization
- **SharedPreferences**: Local data persistence
- **HTTP**: API calls
- **Google Sign-In**: OAuth authentication

## Setup Instructions

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio or VS Code
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository_url>
   cd Kin
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Download `google-services.json` from Firebase Console
   - Place it in `android/app/`
   - Download `GoogleService-Info.plist` for iOS
   - Place it in `ios/Runner/`

4. **Firebase Setup**
   - Create a Firebase project at https://console.firebase.google.com
   - Add Android app with package name `com.example.kin`
   - Enable Google Sign-In in Firebase Authentication
   - Add the Web Client ID: `804464780497-mert1d3i9bcvvd9ur0gk8jd6dc7q5lb7.apps.googleusercontent.com`

5. **Run the app**
   ```bash
   flutter run
   ```

## Firebase Configuration

### Key Details
- **Project ID**: jewellery-6d3a4
- **Web Client ID**: 804464780497-mert1d3i9bcvvd9ur0gk8jd6dc7q5lb7.apps.googleusercontent.com
- **App Name**: Kin

### Required Firebase Services
1. Authentication (Google Sign-In)
2. Firestore Database (optional for future features)
3. Storage (for user profile images)

## API Integration

### Product API
- **Source**: FakeStore API (https://fakestoreapi.com)
- **Endpoint**: https://fakestoreapi.com/products/category/jewelery
- **No API key required**
- **Data cached locally** using SharedPreferences

## Payment Integration

### Razorpay Setup
1. Get your Razorpay API keys from https://dashboard.razorpay.com
2. Update the test key in `checkout_screen.dart`:
   ```dart
   'key': 'rzp_test_YOUR_KEY_HERE',
   ```

### Test Credentials
- Test mode is active by default
- Use test credit cards for testing
- Razorpay provides sample card numbers for testing

## Features Implementation

### Google Sign-In Flow
```
Login Screen → Google Sign-In → Firebase Auth → Home Screen
```

### Cart Functionality
```
Product List → Add to Cart → Cart Screen → Checkout → Payment → Confirmation
```

### Sales Analytics
```
Orders (Local Storage) → Sales Data → Bar Chart Visualization
```

## State Management (GetX)

### Controllers
- **ProductController**: Manages product fetching and caching
- **CartController**: Handles cart operations
- **AuthController**: Manages user authentication

### Reactive Variables
- `products.obs`: Observable product list
- `cartItems.obs`: Observable cart items
- `currentUser.obs`: Observable user data

## Local Storage

### SharedPreferences Keys
- `cart_items`: Store cart data as JSON
- `orders`: Store order history
- `user_id`: Cached user ID
- `user_name`: Cached user name
- `user_email`: Cached user email
- `user_photo_url`: Cached profile photo

## UI Components

### Product Card
- Product image with error handling
- Rating badge (top-left corner)
- Product name and price
- Add to cart button
- Shadow and border radius effects

### Sales Chart
- Bar chart showing quantity sold per product
- X-axis: Product names
- Y-axis: Quantity count
- Golden color theme (#D4AF37)

## Error Handling

- Network error handling with user-friendly messages
- Image loading errors with placeholder icons
- Payment failure handling with retry options
- API timeout handling (10 seconds)

## Testing

### Manual Testing Checklist
- [ ] Google Sign-In functionality
- [ ] Product fetching from API
- [ ] Add/Remove cart items
- [ ] Quantity updates
- [ ] Cart calculations
- [ ] Payment gateway integration
- [ ] Order persistence
- [ ] Profile page navigation
- [ ] Logout functionality
- [ ] Sales chart rendering

## Future Enhancements

- [ ] Order history on profile
- [ ] Wishlist functionality
- [ ] Product filtering and search
- [ ] User reviews and ratings
- [ ] Push notifications
- [ ] Multiple payment methods
- [ ] Admin dashboard
- [ ] Analytics reports

## Troubleshooting

### Issue: Firebase Initialization Error
**Solution**: Ensure `google-services.json` is in the correct location and Firebase project is properly configured.

### Issue: Google Sign-In Fails
**Solution**: Verify Web Client ID is correct and added to Firebase console.

### Issue: Razorpay Payment Gateway Not Opening
**Solution**: Check internet connection and verify Razorpay test key.

### Issue: Products Not Loading
**Solution**: Check internet connection and ensure FakeStore API is accessible.

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## License

This project is licensed under the MIT License - see LICENSE file for details.

## Contact & Support

- **Email**: s4mbh4v@gmail.com
- **Support**: Available in app via Help & Support section

## Screenshots

### Screens Included:
1. **Splash Screen**: Animated loading with Kin branding
2. **Login Screen**: Google Sign-In integration
3. **Home Screen**: Product listing with sales analytics
4. **Product Detail**: Comprehensive product information
5. **Cart Screen**: Shopping cart management
6. **Checkout**: Payment gateway integration
7. **Profile Screen**: User profile and settings

## Code Quality

- **State Management**: GetX for reactive state
- **Error Handling**: Comprehensive try-catch blocks
- **Code Organization**: Feature-based folder structure
- **Documentation**: Inline comments for complex logic
- **UI Consistency**: Unified color scheme and typography

---

**Made with ❤️ for elegant shopping experiences**

Version: 1.0.0
Last Updated: November 2025
#   K i n - J e w e l l e r y  
 