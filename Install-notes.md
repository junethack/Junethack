===Install Notes===
The junethack server will be run on a dedicated micro instance.
This has 613 MB of RAM and 1-2 EC2 Compute Units (throttled).
It has installed the Amazon Linux 32-bit AMI.
I have set up the user 'junethack' to run the server.
That user needs to run a cron job every ten minutes to cd into the mercurial repo and pull the xlogfile for nethack.eu.
