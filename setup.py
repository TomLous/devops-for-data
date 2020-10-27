import shlex
import sys
from subprocess import check_output

from setuptools import setup

GIT_HEAD_REV = check_output(shlex.split('git rev-parse --short HEAD')).decode(sys.stdout.encoding).strip()
STABLE_VERSION = True

try:
    check_output(shlex.split('git describe --exact-match --tags HEAD')).decode(sys.stdout.encoding).strip()
except:
    STABLE_VERSION = False

if STABLE_VERSION:
    tag_build = ""
else:
    tag_build = "_" + GIT_HEAD_REV

# All config is in setup.cfg
setup(
    options=dict(egg_info=dict(tag_build=tag_build))
)
