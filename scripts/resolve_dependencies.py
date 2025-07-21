import sys
import os
import re
from collections import defaultdict, deque

def parse_dependencies(files):
    dep_graph = defaultdict(set)
    package_map = {}

    for filepath in files:
        package = os.path.splitext(os.path.basename(filepath))[0]
        package_map[package] = filepath

        with open(filepath, "r") as f:
            content = f.read()
            matches = re.findall(r'list\(APPEND (\w+)_dependencies\s+"([^"]+)"\)', content)
            for target, dep in matches:
                dep_graph[target].add(dep)

    return dep_graph, list(package_map.keys())

def topological_sort(dep_graph, input_packages):
    reverse_graph = defaultdict(set)
    for target, deps in dep_graph.items():
        if target not in input_packages:
            continue
        for dep in deps:
            if dep in input_packages:
                reverse_graph[target].add(dep)

    in_degree = {pkg: 0 for pkg in input_packages}
    for deps in reverse_graph.values():
        for dep in deps:
            in_degree[dep] += 1

    queue = deque([pkg for pkg in input_packages if in_degree[pkg] == 0])
    sorted_order = []

    while queue:
        pkg = queue.popleft()
        sorted_order.append(pkg)
        for neighbor in reverse_graph.get(pkg, []):
            in_degree[neighbor] -= 1
            if in_degree[neighbor] == 0:
                queue.append(neighbor)

    if len(sorted_order) != len(input_packages):
        raise RuntimeError("Cycle detected or missing dependencies")

    return sorted_order

def main():
    input_files = sys.argv[1:]
    dep_graph, input_packages = parse_dependencies(input_files)
    sorted_packages = topological_sort(dep_graph, input_packages)
    print(";".join(reversed(sorted_packages)))  # CMake-friendly output


if __name__ == "__main__":
    main()

