

## AIR Image Scripts

These scripts are helpful to generate the required icons (including `Assets.car`) and default launch images.


The script takes 3 parameters:

- path to the icon image to use as the base, we suggest a 1024x1024 pixel image;
- colour to use to fill background when required for default images. 
  - Of the format "#RRGGBB";
- [optional] output path for the files. You can use this to point to the assets output folder of your application. Defaults to a directory `dst`.



### Examples

```
generate.sh icon.png "#ff0000" 
```

```
generate.sh icon.png "#ff0000" out
```




### Outputs

Currently this script outputs the following icons and default images:

```
|____Assets.car
|____Default-Portrait@2x.png
|____Default-414w-736h@3x~iphone.png
|____Default-568h@2x~iphone.png
|____Default-375w-667h@2x~iphone.png
|____Default-Portrait@2x~ipad.png
|____Default-Landscape@2x.png
|____Default-Landscape~ipad.png
|____Default-Portrait~ipad.png
|____Default-812h@3x~iphone.png
|____Default~iphone.png
|____Default-Landscape-1112h@2x.png
|____Default-Landscape@2x~ipad.png
|____Default-Landscape-414w-736h@3x~iphone.png
|____Default-Portrait-1112h@2x.png
|____Default-Landscape-812h@3x~iphone.png
|____Default@2x~iphone.png
|____icons
| |____icon120x120.png
| |____icon48x48.png
| |____icon60x60.png
| |____icon58x58.png
| |____icon36x36.png
| |____icon72x72.png
| |____icon20x20.png
| |____icon80x80.png
| |____icon57x57.png
| |____icon180x180.png
| |____icon32x32.png
| |____icon76x76.png
| |____icon1024x1024.png
| |____icon29x29.png
| |____icon152x152.png
| |____icon16x16.png
| |____icon87x87.png
| |____icon512x512.png
| |____icon40x40.png
| |____icon114x114.png
| |____icon144x144.png
| |____icon128x128.png
| |____icon167x167.png
```

Add the following to your application descriptor to pick up these icon image names:

```xml
    <icon>
        <image16x16>icons/icon16x16.png</image16x16>
        <image29x29>icons/icon29x29.png</image29x29>
        <image32x32>icons/icon32x32.png</image32x32>
        <image36x36>icons/icon36x36.png</image36x36>
        <image40x40>icons/icon40x40.png</image40x40>
        <image48x48>icons/icon48x48.png</image48x48>
        <image57x57>icons/icon57x57.png</image57x57>
        <image58x58>icons/icon58x58.png</image58x58>
        <image60x60>icons/icon60x60.png</image60x60>
        <image72x72>icons/icon72x72.png</image72x72>
        <image76x76>icons/icon76x76.png</image76x76>
        <image80x80>icons/icon80x80.png</image80x80>
        <image87x87>icons/icon87x87.png</image87x87>
        <image114x114>icons/icon114x114.png</image114x114>
        <image120x120>icons/icon120x120.png</image120x120>
        <image128x128>icons/icon128x128.png</image128x128>
        <image144x144>icons/icon144x144.png</image144x144>
        <image152x152>icons/icon152x152.png</image152x152>
        <image167x167>icons/icon167x167.png</image167x167>
        <image180x180>icons/icon180x180.png</image180x180>
        <image512x512>icons/icon512x512.png</image512x512>
        <image1024x1024>icons/icon1024x1024.png</image1024x1024>
    </icon>
```

