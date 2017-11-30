These scripts are used to update the code running on an AWS autoscaling group.  They work by spinning up a staging instance using the current image, then opening an SSH terminal to this new staging instance.  The developer can then perform whatever steps are necessary to prepare the updated system, and when everything is as they like it, they log out.  The system then builds a new AMI using this staging server as a template, then rolls it out to the live cluster.

This whole process is interactive, and can be initiated by running:

    $ autoscale-update.sh <AutoscalingGroupName>

This session will look something like this:

    $ ./autoscale-update.sh PresenceServerScalingGroup
    Gathering information about scaling group "PresenceServerScalingGroup"...done
    Scaling group "PresenceServerScalingGroup" is currently using  "ami-xxxxxxxx" (sg-xxxxxxxx MyAWSKey MyServerIAMRole)
    Launch staging instance? [Y/n] y
    Launching new t2.micro instance... i-xxxxxxxxxxxxxxxxx
    Waiting for instance to be fulfilled.....done!
    Will now connect to ec2-xx-xxx-xx-xx.us-west-2.compute.amazonaws.com via SSH.  You can establish your own connection to this server with the following command:

	ssh ec2-user@ec2-xx-xxx-xx-xx.us-west-2.compute.amazonaws.com

    Log out when system is ready for the next step.


    Establishing connection...........Last login: Thu Nov 30 10:59:59 2017 from xxx.xx.xx.xx
				       ___---___
				 ___---___---___---___
			   ___---___---    *    ---___---___
		     ___---___---    o/ 0_/  @  o ^   ---___---___
	       ___---___--- @  i_e J-U /|  -+D O|-| (o) /   ---___---___
	 ___---___---    __/|  //\  /|  |\  /\  |\|  |_  __--oj   ---___---___
    __---___---_________________________________________________________---___---__
    ===============================================================================
     ||||   |||   |||   |||   |||   |||   |||   |||   |||   |||   |||   |||   ||||
     |---------------------------------------------------------------------------|
     |___-----___-----___-----___-----___-----___-----___-----___-----___-----___|
     / _ ----- _ \   / _ ----- _ \   / _ ----- _ \   / _ ----- _ \   / _ ----- _ \
    ( (o\_____/o) ) ( (o\_____/o) ) ( (o\_____/o) ) ( (o\_____/o) ) ( (o\_____/o) )
     \__/|||||\__/   \__/=====\__/   \__/=====\__/   \__/=====\__/   \__/=====\__/
	|||||||         |||||||         |||||||         |||||||         |||||||
	|||||||         |||||||         |||||||         |||||||         |||||||
	|||||||         |||||||         |||||||         |||||||         |||||||
	|||||||         |||||||         |||||||         |||||||         |||||||
	|||||||         |||||||         |||||||         |||||||         |||||||
	|||||||         |||||||         |||||||         |||||||         |||||||
	|||||||         |||||||         |||||||         |||||||         |||||||
	|||||||         |||||||         |||||||         |||||||         |||||||
	|||||||         |||||||         |||||||         |||||||         |||||||
	|||||||         |||||||         |||||||         |||||||         |||||||
	|||||||         |||||||         |||||||         |||||||         |||||||
	|||||||         |||||||         |||||||         |||||||         |||||||
	|||||||         |||||||         |||||||         |||||||         |||||||
	|||||||         |||||||         |||||||         |||||||         |||||||
	|||||||         |||||||         |||||||         |||||||         |||||||
	|||||||         |||||||         |||||||         |||||||         |||||||
	|||||||         |||||||         |||||||         |||||||         |||||||
       (OOOOOOO)       (OOOOOOO)       (OOOOOOO)       (OOOOOOO)       (OOOOOOO)
       )%%%%%%%(       )%%%%%%%(       )%%%%%%%(       )%%%%%%%(       )%%%%%%%(
      (ZZZZZZZZZ)     (ZZZZZZZZZ)     (ZZZZZZZZZ)     (ZZZZZZZZZ)     (ZZZZZZZZZ)

	____      ____    U _____ u ____   U _____ u _   _      ____ U _____ u
       U|  _"\ uU |  _"\ u \| ___"|// __"| u\| ___"|/| \ |"|  U /"___|\| ___"|/
       \| |_) |/ \| |_) |/  |  _|" <\___ \/  |  _|" <|  \| |> \| | u   |  _|"
	|  __/    |  _ <    | |___  u___) |  | |___ U| |\  |u  | |/__  | |___
	|_|       |_| \_\   |_____| |____/>> |_____| |_| \_|    \____| |_____|
	||>>_     //   \\_  <<   >>  )(  (__)<<   >> ||   \\,-._// \\  <<   >>
       (__)__)   (__)  (__)(__) (__)(__)    (__) (__)(_")  (_/(__)(__)(__) (__)


    [ec2-user@ip-xxx-xx-xx-xx ~]$ ... (PERFORM UPDATES HERE) ...
    [ec2-user@ip-xxx-xx-xx-xx ~]$ logout

    done!

    Make new AMI "PresenceServerScalingGroup_11-30-17_115619" image from instance "i-xxxxxxxxxxxxxxxxx"? [Y/n] y
    Tagging new AMI "PresenceServerScalingGroup_11-30-17_115619"...done, AMI id is ami-xxxxxxxx
    Creating launch configuration...done
    Updating autoscaling group...done
    Terminate staging instance? [Y/n] y
    Waiting for image creation to finish.......................done
    Terminating instance "i-xxxxxxxxxxxxxxxxx"...done
    Initiate rolling upgrade? [Y/n] y
    Increasing cluster size to 2 from 1...........done
    Terminating old instances.....done

