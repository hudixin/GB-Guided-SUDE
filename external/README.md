# External dependency: SUDE

GB-Guided SUDE builds on the published SUDE manifold-learning method.

Official repositories:

- MATLAB / original toolkit: https://github.com/ZPGuiGroupWhu/sude
- Python package: https://github.com/ZPGuiGroupWhu/SUDE-pkg

The Python package explicitly states an MIT license. The MATLAB repository
currently does not expose a top-level LICENSE file in its public root listing,
so this release takes the conservative approach of **not redistributing the
MATLAB SUDE source**.

Run:

```matlab
setup_external_sude
```

to download the official MATLAB repository into `external/sude/`.

If the SUDE authors confirm that the MATLAB source is covered by MIT (or grant
redistribution permission), a future release can vendor the exact upstream
revision with its copyright/license notice intact.
