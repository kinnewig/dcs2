import curses
import subprocess
import re

def get_git_tags():
  try:
    result = subprocess.run(['git', 'tag'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
    return result.stdout.splitlines()
  except subprocess.CalledProcessError as e:
    print("Error retrieving git tags:", e.stderr)
    return []



def extract_dealii_version(tags):
  pattern = re.compile(r'^(\d+\.\d+\.\d+)\.\w+$')
  dealii_versions = set()

  for tag in tags:
    match = pattern.match(tag)
    if match:
      dealii_versions.add(match.group(1))

  dealii_versions_string = [{"name": tag} for tag in sorted(dealii_versions)]
  dealii_versions_string.append({"name": "main"})

  return dealii_versions_string



def latest_dcs2_for_dealii_version(dealii_version):
  """
  Given an deal.II version string, find the corresponding tag that corresponds to the latest version of dcs2 building that deal.II version.
  """

  if dealii_version == "main":
    return "main"

  tags = get_git_tags()
  pattern = re.compile(rf'^{re.escape(dealii_version)}\.(\d+)$')
  max_v = -1
  latest_tag = None

  for tag in tags:
    match = pattern.match(tag)
    if match:
      v = int(match.group(1))
      if v > max_v:
        max_v = v
        latest_tag = tag

  return latest_tag



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
        line = f"{opt['name']}".ljust(desc_start_col)
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
    curses.endwin()

  return options[current]["name"]



def select_dealii_version():
  tags = get_git_tags()

  instructions = "Choose a deal.II version:\nUse arrow keys and press Enter"
  options = extract_dealii_version(tags)
  selected_dealii_version = tui_select_from_list(instructions, options)

  tag = latest_dcs2_for_dealii_version(selected_dealii_version)

  try:
    subprocess.run(['git', 'checkout', tag], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
  except subprocess.CalledProcessError as e:
    print(f"Failed to check out tag '{tag}': {e.stderr}")


if __name__ == "__main__":
  select_dealii_version()
