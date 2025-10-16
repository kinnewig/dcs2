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
  name_width   = max(len(opt["name"].removeprefix("TPL_ENABLE_")) for opt in tpls)
  desc_start_col = name_width + 4 + 1  # +4 for "[x] " or "[ ] " and +1 for spacing

  while True:
    stdscr = curses.initscr()
    stdscr.clear()
    stdscr.addstr(0, 0, "Select TPL packages (space to toggle, enter to confirm):")

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



def run_select_tpls():
  # Read the TPLs from the CMakeLists.txt
  tpls = tpls_read_from_cmake("CMakeLists.txt")

  # These TPLs are handeled by the BLAS stack option
  excluded_tpls = {"TPL_ENABLE_BLIS", "TPL_ENABLE_LIBFLAME", "TPL_ENABLE_SCALAPACK"}
  filtered_tpls = [tpl for tpl in tpls if tpl["name"] not in excluded_tpls]

  # Let the user select
  selected_tpls = curses.wrapper(lambda stdscr: tpls_tui_select(filtered_tpls))

  # Write the changes to the CMakeLists.txt
  tpls_update_cmake(selected_tpls, "CMakeLists.txt")



if __name__ == "__main__":
  run_select_tpls()
