import asyncio
import websockets

# Set of connected WebSocket clients
clients = set()

async def register_client(websocket):
    clients.add(websocket)

async def unregister_client(websocket):
    clients.remove(websocket)

async def handle_websocket(websocket, path):
    # Register client
    await register_client(websocket)
    try:
        async for message in websocket:
            # Here, you could handle incoming messages if needed
            print(f"Received message from client: {message}")
    finally:
        # Unregister client
        await unregister_client(websocket)

async def handle_input():
    while True:
        # Read command from CLI
        command = input("Enter a command to send: ")
        # Send command to all connected clients
        for client in clients:
            await client.send(command)

async def main():
    # Start WebSocket server
    start_server = websockets.serve(handle_websocket, "localhost", 8765)
    await start_server
    
    # Run CLI input handling concurrently
    await handle_input()

# Run the server and input handling concurrently
asyncio.run(main())
