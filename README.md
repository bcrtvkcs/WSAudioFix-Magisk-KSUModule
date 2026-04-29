# WSAudioFix Magisk & KSU Module

A Magisk / KernelSU module that eliminates the 500 ms audio session lag when resuming media playback in Windows Subsystem for Android (WSA) or on any other device on which you use this module.

> ### ⚠️ DISCLAIMER ⚠️
> **I am not responsible** for *bricked devices*, *dead SD cards*, *thermonuclear war*, or *you getting fired because the alarm app failed*. Please do some research if you have any concerns about features included in this module before flashing it. YOU are choosing to make these modifications, and if you point the finger at me for messing up your device, I will laugh at you!

## The Problem

WSA's audio bridge between Android and Windows enters a sleep state after approximately 5 minutes of audio inactivity. When media playback resumes, the bridge takes ~500 ms to reopen (`openOutputStream` latency confirmed at 516ms via AudioFlinger). This causes a noticeable stutter and audio/video desync on every cold resume. It may also benefit other virtualized Android environments (such as emulators) where the audio HAL has a high cold-start latency. On physical Android devices, the improvement is unlikely to be noticeable as hardware HAL latency is typically under 50ms.

## What It Does

On boot, the module starts a persistent background process that plays an inaudible 15Hz sine wave through `STREAM_SYSTEM` at a very low amplitude. This keeps the WSA audio bridge active at all times without interfering with media playback or system volume controls.

## How It Works

1. Waits for the device to fully boot.
2. Launches `AudioKeepalive` via `app_process` using a precompiled `.dex`.
3. `AudioKeepalive` opens an `AudioTrack` on `STREAM_SYSTEM` (48000Hz, stereo, 16-bit) and continuously writes a 15Hz sine wave buffer.
4. If the process exits for any reason, it is automatically restarted after 3 seconds.

## Installation

1. [Download the latest release](https://github.com/bcrtvkcs/WSAudioFix-Magisk-KSUModule/releases/latest/download/WSAudioFix-Magisk-KSUModule-main.zip).
2. Flash it via **Magisk**, **KernelSU**, or **KernelSU Next**.
3. Reboot.
4. Verify via: `adb shell ps -A | grep app_process` — you should see the keepalive process running.
5. You're all set!
6. If you experience any issues, please open one through the [Issues](https://github.com/bcrtvkcs/WSAudioFix-Magisk-KSUModule/issues) panel.

## Building from Source

Requirements: JDK 8+, Android SDK build-tools (for `d8`), Android SDK platform (for `android.jar`).

```bash
# Compile
javac -source 8 -target 8 -cp /path/to/android.jar src/AudioKeepalive.java

# Convert to dex
d8 --release --min-api 26 --output . AudioKeepalive.class

# Output: classes.dex → rename to audio_keepalive.dex and place in module root
```

## Uninstallation

Uninstalling the module via Magisk/KSU Manager and rebooting will automatically stop the keepalive process.

## Compatibility

- Android 8.0+
- Magisk or KernelSU or KernelSU Next
