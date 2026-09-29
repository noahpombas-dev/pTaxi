# Taxi Script for ESX and QBCore

A simple taxi system for FiveM servers using ESX or QBCore.

Players can call a taxi, set a destination, and ride to their waypoint. The taxi will wait for the player to enter before starting the journey.

## Features

* Call a taxi using `/callTaxi`
* Taxi spawns on the nearest road
* Set a destination using a map waypoint
* Taxi automatically drives to the destination
* Player is charged the full fare, even if they leave early
* Supports both ESX and QBCore

## Installation

### 1. Download

Download the repository and place it inside your server's `resources` folder.

### 2. Choose Your Framework

Use the version that matches your server:

* `esx/` - ESX
* `qbcore/` - QBCore

Place the selected folder in your `resources` directory.

### 3. Add to server.cfg

For ESX:

```cfg
ensure pTaxi-esx
```

For QBCore:

```cfg
ensure pTaxi-qbcore
```

### 4. Restart Your Server

Restart your server or resource to load the taxi script.

## Usage

1. Use `/callTaxi` to call a taxi.
2. Wait for the taxi to arrive.
3. Enter the taxi.
4. Set a waypoint on the map.
5. The taxi will drive to your destination.
6. You will be charged the fare after the ride.

## Configuration

Each version includes a `config.lua` where you can change settings such as:

* Taxi fare
* Vehicle model
* Wait times
* Other taxi settings

## Dependencies

### ESX

Requires ESX.

### QBCore

Requires QBCore.

## Known Issues

* Make sure a waypoint is set correctly.
* Some vehicle models may behave differently.
* If the taxi does not drive correctly, try changing the vehicle model in `config.lua`.

## License

This script is licensed under the MIT License.

Feel free to modify and share the script.
