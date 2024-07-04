#!/bin/sh

# GPIO mapping has to be adapted with HW
GPIO_CHIP=gpiochip0
GPIO_PIN_SX1302_RESET=17     # SX1302 reset
GPIO_PIN_SX1302_POWER_EN=18  # SX1302 power enable
GPIO_PIN_SX1261_RESET=5     # SX1261 reset (LBT / Spectral Scan)
GPIO_PIN_AD5338R_RESET=13    # AD5338R reset (full-duplex CN490 reference design)

# 100ms duration gpioset
GPIOSET="gpioset -m time -u 100000 $GPIO_CHIP"

# Check if gpioset is available
if ! command -v gpioset > /dev/null 2>&1; then
    echo "gpiod tools are not installed. Please install them first."

fi

init() {
    echo "CoreCell power enable on through GPIO$GPIO_PIN_SX1302_POWER_EN..."
    $GPIOSET $GPIO_PIN_SX1302_POWER_EN=1 2>/dev/null
}

reset() {
    echo "CoreCell reset through GPIO$GPIO_PIN_SX1302_RESET..."
    $GPIOSET $GPIO_PIN_SX1302_RESET=1 2>/dev/null
    $GPIOSET $GPIO_PIN_SX1302_RESET=0 2>/dev/null

    echo "SX1261 reset through GPIO$GPIO_PIN_SX1261_RESET..."
    $GPIOSET $GPIO_PIN_SX1261_RESET=0 2>/dev/null
    $GPIOSET $GPIO_PIN_SX1261_RESET=1 2>/dev/null

    echo "CoreCell ADC reset through GPIO$GPIO_PIN_AD5338R_RESET..."
    $GPIOSET $GPIO_PIN_AD5338R_RESET=0 2>/dev/null
    $GPIOSET $GPIO_PIN_AD5338R_RESET=1 2>/dev/null
}

term() {
    echo "CoreCell power enable off through GPIO$GPIO_PIN_SX1302_POWER_EN..."
    $GPIOSET $GPIO_PIN_SX1302_POWER_EN=0 2>/dev/null
}

case "$1" in
    start)
    init
    reset
    ;;
    stop)
    reset
    term
    ;;
    *)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac

exit 0