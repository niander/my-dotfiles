#!/bin/bash

set -e

dirname="$(dirname "$0")"
conda_root="$HOME/miniconda3"

echo ''

if test -d "$conda_root"
then
  echo 'Current installation of miniconda 3 was found at ~/miniconda'
  echo ''
else
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $dirname/miniconda-latest-linux-64.sh
  chmod +x $dirname/miniconda-latest-linux-64.sh
  bash $dirname/miniconda-latest-linux-64.sh -b
  rm -f $dirname/miniconda-latest-linux-64.sh
fi

# PEP 668 marker keeping pip and uv out of base.
# A python feature-version upgrade relocates the stdlib directory, leaving the new one unmarked.
stdlib="$("$conda_root/bin/python" -c 'import sysconfig; print(sysconfig.get_path("stdlib"))')"
cat > "$stdlib/EXTERNALLY-MANAGED" <<'MARKER'
[externally-managed]
Error=The conda base environment is externally managed. Use `conda install -n base <pkg>`, or create a per-project environment.
MARKER
echo "ok       conda base marked externally managed"
