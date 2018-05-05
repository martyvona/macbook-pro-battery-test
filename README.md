# MacBook Pro Battery Life Test

This repository contains a simple test script for battery life testing on OS X and Linux.  This is based on the [original](https://github.com/geerlingguy/macbook-pro-battery-test) by geerlingguy at the time of this writing geerlingguy's version requires Vagrant and VirtualBox and requires an internet connection.

This version has no dependencies and does not require an internet connection.  It uses [yes](http://osxdaily.com/2012/10/02/stress-test-mac-cpu) commands to stress the CPU, running N copies in parallel where N is the number of CPU cores on your machine.

## Usage

### Before running the test script

  1. **Disable Sleep**: Go to System Preferences > Energy Saver, click on the 'Battery' tab, and drag the 'Turn display off after' slider all the way to 'Never' (alternatively, you could run `caffeinate` in a separate Terminal window).
  2. **Disable Screen Saver**: Open System Preferences > Desktop & Screen Saver, then set the Screen Saver to 'Start after: Never'.
  3. **Turn up brightness**: For consistency's sake, turn up your screen brightness all the way (after the AC power has been disconnected).
  4. **Quit all other Applications**: To make it a fair comparison.

### Run the test script

  1. **Download project**: Download this project to your computer (either download through GitHub or clone it with Git). _Important Note_: Don't download the project in a 'cloud' directory (e.g. inside Dropbox, Google Drive, or a folder synced via iCloud).
  2. **Open Terminal (full screen)**: Open Terminal.app and put it in full screen mode (so the actual pixels displayed is identical from laptop-to-laptop).
  3. **Run Script**: Change into this project's directory (`cd path/to/macbook-pro-battery-test`). Run `./battery-test.sh`, and then walk away for a few hours.

After your Mac forces a sleep (when the battery has run out), plug it back in, then check the most recent file in `results/` in the project directory.

## Results

Results are written to a date-and-timestamped file inside the `results` folder. This file is in CSV format, so you can open it in Excel, Numbers, Google Sheets, or any other CSV-compatible program and graph the results as needed.

The results file has the following structure (as an example):

| Counter | Time                | Battery Percentage |
| ------- | ------------------- | ------------------ |
| 0       | 2017-01-07 15:58:40 | 100%               |
| 0       | 2017-01-07 16:10:48 | 98%                |
| 0       | 2017-01-07 16:17:22 | 94%                |
| ...     | ...                 | ...                |

## Author

The original version of this script was created by [Jeff Geerling](http://www.jeffgeerling.com) to run some more formal battery tests on the 2016 Retina MacBook Pro—both with and without Touch Bar—and to see if battery life and performance between the two models (under heavier load) was much different.

This version was adapted by Marty Vona to use a simple `yes` stress test with no dependencies.
