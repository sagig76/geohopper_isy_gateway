geohopper_isy_gateway
=====================

A gateway between Twocanoes Geohopper iBeacons and ISY home automation system by Universal Devices Inc.


This is a simple Perl script which receives a web service POST message from Geohopper and updates an ISY parameter. When you enter a location, ISY var value changes from 0 to 1, when you exit a location ISY var value changes from 1 to 0 from here the options are endless...
You can create any program you wish using vars and be creative ;)

Here are some cool use cases:

When my front door is locked and I get close to the front door beacon unlock it
Turn on/off lights when I enter or exit a room
Arm my alarm when I get into the car

You can find more information about the Geohopper iOS app and iBeacons here:
http://twocanoes.com


Step by step instructions:

Step 1:
Get a few iBeacons and setup the Geohopper app

Step 2:
Install Perl. Mac and Linux have it pre-installed

Step 3:
The script uses LWP and Mojolicious, it is possible that you need to add these modules to your basic Perl installation.
You can follow the instructions here: http://www.cpan.org/modules/INSTALL.html

Step 4:
Copy the directory with the .pl and .sh scripts to your computer. Make sure you create an empty log dir in that location as well

Step 5:
edit the .pl file and update the parameters relevant to your system -

    Step 5.1:
    Edit ISY IP, port, user and password
    
    Step 5.2:
    Edit location names and matching ISY Var IDs. Location names must match the names you defined in Geohopper (case snesitive)
    
    Step 5.3:
    Update the authorized users. The email account(s) are the same you use in the Geohopper app.
    
Step 6:
Run the app by typing: perl geohopper_isy_gateway.pl daemon --listen "http://*:9129"
(note the port 9129 can be any unused port on your system)
instead of running the script from the command line you can run the .sh (mac or linux) file which does the same thing. If you'd like you can uncomment the 2nd line (don't firget to comment the first line) to run the script in the background.
You may need to make the script executable by using the CHMOD +x command

Step 7:
Test that the server is running - open your browser and point to the server and port your listening on

Step 8:
Make sure the listening port is open on your router, so Geohopper can send a message to your system
(you'll have to figure out how to forward the port based on your router)

Step 9:
Setup Geohopper

    Step 9.1:
    On settings, web service, enable web notify
    
    Step 9.2: 
    Add new web service, point to your external IP and the port you set on your router
    exmaple: http://10.10.10.10:9128/geohopper
    Make sure you send a POST command
    
    Step 9.3:
    Go to locations, choose a beacon location, Web Services and select the new service you just created.
    Make sure that notification for both Enter and Exit are enabled.
    
Step 10:
You should be all set. test by going into a location, the ISY var ID should change to 1, leave a location the ID changes back to 0

Now enjoy and do magic with your home automation :)

    
    


