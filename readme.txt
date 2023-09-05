Task: 
A development project is about to start programming. They ask you to deploy a development environment for them. They have the following requirements:

-  Two storage servers with the GlusterFS server installed, each with a single CPU.

-  Two servers the developers will use to write code on, each with a single CPU. They have to have emacs, jed and git installed

-  All machines have to have four users with preferred usernames:

- bob - janet - alice - tim

-  All four users should get root access via sudo

-  Tim and janet have to be members of the group «developers». That group has to be created.

-  Two compile servers with gcc, make and binutils installed

-  One server running Docker for testing the software developed

-  You don’t have to configure the GlusterFS and Docker services, the project members will do that themselves. Just install the packages.

Using terraform we manage to create a development environment
Here you will find the terraform script to depoly development environment
