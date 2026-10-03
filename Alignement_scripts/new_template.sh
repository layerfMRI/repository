export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=5
export ANTS_RANDOM_SEED=42

antsMultivariateTemplateConstruction2.sh \
  -d 3 -o template_ -k 1 -w 1 \
  -n 0 -r 1 -i 5 -a 2 -g 0.15 \
  -t SyN[0.1,4,0.5] \
  -m CC[4] \
  -q 100x70x50x20 \
  -f 8x4x2x1 \
  -s 4x2x1x0vox \
  -y 0 \
  -b 1 \
  -c 2 -j 20 \
  vol*.nii