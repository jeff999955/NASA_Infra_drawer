import collections
from glob import glob
import json
from logging import getLevelName
import re
import os
from typing import OrderedDict

def get_name_wopo(str):
    return re.sub('(^(?!^VSS$)([a-zA-Z0-9- ]{3,}))-[1-4]$', '\\1', str).strip()

def get_mapping(str):
    if "core" in str.lower(): return "core"
    if "edge" in str.lower(): return "edge"
    str = get_name_wopo(str) 
    str = re.sub('\(.*\)', '', str)
    str = re.sub('to|uplink', '', str.lower()).strip()
    return re.sub('[^a-z0-9/-]|csie', '', str.lower())

def get_level(str):
    if "core" in str.lower(): return 1
    if "edge" in str.lower(): return 2
    if re.fullmatch("^[ab]-(0[1-9]|1[0-2])$", str): return 3
    return 4

class Status:
    CONNECTED = 0
    DISCONNECTED = 1
    DISABLED = 2
    UNKNOWN = 3

    mapping = collections.defaultdict(lambda: Status.UNKNOWN)
    
    mapping.update({
        "connected": CONNECTED,
        "notconnect": DISCONNECTED,
        "disabled": DISABLED,
    })

    def fromString(self, str):
        return Status.mapping[str]

class IntStat:
    def __init__(self, str):
        self.port = str[0:10].strip()
        self.to = str[10:29].strip()
        self.status = Status().fromString(str[29:42].strip())
        self.vlan = str[42:53].strip()
    def __str__(self) -> str:
        return f"{self.port} - {self.to} - {self.status} - {self.vlan}"

    def __repr__(self) -> str:
        return self.__str__()

class Switch:
    def __init__(self, orig_name, config_path):
        self.original_name = orig_name
        self.key_name = get_mapping(orig_name)
        self.full_name = get_name_wopo(orig_name)
        self.config_path = config_path
        self.path = os.path.join(config_path, orig_name)
        self.interface_status = []
        self.active_interfaces = []

    def parseInterfaceStatus(self):
        print("Getting int stat of", self.original_name)
        with open(os.path.join(self.config_path, self.original_name, "int_stat")) as f:
            data = f.readlines()[3:]

        data = [x.strip() for x in data]
        for d in data:
            try:
                int_stat = IntStat(d)
                self.interface_status.append(int_stat)
                if int_stat.status == Status.CONNECTED:
                    self.active_interfaces.append(int_stat)
                elif int_stat.status == Status.UNKNOWN:
                    print("Unknown:",d)
            except Exception as e:
                print(d)
                print("Error:",e)

    def getActiveInterfaces(self):
        return self.active_interfaces 



def main():
    config_path = "./config"
    switch_names = [switch for switch in os.listdir(config_path) if os.path.isdir(os.path.join(config_path, switch))]
    switches = [Switch(switch, config_path) for switch in switch_names]

    name_mapping = {}
    edges = collections.defaultdict(set)

    for switch in switches:
        switch.parseInterfaceStatus()
        mapped_name = switch.key_name 
        name_mapping[mapped_name] = switch.full_name

    for switch in switches:
        active_interfaces = switch.getActiveInterfaces()
        for int_stat in active_interfaces:
            if int_stat.to == "": continue
            orig_name = int_stat.to
            mapped_name = get_mapping(orig_name) 
            if mapped_name == "vss": continue
            if mapped_name not in name_mapping:
                name_mapping[mapped_name] = get_name_wopo(orig_name)
            edges[switch.key_name].add(mapped_name)

    sorted_mapping = OrderedDict(sorted(name_mapping.items(), key=lambda t: t[0]))
    edges = {k: list(v) for k, v in edges.items()}
    adjacency_list = OrderedDict(sorted(edges.items(), key=lambda t: (get_level(t[0]), t[0])))

    sorted_edges = [] 
    nodes = set()
    for src in adjacency_list:
        for dst in adjacency_list[src]:
            if get_level(src) < get_level(dst):
                # sorted_edges.append({"from": src, "to": dst})
                sorted_edges.append({"source": src, "target": dst})
                nodes.add(src)
                nodes.add(dst)

    sorted_edges.sort(key = lambda t: (get_level(t["from"]), get_level(t["to"]), t["from"], t["to"]))
    sorted_nodes = sorted(list(nodes), key=lambda t: (get_level(t), t))

    json_nodes = [{
            "id": node,
            "size": 100 * (4 - get_level(node))
        } for node in sorted_nodes]

    with open("name_mapping.json", "w") as f:
        print(json.dumps(sorted_mapping, indent=4), file=f)
    with open("data.json", "w") as f:
        print(json.dumps({"links": sorted_edges, "nodes": json_nodes}, indent=4), file=f)

    ## TODO: Check if R215 Fiber == R215 Core == R215
    ## TODO: What does uplink mean

if __name__ == "__main__":
    main()
    