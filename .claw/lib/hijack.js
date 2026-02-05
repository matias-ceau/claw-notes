/**
 * Android Compatibility Shim for Node.js
 *
 * Problem: Android kernel blocks os.networkInterfaces() on non-rooted devices,
 * causing "System Error 13" when Node.js applications try to enumerate network
 * interfaces.
 *
 * Solution: Mock the os.networkInterfaces() function to return an empty object.
 *
 * Usage:
 *   node -r /path/to/hijack.js your-script.js
 *
 * For OpenClaw:
 *   node -r ~/.openclaw/hijack.js $(which openclaw) gateway
 */

const os = require('os');

// Store original function in case needed
const originalNetworkInterfaces = os.networkInterfaces;

// Mock networkInterfaces to avoid System Error 13
os.networkInterfaces = function() {
    return {};
};

// Optional: Expose original if needed
os.networkInterfaces.original = originalNetworkInterfaces;

// Log that shim is active (comment out for production)
// console.log('[hijack.js] Android compatibility shim loaded');
