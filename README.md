# OTRS-Metabase-Dashboard
Enable integration between OTRS and Metabase Dashboard in IFrame mode (agent portal)  

1. Create a Metabase dashboard with question, filter, etc  

2. Enable Metabase dashboard 'Sharing and Embedding' > 'Embed this dashboard in application'  

3. At right side, choose which filter will be show 
		
		- locked = value cant be change by dashboard user (for example, username. we will get this from OTRS param $Self->{UserLogin} )  
		- editable = value can be change (for example, year, group)
		
	
4. Copy and paste FROM Metabase Sharing/Embedded Code to OTRS XML (Rebuild and Sync afterwards)  

	a) MetabaseURL, 
	b) SecretKey,
	c) DashboardID = 1 
	
	if metabase embed code,

		resource: { dashboard: 1 }
	
	
	d) HideParam = login=UserLogin 
	
	if metabase embed code, 
	
		params: {
		"login": null
		},
	
		This means hide login filter and assign login value based on logged customer username
	
5. Makesure perl-JSON-WebToken is installed.


[![MB1.png](https://i.postimg.cc/446dgX9m/MB1.png)](https://postimg.cc/Btvs59N0)



