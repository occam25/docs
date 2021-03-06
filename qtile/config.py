# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2009, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import os
import subprocess
from typing import List  # noqa: F401
from libqtile import bar, layout, widget, extension
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

mod = "mod4"
terminal = guess_terminal()
browser = 'google-chrome'
files = 'dolphin'

# keyboard next layout
@lazy.function
def z_next_keyboard(qtile):
    keyboard_widget.cmd_next_keyboard()

mute_command='amixer -q -D pulse set Master toggle'.split()
volume_up_command='amixer -q -D pulse set Master 2%+'.split()
volume_down_command='amixer -q -D pulse set Master 2%-'.split()
get_volume_command='amixer -D pulse get Master'.split()

keys = [
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(),
        desc="Move window focus to other window"),

    Key([mod, "shift"], "space", z_next_keyboard, desc="Set next keyboard layout"),

    Key([], "XF86AudioMute", lazy.spawn(mute_command), desc="Mute sound"),
    Key([], "XF86AudioLowerVolume", lazy.spawn(volume_down_command), desc="Volume down"),
    Key([], "XF86AudioRaiseVolume", lazy.spawn(volume_up_command), desc="Volume up"),

    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(),
        desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(),
        desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(),
        desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),

    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(),
        desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(),
        desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(),
        desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = -1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([mod, "shift"], "Return", lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack"),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),

    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "d", lazy.window.kill(), desc="Kill focused window"),

    Key([mod, "control"], "r", lazy.restart(), desc="Restart Qtile"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawncmd(),
        desc="Spawn a command using a prompt widget"),
    Key([mod], 'm', lazy.run_extension(extension.DmenuRun(
        dmenu_prompt=">",
        dmenu_font="Andika-8",
        background="#15181a",
        foreground="#00ff00",
        selected_background="#079822",
        selected_foreground="#fff",
        #dmenu_height=24,  # Only supported by some dmenu forks
    ))),
    Key([mod], "u",
        lazy.to_screen(0),
        desc='Keyboard focus to monitor 1'),

    Key([mod], "i",
        lazy.to_screen(1),
        desc='Keyboard focus to monitor 2'),

    Key([mod], "period",
        lazy.next_screen(),
        desc='Move focus to next monitor'),

    Key([mod], "comma",
        lazy.prev_screen(),
        desc='Move focus to prev monitor'),

    # Apps

    Key([mod], "b",lazy.spawn(browser)),
    Key([mod], "f",lazy.spawn(files)),
]

groups = [Group(i) for i in "12345"]

for i in groups:
    keys.extend([
        # mod1 + letter of group = switch to group
        Key([mod], i.name, lazy.group[i.name].toscreen(),
            desc="Switch to group {}".format(i.name)),

        # mod0 + shift + letter of group = switch to & move focused window to group
        Key([mod, "shift"], i.name, lazy.window.togroup(i.name, switch_group=True),
            desc="Switch to & move focused window to group {}".format(i.name)),
        # Or, use below if you prefer not to switch to that group.
        # # mod1 + shift + letter of group = move focused window to group
        # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
        #     desc="move focused window to group {}".format(i.name)),
    ])

layout_theme = {"border_width": 4,
                "margin": 0,
                "border_focus": "00ffff",
                "border_normal": "1D2330"
                }
layouts = [
    #layout.Columns(border_focus_stack='#d75f5f'),
    layout.Columns(border_focus='#00ffff', border_focus_stack='#00ffff',border_width=4),
    layout.Max(), 
    # Try more layouts by unleashing below layouts.
    #layout.Stack(num_stacks=2),
    #layout.Bsp(),
    #layout.Matrix(),
    layout.MonadTall(**layout_theme),
    #layout.MonadWide(),
    #layout.RatioTile(),
    #layout.Tile(),
    #layout.Zoomy(),
    #layout.VerticalTile(),
    layout.TreeTab()
]

widget_defaults = dict(
    font='sans',
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()

keyboard_widget=widget.KeyboardLayout(configured_keyboards=['gb','es'])
volume_widget=widget.Volume(mute_command=mute_command, volume_up_command=volume_up_command,volume_down_command=volume_down_command,get_volume_command=get_volume_command)

screens = [
    Screen(
        wallpaper='/home/javi/Pictures/wallpapers/retro_game.jpg',
        wallpaper_mode='fill',
        top=bar.Bar(
            [
                widget.CurrentLayout(),
                widget.GroupBox(),
                widget.CurrentScreen(active_text='ACTIVE',inactive_text='INACTIVE'),
                widget.Prompt(),
                widget.WindowName(),
                widget.Chord(
                    chords_colors={
                        'launch': ("#ff0000", "#ffffff"),
                    },
                    name_transform=lambda name: name.upper(),
                ),
                widget.CheckUpdates(distro='Ubuntu',update_interval=3600,execute=terminal + ' -e "/home/javi/.config/qtile/bin/sysupdate.sh"',colour_have_updates = 'ff0000'), #(Added "/usr/bin/aptitude update &" in /etc/cron.daily/aptitude"
                widget.TextBox("Net"),
                widget.NetGraph(interface='auto'),
                widget.TextBox("Mem"),
                widget.MemoryGraph(graph_color='27DA99'),
                widget.TextBox("CPU"),
                widget.CPUGraph(graph_color='A563EB'),
                widget.ThermalSensor(),
                #widget.TextBox("default config", name="default"),
                #widget.TextBox("Press &lt;M-r&gt; to spawn", foreground="#d75f5f"),
                #widget.KeyboardLayout(configured_keyboards=['gb','es']),
                keyboard_widget,
                volume_widget,
                widget.Systray(),
                #widget.Net(interface='eno1'),
                widget.Clock(format='%Y-%m-%d %a %H:%M'),
                widget.QuickExit(),
            ],
            24,
        ),
    ),
    Screen(
        wallpaper='/home/javi/Pictures/wallpapers/retro_game.jpg',
        wallpaper_mode='fill',
        top=bar.Bar(
            [
                widget.CurrentLayout(),
                widget.GroupBox(),
                widget.CurrentScreen(active_text='ACTIVE',inactive_text='INACTIVE'),
                widget.Prompt(),
                widget.WindowName(),
                widget.Chord(
                    chords_colors={
                        'launch': ("#ff0000", "#ffffff"),
                    },
                    name_transform=lambda name: name.upper(),
                ),
                #widget.TextBox("default config", name="default"),
                #widget.TextBox("Press &lt;M-r&gt; to spawn", foreground="#d75f5f"),
                widget.Systray(),
                widget.Clock(format='%Y-%m-%d %a %H:%M'),
                widget.QuickExit(),
            ],
            24,
        ),
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front())
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
main = None  # WARNING: this is deprecated and will be removed soon
#follow_mouse_focus = True
follow_mouse_focus = False #//+++
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(float_rules=[
    # Run the utility of `xprop` to see the wm class and name of an X client.
    Match(wm_type='utility'),
    Match(wm_type='notification'),
    Match(wm_type='toolbar'),
    Match(wm_type='splash'),
    Match(wm_type='dialog'),
    Match(wm_class='file_progress'),
    Match(wm_class='confirm'),
    Match(wm_class='dialog'),
    Match(wm_class='download'),
    Match(wm_class='error'),
    Match(wm_class='notification'),
    Match(wm_class='splash'),
    Match(wm_class='toolbar'),
    Match(wm_class='confirmreset'),  # gitk
    Match(wm_class='makebranch'),  # gitk
    Match(wm_class='maketag'),  # gitk
    Match(wm_class='ssh-askpass'),  # ssh-askpass
    Match(title='branchdialog'),  # gitk
    Match(title='pinentry'),  # GPG key password entry
])
auto_fullscreen = True
focus_on_window_activation = "smart"

#@hook.subscribe.startup_once
#def start_once():
#    home = os.path.expanduser('~')
#    subprocess.call([home + '/.config/qtile/autostart.sh'])

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
