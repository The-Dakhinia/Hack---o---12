import json
import asyncio
import websockets
import random

async def send_data():
    uri = "ws://192.168.2.72:5000"
    async with websockets.connect(uri) as websocket:
        while True:
            # Simulate inputs from the IoT device (replace this with actual input mechanism)
            latitude = random.uniform(-90, 90)
            longitude = random.uniform(-180, 180)
            decision_value = random.uniform(0, 100)
            
            # Create a JSON object containing the data
            data = {
                "location": [latitude, longitude],
                "decision_value": decision_value
            }
            
            # Send the data to the backend server
            await websocket.send(json.dumps(data))
            print("Sent data:", data)
            
            # Wait for a short duration before sending the next data
            await asyncio.sleep(5)  # Adjust the interval duration (in seconds) as needed

asyncio.run(send_data())
