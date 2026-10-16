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
  # The installer build is per platform and architecture. macOS downloads
  # with curl because stock macOS has no wget.
  if [[ $OSTYPE == darwin* ]]; then
    if [[ $(uname -m) == arm64 ]]; then
      conda_build=MacOSX-arm64
    else
      conda_build=MacOSX-x86_64
    fi
  else
    conda_build=Linux-x86_64
  fi
  installer="Miniconda3-latest-$conda_build.sh"
  if [[ $OSTYPE == darwin* ]]; then
    curl --fail --silent --show-error --location "https://repo.anaconda.com/miniconda/$installer" -o "$dirname/$installer"
  else
    wget "https://repo.anaconda.com/miniconda/$installer" -O "$dirname/$installer"
  fi
  chmod +x "$dirname/$installer"
  bash "$dirname/$installer" -b
  rm -f "$dirname/$installer"
fi

# PEP 668 marker keeping pip and uv out of base.
# A python feature-version upgrade relocates the stdlib directory, leaving the new one unmarked.
stdlib="$("$conda_root/bin/python" -c 'import sysconfig; print(sysconfig.get_path("stdlib"))')"
cat > "$stdlib/EXTERNALLY-MANAGED" <<'MARKER'
[externally-managed]
Error=The conda base environment is externally managed. Use `conda install -n base <pkg>`, or create a per-project environment.
MARKER
echo "ok       conda base marked externally managed"
