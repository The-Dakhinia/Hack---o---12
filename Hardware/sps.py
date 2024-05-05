import json
import asyncio
import websockets
import random

# Define the constant device ID for the IoT device
DEVICE_ID = "ABC123"  # Change this to the actual device ID

async def send_data():
    uri = "ws://192.168.2.72:3000"
    async with websockets.connect(uri) as websocket:
        while True:
            # Simulate inputs from the IoT device (replace this with actual input mechanism)
            # latitude = random.uniform(-90, 90)
            # longitude = random.uniform(-180, 180)
            latitude = 20.350588006464434
            longitude = 85.80648774663918
            decision_value = random.uniform(15, 25)
            
            # Create a JSON object containing the data including the device ID
            data = {
                "deviceId": DEVICE_ID,
                "location": [latitude, longitude],
                "decision_value": decision_value
            }
            
            # Send the data to the backend server
            await websocket.send(json.dumps(data))
            print("Sent data:", data)
            
            # Wait for a short duration before sending the next data
            await asyncio.sleep(5)  # Adjust the interval duration (in seconds) as needed

asyncio.run(send_data())