# 3D Gaussian Splatting with Normal Information for Mesh Extraction and Improved Rendering

Meenakshi Krishnan, Liam Fowl, Ramani Duraiswami

ICASSP 2025 Workshop on Generative Data Augmentation for Real-World Signal Processing Applications

[Paper (IEEE)](https://ieeexplore.ieee.org/abstract/document/11011170) | [arXiv](https://arxiv.org/abs/2501.08370)

We regularize 3D Gaussian Splatting with the gradient of the signed distance function (SDF) estimated
from the Gaussians, supervised by monocular normals. This improves rendering quality on
Mip-NeRF360, Tanks and Temples and Deep Blending while still allowing a surface mesh to be extracted.

## Method
The regularization is added in the coarse SDF stage, `sugar_trainers/coarse_sdf.py`. From iteration 9000 on:
1. the SDF gradient at each Gaussian is estimated as the normalized sum of the normals of its nearest neighbouring Gaussians;
2. it is rendered into the current training view (`SuGaR.render_normal` in `sugar_scene/sugar_model.py`);
3. the rendered normal map is compared with the monocular normal map of that view, and
   `normal_factor * (1 - cosine_similarity)` is added to the loss.

## Setup
The environment is the same as SuGaR's. Create it from `environment.yml`, then install the
Gaussian Splatting rasterizer and simple-knn from `gaussian_splatting/submodules/` (or run `python install.py`).

## Monocular normals
Predict normals for every training image with [Omnidata](https://github.com/EPFL-VILAB/omnidata)
(the DPT normal model). Save one `.npy` per image:
- shape `(3, H, W)`, float32, values in `[0, 1]`, same resolution as the images in `<scene>/images`;
- file names must sort in the same order as the images (e.g. `00001.npy` or `_DSC8679.npy`).

By default they are read from `<scene_path>/normals_from_pretrain/`; use `--normals_dir` to point elsewhere.

## Training and evaluation
1. Train vanilla 3D Gaussian Splatting for 7,000 iterations (checkpoints are saved at 7k and 30k):
   ```bash
   python gaussian_splatting/train.py -s <scene_path> -m <gs_checkpoint_dir> --iterations 7000
   ```
2. Train with normal supervision, then extract and refine the mesh:
   ```bash
   python train.py -s <scene_path> -c <gs_checkpoint_dir>/ -r sdf \
       --normal_factor 0.1 --normals_dir <scene_path>/normals_from_pretrain --gpu 0
   ```
3. Evaluate (PSNR / SSIM / LPIPS on the test split):
   ```bash
   python metrics.py --scene_config <metrics_scene.json> -r sdf --normal_factor 0.1 --gpu 0
   ```

`run_mipnerf.sh`, `run_data.sh` and `test*.sh` are the sweep scripts we used. They contain absolute paths from our machine.

## Citation
```bibtex
@inproceedings{krishnan2025normal,
  title     = {3D Gaussian Splatting with Normal Information for Mesh Extraction and Improved Rendering},
  author    = {Krishnan, Meenakshi and Fowl, Liam and Duraiswami, Ramani},
  booktitle = {ICASSP 2025 Workshop on Generative Data Augmentation for Real-World Signal Processing Applications},
  year      = {2025},
  url       = {https://ieeexplore.ieee.org/abstract/document/11011170}
}
```

## Acknowledgements
This code is built on [SuGaR](https://github.com/Anttwo/SuGaR) (Guédon and Lepetit, CVPR 2024) and the original
[3D Gaussian Splatting](https://github.com/graphdeco-inria/gaussian-splatting) (Kerbl et al., SIGGRAPH 2023).
We thank the authors of both for releasing their code. Monocular normals come from [Omnidata](https://github.com/EPFL-VILAB/omnidata).
See `LICENSE.md`.
