#!/usr/bin/env python
import asyncio
import websockets

async def echo(websocket, path):
    while True:
        command = input("$ ")
        await websocket.send(command)

async def main():
    async with websockets.serve(echo, "192.168.1.176", 8765):
        await asyncio.Future()  # run forever

asyncio.run(main())
