<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.ArrayList"%>
<%
	String connectionURL = "jdbc:mysql://localhost:3306/appathonMed";
	Connection connection = null;
	Statement statement = null;	
	ResultSet rs = null;
%>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Appathon-Medicines</title>
</head>

<style>
.header {
text-align:center;
background-color:cornsilk;
border:1px solid;
}

#description {
background-color:cornsilk;
padding:20px;
border:1px solid;
padding:20px;
border-top:none;
}

#result {
background-color:palegreen; 
border:1px solid black;
text-align:center;
padding:50px;
margin:0px;
}

.result-table th, 
.result-table td {
  padding: 5px;
  border: 1px solid black;
}

.center {
  margin-left: auto;
  margin-right: auto;
}

.tab {
  overflow: hidden;
  border:1px solid black;
  background-color: cornsilk;
}

.tab button {
  background-color: cornsilk;
  float: left;
  border: none;
  outline: none;
  cursor: pointer;
  padding: 14px 16px;
  transition: 0.3s;
}

.tab button:hover {
  background-color: brown;
}

.tab button.active {
  background-color: brown;
}

.tabcontent {
  display: none;
  padding: 6px 12px;
  border: 1px solid palegreen;
  border-top: none;
  background-color:cornsilk;
}
</style>

<body>

<script>
function openTable(evt, tableName) {
	var i, tabcontent, tablinks;
	tabcontent = document.getElementsByClassName("tabcontent");
	for(i = 0; i < tabcontent.length; i++) {
		tabcontent[i].style.display = "none";
	}
	
	tablinks = document.getElementsByClassName("tablinks");
	for(i = 0; i < tablinks.length; i++) {
		tablinks[i].className = tablinks[i].className.replace(" active", "");
	}
	document.getElementById(tableName).style.display = "block";
	evt.currentTarget.className += " active";
}
</script>

<h1 style="background-color:lightblue; color:white; text-align:center; border:1px solid black; padding:20px; margin:0px;">#Appathon project based on <em>CTGOV-03</em></h1>

<div class="header" style="font-style:italic"> <h3><table class="result-table center"><tr><td> National Technical University of Athens </td></tr> 
<tr><td>School of Electrical and Computer Engineering</td></tr>
<tr><td>Internet and Applications, <i>Spring 2020</i></td></tr></table></h3>
</div>

<div id="description"> 

<h3> Welcome! In this site, you will find a variety of clinical trials, derived from  
<a href=https://clinicaltrials.gov target="_blank"><i>ClinicalTrials</i></a> database that mention the input medicines, in a combination of the following fields of interest:</h3>
<h3>
<ul style="font-style:italic">
<li>Interventions</li>
<li>Brief Summary</li>
<li>Eligibility Criteria</li>
</ul>
</h3>

<hr>

<form method="post" action="medicines.jsp"> 
  <table>
    <tr>
      <td><h3>Please, enter the medicines here:<input type="text" name="medicines"/></h3></td>
    </tr>
    <tr>
      <td><b><i><mark>Before you submit, note that in case of more than one medicines, they should be separated by comma</mark></i></b></td>
      <td><input type="submit"/></td>
    </tr>
  </table>
</form>

<h3>After the submission, the results will be shown in tables in the green section below.</h3>

</div>

<div id="result"> <h4 style="color:red; text-align:left; font-style:italic">Click on tabs to see content!</h4>

<div class="tab">
  <button class="tablinks" onclick="openTable(event, 'TABLE1')">TABLE 1</button>
  <button class="tablinks" onclick="openTable(event, 'TABLE2')">TABLE 2</button>
</div>


<% String med = request.getParameter("medicines");

  if(med == null) { %>
	<h2><b style='color:red;'>You haven't submitted anything yet...</b></h2>

<%
  } else {
	  String username = "root", password = "";
				
      Class.forName("com.mysql.jdbc.Driver").newInstance();
      connection = DriverManager.getConnection(connectionURL, username, password);
	  statement = connection.createStatement();
      
      String sqlSelect = "SELECT * FROM studies";
      
      rs = statement.executeQuery(sqlSelect);	  
      
	  String[] medArr = med.split(",");
      String medStr, interStr;
	  int i, index, sizeA, sizeB, row;
	  boolean b1, b2, b3, b4;
	  ArrayList<String> briefTitleA = new ArrayList<String>();
	  ArrayList<String> briefTitleB = new ArrayList<String>();
	  ArrayList<String> linkA = new ArrayList<String>();
	  ArrayList<String> linkB = new ArrayList<String>();
	  ArrayList<String> medA = new ArrayList<String>();
	  ArrayList<String> medB = new ArrayList<String>();
	  ArrayList<String> field = new ArrayList<String>();
	  while(rs.next()) {
		b1 = b2 = false;
		interStr = rs.getString("interventions").toLowerCase();
		for(i = 0; i < medArr.length; i++) {
			medStr = medArr[i].toLowerCase();
			index = interStr.indexOf(medStr);
			if(index == -1) continue;
			
			if(rs.getString("briefSummary").toLowerCase().indexOf(medStr) >= 0) b1 = true;
			if(rs.getString("eligibilityCriteria").toLowerCase().indexOf(medStr) >= 0) b2 = true;
			
			if(b1 && b2) {
				briefTitleA.add(rs.getString("briefTitle"));
				linkA.add("https://clinicaltrials.gov/show/" + rs.getString("fileName"));
				medA.add(medStr.toUpperCase());
			}
            else if(b1 || b2) {
				briefTitleB.add(rs.getString("briefTitle"));
				linkB.add("https://clinicaltrials.gov/show/" + rs.getString("fileName"));
				medB.add(medStr.toUpperCase());
				if(b1) { field.add("Brief Summary"); }
				else { field.add("Eligibility Criteria"); }
			}
            else continue;			
			break;
		}	
	  }
      rs.close(); 
	  sizeA = briefTitleA.size();
	  %> <div id="TABLE1" class="tabcontent"> <%
      if(sizeA > 0) {
    	  String word;
    	  if(sizeA == 1) { word = "Study"; }
    	  else { word = "Studies"; }
		%> 
         <table class='result-table center' style='border:1px solid black; background-color:cornsilk;'>
		   <caption><h3><em>
		    <%=sizeA%> <%=word%> that mention(s) al least one of the input medicines in all tree fields (see above) 
		   </em></h3></caption>
		   <tr><th>Row</th><th>Brief Title</th><th>url</th><th>Referenced medicine</th></tr> 
        <%	for(i = 0; i<sizeA; i++) { row = i + 1; %>
		   <tr><td><%=row%></td><td><%=briefTitleA.get(i)%></td><td><a href=<%=linkA.get(i)%> target=_blank>Read full study</a> </td><td><%=medA.get(i)%></td></tr>
         <% } %>
        </table>	
    <%} if(sizeA == 0) { %> <h4 style="color:red;">No content</h4> <%} %> </div> <div id="TABLE2" class="tabcontent"> <%
	  sizeB = briefTitleB.size(); 
      if(sizeB > 0) {
    	  String word;
    	  if(sizeB == 1) { word = "Study"; }
    	  else { word = "Studies"; }
		%> 
         <table class='result-table center' style='border:1px solid black; background-color:cornsilk;'>
		   <caption><h3><em>
		    <%=sizeB%> <%=word%> that mention(s) at least one of the input medicines as Interventions and either in Brief Summary or Eligibility Criteria 
		   </em></h3></caption>
		   <tr><th>Row</th><th>Brief Title</th><th>url</th><th>Referenced medicine</th><th>Mentioned in</th></tr> 
        <%	for(i = 0; i < sizeB; i++) { row = i + 1;%>
		   <tr><td><%=row%></td><td><%=briefTitleB.get(i)%></td><td><a href=<%=linkB.get(i)%> target=_blank>Read full study</a> </td><td><%=medB.get(i) %></td><td><%=field.get(i)%></td></tr>
         <% } %>
        </table>	
   <% } if(sizeB == 0) { %> <h4 style="color:red;"> No content </h4> </div> <%}
        } %>       
</div>
</body>
</html>