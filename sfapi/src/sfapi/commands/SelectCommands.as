/*	
 *	License
 *	
 *	This file is part of The SeleniumFlex-API.
 *	
 *	The SeleniumFlex-API is free software: you can redistribute it and/or
 *  modify it  under  the  terms  of  the  GNU  General Public License as 
 *  published  by  the  Free  Software Foundation,  either  version  3 of 
 *  the License, or any later version.
 *
 *  The SeleniumFlex-API is distributed in the hope that it will be useful,
 *  but  WITHOUT  ANY  WARRANTY;  without  even the  implied  warranty  of
 *  MERCHANTABILITY   or   FITNESS   FOR  A  PARTICULAR  PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with The SeleniumFlex-API.
 *	If not, see http://www.gnu.org/licenses/
 *
 */
package sfapi.commands
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.controls.AdvancedDataGrid;
	import mx.events.ListEvent;
	import mx.controls.Alert;
	import sfapi.core.AppTreeParser;
	import sfapi.core.ErrorMessages;
	import sfapi.core.ReferenceData;
	import sfapi.core.Tools;
	
	public class SelectCommands
	{
		// TODO use reference standard for these
		private static const PROPERTY_DATA_PROVIDER:String = "dataProvider";
		private static const PROPERTY_SELECTED_INDEX:String = "selectedIndex";

		private var appTreeParser:AppTreeParser;
		
		public function SelectCommands(aptObj:AppTreeParser)
		{
			appTreeParser = aptObj;
		}
		
		/**
		 * Selects an option on a list related control
		 * @param  id  The ID of the Flex object
		 * @param  arg  the text value of the list item to select 
		 * @return  'true' if the selection was made. An error message if the call fails.
		 */
		
		
		
		public function doFlexSelect(id:String, args:String):String
		{
			var comboNotSet:Boolean = true;
			var child:Object = appTreeParser.getElement(id);
			
			if(child === null)
			{
				return ErrorMessages.getError(ErrorMessages.ERROR_ELEMENT_NOT_FOUND, [id]);
			}
			
			var selection:int = getIndexOf(args, child);
			if(selection >= 0)
			{
				child.selectedIndex = selection;
				return dispatchIndexChangeEvent(child);
			}
			return ErrorMessages.getError(ErrorMessages.ERROR_NO_SELECTION, [args, id]);
		}
		
		//My custom method
		
		[Bindable]
		private var searchResult:XMLList;
		private var searchResultIndex:uint = 0;
		
		
		//My custom method
		
		public function selectFlexTreeItem(id:String, args:String, nodeDepth:String):void
		{
			
			
			var nodeLevel:int = parseInt(nodeDepth);
			
			var child:Object = appTreeParser.getElement(id);
			
			
			var mixml:XMLList = new XMLList(child.dataProvider.source);
			
			
			var searchStr:String = args;
			//child.expandChildrenOf(myXML[0], false);
			
			
			//mixml=data;
			
			
				
				if(nodeLevel==1){
					
					searchResult= mixml.node.(@label==searchStr);
				
				}
				else if (nodeLevel==2){
					searchResult= mixml.node.node.(@label==searchStr);
				}
				else if (nodeLevel==3){
					searchResult= mixml.node.node.node.(@label==searchStr);
				}
				else if (nodeLevel==4){
					searchResult= mixml.node.node.node.node.(@label==searchStr);
				}
				else if (nodeLevel==5){
					searchResult= mixml.node.node.node.node.node.(@label==searchStr);
				}
				
			
			var xn:XML = searchResult[searchResultIndex];
			
			
			
			searchResultIndex = 0;
			
			if (searchResult[searchResultIndex] != undefined)
				
				
				var xmlNode:XML = searchResult[searchResultIndex];
			
			while (xmlNode.parent() != null) {
				
				

				xmlNode = xmlNode.parent();

				child.expandItem(xmlNode, true, false);
				child.selectedItem = searchResult[searchResultIndex];
		

			}
			
			
			
		}
		
		/**
		 * Gets the index of a literal value of a list item in a list related control
		 * @param  id  The ID of the Flex object
		 * @param
		 * @return  'true' if the selection was made. An error message if the call fails.
		 */
		public function getIndexOf(args:String, child:Object):int
		{
			
			
			if(child.dataProvider == null)
			{
				return -1;
			}
			
			var i:int = 0;
			for each(var item:Object in child.dataProvider)
			{
				if((item.hasOwnProperty("label") && item.label == args) || item.toString() == args)
				{
					return i;
				}
				i++;
			}
			return -1;
		}
		
		/**
		 * Selects an option on a list related control based on index
		 * @param  id  The ID of the Flex object
		 * @param
		 * @return  'true' if the selection was made. An error message if the call fails.
		 */
		public function doFlexSelectIndex(id:String, args:String):String
		{
			var child:Object = appTreeParser.getElement(id);
			
			if(child == null)
			{
				return ErrorMessages.getError(ErrorMessages.ERROR_ELEMENT_NOT_FOUND, [id]);
			}
			try
			{
				child.selectedIndex = parseInt(args);
				return dispatchIndexChangeEvent(child);
			}
			catch(e:Error)
			{
				return ErrorMessages.getError(ErrorMessages.ERROR_NO_SELECTION, [args, id]);
			}
			
			return null;
		}
		
		/**
		 * Retrieves a selection list related object
		 * @param  id  The ID of the Flex object
		 * @param  args  <empty string>
		 * @return  The text value of the selected item. An error message if the call fails.
		 */
		public function getFlexSelection(id:String, args:String):String
		{
			var child:Object = appTreeParser.getElement(id);
			
			if(child == null)
			{
				return ErrorMessages.getError(ErrorMessages.ERROR_ELEMENT_NOT_FOUND, [id]);
			}
			
			if(child.hasOwnProperty("selectedLabel"))
			{
				return child.selectedLabel;
			}
			else
			{
				return ErrorMessages.getError(ErrorMessages.ERROR_NO_PROPERTY, [id]);
			}
			return null;
		}
		
		/**
		 * Retrieves a selection list related object based on index
		 * @param  id  The ID of the Flex object
		 * @param  args  <empty string>
		 * @return  The text value of the selected item's index. An error message if the call fails.
		 */
		public function getFlexSelectionIndex(id:String, args:String):String
		{
			var child:Object = appTreeParser.getElement(id);
			
			if(child == null)
			{
				return ErrorMessages.getError(ErrorMessages.ERROR_ELEMENT_NOT_FOUND, [id]);
			}
			
			if(child.hasOwnProperty("selectedIndex"))
			{
				return child.selectedIndex;
			}
			else
			{
				return ErrorMessages.getError(ErrorMessages.ERROR_NO_PROPERTY, [id]);
			}		
			return null;
		}
		
		/**
		 * Add a selected index to the list of selections, maintaining the previous selections.
		 * 
		 * @param  id  The ID of the Flex object
		 * @param args the index to be selected
		 * 
		 * @return  'true' if the selection was made. An error message if the call fails.
		 */
		public function doFlexAddSelectIndex(id:String, args:String) : String {
			var result:String;
			try
			{
				var widget:Object = appTreeParser.getWidgetById(id);
				var selected:Array = widget.selectedIndices;
				selected.push(parseInt(args));
				widget.selectedIndices = selected;
				result = String(widget.dispatchEvent(new ListEvent(ListEvent.CHANGE)));		
			}
			catch (e:Error)
			{
				// TODO use error standard
				result = "ERROR: Widget '" + id + "': " + e.message;
			}
			
			return result;
		}
		
		public function doFlexAddSelectMatchingOnField(id:String, field:String, value:String) : String {
			var result:String;
		
			try
			{
				var widget:Object = appTreeParser.getWidgetById(id);
				var provider:Object = widget.dataProvider;
				var index:int = -1;
				var i:int = 0;
				for each (var row:Object in provider)
				{
					if (row.hasOwnProperty(field))
					{
						if (row[field].toString() == value)
						{
							index = i;
							break;
						}
					} 
					i++;			
				}
				
				if (index > -1)
				{
					// The selected indices is managed like this in order to
					// enable the Flash player to pick up the change
					var selected:Array = widget.selectedIndices;
					selected.push(index);
					widget.selectedIndices = selected;
					result = String(widget.dispatchEvent(new ListEvent(ListEvent.CHANGE)));			
				}	
				else
				{
					// TODO use error standard
					throw new Error("No row with a value of '" + value + "' for field '" + field + "'");
				}	
			}
			catch(e:Error)
			{
				// TODO use error standard
				result = "ERROR: Widget '" + id + "': " + e.message;
			}
			
			return result;
		}
		
		/**
		 * Goes thru a Tree (which should use ArrayCollection as a backend OR AdvancedDataGrid as frontend) 
		 * and opens the branches and selects one or more items.
		 * @param	id  Locator for the tree item
		 * @param	args  First the property to use in searching separated with '|,|' from a list of search words.
		 * The search words must be separated with '#,#'. Example:
		 * node|,|word1#,#word2
		 * @return
		 */
		public function doFlexSelectTreeItem(id:String, args:String) : String {
			var result:String;
			result = "";
			
			try
			{
				var argsAr:Array = args.split("|,|");
				var propertyName:String = argsAr[0];
				var searchWord:String = argsAr[1];
				
				result = result + "args: "+args+" propertyName: "+propertyName+" searchWord: "+searchWord;
				
				// TreeItems = array for multiple selections
				var treeItems:Array = new Array();
				var searchWords:Array = new Array();
				if (searchWord.indexOf("#,#") != -1) {
					searchWords = searchWord.split("#,#");
				}
				
				var myTree:Object = appTreeParser.getWidgetById(id);
				var myNode:Object = myTree.dataProvider;
				
				// If there is an arraycollection behind the tree
				if (myNode is ArrayCollection) {
					for (var i:Number = 0; i<myNode.length; i++) {
						var objValue:Object = raw_findTreeNode(myTree, myNode.getItemAt(i), propertyName, searchWord);
						result = result+"1-: "+objValue;
						if (objValue != null) {
							result = result+"1: "+objValue;
							if (searchWords.length > 0) {
								result = result+"1.1: "+objValue;
								treeItems.push(objValue);
							}
							else {
								result = result+"1.2: "+objValue;
								myTree.selectedItem = objValue;
								myTree.dispatchEvent(new ListEvent(ListEvent.CHANGE));
								return result+"true"+objValue;
							}
						}
					}
				}
					// If the tree is a AdvancedDataGrid pseudo-tree 
				else if (myTree is AdvancedDataGrid) {
					myTree.collapseAll();
					// This means we search with parent and with the child
					if (searchWords.length == 2) {
						return ""+advancedDataGrid_selectTreeItem(myTree, searchWords[0], searchWords[1]);
					}
						// We search only with child
					else {
						result = result + "2.3:";
						myTree.expandAll();
						myTree.validateNow();
						result = result + "2.4:";
						if (myTree.findString(searchWord) == false) {
							result = result+" Error: child not found!";
							return result;
						}
						myTree.validateNow();
						// This is just a test, remove this line if any problems arise:
						return result + myTree.selectedItem;
					}
				}
				
				if (treeItems.length > 0) {
					myTree.selectedItems = treeItems;
					myTree.dispatchEvent(new ListEvent(ListEvent.CHANGE));
					return result+"true";
				}
				return result+"false";
			}
			catch (e:Error)
			{
				// TODO use error standard
				result = result + "ERROR: Widget '" + id + "': " + e.message;
			}
			
			return result;
		}
		
		/**
		 * TODO method description
		 * @param	myTree
		 * @param	myNode
		 * @param	propertyName
		 * @param	searchWord
		 * @return
		 */
		private function raw_findTreeNode(myTree:Object, myNode:Object, propertyName:String, searchWord:String):Object {
			if (propertyName != "") {
				if (myNode.hasOwnProperty(propertyName)) {
					if (myNode[propertyName] == searchWord) {
						return myNode;
					}
				}
			} // If propertyName is not supplied, go thru all the properties
			else {
				for(var id:String in myNode) {
					var value:Object = myNode[id];
					if (value == searchWord) {
						return myNode;
					}
				}
			}
			if (myNode.hasOwnProperty("children")) {
				for (var i:Number = 0; i<myNode.children.length; i++) {
					var objValue:Object = raw_findTreeNode(myTree, myNode.children[i], propertyName, searchWord);
					if (objValue != null) {
						// Open this branch, because it clearly has children
						myTree.expandItem(myNode, true);
						return objValue;
					}
				}
			}
			return null;
		}
		
		/**
		 * TODO method description
		 * @param	myTree
		 * @param	parent
		 * @param	child
		 * @return
		 */
		private function advancedDataGrid_selectTreeItem(myTree:Object, parent:String, child:String):Boolean {
			var foundParent:Boolean = true;
			var lastIndex:int = 0;
			
			while (foundParent != false) {
				foundParent = myTree.findString(parent);
				// If lastIndex is bigger than myTree.selectedindex
				// the findString didn't find anything and went around the whole tree and started at beginning
				if (lastIndex > myTree.selectedIndex) {
					foundParent = false;
					break;
				}
				lastIndex = myTree.selectedIndex;
				if (myTree.itemToLabel(myTree.selectedItem) == parent) {
					foundParent = true;
					break;
				}
			}
			if (foundParent == false) {
				return false;
			}
			// Now the parent is selected, we want to open it up
			myTree.expandItem(myTree.selectedItem, true);
			
			myTree.validateNow();
			var foundChild:Boolean = true;
			myTree.validateNow();
			lastIndex = 0;
			while (foundChild != false) {
				foundChild = myTree.findString(child);
				
				if (lastIndex > myTree.selectedIndex) {
					foundChild = false;
					break;
				}
				
				lastIndex = myTree.selectedIndex;
				if (myTree.itemToLabel(myTree.selectedItem) == child) {
					foundChild = true;
					break;
				}
			}
			
			if (foundChild == false) {
				return false;
			}
			myTree.validateNow();
			myTree.dispatchEvent(new ListEvent(ListEvent.CHANGE));
			return true;
		}
		
		// todo fix
		/**
		 * Sets an item on a list based on a matching value on one of its fields in its dataProvider
		 * 
		 * Command:	flexSelectMatchingOnField
		 * Target:	myListControl
		 * Value:	fieldName,this is the data value
		 * 
		 * Breakdown:
		 * 
		 * Command:	<command>
		 * Target:	<list id>,<field>
		 * Value:	<data value>
		 * 
		 * All fields are compulsory
		 * 
		 * @param  id  id of the control
		 * @param  value  takes the form <field>,<data value>
		 * @return  'true' if successfully set, error if not  
		 */
		public function doFlexSelectMatchingOnField(target:String, data:String):String
		{
			var args:Array = target.split(",");
			var id:String = args[0];
			var field:String = args[1];
			return rawFlexSelectMatchingOnField(id, field, data);
		}
		
		// TODO com
		public function rawFlexSelectMatchingOnField(id:String, field:String, value:String):String
		{
			var result:String;
			try
			{
				var widget:Object = appTreeParser.getWidgetById(id);
				if(! widget.hasOwnProperty(PROPERTY_DATA_PROVIDER))
				{
					// TODO use error standard
					throw new Error("Has no dataProvider property");
				}
				if (!widget.hasOwnProperty(PROPERTY_SELECTED_INDEX))
				{
					// TODO use error standard
					throw new Error("Has no selectedIndex property");
				}
				var dataProvider:Object = widget[PROPERTY_DATA_PROVIDER];
				var index:int = -1;
				var i:int = 0;
				for each (var row:Object in dataProvider)
				{
					if (row.hasOwnProperty(field))
					{
						if (row[field].toString() == value)
						{
							index = i;
							break;
						}
					} 
					i++;			
				}		
				if(index > -1)
				{
					widget[PROPERTY_SELECTED_INDEX] = i;
					result = String(widget.dispatchEvent(new ListEvent(ListEvent.ITEM_CLICK)) && widget.dispatchEvent(new ListEvent(ListEvent.CHANGE)));			
				}
				else
				{
					// TODO use error standard
					throw new Error("Could not select value '" + value + "' in field '" + field + "'");
				}
			}
			catch(e:Error)
			{
				// TODO use error standard
				result = "ERROR: Widget '" + id + "': " + e.message;
			}
			
			return result;
		}
		
		// TODO comm
		public function getFlexNumSelectedItems(id:String) : String {
			var result:String;
		
			try
			{
				var widget:Object = appTreeParser.getWidgetById(id);
				result = String(widget.selectedItems.length);
			}
			catch (e:Error)
			{
				// TODO use error standard
				result = "ERROR: Widget '" + id + "': " + e.message;
			}
			
			return result;
		}
		
		// TODO comm	
		public function getFlexSelectedItemAtIndex(id:String, index:String) : String {
			var result:String;
		
			try {
				var widget:Object = appTreeParser.getWidgetById(id);
				
				result = widget.selectedItems[parseInt(index)].toString();
			}
			catch (e:Error) {
				// TODO use error standard
				result = "ERROR: Widget '" + id + "': " + e.message;
			}
			
			return result;
		}
		
		// TODO comm
		private function dispatchIndexChangeEvent(child:Object):String
		{
			var comtype:String = Tools.getOjectType(child);
			switch(comtype)
			{
				case ReferenceData.TABNAVIGATOR_DESCRIPTION :
					return String(child.dispatchEvent(new Event(Event.TAB_INDEX_CHANGE)));
					break;
				default :
					return String(child.dispatchEvent(new ListEvent(ListEvent.CHANGE)));
					break;	
			}
			return null;
		}
	}
}