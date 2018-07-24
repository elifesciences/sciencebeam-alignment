from setuptools import find_packages, setup, Extension

import numpy as np


with open('requirements.txt', 'r') as f:
    REQUIRED_PACKAGES = f.readlines()

packages = find_packages()

setup(
    name='sciencebeam_alignment',
    version='0.0.1',
    install_requires=REQUIRED_PACKAGES,
    packages=packages,
    include_package_data=True,
    description='ScienceBeam Alignment',
    setup_requires=[
        # Setuptools 18.0 properly handles Cython extensions.
        'setuptools>=18.0',
        'cython',
    ],
    ext_modules=[
        Extension(
            'sciencebeam_alignment.align_fast_utils',
            sources=['sciencebeam_alignment/align_fast_utils.pyx'],
        ),
    ],
    include_dirs=[np.get_include()],
)
