# Configuration file for the 'lit' test runner.

import os
import sys
import re
sys.path.append(os.path.dirname(os.path.abspath(__file__)))  # noqa
from test_format import MakeTest


def get_build_config():
    # Read CMakeCache.txt to find our build settings
    need = ['BUILD_PLATFORM', 'OPT_LEVEL', 'SANITIZERS', 'LTO']
    found = dict()
    expected = set(need)

    with open("CMakeCache.txt", 'r') as cf:
        var_regex = re.compile("(?P<var>.+):.+=(?P<value>.+)")

        for line in cf.read().splitlines():
            m = var_regex.match(line)
            if m:
                var_name = m.group('var')
                if var_name in expected:
                    found[var_name] = m.group('value')
                    expected.remove(var_name)

                    if not expected:
                        break

        if expected:
            raise RuntimeError("Couldn't find the build config.")

    # Don't rely on dict order, or order of vars in CMakeCache.txt
    return [found[k] for k in need]


platform, opt_level, sanitizers, lto = get_build_config()
config.name = '{}_O{}_SANITIZERS_{}_LTO_{}'.format(
        platform, opt_level, sanitizers, lto)
config.test_format = MakeTest()
config.suffixes = ['.log']
config.test_source_root = os.path.dirname(__file__)
config.test_exec_root = os.path.join(config.test_source_root, '..')

# Exclude cmake related directory
config.excludes.add('CMakeFiles')

config.excludes.add('shell')
# lower() because Github Actions config is case sensitive
# but local use may not be
if platform.lower() == 'aarch64':
    config.excludes.add('threadlocalstorage')
if platform.lower() == 'thumb' and \
        opt_level == '3' and \
        sanitizers == 'ON':
    config.excludes.add('loadbinaries')
if not (
        (platform.lower() == 'arm') and
        (opt_level == '0')):
    config.excludes.add('backtrace')
if lto == 'ON':
    config.excludes.add('loadbinary')
    config.excludes.add('loadbinaries')
    config.excludes.add('loadpiebinary')
