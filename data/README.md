# Dataset access and redistribution policy

The repository **does not redistribute third-party benchmark data by default**.
This keeps the source repository small and avoids accidental redistribution
outside the terms of the original data providers.

Place processed files under `data/processed/` using the paths expected by
`scripts/config_benchmarks.m`.

| Dataset | Official / primary source | License / terms found | Approx. source size | Repository recommendation |
|---|---|---|---:|---|
| Kuzushiji-49 | https://github.com/rois-codh/kmnist | CC BY-SA 4.0 (dataset and repo) | ~74 MB compressed for K49 arrays | Download from source. Rehosting is possible with attribution/share-alike, but not recommended in the main repo. |
| EMNIST Balanced | https://www.nist.gov/itl/products-and-services/emnist-dataset | Hosted by NIST; NIST generally permits copying/distribution of non-copyright-marked public information, with attribution. | tens to hundreds of MB depending on package | Download from NIST. Do not bundle until page-specific redistribution terms are confirmed. |
| MNIST | https://yann.lecun.org/exdb/mnist/ | Original page does not state an explicit license. | ~11 MB compressed | Download from original/mirror; do not rehost in this repo. |
| Fashion-MNIST | https://github.com/zalandoresearch/fashion-mnist | MIT License shown in the official repository | ~30 MB compressed | Redistribution is permissive with license notice, but download-on-demand is cleaner. |
| CIFAR-10 | https://www.cs.toronto.edu/~kriz/cifar.html | Official page requests citation but does not state a redistribution license. | 162–175 MB | Do not rehost. Download from the official source. |
| CIFAR10-ResNet50 | Derived from CIFAR-10 | Derived feature file; source-image terms still matter. | local feature file may be hundreds of MB | Do not commit the `.mat` feature file. Provide the extraction procedure or an external archive only after confirming terms. |
| Pavia University | https://www.ehu.eus/ccwintco/index.php/Hyperspectral_Remote_Sensing_Scenes | Official page identifies the provider but no explicit redistribution license was located. | ~33 MB data + ground truth | Link to the official source; do not rehost. |
| UCI HAR | https://archive.ics.uci.edu/dataset/240/human+activity+recognition+using+smartphones | CC BY 4.0 | ~58 MB | May be redistributed with attribution, but download-on-demand is recommended. |
| USPS | https://www.csie.ntu.edu.tw/~cjlin/libsvmtools/datasets/ | Public LIBSVM mirror; no explicit dataset redistribution license located on the index page. | ~8 MB compressed | Link to LIBSVM/original source; do not rehost. |
| ISOLET | https://archive.ics.uci.edu/dataset/54/isolet | CC BY 4.0 | ~9.6 MB | May be redistributed with attribution; download-on-demand recommended. |
| Gisette | https://archive.ics.uci.edu/dataset/170/gisette | CC BY 4.0 | ~20.3 MB | May be redistributed with attribution; download-on-demand recommended. |
| COIL20 | https://www.cs.columbia.edu/CAVE/databases/SLAM_coil-20_coil-100/ | Original Columbia page provides downloads but no explicit redistribution license was located. | modest | Link to original source; do not rehost. |
| ORL / AT&T Faces | https://cam-orl.co.uk/facedatabase.html/ | Official page asks users to credit AT&T Laboratories Cambridge; no explicit open redistribution license is stated. | ~4.5 MB | **Do not rehost face images.** Download from the original source and give required credit. |

## Exact processed filenames used by the public scripts

```text
data/processed/
├─ K49/K49.mat
├─ EMNIST/EMNIST_Balanced.mat
├─ MNIST/MNIST.mat
├─ fashion/FashionMNIST.mat
├─ CIFAR10_ResNet50/CIFAR10_ResNet50.mat
├─ paviau/PaviaU_clustering.mat
├─ UCI HAR/HAR.mat
├─ USPS/USPS.mat
├─ ISOLET/ISOLET.mat
├─ gisette_X.csv
├─ gisette_Y.csv
├─ COIL20_X_1_0_.csv
├─ COIL20_Y_1_0_.csv
├─ ORL_X_1_0_.csv
└─ ORL_Y_1_0_.csv
```

For `.mat` files, the loader accepts common feature names such as `X`, `data`,
or `features`, and label names such as `Y`, `y`, `label`, `gnd`, or `gt`.

## Recommended paper wording

> All benchmark datasets are publicly available from their original
> providers. Source links, preprocessing/file-layout instructions, and the
> code used in the experiments are provided in the project repository.
