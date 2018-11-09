NOTE 1:

Open the script New_AD_Users_CSV.v1.0.ps1 in your favourate scripting editor, preferably PowerShell ISE. Amend the following lines to customize for your environment:

1. Line 20: change the location of your script, log file and CSV

2. Line 26: change the name of your CSV file

3. Line 33: Change your AD Server name

4. Line 46: Change location to store your new users (Use ADSIEDIT to get the name in the format shown in the script)

5. Line 69: May need to amend $_.Directorate to $_.Description if you amend your CSV header (see note below)

6. Line 81: Change the country name to reflect the country you are configuring - Google "Active Directory country codes" or get it from here: 

7. Line 89: change your domain name.
 


NOTE 2:

1. You may also need to customize the CSV headers. For example Change Directorate to Description. 

2. Change the password on the CSV to what you want. The script configures user must change password at next log on to TRUE

3. Ensure that the Manager account used in the CSV already exists in AD, otherwise the Managers field will not be populated. 

4. If you need further support, please fill the contact me form in this URL: 

http://www.itechguides.com/contact-me