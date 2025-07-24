import curses
import os
import re

def parse_cmake_options(file_path):
    pattern = re.compile(r'option\(\s*(TPL_ENABLE_\w+)\s*"([^"]*)"\s*(ON|OFF)\s*\)')
    tpls = []

    with open(file_path, 'r') as f:
        for line in f:
            match = pattern.search(line)
            if match:
                name, description, enabled = match.groups()
                tpls.append({
                    "name": name,
                    "description": description,
                    "enabled": enabled == "ON"
                })

    return tpls 



def tui_select_tpls(tpls):
    curses.curs_set(0)
    current = 0

    while True:
        stdscr = curses.initscr()
        stdscr.clear()
        stdscr.addstr(0, 0, "Select TPL packages (space to toggle, enter to confirm):")

        for idx, opt in enumerate(tpls):
            mark = "[x]" if opt["enabled"] else "[ ]"
            line = f"{mark} {opt['name']}"
            if idx == current:
                stdscr.addstr(idx + 2, 0, line, curses.A_REVERSE)
            else:
                stdscr.addstr(idx + 2, 0, line)

        key = stdscr.getch()
        if key == curses.KEY_UP and current > 0:
            current -= 1
        elif key == curses.KEY_DOWN and current < len(tpls) - 1:
            current += 1
        elif key == ord(" "):
            tpls[current]["enabled"] = not tpls[current]["enabled"]
        elif key == ord("\n"):
            break

        curses.endwin()

    curses.endwin()
    return tpls



def tui_prefix_path(stdscr, default_prefix="~/dcs2/"):
    curses.curs_set(1)
    prefix = os.path.expanduser(default_prefix)
    max_y, max_x = stdscr.getmaxyx()

    instructions = "Please enter the path where to install deal.II (Enter to confirm, ESC to cancel):"
    input_y = 2

    while True:
        stdscr.clear()
        stdscr.addstr(0, 0, instructions, curses.A_BOLD)
        stdscr.addstr(input_y, 0, prefix, curses.A_REVERSE)
        stdscr.refresh()

        key = stdscr.getch()

        if key in (curses.KEY_ENTER, ord("\n")):
            break
        elif key in (curses.KEY_BACKSPACE, 127):
            prefix = prefix[:-1]
        elif key == 27:  # ESC
            prefix = None
            break
        elif 32 <= key <= 126:
            prefix += chr(key)

    curses.curs_set(0)
    return prefix



def tui_install_tools(stdscr):
    curses.curs_set(0)
    modes = ["download", "ON", "OFF"]  # Order matters for toggling
    tools = [
        {"name": "mold", "mode": "download"},
        {"name": "ninja", "mode": "download"}
    ]
    current = 0

    instructions = "Choose which build tools to use: (space to cycle: Download →  ON (build from source) →  OFF, Enter to confirm):"

    while True:
        stdscr.clear()
        stdscr.addstr(0, 0, instructions, curses.A_BOLD)

        for idx, tool in enumerate(tools):
            line = f"[{tool['mode']:^8}] {tool['name']} (recommended)"
            if idx == current:
                stdscr.addstr(idx + 2, 0, line, curses.A_REVERSE)
            else:
                stdscr.addstr(idx + 2, 0, line)

        stdscr.refresh()
        key = stdscr.getch()

        if key == curses.KEY_UP and current > 0:
            current -= 1
        elif key == curses.KEY_DOWN and current < len(tools) - 1:
            current += 1
        elif key == ord(" "):
            # Cycle through modes
            current_mode = tools[current]["mode"]
            next_index = (modes.index(current_mode) + 1) % len(modes)
            tools[current]["mode"] = modes[next_index]
        elif key == ord("\n"):
            break

    return {tool["name"]: tool["mode"] for tool in tools}



if __name__ == "__main__":
    tpls = parse_cmake_options("CMakeLists.txt")

    selected_tpls = curses.wrapper(lambda stdscr: tui_select_tpls(tpls))
    cmake_args = [f"-D {tpl['name']}={'ON' if tpl['enabled'] else 'OFF'}" for tpl in selected_tpls]

    dcs2_args = []
    prefix = curses.wrapper(tui_prefix_path)
    dcs2_args.append(f"--path {prefix}")

    install_tools = curses.wrapper(tui_install_tools)
    for tool, enabled in install_tools.items():
        dcs2_args.append(f"--{tool} {enabled}")

    #print(" ".join(cmake_args))
    print(cmake_args)
    print(dcs2_args)

