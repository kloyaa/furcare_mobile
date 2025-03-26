const os = require('os');
const fs = require('fs');
const path = require('path');

function getLocalIPAddress() {
    // Get all network interfaces
    const networkInterfaces = os.networkInterfaces();

    // Iterate through interfaces to find a suitable IP
    for (const interfaceName in networkInterfaces) {
        const interfaces = networkInterfaces[interfaceName];

        for (const face of interfaces) {
            // Skip loopback and non-IPv4 addresses
            if (!face.internal && face.family === 'IPv4') {
                return face.address;
            }
        }
    }

    // Fallback to localhost
    return '127.0.0.1';
}

function generateDartConfig(ip) {
    const dartConfig = `
// AUTO-GENERATED FILE - DO NOT EDIT MANUALLY
class AppConfig {
  static const String baseUrl = 'http://${ip}:3432/api';
}
`;

    // Ensure the directory exists
    const configDir = path.resolve(__dirname, '../lib/core/config');
    fs.mkdirSync(configDir, { recursive: true });

    // Write the Dart configuration file
    const configPath = path.resolve(configDir, 'base_url_config.dart');
    fs.writeFileSync(configPath, dartConfig);

    console.log(`Generated base URL: http://${ip}:3432/api`);
    console.log(`Configuration saved to: ${configPath}`);
}

function main() {
    try {
        // Get the local IP address
        const localIp = getLocalIPAddress();

        // Generate the Dart configuration file
        generateDartConfig(localIp);
    } catch (error) {
        console.error('Error generating base URL configuration:', error);
    }
}

// Run the script
main();