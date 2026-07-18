#!/bin/bash
#
# Renzo: note, you might need to install "pip install ./python" locally. 
# 
# Run NORDIC denoising on a magnitude-only fMRI time series.
#
# Usage:
#   ./run_nordic_magnitude.sh
#   KERNEL_SIZE_PCA=10,10,10 ./run_nordic_magnitude.sh
#
# Tunable environment variables (all optional):
#   MAG_FILE          input magnitude nii.gz (default: Stcat_bold_.nii.gz)
#   OUT_DIR           output directory (default: nordic_output)
#   ALGORITHM         nordic | mppca | gfactor+mppca (default: nordic)
#   KERNEL_SIZE_PCA   PCA kernel as X,Y,Z (default: auto)
#   KERNEL_SIZE_GFACTOR  g-factor kernel as X,Y,Z (default: auto -> 14,14,1)
#   N_JOBS            worker threads (default: 1)
#   PREFIX            output filename prefix (default: none)

set -euo pipefail

MAG_FILE="${MAG_FILE:-Stcat_bold_.nii.gz}"
OUT_DIR="${OUT_DIR:-nordic_output}"
ALGORITHM="${ALGORITHM:-nordic}"
KERNEL_SIZE_PCA="${KERNEL_SIZE_PCA:-}"
KERNEL_SIZE_GFACTOR="${KERNEL_SIZE_GFACTOR:-}"
N_JOBS="${N_JOBS:-1}"
PREFIX="${PREFIX:-}"

# Use the local virtual environment created for this project.
source "$(dirname "$0")/venv_nordic/bin/activate"

# Build the python command.
CMD=(
    python "$(dirname "$0")/run_nordic_magnitude.py"
    --magnitude "$MAG_FILE"
    --out-dir "$OUT_DIR"
    --algorithm "$ALGORITHM"
    --n-jobs "$N_JOBS"
)

if [ -n "$KERNEL_SIZE_PCA" ]; then
    CMD+=(--kernel-size-pca "$KERNEL_SIZE_PCA")
fi

if [ -n "$KERNEL_SIZE_GFACTOR" ]; then
    CMD+=(--kernel-size-gfactor "$KERNEL_SIZE_GFACTOR")
fi

if [ -n "$PREFIX" ]; then
    CMD+=(--prefix "$PREFIX")
fi

# For reproducibility, constrain BLAS to one thread per worker when N_JOBS > 1
# to avoid oversubscription. See run_nordic docstring for details.
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1

# Append any extra command-line arguments passed to this script (e.g. --help).
if [ $# -gt 0 ]; then
    CMD+=("$@")
fi

echo "Running: ${CMD[*]}"
"${CMD[@]}"
