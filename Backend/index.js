const express = require('express');
const http = require('http');
const WebSocket = require('ws');

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

const PORT = process.env.PORT || 3000;

// Store a reference to connected clients
const clients = new Set();

// Store IoT device data with unique IDs
const deviceData = {};

// WebSocket connection handler
wss.on('connection', (ws) => {
    console.log('Client connected');

    // Add the client to the set of connected clients
    clients.add(ws);

    // Handle incoming messages from clients
    ws.on('message', (message) => {
        try {
            const data = JSON.parse(message);
            console.log('Received data:', data);

            // Store the data with the device ID
            deviceData[data.deviceId] = data;

            // Broadcast all device data to all connected clients
            wss.clients.forEach((client) => {
                if (client.readyState === WebSocket.OPEN) {
                    client.send(JSON.stringify(Object.values(deviceData)));
                }
            });
        } catch (error) {
            console.error('Error parsing message:', error);
        }
    });

    // Handle WebSocket close event
    ws.on('close', () => {
        console.log('Client disconnected');
        // Remove the client from the set of connected clients
        clients.delete(ws);
    });
});

server.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
