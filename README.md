![Celeste](/Source/SystemAssets/card.png)

# Celeste Classic

A port of Celeste Classic from PICO-8 to Playdate.

## How to play

1. Download the latest release at https://github.com/hteumeuleu/celeste/releases .
2. Get the `Celeste.pdx.zip ` file.
3. Sideload it to your Playdate device. (You can refer to the official [Sideloading Playdate games](https://help.play.date/games/sideloading/) documentation.)

If you don’t own a Playdate, you can play in the [Playdate Simulator](https://help.play.date/manual/simulator/) on Windows, macOS or Linux. Download and install the [Playdate SDK](https://play.date/dev/). Place the `.pdx` file in the `PlaydateSDK/Disk/Games/` folder.

### Compilation

The `.pdx` available for download has been compiled on macOS. If you play on another system, you’ll need to recompile the game. You can do this by cloning this repository and executing the following command from the root of the project.

```sh
pdc ./Source Celeste.pdx
```

## Changes

Celeste Classic on Playdate was made to be as faithful as possible to the original game on PICO-8. But here are a few notable changes:

* The game is in **black and white** only. A lot of visual elements have an outline to make them more readable. But this does not impact their original hitbox.
* The game is rendered at **256×240** from the original 128×128. Four pixel lines are cropped at the top and bottom of the screen. The game can be played at its original resolution by disabling the _Fullscreen_ option available in the game’s menu.
* **Assist mode** is available under the game’s menu. This allows player to skip a level, change the game speed to 0.5×, get infinite dashes, and enable invincibility. If assist mode is used during a run, a mention is added on each level in the lower right corner, as well as in the pause screen and the final score screen.

![The assist mode option screen.](/Support/assist-mode.png)

## Credits

[Celeste Classic](https://mattmakesgames.itch.io/celesteclassic) is an original game on PICO-8 by Noel Berry and Maddy Thorson.

PICO-8 and the PICO-8 font are the property of [Lexaloffle Games](https://www.lexaloffle.com/).

Playdate is a registered trademark of [Panic](https://panic.com/).

The Playdate port was done by [Rémi Parmentier](https://github.com/HTeuMeuLeu).

Thanks to [Alex Larioza](https://github.com/SHiLLySiT) for help and tips on performance optimizations. And thanks to the wonderful people on Discord (_orkn, Grhmhome, Drew-Lo, Gamma, Kiwi, Tristianski, jeffamphetamines, PizzaDev, Kucromy, Guv_Bubbs, NickSr, Andrew, DoctorMikeReddy, natch, rasith, Braillynn, fnc12_) for their feedback.

## License

This project is under the [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) license. While it is unclear what license the original [Celeste Classic](https://www.lexaloffle.com/bbs/?tid=2145) is under, this is the license used by further [EXOK](https://exok.com/) projects like [Oldeste](https://www.lexaloffle.com/bbs/?tid=48946) or [Celeste 2](https://www.lexaloffle.com/bbs/?tid=41282).