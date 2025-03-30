# Get Started

Follow these steps to set up and run the project.

<h1> Step 1: Generate the Base URL </h1>

Before starting the server, generate the base URL for the application. This will determine the local network IP address needed for API communication.

<code> npm run generate:base_url </code>

This will create a configuration file containing the generated IP address.

<h1> Step 2: Install Server Dependencies </h1>

Navigate to the __server__ directory and install the necessary dependencies:

<code> npm run install </code>

This ensures all required Node.js packages are installed.

<h1> Step 3: Start the Server </h1>

Run the server to enable backend functionality:

<code> npm run start:server </code>

This will initialize the backend and make the API available.

<h1> Step 4: Run the Flutter App </h1>

Once the server is running, start the Flutter application:

<code> flutter run </code>

This will launch the mobile app and connect it to the backend.

Notes:

Ensure you have Node.js and Flutter SDK installed.

The server must be running before launching the Flutter app.

If you encounter issues, check the logs and verify dependencies are installed correctly.

