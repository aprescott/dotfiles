# pyright: reportMissingImports=false

from kitty.fast_data_types import Screen
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    TabAccessor,
    TabBarData,
    as_rgb,
    draw_title,
)
from kitty.utils import color_as_int

def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    if draw_data.leading_spaces:
        screen.draw(" " * draw_data.leading_spaces)

    screen.cursor.bg = as_rgb(int(draw_data.default_bg))
    tab_fg = as_rgb(color_as_int(draw_data.active_fg if tab.is_active else draw_data.inactive_fg))
    screen.cursor.fg = tab_fg

    bell_icon = "\U000f116b"
    text_lines_icon = "\U000f1a07"
    dot_icon = "\uf4c3"
    dot_filled_icon = "\uf444"
    dot_filled_circled_icon = "\uf192"

    active_exe = TabAccessor(tab.tab_id).active_exe
    shells = {'bash', 'zsh', 'fish', 'sh', 'dash', 'ksh', 'tcsh', 'csh'}
    tab_has_process = active_exe and active_exe.lstrip('-') not in shells

    # For icons, see https://www.nerdfonts.com/cheat-sheet
    if tab.is_active:
        screen.draw(" " + dot_filled_circled_icon)
    elif tab.has_activity_since_last_focus:
        # text_lines_icon isn't needed here since it's baked into
        # {activity_symbol} in the template in kitty.conf, and if we don't
        # include it in {activity_symbol}, it ends up in the wrong spot.
        screen.draw(" ")
    elif tab.needs_attention:
        screen.draw(" " + bell_icon)
    else:
        tab_icon = dot_filled_icon if tab_has_process else dot_icon
        screen.draw(" " + tab_icon)

    draw_title(draw_data, screen, tab, index)

    if not is_last:
        screen.draw(draw_data.sep)

    return screen.cursor.x
