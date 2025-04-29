# Cavacham - Crystal E-Commerce App

Cavacham is a modern iOS e-commerce application specializing in crystals and spiritual items. Built with SwiftUI and Firebase, it offers a seamless shopping experience with a beautiful, intuitive interface.

## Features

### User Authentication
- Email & Password sign-in
- Guest browsing capability
- User profile management
- Secure authentication flow

### Product Management
- Featured products showcase
- Category-based browsing
- New arrivals section
- Popular products listing
- Detailed product views with descriptions and images

### Shopping Experience
- Intuitive cart management
- Wishlist functionality
- Order tracking
- Multiple shipping address support
- Secure checkout process

### Categories
- Raw crystals
- Jewelry
- Home decor
- Spiritual items
- Easy category navigation

### User Profile
- Order history
- Address management
- Wishlist management
- Personal information settings

## Technical Stack

### Frontend
- SwiftUI
- MVVM Architecture
- Async/await for concurrency
- Custom UI components

### Backend
- Firebase
- Firestore Database
- Firebase Authentication
- Firebase Storage

## Project Structure

```
Cavacham/
├── Views/              # All SwiftUI views
├── Components/         # Reusable UI components
├── ViewModels/        # MVVM view models
├── Models/            # Data models
├── Services/          # Firebase and other services
├── Utilities/         # Helper functions and extensions
├── Design/            # Design system and theme
└── Assets.xcassets/   # Images and resources
```

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+
- CocoaPods or Swift Package Manager
- Firebase account and configuration

## Setup Instructions

1. Clone the repository:
```bash
git clone [repository-url]
cd Cavacham
```

2. Install dependencies:
```bash
pod install
# or if using SPM, open in Xcode and wait for package resolution
```

3. Configure Firebase:
- Add your `GoogleService-Info.plist` to the project
- Enable necessary Firebase services (Authentication, Firestore, Storage)

4. Open the project:
```bash
open Cavacham.xcworkspace
# or if using SPM, open Cavacham.xcodeproj
```

5. Build and run the project

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture:

- **Models**: Define the data structure
- **Views**: Handle the UI and user interactions
- **ViewModels**: Manage business logic and data operations
- **Services**: Handle external communications and data persistence

## Key Components

### Views
- `HomeView`: Main product discovery
- `CategoryView`: Category-based browsing
- `ProductDetailView`: Detailed product information
- `CartView`: Shopping cart management
- `UserProfileView`: User settings and information

### ViewModels
- `HomeViewModel`: Manages featured products and categories
- `ProductViewModel`: Handles product data and operations
- `CartViewModel`: Manages shopping cart operations
- `AuthViewModel`: Handles authentication flow
- `UserProfileViewModel`: Manages user data and settings

## Firebase Structure

### Collections
- `users`: User profiles and settings
- `products`: Product information
- `categories`: Product categories
- `orders`: Order information
- `cart`: Shopping cart data
- `addresses`: User shipping addresses

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For any queries or support, please contact:
- Email: [contact@cavacham.com](mailto:contact@cavacham.com)

## Acknowledgments

- SwiftUI for the modern UI framework
- Firebase for backend services
- All contributors who have helped shape this project
