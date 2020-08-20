import javax.xml.parsers.DocumentBuilderFactory;  
import javax.xml.parsers.DocumentBuilder;  
import org.w3c.dom.Document;  
import org.w3c.dom.NodeList;  
import org.w3c.dom.Node;  
import org.w3c.dom.Element;  
import org.xml.sax.InputSource;
import java.io.ByteArrayInputStream;
import java.io.BufferedInputStream;
import java.io.FileInputStream;
import java.io.File; 
import java.sql.*;

public class ReadXML{

  public static void main(String args[]) {
    
    String username = "root", password = "";
    
    NodeList nodeListInter, nodeListBS, nodeListEC, nodeList, nodeListBT;
    Node nodeInter, nodeBS, nodeEC, nodeBT, node;
    Element eElementInter, eElementBS, eElementEC, eElement;
    String inter = "", bs, ec, bt, sql;
    int result, i = 0, j, k;

    try{    
       String connectionURL = "jdbc:mysql://localhost:3306/AppathonMed";
       Connection connection = null;
       Statement statement = null;
       Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
       connection = DriverManager.getConnection(connectionURL, username, password); 
       statement = connection.createStatement();
       
       File TopFolder = new File("./AllPublicXML");
       String[] folderNames = TopFolder.list();
       File[] folder = new File[folderNames.length];

       for(k = 0; k < folderNames.length; k++) {
         folder[k] = new File("./AllPublicXML/" + folderNames[k]);
         String[] fileNames = folder[k].list(); 
         BufferedInputStream[] input = new BufferedInputStream[fileNames.length];
         InputSource[] source = new InputSource[fileNames.length];

         for(j = 0; j < fileNames.length; j++) {
           bs = ec = "";
           input[j] = new BufferedInputStream(new FileInputStream("./AllPublicXML/" + folderNames[k] + "/" + fileNames[j]));
           source[j] = new InputSource(input[j]);  
           DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
           DocumentBuilder db = dbf.newDocumentBuilder();
           Document doc = db.parse(source[j]);
           doc.getDocumentElement().normalize();
      
           nodeListInter = doc.getElementsByTagName("intervention");
     
           if(nodeListInter.getLength() > 0) {
             inter = "";
             for(i = 0; i < nodeListInter.getLength()-1; i++) {
               nodeInter = nodeListInter.item(i); 
               eElementInter = (Element) nodeInter;
               if(eElementInter.getElementsByTagName("intervention_type").item(0).getTextContent().equals("Drug")) 
                 inter += eElementInter.getElementsByTagName("intervention_name").item(0).getTextContent() + ","; 
             }

             nodeInter = nodeListInter.item(i);
             eElementInter = (Element) nodeInter;
             if(eElementInter.getElementsByTagName("intervention_type").item(0).getTextContent().equals("Drug")) 
               inter += eElementInter.getElementsByTagName("intervention_name").item(0).getTextContent();     
           
             if(inter.equals("")) { input[j].close(); continue; }
             if(inter.endsWith(",")) inter = inter.replaceAll(",$","");
             nodeListBS = doc.getElementsByTagName("brief_summary");
             if(nodeListBS.getLength() > 0) {
               nodeBS = nodeListBS.item(0);
               eElementBS = (Element) nodeBS;
               bs = eElementBS.getElementsByTagName("textblock").item(0).getTextContent();
             }
             nodeList = doc.getElementsByTagName("eligibility");
             if(nodeList.getLength() > 0) { 
               node = nodeList.item(0);
               eElement = (Element) node;
               nodeListEC = eElement.getElementsByTagName("criteria");
               if(nodeListEC.getLength() > 0) {
                 nodeEC = nodeListEC.item(0);
                 eElementEC = (Element) nodeEC;
                 ec = eElementEC.getElementsByTagName("textblock").item(0).getTextContent();
               }
               else if(bs.equals("")) { input[j].close(); continue; } 
             }
             else if(bs.equals("")) { input[j].close(); continue; }
             nodeListBT = doc.getElementsByTagName("brief_title");
             nodeBT = nodeListBT.item(0);
             bt = nodeBT.getTextContent();
           
             if(inter.contains("\"")) inter = inter.replace("\"", "\\\"");
             if(bs.contains("\"")) bs = bs.replace("\"", "\\\"");
             if(ec.contains("\"")) ec = ec.replace("\"", "\\\"");
             if(bt.contains("\"")) bt = bt.replace("\"", "\\\"");
             
             sql = "INSERT INTO studies (fileName, interventions, briefSummary, eligibilityCriteria, briefTitle) VALUES (\""+fileNames[j].replace(".xml","")+"\",\""+inter+"\",\""+bs+"\",\""+ec+"\",\""+bt+"\")";
             result = statement.executeUpdate(sql);
           } 
           input[j].close();
        } 
      }
    }  
    catch(Exception e) { e.printStackTrace(); }
  }
}