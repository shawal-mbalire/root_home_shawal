let temp = [" %UnsafeStdinReader% }{"
       ,"<box type=Bottom width=2 mb=2 color=#b5bd68><fc=#b5bd68>"
       ,"<action=`alacritty -e htop`>%cpu%</action></fc></box>"
       ,"<box type=Bottom width=2 mb=2 color=#e6c547><fc=#e6c547>"
       ,"<action=`alacritty -e htop`>%memory%</action></fc></box>"
       ,"<box type=Bottom width=2 mb=2 color=#81a2be><fc=#81a2be>%disku%</fc></box>"
       ,"<box type=Bottom width=2 mb=2 color=#b294bb><fc=#b294bb>%uparrow%  %uptime%</fc></box>"
       ,"<box type=Bottom width=2 mb=2 color=#70c0ba><fc=#70c0ba>%bell%"
       ,"<action=`alacritty -e sudo pacman -Syu`>%pacupdate%</action></fc></box>"
       ,"<box type=Bottom width=2 mb=2 color=#ff3334><fc=#ff3334>%baticon%  %battery%</fc></box>"
       ,"<box type=Bottom width=2 mb=2 color=#9ec400><fc=#9ec400>"
       ,"<action=`emacsclient -c -a 'emacs' --eval '(doom/window-maximize-buffer(dt/year-calendar))'`>%date%</action></fc></box>"
       ,"%trayerpad%"
    ]
    separator = " "
mytemplate = concat $ Data.List.intersperse separator temp
Config {
    font            = "Sono Bold 9"
  , additionalFonts = [ "Comfortaa"
                      , "Font Awesome 6 Free Solid 12"
                      , "Font Awesome 6 Brands 12"
                      ]
  , bgColor         = "#1d1f21"
  , fgColor         = "#ffffff"
  , position        = TopSize L 100 24
  , lowerOnStart    = True
  , hideOnStart     = False
  , allDesktops     = True
  , persistent      = True
  , sepChar         = "%"
  , alignSep        = "}{"
  , template        = "%UnsafeStdinReader% }{ \
                      \ <box type=Bottom width=2 mb=2 color=#b5bd68><fc=#b5bd68><action=`alacritty -e htop`>%cpu%</action></fc></box> \
                      \ <box type=Bottom width=2 mb=2 color=#e6c547><fc=#e6c547><action=`alacritty -e htop`>%memory%</action></fc></box> \
                      \ <box type=Bottom width=2 mb=2 color=#81a2be><fc=#81a2be>%disku%</fc></box> \
                      \ <box type=Bottom width=2 mb=2 color=#b294bb><fc=#b294bb>%uparrow%  %uptime%</fc></box> \
                      \ <box type=Bottom width=2 mb=2 color=#70c0ba><fc=#70c0ba>%bell%  <action=`alacritty -e sudo pacman -Syu`>%pacupdate%</action></fc></box> \
                      \ <box type=Bottom width=2 mb=2 color=#ff3334><fc=#ff3334>%baticon%  %battery%</fc></box> \
                      \ <box type=Bottom width=2 mb=2 color=#9ec400><fc=#9ec400><action=`emacsclient -c -a 'emacs' --eval '(doom/window-maximize-buffer(dt/year-calendar))'`>%date%</action></fc></box> \
                      \ %trayerpad%"
  , commands = [
      Run Cpu ["-t", "<fn=2>\xf108</fn>  cpu: (<total>%)","-H","50","--high","red"] 20
    , Run Memory ["-t", "<fn=2>\xf233</fn>  mem: <used>M (<usedratio>%)"] 20
    , Run DiskU [("/", "<fn=2>\xf0c7</fn>  hdd: <free> free")] [] 60
    , Run Com "echo" ["<fn=2>\xf0aa</fn>"] "uparrow" 3600
    , Run Uptime ["-t", "uptime: <days>d <hours>h"] 360
    , Run Com "echo" ["<fn=2>\xf0f3</fn>"] "bell" 3600
    , Run Com ".local/bin/pacupdate" [] "pacupdate" 36000
    , Run Com "echo" ["<fn=2>\xf242</fn>"] "baticon" 3600
    , Run BatteryP ["BAT01"] ["-t", "<acstatus><watts> (<left>%)"] 360
    , Run Date "<fn=2>\xf017</fn>  %b %d %Y - (%H:%M) " "date" 50
    , Run Com ".config/xmobar/trayer-padding-icon.sh" [] "trayerpad" 20
    , Run UnsafeStdinReader
    ]
}
