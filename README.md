# OTRS-Metabase-Dashboard
- Enable integration between OTRS and Metabase Dashboard in IFrame mode (agent portal)    
- Metabase: https://www.metabase.com/  
- Embedding Metabase : https://www.metabase.com/docs/latest/administration-guide/13-embedding.html  

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://paypal.me/MohdAzfar?locale.x=en_US)  

1. Create a Metabase dashboard with question, filter, etc  

2. Enable Metabase dashboard 'Sharing and Embedding' > 'Embed this dashboard in application'  

	a) At right side, choose which filter will be show 
		
		- locked = value cant be change by dashboard user (for example, username. we will get this from OTRS param $Self->{UserLogin} )  
		- editable = value can be change by user (for example, year, group)
		
	
3. Copy and paste FROM Metabase Sharing/Embedded Code to Admin > System Configuration > DashboardBackend###0402-Metabase1  

	a) set 'MetabaseURL',  
	b) set 'SecretKey',  
	c) set 'DashboardID' = 1   
	
	if Metabase embed code contains, 

		resource: { dashboard: 1 }
	
	
	d) set 'HideParam'= login=UserLogin; 
	
	if Metabase embed code contains, 
	
		params: {
		"login": null
		},
	
		*This means hide login filter and we will assign login value based on logged agent username(only if your SQL has this input filter)  
		*Leave it empty if not applicable  
		*Can assign multiple parameter using this format: filtername1=UserLogin;filtername2=UserFullname;
	
4. Makesure perl-JSON-WebToken is installed.


[![MB1.png](https://i.postimg.cc/446dgX9m/MB1.png)](https://postimg.cc/Btvs59N0)

