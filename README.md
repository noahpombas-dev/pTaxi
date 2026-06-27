
# Taxi Script for ESX and QBCore !

A simple and efficient taxi system for FiveM servers that works with both **ESX** and **QBCore** frameworks. This script allows players to call a taxi , set a waypoint, and enjoy an immersive ride. The taxi waits patiently 🕒, takes you to your destination, and ensures you pay the fare even if you decide to hop off early! 

---

## Features

- ** Call a Taxi:** Use the `/callTaxi` command to spawn a taxi on the nearest road. 🛣️
- ** Waypoint Navigation:** Set a waypoint on the map for the taxi to drive to. 🗺️
- ** Fair Pricing:** Pay the full fare, even if you exit the taxi before reaching your destination.
- ** Immersive Interaction:** The taxi waits for you to enter and starts the ride once you're inside.

---

##  Installation

### 1️⃣ Download and Extract
 Download the repository and extract the contents into your server's `resources` folder.

### 2️⃣ Choose Your Framework
The repository includes two versions:
- **`esx/`** - For servers using ESX framework.
- **`qbcore/`** - For servers using QBCore framework.

Place the respective folder in your `resources` directory.

### 3️⃣ Configure `server.cfg`
Add the appropriate script to your `server.cfg` file:
```plaintext
ensure pTaxi-esx
```
or
```plaintext
ensure pTaxi-qbcore
```

### Restart the Server
🔄 Restart your server to ensure the resource is loaded and ready to use.

---

## Usage

1. ** Call a Taxi:**  
   Use `/callTaxi` in chat to summon a taxi.  
   🛣️ The taxi spawns at the nearest road and waits for you to enter.

2. ** Set a Destination:**  
   Open your map 🗺️ and set a waypoint. The taxi will drive you to your destination. 🚗

3. ** Exit and Fare:**  
   If you exit the taxi before reaching your destination, the full fare is still charged.

---

## Configuration

- **For ESX:**  
  Edit `config.lua` in the `esx/` folder to adjust settings like:
  - Fare rates 
  - Vehicle models 
  - Wait times 

- **For QBCore:**  
  Edit `config.lua` in the `qbcore/` folder for similar settings.

---

## Dependencies

- **ESX Version:** Requires ESX framework.  
- **QBCore Version:** Requires QBCore framework.

---

## Known Issues
- Ensure that the map waypoint is set correctly, as the taxi relies on it for navigation. 🗺️
- Some vehicle models may behave differently. Adjust in `config.lua` if needed.

---

## License
This script is licensed under the **MIT License**. Feel free to modify and share! 🛠️

---


Enjoy the ride! 🚖✨
