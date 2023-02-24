# Deep Learning Workspaces for CTAR Bilkent

## Connecting

There are multiple options to connect to your workspace using local clients or browser.
![deeplearning-connect](./deeplearning-connect.png)

### VS Code Server

Click on the VS Code icon to launch a VS Code server that you can connect from your browser.

### Jupyter Notebook

Click on the jupyter icon to launch a jupyter notebook server that you can connect from your browser.

Also, you can connect using the **Web Terminal** or **SSH** by clicking on the above buttons.

### VS Code Remote

Once you've configured SSH, you can work on projects from your local copy of VS Code, connected to your Coder workspace for compute, etc.

1. Open [VS Code](https://code.visualstudio.com/download) locally.
2. Install the [Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) extension.
3. In VS Code's left-hand nav bar, click **Remote Explorer** and right-click on a workspace to connect.

### JetBrains PyCharm Professional

1. Install PyCharm Professional by using [JetBrains Toolbox App](https://www.jetbrains.com/toolbox-app/).
2. Connect your local machine to server via ssh by following the [instructions](https://www.jetbrains.com/help/pycharm/configuring-remote-interpreters-via-ssh.html#prereq) here.

### JetBrains Gateway

1. Follow the [instructions](https://coder.com/docs/coder-oss/latest/ides/gateway) here to get a fully working PyCharm IDE.

### Spyder (Remote Kernels) [Advanced]

(not tested)

1. Install [Spyder](https://docs.spyder-ide.org/current/installation.html) on your local machine.
2. Connect Spyder with external kernel by following the [instructions](https://docs.spyder-ide.org/current/panes/ipythonconsole.html#using-external-kernels) here.

## Persistent Storage

There will be a `~/data` inside every workspace. All files placed here will survive reboots and be available to all workspaces.

To upload or download files to `~/data` go to https://share.ctar.ml

## Docker Image
This template uses the following docker image: https://github.com/matifali/dockerdl
