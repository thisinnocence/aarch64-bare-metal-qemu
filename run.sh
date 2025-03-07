#!/bin/bash

~/github/qemu/build/qemu-system-aarch64 \
    -nographic \
    -M virt \
    -cpu cortex-a57 \
    -kernel test64.elf