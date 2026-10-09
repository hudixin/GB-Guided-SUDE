# GB-Guided SUDE

Official research-code release for:

**GB-Guided SUDE: Granular-Ball Landmark Compression for Scalable High-Dimensional Clustering**

GB-Guided SUDE compresses the PPS landmark set with a granular-ball
coarse-graining stage, retains one real PPS representative per terminal ball,
and completes the landmark budget using RNN importance before SUDE embedding.

## Repository policy

- The GB-guided compression/integration code authored for this project is
  included here.
- The upstream **SUDE MATLAB source is not redistributed**. Run
  `setup_external_sude.m` to obtain it from the official repository.
- Third-party raw benchmark datasets are **not bundled**. See
  `data/README.md` for official sources and licensing notes.

## Requirements

Tested with MATLAB R2025a.

The code uses MATLAB functions including `knnsearch`, `kmeans`, `pdist2`, and
`matchpairs`.

## Quick start

1. Open MATLAB in the repository root.
2. Download the official SUDE dependency:

```matlab
setup_external_sude
```

3. Initialize the local paths and check the generated demo:

```matlab
startup_gbsude
run_synthetic_demo
```

4. For the paper benchmarks, download datasets from the original providers,
   prepare the files described in `data/README.md`, and run:

```matlab
startup_gbsude
T = run_all_benchmarks;
```

Results are written to `results/gbsude_results.csv`.

## Paper configuration

```text
Target dimension d = 30
Landmark coefficient c = 16
GB alpha            = 0.2
Minimum child size  = 3
Root seed            = 2026
Root replicates      = 20
K-means seed         = 2026
K-means replicates   = 10
```

The target landmark budget is

```text
L = min(P, max(d+2, ceil(c*sqrt(Nu))))
```

where `P` is the PPS landmark count and `Nu` is the number of unique samples.

## Directory layout

```text
GB-Guided-SUDE/
├─ README.md
├─ LICENSE
├─ CITATION.cff
├─ THIRD_PARTY.md
├─ setup_external_sude.m
├─ startup_gbsude.m
├─ src/
│  ├─ gbsude/
│  └─ evaluation/
├─ scripts/
├─ data/
│  ├─ README.md
│  ├─ raw/
│  └─ processed/
├─ external/
│  └─ README.md
└─ results/
```

## Data availability

All benchmark datasets are publicly available from their original providers.
The project does not rehost datasets whose redistribution terms are unclear.
Official source links and expected processed filenames are listed in
`data/README.md`.

## Reproducibility note

Runtime depends on MATLAB version, hardware, and the exact upstream SUDE
revision. Local absolute paths are stripped from exported result metadata. The repository includes the method parameters and a reference result
table from the authors' experiment environment so that users can compare
quality and landmark-retention behavior.

## Citation

If this code is useful, please cite the ICGBC 2026 paper and the original SUDE
paper. See `CITATION.cff`.

## License

Repository-authored code is released under the MIT License. This license does
**not** relicense SUDE or any benchmark dataset. See `THIRD_PARTY.md`.
