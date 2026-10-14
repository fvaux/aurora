\# Install an desktop icon to start Aurora on Windows



\## Desktop shortcuts

Aurora can be started via command line in a batch file (‘aurora rversion.bat’, found in the ‘icons’ folder of the app).

To make this seamless (and enjoyable) the batch file may be pasted as a shortcut on desktop and branded with an identifiable icon. 

An icon of the 1876 ship Aurora is provided, but user may customise with a shortcut of their choice.



\## Step by step

The batch file itself has 2 commands: 

"C:\\PROGRA\~1\\R\\R-4.4.0\\bin\\Rscript.exe" -e "shiny::runApp('mypath/Aurora', launch.browser = TRUE)"  and ‘pause’



Right click > edit Aurora R4.4.0.bat to match the user's R installation location (and R version) and path to the Aurora app. 



The command ‘pause’ allows the command pane to stay open after app start. This is useful for testing and error handling, but the user has to manually close the batch windows afterwards. ‘pause’ may be removed.

Copy and Paste \\aurora app folder\\icons\\Aurora R4.4.0.bat  as a shortcut on the users desktop. 

Rename it ‘Aurora’ 

Right click on the new shortcut > select properties > change icon,  then add icon from \\aurora app folder\\icons\\Aurora.ico, (or your choice of icon).



\## Details

To start, the package Shiny and all its dependencies need to be in the R installation’s default user directory (preferable), or alternatively in the R root directory. 



Sometimes an icon wont permanently attach to a shortcut, we have found that a simple fix is to paste a copy of the icon in the users ‘Documents’ folder, then add this to the shortcut.



\## why use a shortcut?

When deploying an app for the team in a serverless environment, we have three options:



\### Run via batch files

The safe choice where team members are not computer-savvy and just want to get on with it in a small team, server-less environment.

Users run the app via the shortcut. 

Deployment has minimal admin.

When the app is started, it exists in its own session, with no data caches or code exposed, and it runs with the given R and packages versions. If everyone has the same version of R, and the same version of the packages, no version control issues are expected.

Apps can of course fail, when that happens it’s a clean halt, with error messages posted to the command window for troubleshooting. 



\### Run via integrated development environment (IDE)

The IDE provides tools for troubleshooting, and for advanced data maintenance.

Users could also run the app from an IDE. This is generally not a safe means to deploy to a team, depending on skill levels.

There are many possible variations to the run process since the IDE are usually very flexible: can open, edit, save and run files in all sorts of ways. Admin would need to control this variability. If the overall aim is to simply run a code, the IDE is overkill.

The IDE does provide extensive error messages and troubleshooting hints. For example, pop up messages to update the IDE, or R, or packages seem harmless to the user but doing any of these could break the app. Similarly, some IDE’s highlight ‘warnings’ in code and prompt the user for action. These auto or AI prompts are pulling the user away from the singular aim of simply ‘running the code’

The IDE has cached memory- convenient for developers to start work where they left off, but could load stale data into the IDE, subsequently saved over recent data. Additional admin and training steps are needed for cache awareness.

In an IDE, users have direct access to datafiles and code, which could be modified unwittingly. IDE’s often have auto-save options that would embed a simple mistake into the active codebase. 



\### Server

A server deployment may be ideal, but Aurora is not designed per se to be deployed directly onto a server, rather as a small team installation. Some adjustments to the codebase would be required to run on a server.



