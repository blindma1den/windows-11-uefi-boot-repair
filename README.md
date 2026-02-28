# Windows 11 UEFI Boot Repair Script

Rebuilds the Windows 11 UEFI bootloader when Automatic Repair fails and
the SSD is healthy.

This script is designed for situations where:

-   Windows drops into Automatic Repair
-   `SrtTrail.txt` appears
-   The SSD is detected in BIOS
-   `chkdsk` reports 0 bad sectors
-   `sfc /scannow` reports no integrity violations

If your hardware is fine but Windows will not boot, the issue is often a
corrupted UEFI boot configuration (BCD). This script restores it
cleanly.

------------------------------------------------------------------------

## What This Fixes

-   Corrupted BCD (Boot Configuration Data)
-   Broken UEFI boot entries
-   Systems stuck in Automatic Repair
-   Boot failures after updates or forced shutdowns

It does not modify system files or format the disk.\
It only rebuilds the UEFI bootloader using Microsoft's `bcdboot`
utility.

------------------------------------------------------------------------

## What This Does NOT Fix

-   SSD hardware failure
-   Undetected drives in BIOS
-   Physical disk errors
-   RAM or motherboard issues
-   BitLocker-locked systems without a recovery key

If your disk is not detected in BIOS, this is not a software problem.

------------------------------------------------------------------------

## Requirements

-   UEFI system (GPT partition layout)
-   Windows 10 or Windows 11
-   Access to Windows Recovery Environment (WinRE)

------------------------------------------------------------------------

## How to Use

### 1. Enter Windows Recovery

If Windows does not boot:

-   Power on the system
-   Interrupt startup three times to trigger recovery\
    or\
-   Boot from a Windows installation USB

Then go to:

Troubleshoot → Advanced Options → Command Prompt

------------------------------------------------------------------------

### 2. Run the Script

1.  Insert the USB drive containing `repair-uefi-boot-win11.bat`

2.  In Command Prompt, identify the USB letter:

        diskpart
        list volume
        exit

3.  Switch to the USB drive:

        E:

    (Replace `E:` with your USB drive letter.)

4.  Run:

        repair-uefi-boot-win11.bat

5.  Follow the on-screen instructions.

------------------------------------------------------------------------

## Expected Result

If successful, you should see:

    Boot files successfully created.

Restart your machine.

Windows should boot normally.

------------------------------------------------------------------------

## How It Works

The script:

1.  Detects the Windows installation automatically

2.  Lists volumes to identify the EFI partition

3.  Mounts the EFI partition

4.  Rebuilds the UEFI bootloader using:

        bcdboot <WindowsDrive>\Windows /s Z: /f UEFI

This restores the boot configuration without reinstalling Windows.

------------------------------------------------------------------------

## Tested On

-   Windows 11 (UEFI systems)
-   GPT partition layout
-   Lenovo ThinkPad T480

Should work on most modern UEFI Windows systems.

------------------------------------------------------------------------

## Why This Exists

This project was created after a real-world recovery case where:

-   The SSD was healthy
-   System files were intact
-   Only the UEFI boot configuration was corrupted

Rebuilding the bootloader restored the system immediately, avoiding a
full OS reinstall.

This script makes that recovery process accessible and repeatable. Please feel free to contact me if you find any issues, encounter a specific edge case, or have ideas to improve this solution.

By: @blindma1den
------------------------------------------------------------------------

## License

MIT License.
