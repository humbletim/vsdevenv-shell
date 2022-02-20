#!/bin/bash
which ml.exe 2>/dev/null && { dirname $(cygpath -ms "$(cygpath "$(which ml.exe)")"); exit 0; }
realpath "$(dirname "$(cygpath -ms "$(cygpath "$(which cl.exe)")")")/../x86"
