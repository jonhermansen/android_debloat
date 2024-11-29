# How to use (macOS 15.1.1)

1. [Install Homebrew, so that we can install additional prerequisites](https://docs.brew.sh/Installation)
```sh
brew doctor || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
```
2. [Install ADB](https://developer.android.com/tools/adb)
```sh
brew install android-platform-tools
```
3. Connect and pair with Android device
```sh
adb connect 192.168.1.101
```
4. On the Android device, check the box to 'Always allow pairing from this device' and click Allow
5. Ensure that Android device is connected
```sh
adb devices | grep 'device$'
```
6. Run it!
```sh
git clone https://github.com/jonhermansen/android_debloat
cd android_debloat
./debloat.sh
```

