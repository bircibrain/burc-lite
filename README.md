# Windows Configuration

## Requirements

- Windows 10 Pro or Enterprise
- >8GB of disk space

## Installation


1. Download Docker CE for Windows
2. Run the installer
3. On the configuration screen that comes up, leave 'Use Windows containers...' unchecked.
4. Close and logout
5. Log back in to windows
6. A message that 'Hyper-V and Containers features are not enabled.' comes up. Click OK to restart and enable them.
7. After your computer restarts, wait for the notification tray message that Docker is starting to go away. Once docker has started you will see the white static Docker icon in your system tray. If the icon is grey, Docker is still starting up. The first time, Docker should give you a login box. Login with the same account you used to register and download. Important: use your Docker username, not your email address, here. If you don't get a signin box, right click on the docker icon and click Sign in.
8. Open the search box from the Start menu, type cmd and right click on 'Command Prompt'. Select 'Run as administrator'
9. Allow this app to make changes to your device
10. Pull container by typing docker pull rhancock/burc-lite and pressing enter. You should see several download messages

## Tes Docker
Run the container:

```
docker run -it --rm rhancock/burc-lite /bin/bash
```

If your prompt changes to end in

```
/tmp/downloads#
```

then the container is working and you have a Linux environment!

Attaching volumes
The windows equivalent to $HOME is %UserProfile%. To replicate the in-class exercise of attaching your home folder to the container run

```
run -it --rm -v %UserProfile%:/bind rhancock/burc-lite /bin/bash
```

A notification tray message will ask if you want to share C:\. Click 'Share it'
A separate window will come up asking for your computer username and password. For me this came up behind the command window, so you may have to move some windows around to see it.

Now you should be able to run

```
ls /bind
```

and see your files from Windows.

### Graphical interface setup


1. Download [VcXsrv](https://sourceforge.net/projects/vcxsrv/)
2. Install VcXsrv with default options
3. Start VcXsrv
4. At the security alert, allow VcXsrv to communicate on private and public networks
5. Download the [docker_interactive](https://raw.githubusercontent.com/bircibrain/burc-lite/master/docker_interactive.ps1) PowerShell script
6. Run the `docker_interactive.ps1` script. You may need to right click and select 'Run with PowerShell'. 
7. Test the GUI by typing `afni` at the container prompt. You should see the AFNI window with slices through the template T1w MRI.



