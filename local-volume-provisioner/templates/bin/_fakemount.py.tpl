#!/usr/bin/env python3
#
# Copyright 2019 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
"""Fakemount python module
The module is aimed to crate fake mountpoints (--bind).
Example:
  python3  fakemount --config-file '/root/mymount.yml'
Attributes:
  config-file - file path to config file that contains fake mounts.
"""
__version__ = "1.0"
import argparse
import logging
import os
import re
import subprocess
import sys
from collections import defaultdict
import yaml
logging.basicConfig(stream=sys.stdout, level=logging.INFO)
LOG = logging.getLogger(__name__)
MOUNT_BIN = "/bin/mount"
###Fork https://github.com/b10011/pyfstab/ #####################################
#  Latest commit 828540d
class InvalidEntry(Exception):
    """
    Raised when a string cannot be generated because of the Entry is invalid.
    """
class InvalidFstabLine(Exception):
    """
    Raised when a line is invalid in fstab. This doesn't just mean that the
    Entry will be invalid but also that the system can not process the fstab
    file fully either.
    """
class Entry:
    """
    Handles parsing and formatting fstab line entries.
    :var device:
        (str or None) -
        Fstab device (1st parameter in the fstab entry)
    :var dir:
        (str or None) -
        Fstab device (2nd parameter in the fstab entry)
    :var type:
        (str or None) -
        Fstab device (3rd parameter in the fstab entry)
    :var options:
        (str or None) -
        Fstab device (4th parameter in the fstab entry)
    :var dump:
        (int or None) -
        Fstab device (5th parameter in the fstab entry)
    :var fsck:
        (int or None) -
        Fstab device (6th parameter in the fstab entry)
    :var valid:
        (bool) -
        Whether the Entry is valid or not. Can be checked with "if entry:".
    """
    def __init__(
            self,
            _device=None,
            _dir=None,
            _type=None,
            _options=None,
            _dump=None,
            _fsck=None,
    ):
        """
        :param _device: Fstab device (1st parameter in the fstab entry)
        :type _device: str
        :param _dir: Fstab device (2nd parameter in the fstab entry)
        :type _dir: str
        :param _type: Fstab device (3rd parameter in the fstab entry)
        :type _type: str
        :param _options: Fstab device (4th parameter in the fstab entry)
        :type _options: str
        :param _dump: Fstab device (5th parameter in the fstab entry)
        :type _dump: int
        :param _fsck: Fstab device (6th parameter in the fstab entry)
        :type _fsck: int
        """
        self.device = _device
        self.dir = _dir
        self.type = _type
        self.options = _options
        self.dump = _dump
        self.fsck = _fsck
        self.valid = True
        self.valid &= self.device is not None
        self.valid &= self.dir is not None
        self.valid &= self.type is not None
        self.valid &= self.options is not None
        self.valid &= self.dump is not None
        self.valid &= self.fsck is not None
    def read_string(self, line):
        """
        Parses an entry from a string
        :param line: Fstab entry line.
        :type line: str
        :return: self
        :rtype: Entry
        :raises InvalidEntry: If the data in the string cannot be parsed.
        """
        line = line.strip()
        if line and not line[0] == "#":
            parts = re.split(r"\s+", line)
            if len(parts) == 6:
                [_device, _dir, _type, _options, _dump, _fsck] = parts
                _dump = int(_dump)
                _fsck = int(_fsck)
                self.device = _device
                self.dir = _dir
                self.type = _type
                self.options = _options
                self.dump = _dump
                self.fsck = _fsck
                self.valid = True
                return self
            else:
                raise InvalidFstabLine()
        self.device = None
        self.dir = None
        self.type = None
        self.options = None
        self.dump = None
        self.fsck = None
        self.valid = False
        raise InvalidEntry("Entry cannot be parsed")
    def write_string(self):
        """
        Formats the Entry into fstab entry line.
        :return: Fstab entry line.
        :rtype: str
        :raises InvalidEntry:
            A string cannot be generated because the entry is invalid.
        """
        if self:
            return "{} {} {} {} {} {}".format(
                self.device,
                self.dir,
                self.type,
                self.options,
                self.dump,
                self.fsck,
            )
        else:
            raise InvalidEntry("Entry cannot be formatted")
    def __bool__(self):
        return self.valid
    def __str__(self):
        return self.write_string()
    def __repr__(self):
        try:
            return "<Entry {}>".format(str(self))
        except InvalidEntry:
            return "<Entry Invalid>"
class Fstab:
    """
    Handles reading, parsing, formatting and writing of fstab files.
    :var entries:
        (list[Entry]) -
        List of entries.
        When writing to a file, entries are listed from this list.
    :var entries_by_device:
        (dict[str, list[Entry]]) -
        Fstab entries by device.
    :var entry_by_dir:
        (dict[str, Entry]) -
        Fstab entry by directory.
    :var entries_by_type:
        (dict[str, list[Entry]]) -
        Fstab entries by type.
    """
    def __init__(self):
        self.entries = []
        # A single device can have multiple mountpoints
        self.entries_by_device = defaultdict(list)
        # If multiple devices have same mountpoint, only the last entry in the
        # fstab file is taken into consideration
        self.entry_by_dir = dict()
        # And the most obvious one, many entries can have mountpoints of same
        # type
        self.entries_by_type = defaultdict(list)
    def read_string(self, data, only_valid=False):
        """
        Parses entries from a data string
        :param data: Contents of the fstab file
        :type data: str
        :param only_valid:
            Skip the entries that do not actually mount. For example, if device
            A is mounted to directory X and later device B is mounted to
            directory X, the A mount to X is undone by the system.
        :type only_valid: bool
        :return: self
        :rtype: Fstab
        """
        for line in reversed(data.splitlines()):
            try:
                entry = Entry().read_string(line)
                if entry and (
                        not only_valid or entry.dir not in self.entry_by_dir
                ):
                    self.entries.insert(0, entry)
                    self.entries_by_device[entry.device].insert(0, entry)
                    self.entry_by_dir[entry.dir] = entry
                    self.entries_by_type[entry.type].insert(0, entry)
            except InvalidEntry:
                pass
        return self
    def write_string(self):
        """
        Formats entries into a string.
        :return: Formatted fstab file.
        :rtype: str
        :raises InvalidEntry:
            A string cannot be generated because one of the entries is invalid.
        """
        return "\n".join(str(entry) for entry in self.entries)
    def read_file(self, handle, only_valid=False):
        """
        Parses entries from a file
        :param handle: File handle
        :type handle: file
        :param only_valid:
            Skip the entries that do not actually mount. For example, if device
            A is mounted to directory X and later device B is mounted to
            directory X, the A mount to X is undone by the system.
        :type only_valid: bool
        :return: self
        :rtype: Fstab
        """
        self.read_string(handle.read(), only_valid)
        return self
    def write_file(self, handle):
        """
        Parses entries in data string
        :param path: File handle
        :type path: file
        :return: self
        :rtype: Fstab
        """
        handle.write(str(self))
        return self
    def __bool__(self):
        return len(self.entries) > 0
    def __str__(self):
        return self.write_string()
    def __repr__(self):
        res = "<Fstab [{} entries]".format(len(self.entries))
        if self.entries:
            res += "\n"
            for entry in self.entries:
                res += "  {}\n".format(entry)
        res += ">"
        return res
###End Fork https://github.com/b10011/pyfstab/ #################################
def fstab_bindmount(src, mountpoint, fstab_path="/mnt/host/fstab", opts=None):
    if opts is None:
        opts = ["bind"]
    mountpoint = os.path.normpath(mountpoint.strip())
    with open(fstab_path, "r") as f:
        fstab = Fstab().read_file(f)
    if mountpoint in fstab.entry_by_dir:
        LOG.info(f'Mount point {mountpoint} already defined in {fstab_path}')
        return
    fstab.entries.append(Entry(src, mountpoint, "none", ",".join(opts), 0, 0))
    str_fstab = str(fstab)
    LOG.info(f'Attempt to overwrite file:{fstab_path}, with data:\n'
             f'{str_fstab}')
    with open(fstab_path, "w") as f:
        f.write(str_fstab)
def get_volumes(mount_point, i):
    vol_template = "vol%d%%d" % i
    volumes = mount_point.get("mounts")
    if volumes is not None:
        return volumes
    return [vol_template % vol_number for vol_number in
            range(mount_point["volPerNode"])]
def ensure_directories_exists(storage_class):
    target_root = storage_class.get("mountDir", storage_class["hostDir"])
    for i, bind_mount in enumerate(storage_class["bindMounts"]):
        for vol_name in get_volumes(bind_mount, i):
            source = os.path.normpath(f"{bind_mount['srcRoot']}/{vol_name}")
            target = os.path.normpath(f"{target_root}/{vol_name}")
            os.makedirs(target, exist_ok=True)
            os.makedirs(source, exist_ok=True)
def is_mount(directory):
    # Do not use os.path.ismount due to bug
    # https://bugs.python.org/issue29707
    directory = os.path.normpath(directory.strip())
    with open("/proc/mounts") as f:
        for line in f.readlines():
            if line.split(" ")[1] == directory:
                return True
def mount_directories(storage_class):
    failed_mounts = []
    target_root = storage_class.get("mountDir", storage_class["hostDir"])
    additional_opts = storage_class.get("additionalMountOptions", [])
    opts = ["bind"] + additional_opts
    for i, bind_mount in enumerate(storage_class["bindMounts"]):
        for vol_name in get_volumes(bind_mount, i):
            source = os.path.normpath(f"{bind_mount['srcRoot']}/{vol_name}")
            target = os.path.normpath(f"{target_root}/{vol_name}")
            LOG.info(f"Trying to mount {source} to {target}")
            if is_mount(target):
                LOG.info(
                    f"The directory {target} already mounted, skipping it...")
            else:
                cmd = [MOUNT_BIN, "-o", ",".join(opts), source, target]
                LOG.info(f"Running {cmd}")
                obj = None
                try:
                    obj = subprocess.run(
                        cmd,
                        stdout=subprocess.PIPE,
                        stderr=subprocess.PIPE,
                    )
                    obj.check_returncode()
                except Exception as e:
                    LOG.exception(
                        f"Failed to mount {source} {target}\n"
                        f"stdout: {obj.stdout}\n"
                        f"stderr: {obj.stderr}"
                    )
                    failed_mounts.append((source, target))
                else:
                    LOG.info(f"Successfully mount {source} {target}")
            fstab_bindmount(source, target, opts=opts)
    if failed_mounts:
        raise Exception(f"Failed to mount some directories: {failed_mounts}")
def main():
    parser = argparse.ArgumentParser(
        description="Create fake mountpotins with specified directories."
    )
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument(
        "--config-file", help="Path to file with image layout",
    )
    parser.add_argument(
        "--create-only",
        help="Ensure target directories exists.",
        dest="create_only",
        action="store_true",
    )
    parser.set_defaults(create_only=False)
    args = parser.parse_args()
    with open(args.config_file) as f:
        data = yaml.safe_load(f)
    if data is None:
        LOG.exception("Invalid data supplied from the config file.")
        raise Exception
    classes_data = data.get("classes", [])
    if isinstance(classes_data, list):
        for storage_class in classes_data:
            ensure_directories_exists(storage_class)
        if not args.create_only:
            for storage_class in classes_data:
                mount_directories(storage_class)
if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        LOG.exception("Can't create volume mounts.")
        sys.exit(1)
