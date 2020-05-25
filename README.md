# environ-monitor
Runs on a Raspberry Pi, scrapes data from an environmental monitor and presents it as a scrape target.

# Running

1. `sudo apt install wiringpi`
2. `gpio readall`
3. `sudo apt install i2c-tools`
4. `sudo raspi-config`
5. `i2cdetect -y 1`
