
# AY Sound FX Editor (Improved)

## Contents

[Overview](#overview)   
[Improved version](#improved-version)  
[Interface](#interface)  
[Hotkeys](#hotkeys)  
[Import effects](#import-effects)  
[Export effects](#export-effects)  
[File formats](#file-formats)  
[ZX Spectrum player](#zx-spectrum-player)  
[Demo video](#demo-video)  
[Version history](#version-history)  
[Thanks](#thanks)  
[Contacts](#contacts)  

<a href="https://raw.githubusercontent.com/Threetwosevensixseven/ayfxedit-improved/master/images/screenshot-1.png" title="AYFXedit User Interface" target="_blank"><img src="https://raw.githubusercontent.com/Threetwosevensixseven/ayfxedit-improved/master/images/screenshot-1.png" alt="AYFXedit User Interface" width="480"></a>

## Overview

[AY Sound FX Editor](https://shiru.untergrund.net/software.shtml) is a complete solution to create sound effects for the [AY-3-8910](http://map.grauw.nl/resources/sound/generalinstrument_ay-3-8910.pdf) sound chip. The effects can be used in games or other software for ZX Spectrum. It is also possible to use them with other micro computers that use the AY-3-8910. The package includes a [Windows cross editor](https://github.com/Threetwosevensixseven/ayfxedit-improved/raw/master/ayfxedit.exe), an example [sound effects player](https://raw.githubusercontent.com/Threetwosevensixseven/ayfxedit-improved/master/zeusexample/ayfxplay.asm) with Z80 assembly source code, a compiled [example](https://github.com/Threetwosevensixseven/ayfxedit-improved/raw/master/zeusexample/playtest.tap), and a [sound effects library](https://github.com/Threetwosevensixseven/ayfxedit-improved/tree/master/sfxcollection). 

The editor allows to create single channel sound effects with duration up to 4096 TV frames. Frame duration is 1/50s, so maximum effect duration is about 80 seconds. Volume, noise and mixer settings can be changed every frame. Data is stored in a compact format that omits repeating values. Effects are combined into banks, up to 256 effects. The effects player works with a bank, and an effect is played using its order number in the bank. 

It should be noted that the editor can't create effects on its own, it only allows to edit AY registers data in easy way. It is quite similar to the sample editors in AY music trackers. You have to know how the AY sound chip works in order to get your desired results. However, the editor allows you to import data from various formats, which can make things easier.

### Improved version

This "improved" version is a fork of [Shiru](https://shiru.untergrund.net/aboutme.shtml)'s superb [ayfxedit tool and player](https://shiru.untergrund.net/software.shtml), available [here](https://shiru.untergrund.net/software.shtml). It's not really improved in any meaningful way; the name was a good-natured nod to the  [Vortex II AY tracker](https://bulba.untergrund.net/vortex_e.htm) mod made by [siril](https://demozoo.org/sceners/8954/)/[4d](https://demozoo.org/groups/8953/), called [Vortex Tracker II Improved](https://github.com/oisee/vti) :)

I got frustrated trying to build Shiru's C++ Builder source in any of the publicly available C++ Builder versions, so I converted the project to unicode and built this fork in the free [C++ Builder 10.2 Tokyo Starter Edition](https://www.embarcadero.com/products/cbuilder/starter/info).

The main reason I forked ayfxedit was because I wanted to add looped sustain effects to the editor and player - my use case was a thrust sound for [Jet Power Jack](http://zxbasic.uk/db/40) that ramps up when you thrust, sustains as long as you hold '''SPACE''' down, then fades away when you release ```SPACE```. I eventually realised I could do this in the player without needing to modifiy the editor, but by then I had made some other small UI enhancements like aligning the column headers, and being able to double-click on .afx and .afb files if the file extensions are registed.

I would also like to make an enhanced player that locks certain sounds to certain channels, so thrust is panned center, and other sounds like pick up and die are panned left/right. ANn maybe even a pseudo-surround-sound mode that bounces a monophonic fx around all three channels...

I added an alternate set of z80 player and test files optimised for the [Zeus](http://www.desdes.com/products/oldfiles/zeus.htm) Windows cross-assembler, and translated Shiru's Russian comments into English.

Basically, treat anything in this fork as experimental and possibly buggy, and go to [the original source](https://shiru.untergrund.net/software.shtml) for the definitive version of ayfxedit.

## Interface

Program interface is all-english. There is main menu at the top of the window. The items:

### File
**New bank** - Clear effects bank, create one empty effect;   
**Load bank** - Load effects bank from file;   
**Save bank** - Save effects bank into file;   
**Save bank w/o names** - Save effects bank into file without effect names;

**Clear current effect** - Clear current effect;   
**Load current effect** - Load single effect file as current effect;   
**Save current effect** - Save current effect into single effect file;

**Multi-load to bank** - Append a number of single effect files to end of the bank, starting from last empty effect;   
**Multi-save from bank** - Save all effects from bank into separate single effect files. Names will be taken from effect names, all effects will be stored in the selected folder;

**Exit** - Exit from the editor.

### Edit

**Cut** - Cut selected frames from effect and put them into the clipboard. For this and the next action, when there is no selection, current frame will be used (the one under the cursor);   
**Copy** - Copy selected frames into the clipboard, they will get deselected after this action;   
Paste - Paste the clipboard contents into the cursor position, current and subsequent frames will be shifted down;   
**Delete** - Delete selected frames;

**Select all** - Select all frames that contain actual data;   
**Unselect all** - Remove selection;   
**Inverse selection** - Invert selection.

### View

**Piano input** - Show/hide virtual piano window (see [below](#piano));   
**Linear period** - Display tone values in linear scale (irregular spread of actual frequences);   
**Logarithmic period** - Display tone values in logarithmic scale.   

### Bank

**Add new effect** - Append a new effect to the end of the bank and make it current;   
**Delete effect** - Delete current effect from the bank;   
**Insert new effect** - Insert a new effect in place of current, the current and all subsequent will be shifted.     
### Import (see [Import effects](#import-effects))

**PSG for AY** - Import from PSG;   
**VTX file** - Import from VTX;   
**VGM file** - Import from VGM;   
**Wave file** - Import from WAV.

### Export (see [Export effects](#export-effects))

**VTII Sample** - Export as [Vortex Tracker II](http://bulba.untergrund.net/vortex_e.htm) instrument;   
**Wave file**- Export as WAV file;   
**CSV** - Export as text-based CSV file.

Below the main menu there is a bar with a number of controls. When you hover the mouse above them, a hint is displayed. 

At the left of the bar there are three buttons. Play and Stop perform corresponding actions with the current effect. The button with the piano keys shows or hides the virtual piano window (see [below](#piano)). 

At the right of the bar there are bank controls. [Add] appends an effect to the end of the bank. [Del] deletes current effect. Next four buttons with two numbers (current effect and total number of effects in bank) in between are to navigate between effects. Double arrows are to go to the first and the last effect in the bank. Last in the bar there is effect name. You can edit it by clicking it with left mouse button, entering a new name, and pressing Enter to confirm changes. Some hotkeys won't work while the name editor is active. 

All remaining space of the program window is the effect editor. You can use either mouse or keyboard to edit values. There are few columns. Pos is frame number. You can select frames with LMB on the frame number or deselect them with RMB. T, N are the AY mixer bits, edited similar to the selection. Per is the tone period. Ns is the noise period. V is the volume. When you click on any of Per, NS or V value, cursor moves to the frame. In the right part of the window the same values are represented in graphic form, they can also be edited using mouse buttons. When the Ctrl button is held down, mouse won't move horizontally, allowing easier drawing a sequence of the same values. 

The editor window can be resized vertically with one frame step, but can not be resized horizontally. 

<a name="piano"></a>There is a special window to simplify creation of sound effects based on musical notes. It can be brought with the button with piano keys or through View->Piano Input item of the main menu. At the left part of the window there is a hint which keyboard buttons correspond to notes. At the right there are controls that affect to the input. The Octave field sets up the current octave (1...8). The Step field sets up the number of frames that the cursor will advance after entering a note. The Fill field sets up how many subsequent frames will be set to the same value with a single note input. The Link button links Step and Fill fields, matching up the fill value to the step. When the Set T button is down, T flag is set for frame at note input, when it is up, existing T value of a frame won't be changed. Set Volume does the same for volume column, entering value that can be changed at the right of the button.

## Hotkeys

### Main window
Key | Action
--- | ----
Cursor Up/Down | Go to the previous/next frame.
Cursor Left/Right | Switch between tone/noise/volume columns.
0-9, A-F | Enter tone/noise/volume value.
Page Up/Down | Go a page up/down.
Mouse wheel | Go five frames up/down.
Home | Go to the begin of current effect (frame 0).
End | Go to the end of current effect (last frame with non-zero volume).
Mouse buttons | On the tone/noise/volume bars - change a value, on the effect name - edit name mode.
Left Mouse Button | On the T/N flags - set them; on a frame number - select frame.
Right Mouse Button | On the T/N flags - reset them; on a frame number - deselect frame.
Ctrl | Disable horizontal mouse movements inside the effect value bars.
~ | Show/hide the piano input window.
Enter | In the effect edit mode - play current effect; in the name edit mode - go to the effect edit mode.
Ctrl+Enter | Play effect starting from current frame.
Space |	Stop playing.
Delete |	Delete selection, selected frames will be removed, remaining will be shifted. When there is no selection, current frame will be deleted.
Insert |	Insert an empty frame, current and subsequent frames will be shifted down.
Ctrl+Insert |	Clone current frame, subsequent frames will be shifted down.
T |	Toggle T flag for the current frame.
N |	Toggle N flag for the current frame.
Ctrl+A |	Select the whole actual effect, from start to last frame with non-zero volume.
Ctrl+I |	Invert selection in the actual effect frames.
Ctrl+X |	Cut frames into the clipboard.
Ctrl+C |	Copy frames into the clipboard, selection will be reset.
Ctrl+V |	Paste the clipboard content into the cursor position, current and subsequent frames will be shifted down.
[+] or Numpad [+] |	Go to the next effect.
[-] or Numpad [-] |	Go to the previous effect.
Shift+[+] or Shift+Numpad [+] |	Increase tone, noise, or volume value by 1.
Shift+[-] or Shift+Numpad [-] |	Decrease tone, noise, or volume value by 1.


### Piano window
Key | Action
--- | ----
Z,S,X,D,C,V,G,B,H,N,J,M |Note keys, input notes in range of current octave.
Shift+Note key |	Input note one octave higher.
Ctrl+Note key |	Input note one octave below.
Numpad 1...8 |	Change current octave.


## Import effects

Following file formats are supported. 

### PSG 

AY registers dump. Files with complete 16-byte header are supported. These files could be created with [AY Emulator](https://bulba.untergrund.net/emulator_e.htm) or [Z80Stealth](http://z80stealth.emuunlim.com/). You can select channel that will be source of data before import. Auto option will select the channel where the volume changes first, with automatic skip of the pause before. Tone, noise, volume, and mixer settings of selected channel will be imported. To simplify things, it is better to use source files with single channel effects. 

### VTX 

AY registers dump. These files could be created with [AY Emulator](https://bulba.untergrund.net/emulator_e.htm) and [UnrealSpeccy](https://sourceforge.net/projects/unrealspeccy/). Import options are the same as for PSG. 

### VGM 

Registers dump for SN76489 or compatibles, the sound chip that has been used in Master System, Game Gear, Sega Genesis, ColecoVision, and some other computers or game consoles. The imported data is adapted to get similar sound, but as the chip capabilities are quite different, there will be difference. 

### WAV 

Only standard, unpacked PCM files supported, of any sample rate, bits depth, mono or stereo. Volume envelope gets imported, tone pitch gets analyzed. If it is possible to detect pitch for a frame, T flag sets along with the pitch value, otherwise N flag sets. 

## Export effects

Following file formats are supported. 

### VTII Instrument 

[Vortex Tracker II](http://bulba.untergrund.net/vortex_e.htm) instrument, which is a plain text file. Export dialogs allows to set a base note that should be used to get original pitch in the tracker. 

### WAV 

Standard uncompressed PCM file, 44100 Hz, 16 bit, mono. 

### CSV 

Comma separated values in a text file. Can be handy for further parsing and processing with external tools. 

### Current effect 

When this item is checked, export functions will export current effect only, under specified filename. 

### All effects 

When this item is checked, export functions will export all effects from the bank. The filename can have an optional prefix with effect number and name, this can be selected as the file type in the export dialog. 

## File formats

16-bit numbers stored in the LSB,MSB format.

### Single effect, file extension .afx 

Every frame encoded with a flag byte and a number of bytes, which is vary depending from value change flags.

Bit(s) | Purpose
--- | ---
 bit0..3 |  Volume
 bit4 |     Disable T
 bit5 |     Change Tone
 bit6  |    Change Noise
 bit7  |    Disable N

When the bit5 set, two bytes with tone period will follow; when the bit6 set, a single byte with noise period will follow; when both bits are set, first two bytes of tone period, then single byte with noise period will follow. When none of the bits are set, next flags byte will follow. 

End of the effect is marked with byte sequence `#D0, #20`. Player should detect it before outputting it to the AY registers, by checking noise period value to be equal `#20`. The editor considers last non-zero volume value as the last frame of an effect, other parameters aren't matter. 

### Effects bank, file extension .afb 

#### Header: 
Offset | Contents
--- | ---
+0 (1 byte) | Total number of effects in the bank, up to 256 (0 means 256);
+1 (2 bytes per effect)  |Table of offsets to data of every effect. Offset value is given relative to the second byte of the offset itself, this allows to calculate absolute address very fast:

```
hl=offset in the effects table
ld c,(hl)
inc hl
ld b,(hl)
add hl,bc   
hl=absolute address of effect data
```

#### Data 

Offset | Contents
--- | ---
+n (m bytes) | The effects data, format is the same as in the single effect file. After every effect there could be a null terminated text string with name of the effect. It may absent, if the bank was saved into a file using corresponding item of the File menu, in this case null terminator bytes are absent as well.


## ZX Spectrum player

The package includes a simple sound effects player. It is located at [/z80player/ayfxplay.a80](https://github.com/Threetwosevensixseven/ayfxedit-improved/blob/master/z80player/ayfxplay.a80). This file is a text file with Z80 source code for [asm80](http://www.asm80.com/) cross assembler. There are comments on use and internals as well. 

The player can play effects using all three AY channels. When there is an empty (not playing) channel, it will be used, otherwise the one that was active for longest time will be used. AY music can't play while this version of the player is active. 

Besides the player, there is an example program, available as [compiled SCL disk image](https://github.com/Threetwosevensixseven/ayfxedit-improved/blob/master/z80player/playtest.scl) and [source code](https://github.com/Threetwosevensixseven/ayfxedit-improved/blob/master/z80player/playtest.a80). All keys has sound effects assigned to them. Space key turns on/off music that is played on the second sound chip of TurboSound device (NedoPC version), if it is available. If the TurboSound is absent, music will play on the same chip, producing various sound artefacts.

## Demo video

<a href="https://www.youtube.com/watch?v=XI6aW2QSUXw" title="AYFX Editor demonstration video" target="_blank"><img src="https://github.com/Threetwosevensixseven/ayfxedit-improved/raw/master/images/video-1.png" alt="AYFX Editor demonstration video" width="480"></a>


## Version history

v0.6 01.02.17   
v0.5, v0.51, v0.52 _unreleased during 2006-2017_   
v0.4 09.05.06   
v0.3 28.02.06   
v0.2 12.02.06   
v0.1 02.02.06

## Thanks

Thanks goes to: 
* __[Shiru](https://shiru.untergrund.net/aboutme.shtml)__, for the definitive [original version](https://shiru.untergrund.net/files/ayfxedit.zip) of the project;  
* __[Alone Coder](http://alonecoder.nedopc.com/zx/)__, for help with the project;  
* __[Sergey Bulba](https://bulba.untergrund.net/main_e.htm)__, for [AY Emulator](https://bulba.untergrund.net/emulator_e.htm), [Vortex Tracker](https://bulba.untergrund.net/vortex_e.htm), and various docs at his webpage;
* __[SMT](https://sourceforge.net/u/open-smt/profile/)__, for [UnrealSpeccy](https://sourceforge.net/projects/unrealspeccy/) and [open source VTX format player](https://sourceforge.net/projects/zxssk/);
* __[Copper Feet](http://speccy.info/Copper_Feet)/[Bytex](http://speccy.info/Bytex)__, for [asm80](http://zxsoft.zxby.org/ZXUTIL/asm80222.rar) cross assembler;
* Also thanks to authors of the sound effects that are included into the library.

## Contacts

You can send bug reports, suggestions, or sound effects to include into the bundled library, at [shiru@mail.ru](mailto://shiru@mail.ru).
