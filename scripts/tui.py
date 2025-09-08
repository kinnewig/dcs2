import curses
import os
import re

import subprocess
import pty

from packaging import version as v

def tpls_read_from_cmake(file_path):
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



def tpls_tui_select(tpls):
    curses.curs_set(0)
    current = 0

    # Precompute the max width of the name field for alignment
    name_width     = max(len(opt["name"].removeprefix("TPL_ENABLE_")) for opt in tpls)
    desc_start_col = name_width + 4 + 1  # +4 for "[x] " or "[ ] " and +1 for spacing

    while True:
        stdscr = curses.initscr()
        stdscr.clear()
        stdscr.addstr(0, 0, "Select TPL packages (space to toggle, enter to confirm:")

        for idx, opt in enumerate(tpls):
            mark = "[x]" if opt["enabled"] else "[ ]"
            name = opt["name"].removeprefix("TPL_ENABLE_")
            line = f"{mark} {name}"
            if "description" in opt:
                line = line.ljust(desc_start_col) + f"- {opt['description']}"
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

    return tpls

 

def tpls_update_cmake(tpls, file_path="CMakeLists.txt"):
    # Create a lookup dictionary keyed by full name
    tpl_lookup = {tpl["name"]: tpl for tpl in tpls}

    pattern = re.compile(r'option\(\s*(TPL_ENABLE_\w+)\s*"([^"]*)"\s*(ON|OFF)\s*\)')

    updated_lines = []

    with open(file_path, "r") as f:
        lines = f.readlines()

    for line in lines:
        match = pattern.search(line)
        if match:
            name, old_description, old_status = match.groups()
            if name in tpl_lookup:
                tpl = tpl_lookup[name]
                new_status = "ON" if tpl["enabled"] else "OFF"
                new_description = tpl["description"]
                line = f'option({name} "{new_description}" {new_status})\n'
        updated_lines.append(line)

    with open(file_path, "w") as f:
        f.writelines(updated_lines)



def program_available(program, env, min_version="0.0.0"):
    try:
        output = subprocess.check_output([f"{program}", "--version"], stderr=subprocess.STDOUT, env=env)
        line = output.decode().splitlines()[0]

        if v.parse(line.split()[-1]) >= v.parse(min_version):
            return True 
        else:
            return False
    except Exception:
        return False



def tui_read_path(default_path, instructions):
    stdscr = curses.initscr()
    curses.curs_set(1)
    prefix = os.path.expanduser(default_path)
    max_y, max_x = stdscr.getmaxyx()

    input_y = 2

    while True:
        stdscr.clear()
        stdscr.addstr(0, 0, instructions, curses.A_BOLD)
        stdscr.addstr(input_y, 0, prefix)
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



def tui_select_with_options(instructions, options, modes):
    stdscr = curses.initscr()
    curses.curs_set(0)
    current = 0

    instruction_lines = instructions.split("\n")

    while True:
        stdscr.clear()
        for i, line in enumerate(instruction_lines):
            stdscr.addstr(i, 0, line, curses.A_BOLD)

        for idx, tool in enumerate(options):
            line = f"[{tool['mode']:^8}] {tool['name']} (recommended)"
            line_y = len(instruction_lines) + idx + 1 
            if idx == current:
                stdscr.addstr(line_y, 0, line, curses.A_REVERSE)
            else:
                stdscr.addstr(line_y, 0, line)

        stdscr.refresh()
        key = stdscr.getch()

        if key == curses.KEY_UP and current > 0:
            current -= 1
        elif key == curses.KEY_DOWN and current < len(options) - 1:
            current += 1
        elif key == ord(" "):
            # Cycle through modes
            current_mode = options[current]["mode"]
            next_index = (modes.index(current_mode) + 1) % len(modes)
            options[current]["mode"] = modes[next_index]
        elif key == ord("\n"):
            break

    return {tool["name"]: tool["mode"] for tool in options}



def tui_select_from_list(instructions, options):
    stdscr = curses.initscr()
    curses.curs_set(0)
    curses.noecho()
    curses.cbreak()
    stdscr.keypad(True)

    # Precompute the max width of the name field for alignment
    name_width     = max(len(opt["name"]) for opt in options)
    desc_start_col = name_width + 1  # +1 for spacing

    current = 0

    try:
        while True:
            stdscr.clear()
            stdscr.addstr(0, 0, instructions, curses.A_BOLD)

            for idx, opt in enumerate(options):
                line = f"{opt['name']}"
                line = line.ljust(desc_start_col) + f"- {opt['description']}"
                if idx == current:
                    stdscr.addstr(idx + 2, 2, line, curses.A_REVERSE)
                else:
                    stdscr.addstr(idx + 2, 2, line)

            stdscr.refresh()
            key = stdscr.getch()

            if key == curses.KEY_UP and current > 0:
                current -= 1
            elif key == curses.KEY_DOWN and current < len(options) - 1:
                current += 1
            elif key == ord("\n"):
                break

    finally:
        curses.nocbreak()
        stdscr.keypad(False)
        curses.echo()
        curses.endwin()

    return options[current]["name"]



def run_with_pty(command, args):
    # Create a pseudo-terminal
    master_fd, slave_fd = pty.openpty()

    process = subprocess.Popen(
        [command] + args,
        stdout=slave_fd,
        stderr=slave_fd,
        close_fds=True
    )
    os.close(slave_fd)

    # Read and print output live
    try:
        while True:
            output = os.read(master_fd, 1024)
            if not output:
                break
            print(output.decode(), end="")
    finally:
        os.close(master_fd)
        process.wait()



if __name__ == "__main__":
    # === Installation Mode ===
    instructions = "Select the installation mode (↑/↓ to navigate, Enter to confirm):"
    options = [
        {"name": "DEFAULT",   "description": "You only need to provide the version of deal.II and the install path, DCS2 does the rest."},
        {"name": "CUSTOM",    "description": "Customize everything (which packages to install, etc..)"},
    ]
    installation_mode = curses.wrapper(lambda stdscr: tui_select_from_list(instructions, options))

    # === deal.II Version ===
    # TODO: Write a selector that checks out the corresponding dcs2 branch
    dealii_version="9.7.0"

    # Add to path:
    instructions = "To ensure deal.II and its tools are easily accessible after installation, DCS2 can automatically add the necessary environment variables (including DEAL_II_DIR) to your ~/.bashrc.\nIt is strongly recommended to add these values to your shell configuration—either manually or by letting DCS2 handle it for you.\n\nWould you like DCS2 to update your ~/.bashrc automatically? (Use space to toggle: yes → no, press Enter to confirm)"
    options = [
        {"name": "Add to path", "mode": "yes"},
    ]
    modes = ["yes", "no"]  # Order matters for toggling
    add_to_path = curses.wrapper(lambda stdscr: tui_select_with_options(instructions, options, modes))


    # === Package selection ===
    instructions = "Please enter the path where to install deal.II (Enter to confirm, ESC to cancel):"
    prefix = curses.wrapper(lambda stdscr: tui_read_path("~/dcs2", instructions))

    if installation_mode == "DEFAULT":
        build = f"{prefix}/tmp"
        bin_dir = f"{prefix}/bin"

        install_tools = [{"ninja", "download"}, {"mold", "download"}]

        blas_stack = "BLIS"
        add_aocc = False


    else: 
        instructions = "Please enter the path where to store the temporarie build files (Enter to confirm, ESC to cancel):"
        build = curses.wrapper(lambda stdscr: tui_read_path(f"{prefix}/tmp", instructions))

        instructions = "Please enter the path where to store binary files (Enter to confirm, ESC to cancel):"
        bin_dir = curses.wrapper(lambda stdscr: tui_read_path(f"{prefix}/bin", instructions))


        # Choose to compile or download ninja and mold
        instructions = "Choose which build tools to use: (space to cycle: download →  compile (build from source) →  OFF, Enter to confirm):"
        options = [
            {"name": "mold", "mode": "download"},
            {"name": "ninja", "mode": "download"}
        ]
        modes = ["download", "compile", "OFF"]  # Order matters for toggling
        install_tools = curses.wrapper(lambda stdscr: tui_select_with_options(instructions, options, modes))

        # Select the BLAS Stack:
        instructions = "Select the BLAS stack to use (↑/↓ to navigate, Enter to confirm):"
        options = [
            {"name": "BLIS",      "description": "Generic BLAS implementation from BLIS"},
            {"name": "SYSTEM",    "description": "Use system-provided BLAS"},
            {"name": "AMD",       "description": "Optimized for AMD CPUs using AOCL"},
            {"name": "INTEL",     "description": "Optimized for Intel CPUs using oneMKL"},
        ]
        blas_stack = curses.wrapper(lambda stdscr: tui_select_from_list(instructions, options))

        if blas_stack == "AMD":
            add_aocc = True
        else:
            add_aocc = False

        # Read the TPLs from the CMakeLists.txt
        tpls = tpls_read_from_cmake("CMakeLists.txt")

        # These TPLs are handeled by the BLAS stack option
        excluded_tpls = {"TPL_ENABLE_BLIS", "TPL_ENABLE_LIBFLAME", "TPL_ENABLE_SCALAPACK"}
        filtered_tpls = [tpl for tpl in tpls if tpl["name"] not in excluded_tpls]

        # Let the user select
        selected_tpls = curses.wrapper(lambda stdscr: tpls_tui_select(filtered_tpls))

        # Write the changes to the CMakeLists.txt
        tpls_update_cmake(selected_tpls, "CMakeLists.txt")


    # === Start the installation ===

    # Set the prefix, in case CMake, Ninja or mold where already installed.
    current_prefix = os.environ.get("PREFIX", "")
    os.environ["PREFIX"] = f"{bin_dir}:{current_prefix}"

    cmake_available = program_available("cmake", os.environ)
    ninja_available = program_available("ninja", os.environ)
    mold_available  = program_available("mold", os.environ)
    
    if cmake_available == False:
        script_path = "./scripts/install_cmake.sh"
        args = [f"{prefix}", f"{build}", f"{bin_dir}"]
        run_with_pty(script_path, args)

    if ninja_available == False and install_tools.get("ninja", "download") != "OFF":
        script_path = "./scripts/install_ninja.sh"
        args = [f"{prefix}", f"{build}", f"{bin_dir}", f"{use_ninja}"]
        run_with_pty(script_path, args)

    if mold_available == False and install_tools.get("mold", "download") != "OFF":
        script_path = "./scripts/install_mold.sh"
        args = [f"{prefix}", f"{build}", f"{bin_dir}", f"{use_mold}"]
        run_with_pty(script_path, args)

    if add_aocc:
        script_path = "scripts/install_aocc.sh"
        args = [f"{prefix}"]
        run_with_pty(script_path, args)

    if add_to_path.get("Add to path", "yes") == "yes":
        script_path = "scripts/add_to_path.sh"
        add_aocc_parsed = "ON" if add_aocc else "OFF"
        args = [f"{prefix}", f"{build}", f"{bin_dir}", f"{dealii_version}", f"{add_aocc_parsed}"]
        run_with_pty(script_path, args)


    run_with_pty("cmake", ["-S", ".", 
                           "-B", f"{build}",
                           f"-D CMAKE_INSTALL_PREFIX={prefix}", 
                           f"-D BLAS_STACK={blas_stack}"
                           ]
                 )

    run_with_pty("cmake", ["--build", f"{build}"])
