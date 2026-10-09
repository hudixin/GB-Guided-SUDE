# Public release checklist

Before making the GitHub repository public:

- [ ] Confirm paper title and author list.
- [ ] Confirm `alpha = 0.2`, `c = 16`, `m = 3`, `d = 30`.
- [ ] Run `setup_external_sude.m`.
- [ ] Run `run_synthetic_demo.m`.
- [ ] Test at least one real benchmark using your processed local file.
- [ ] Do not commit `data/raw/`, `data/processed/`, or `external/sude/`.
- [ ] If you later vendor SUDE MATLAB files, obtain/confirm redistribution
      permission and preserve the upstream copyright/license notice.
- [ ] Add the final GitHub URL to the manuscript abstract.
