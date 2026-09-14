# OCEAN 215 JupyterHub image
All notable changes to the OCEAN 215 JupyterHub image will be documented here. 

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2026.1.2] - 2026-09-14

### Fixed

- Fixed version conflicts between argopy and erddapy by pinning the version of erddapy in pip-packages.txt


## [2026.1.1] - 2026-09-10

### Security

- Update cryptography to 50.0.1 in pip-packages.txt to fix vulnerabilities.


## [2026.1.0] - 2026-09-10

### Added

- Added statsmodels, dask, zarr, h5netcdf, and jupyter-book to conda-packages.txt

### Removed

- Removed termscp from Dockerfile


## [2026.0.0] - 2026-09-09

### Added

- Initial release
