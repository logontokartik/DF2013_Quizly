Dreamforce 2013 - Sample Quizly Application
================
Sample application showing the demonstration of the visual workflows in Salesforce working in Conjunction with Apex Classes. Application to create & manage Quizzes.  

<h2>Working Sites URL</h2>
<a>http://quizmaster-developer-edition.na15.force.com/</a>

The above is built using Force.com Sites

<h2>Installation and Configuration</h2>
* Use the <a>https://login.salesforce.com/packaging/installPackage.apexp?p0=04ti0000000SsoX</a> package to install the components into any Salesforce Org. 
* After the package is successfully installed, use Configure Button on the Package Details page, to load the Sample Quiz data
* An App "Quizly" is created and now you have a Sample Quiz pre-loaded.

<h2>Sites Setup</h2>
* Create Force.com Sites and assign a name.
* Set the Active Site Homepage as "QuizMaster"
* On the Site Details page, in the Visualforce Access, make sure you add QuizConSummary, QuizMaster, QuizMasterSummary, QuizmasterNoStyles Visualforce pages
* Click on the Public Access settings and edit the object Settings
* 	Contact Responses - Read, Create, Edit
* 	Contact   		  - Read, Create
	Questions 		  - Read, View All
	Quizzes   		  - Read, View All
	Summaries		  - Read, Create, Edit, View All
* Apex Class Access
	QuizConSummaryCon
	QuizMasterCon
	QuizMasterSummaryCon
	QuizQuestionPlugin

 

