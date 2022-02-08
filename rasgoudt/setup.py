from setuptools import setup
import os

_here = os.path.abspath(os.path.dirname(__file__))

version = {}
with open(os.path.join(_here, 'rasgoudt', 'version.py')) as f:
    exec(f.read(), version)

with open(os.path.join(_here, 'DESCRIPTION.md'), encoding='utf-8') as f:
    long_description = f.read()

setup(
    name='rasgoudt',
    version=version['__version__'], 
    description=('Open-source SQL transform templates provided by RasgoML.'),
    long_description=long_description,
    long_description_content_type='text/markdown',
    author='Rasgo Intelligence',
    author_email='patrick@rasgoml.com',
    project_urls={
    'Documentation': 'https://docs.rasgoml.com/rasgo-docs/transforms/overview',
    'Source': 'https://github.com/rasgointelligence/RasgoTransforms',
    'Rasgo': 'https://www.rasgoml.com/',
    }, 
    license='GNU Affero General Public License v3 or later (AGPLv3+)',
    packages=['rasgoudt'],
    install_requires=[
        'pyyaml',
    ],
    include_package_data=True,
    classifiers=[
        'Development Status :: 3 - Alpha',
        'License :: OSI Approved :: GNU Affero General Public License v3 or later (AGPLv3+)',
        'Intended Audience :: Science/Research',
        'Intended Audience :: Developers',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Topic :: Database',
        'Topic :: Scientific/Engineering :: Information Analysis',
        'Topic :: Software Development :: Code Generators'
        ]
)
