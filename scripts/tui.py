import curses
import os
import re

import subprocess
import pty

from select_packages import run_select_tpls

from packaging import version as v



def check_clang_for_amd(env):
  try:
    result = subprocess.run(["clang", "--version"], capture_output=True, text=True)
    output = result.stdout
    if keyword in output:
      return True
    else:
      return False
  except FileNotFoundError:
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
      line = f"[{tool['mode']:^8}] {tool['name']}"
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

  instruction_lines = instructions.split("\n")
  name_width = max(len(opt["name"]) for opt in options)
  desc_start_col = name_width + 1  # +1 for spacing

  current = 0

  try:
    while True:
      stdscr.clear()

      # Display multiline instructions
      for i, line in enumerate(instruction_lines):
        stdscr.addstr(i, 0, line, curses.A_BOLD)

      # Display options below instructions
      for idx, opt in enumerate(options):
        line = f"{opt['name']}".ljust(desc_start_col) + f"- {opt['description']}"
        line_y = len(instruction_lines) + idx + 1
        if idx == current:
          stdscr.addstr(line_y, 2, line, curses.A_REVERSE)
        else:
          stdscr.addstr(line_y, 2, line)

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

  return options[current]["name"]



if __name__ == "__main__":
  # === Greetings and Installation Mode ===
  instructions = """\
========================================================================================
                                       _  __ ____ 
                                      | \\/  (_  _)
                                      |_/\\____)/__
                  
                                    one line installer               

========================================================================================

Welcome to the TUI of dcs2, this tool will walk you through the configuration of deal.II.

First, select the installation mode (↑/↓ to navigate, Enter to confirm):
    """
  options = [
    {"name": "DEFAULT", "description": "You only need to provide the version of deal.II and the install path, DCS2 does the rest."},
    {"name": "CUSTOM",  "description": "Customize everything (which packages to install, etc..)"},
  ]
  installation_mode = curses.wrapper(lambda stdscr: tui_select_from_list(instructions, options))


  # === deal.II Version ===
  # TODO: Write a selector that checks out the corresponding dcs2 branch
  dealii_version="9.7.0"

  
  # === Install path ===
  # Add to path:
  instructions = """\
To ensure deal.II and its tools are easily accessible after installation, DCS2 can automatically 
add the necessary environment variables (including DEAL_II_DIR) to your ~/.bashrc.

It is strongly recommended to add these values to your shell configuration—either manually or by 
letting DCS2 handle it for you.

Would you like DCS2 to update your ~/.bashrc automatically? 
(Use space to toggle: yes → no, press Enter to confirm)
    """
  options = [
    {"name": "Add to path", "mode": "ON"},
  ]
  modes = ["ON", "OFF"]
  add_to_path = curses.wrapper(lambda stdscr: tui_select_with_options(instructions, options, modes))
  add_to_path = add_to_path.get("Add to path", "ON")


  # === Package selection ===
  instructions = "Please enter the path where to install deal.II (Enter to confirm, ESC to cancel):"
  prefix_dir = curses.wrapper(lambda stdscr: tui_read_path("~/dcs2", instructions))

  if installation_mode == "DEFAULT":
    build_dir = f"{prefix_dir}/tmp"
    bin_dir = f"{prefix_dir}/bin"

    use_ninja = "DOWNLOAD"
    use_mold  = "DOWNLOAD"

    blas_stack = "FLAME"

  else: 
    instructions = "Please enter the path where to store the temporarie build files (Enter to confirm, ESC to cancel):"
    build_dir = curses.wrapper(lambda stdscr: tui_read_path(f"{prefix_dir}/tmp", instructions))

    instructions = "Please enter the path where to store binary files (Enter to confirm, ESC to cancel):"
    bin_dir = curses.wrapper(lambda stdscr: tui_read_path(f"{prefix_dir}/bin", instructions))


  # === Custom Options ===
  if installation_mode == "CUSTOM":
    # Choose to compile or download ninja and mold
    options = []
    options.append({"name": "mold", "mode": "DOWNLOAD"})
    options.append({"name": "ninja", "mode": "DOWNLOAD"})

    instructions = "Choose which build tools to use: (space to cycle: download →  compile (build from source) →  OFF, Enter to confirm):"
    modes = ["DOWNLOAD", "ON", "OFF"]
    install_tools = curses.wrapper(lambda stdscr: tui_select_with_options(instructions, options, modes))

    # Read the result
    use_ninja = install_tools.get("ninja", "DOWNLOAD")
    use_mold  = install_tools.get("mold", "DOWNLOAD")

    # Select the BLAS Stack:
    instructions = "Select the BLAS stack to use (↑/↓ to navigate, Enter to confirm):"
    options = [
      {"name": "FLAME",  "description": "Generic BLAS implementation from FLAME"},
      {"name": "SYSTEM", "description": "Use system-provided BLAS"},
      {"name": "AMD",    "description": "Optimized for AMD CPUs using AOCL"},
      {"name": "MKL",    "description": "Optimized for Intel CPUs using oneMKL"},
    ]
    blas_stack = curses.wrapper(lambda stdscr: tui_select_from_list(instructions, options))

    run_select_tpls()

  # === Write the result ===
  dcs2_root = os.getcwd()
  with open("dcs2_autogenerated-build-command.sh", "w") as file:
    file.write("#!/bin/bash\n") 
    file.write("\n") 
    file.write("# This file was autogenerated by 'scripts/tui.py'.\n")
    file.write("# All changes made to this file will be overwritten on the\n")
    file.write("# next run of 'scripts/tui.py'\n")
    file.write("\n") 
    file.write(f"{dcs2_root}/dcs2.sh \\\n") 
    file.write(f"  --prefix {prefix_dir} \\\n") 
    file.write(f"  --build {build_dir} \\\n")
    file.write(f"  --bin-dir {bin_dir} \\\n")
    file.write(f"  --add_to_path {add_to_path} \\\n")
    file.write(f"  --ninja {use_ninja} \\\n")
    file.write(f"  --mold {use_mold} \\\n")
    file.write(f"  --blas-stack {blas_stack} \\\n")
    file.write(f"  --user-interaction ON\n")

  # === Configuration done ===
  instructions = """\
Configuration Done!

The configuration was written to the file dcs2_autogenerated-build-command.sh. 
If you want to restart the installation, you can use the generated build command in that file or run:

  bash dcs2_autogenerated-build-command.sh

Next, we switch to the dcs2 install script...

(press enter to continue)
    """
  options = [
    {"name": "", "mode": "Okay"},
  ]
  modes = ["Okay"]
  curses.wrapper(lambda stdscr: tui_select_with_options(instructions, options, modes))


