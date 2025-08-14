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


def recursive_add(package, dependencie_graph, sorted_list):
    if package in sorted_list:
        return sorted_list

    package_dependencies = dependencie_graph[package]
    if len(package_dependencies) == 0:
        sorted_list.append(package)
        return sorted_list
    
    for dependencie in package_dependencies:
        sorted_list = recursive_add(dependencie, dependencie_graph, sorted_list)
    sorted_list.append(package)

    return sorted_list
            

def sort(dependencie_graph, unsorted_list):
    sorted_list = []
    for package in unsorted_list:
        sorted_list = recursive_add(package, dependencie_graph, sorted_list)

    return sorted_list


def main():
    input_files = sys.argv[1:]
    dependencie_graph, unsorted_list = parse_dependencies(input_files)
    sorted_list = sort(dependencie_graph, unsorted_list)

    # Remove all packages that are not in the input list
    sorted_list_filtered = list(filter(lambda package: package in unsorted_list, sorted_list))

    print(";".join(sorted_list_filtered))


if __name__ == "__main__":
    main()

