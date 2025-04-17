# Flutter User Directory App

A Flutter application that fetches user data from an API and displays it in a custom ListView with search and pagination functionality.

## Features

- **API Integration**: Fetches user data from `https://reqres.in/api/users`
- **Pagination**: Navigate between pages of user data with an intuitive pagination interface
- **Search Functionality**: Filter users by first name in real-time
- **Responsive UI**: Modern Material Design with both light and dark mode support
- **Detailed User View**: View detailed information about each user
- **Error Handling**: Graceful handling of network issues and empty states

## Getting Started

### Prerequisites

- Flutter SDK (2.0.0 or higher)
- Dart SDK (2.12.0 or higher)
- Android Studio / VS Code with Flutter extensions
- An Android or iOS device/emulator

### Installation

1. Clone this repository:
   ```
   git clone https://github.com/[your-username]/flutter-user-directory.git
   ```

2. Navigate to the project directory:
   ```
   cd flutter-user-directory
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## Project Structure

- `main.dart`: Entry point of the application, contains the main app widget
- `user_list_screen.dart`: Screen that displays the list of users with search and pagination
- `user_card.dart`: Widget for displaying individual user information

## Dependencies

- `flutter`: The Flutter SDK
- `http`: For making API requests
- `cupertino_icons`: Default icons used by Flutter

## API Details

This app uses the [Reqres.in](https://reqres.in/) API to fetch user data:

- Endpoint: `https://reqres.in/api/users?page={page_number}`
- Response format:
  ```json
  {
    "page": 2,
    "per_page": 6,
    "total": 12,
    "total_pages": 2,
    "data": [
      {
        "id": 7,
        "email": "michael.lawson@reqres.in",
        "first_name": "Michael",
        "last_name": "Lawson",
        "avatar": "https://reqres.in/img/faces/7-image.jpg"
      },
      ...
    ],
    "support": {
      "url": "...",
      "text": "..."
    }
  }
  ```

## Features in Detail

### User List
- Displays user ID, first name, last name, email, and avatar
- Tapping on a user card shows more details in a bottom sheet

### Search Functionality
- Real-time filtering as you type
- Searches by first name
- Visual feedback when no results are found

### Pagination
- Navigate between pages using page number buttons
- Previous and next buttons for sequential navigation
- Visual indication of current page
- Displays count of users being shown

## Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Reqres.in](https://reqres.in/) for providing the API
- Flutter team for the amazing framework
