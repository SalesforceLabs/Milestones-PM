public class SearchController
{
private apexpages.standardController controller {get; set; }
private Account l;
public string userid;
public List<Account> searchResults {get; set; }
/*public string searchText
 {
 get
 {
   if (searchText==null) searchText = '';
   return searchText;
   }
 set;
 }*/

public SearchController(ApexPages.StandardController controller)
  {
  this.controller = controller;
  this.l = (Account) controller.getRecord();
  }

public PageReference search()
  {
  if(SearchResults == null)
   {
   SearchResults = new List<Account>();
  }
  else
   {
   SearchResults.Clear();
   }
userid = UserInfo.getUserId();
//String qry = 'Select Id, Name from Account where name like \'%'+searchText+'%\') Order By Name';
String qry = 'Select Id, Name from Account where Owner = \'%'+userid+'%\') Order By Name';
SearchResults = Database.query(qry);
return null;
}
}