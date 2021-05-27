## Classifier Training Action
[![ci](https://github.com/Incuvers/train-classifier/actions/workflows/ci.yaml/badge.svg)](https://github.com/Incuvers/train-classifier/actions/workflows/ci.yaml)

Modified: 2021-05

![img](/docs/img/Incuvers-black.png)

## Navigation
 1. [About](#cuda-accelerated-machine-learning)
 2. [Host Preconfiguration](/docs/README.md)
 3. [Usage](#action-usage)
 4. [Deployment](#train-classifier-deployment)
 5. [License](#license)

## CUDA Accelerated Machine Learning
The server enables remote classifier training jobs to be executed on a host with an NVIDIA CUDA supported GPU with at least 4GB of VRAM. The code uses [nvidia-docker](https://github.com/NVIDIA/nvidia-docker) in combination with a [tensorflow/tensorflow:latest-gpu](https://hub.docker.com/layers/tensorflow/tensorflow/latest-gpu/images/sha256-0cb24474909c8ef0a3772c64a0fd1cf4e5ff2b806d39fd36abf716d6ea7eefb3?context=explore) docker image to mount and execute a tensorflow-powered python training with full access to the hosts CUDA cores.

## Action Runner Brief
The code in this repository is executed as defined by the [action.yaml](action.yaml) file in the root. This action can be invoked in another repository's build-spec by pointing to this action (see [Action Usage](#action-usage)). This action is not deployed to a server directly and instead is pulled by the github action runner when the build-spec requires this action. This way subsequent updates to this build action on the target branch will be automatically be pulled by the build server so it is always running the latest source code.

## Action Usage
This action requires `actions/checkout@v2` for access to the target repository's source code and `actions/upload-artifact@v2` for pushing the training results to the action runner dashboard. This action will copy the source code into its working directory mounting it to the container, installing the neccesary dependancies and executing the module.

The target repository must have a filesystem schema similar to what is outlined below:
```
├── .github
│   └── workflows
│       └── train.yaml
├── .gitignore
├── README.md
├── artefacts
│   ├── .gitignore
│   └── README.md
├── mnist
│   ├── __init__.py
│   ├── __main__.py
│   ├── apt-pkgs.txt
│   ├── requirements.txt
│   └── sample
│       ├── __init__.py
│       └── runner.py
└── yolo
    ├── __init__.py
    ├── __main__.py
    ├── apt-pkgs.txt
    ├── requirements.txt
    └── sample
        ├── __init__.py
        └── runner.py
  ...
```
Here are the primary requirements:
1. self contained python modules (`mnist` and `yolo`) each with their own entry points `__main__.py` and apt/pip requirement files.
2. `artefacts/` directory for writing training results of each classifer model

Below is a sample model entry point for the `yolo` classifer:
```py
import os
from pathlib import Path
from yolo.train import main
from distutils.dir_util import copy_tree
from yolo.mnist.make_data import generate

# run data preprocessing jobs
generate()
# run training job
main()
# copy artefacts to global path 
src = str(Path(__file__).parent.joinpath("checkpoints"))
dest = str(Path(__file__).parent.parent.joinpath("artefacts"))
if not os.path.exists(dest): os.mkdir(dest)
copy_tree(src,dest)
```

The action takes in a `MODEL` specifier corresponding to the name of the target python module (containing directory name). Below is a sample buildspec job training an `mnist` model using the `train-classifier` action:
```yaml
train:
  name: train classifier
  runs-on: [ self-hosted, linux, docker, X64 ]
  steps:
    - name: checkout src
    uses: actions/checkout@v2
    - name: train classifier build action 
    uses: Incuvers/train-classifier@master
    env:
      MODEL: mnist
      SLACK_IDENTIFIER: ${{ secrets.SLACK_IDENTIFIER }}
    - name: upload training artefacts
    uses: actions/upload-artifact@v2
    with:
      name: artefacts
      path: artefacts.tar.gz
      retention-days: 5
    - name: Notify
    run: |
      curl -X POST -H 'Content-type: application/json' \
      --data "{\"text\":\"Model training complete. Download the artefacts here: https://github.com/Incuvers/handwriting-recognition/actions/runs/$GITHUB_RUN_ID\"}"\
      https://hooks.slack.com/services/${{ secrets.SLACK_IDENTIFIER }}
```

## Train Classifier Deployment
To be implemented using ansible. See server [preconfiguration](docs/README.md) for host setup.

## License
[GNU General Public License v3](LICENSE)