#!/bin/bash
# Load the blast module
module load blast

set -e

"$@"
