#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting RISC-V Toolchain and Simulator Installation..."

# Ubuntu / Debian / Windows Subsystem for Linux (WSL)
if [ -f "/etc/debian_version" ]; then
    echo "Detected Ubuntu / Debian / WSL environment."
    echo "Updating package lists..."
    sudo apt-get update

    echo "Installing RISC-V GNU Toolchain..."
    # gcc-riscv64-unknown-elf includes the compiler and binutils (objcopy, as, ld)
    sudo apt-get install -y gcc-riscv64-unknown-elf 

    echo "Installing Simulation Tools (Icarus Verilog, GTKWave, Make)..."
    sudo apt-get install -y iverilog gtkwave make

    echo "Installation complete!"

# macOS (using Homebrew)
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS environment."
    
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        echo "Error: Homebrew is required but not installed."
        echo "Install it from https://brew.sh/ and run this script again."
        exit 1
    fi

    echo "Tapping RISC-V Homebrew repository..."
    brew tap riscv/riscv

    echo "Installing RISC-V GNU Toolchain..."
    brew install riscv-gnu-toolchain

    echo "Installing Simulation Tools..."
    brew install icarus-verilog gtkwave

    echo "Installation complete!"

# Unsupported / Other OS
else
    echo "Unsupported Operating System."
    echo "Please download the pre-compiled binaries manually from:"
    echo "https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases"
fi

# Verify the installation by checking the gcc version
echo "----------------------------------------"
echo "Verifying installation:"
riscv64-unknown-elf-gcc --version | head -n 1
