# Perun

## About

Framework for building server APIs with zig.

## Usage

### Initialisate

* Create a "my-perun-project" subdirectory with all battaries included 
`perun i my-perun-project -c c`
* Create files without creating new directory with minimal configurations
`perun i -t -c m`

### Start

* Starts the server with debugger and guards being off
`perun s -d -g`
* Starts the server with env at "./prod.env" over env path in main.zig
`perun i -e ./prod.env`

### Build

* Will build and run with "-Doptimize=ReleaseFast" flag
`perun b -r -d rf`