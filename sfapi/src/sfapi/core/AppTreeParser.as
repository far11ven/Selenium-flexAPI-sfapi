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
package sfapi.core
{
	import flash.utils.getQualifiedClassName;
	
	public class AppTreeParser
	{
		public var thisApp:Object;
		private var nextNode:AppTreeNode;
		private var firstNode:AppTreeNode;
		
		
		public function AppTreeParser()
		{
			
		}
		/**
		 * Find a Object using its id attribute, wherever it is in the application
		 * @param  id  id attribute of the Object to return
		 * @return  The Object corresponding to the id, or null if not found
		 */
		public function getElement(target:String):Object
		{
			
			if(target.indexOf(":") >= 0)
			{
				return getElementByCustomTarget(target.split('/'), thisApp.parent);
			}
			
			var locatorDelimeter:int = target.indexOf("=")
			if(locatorDelimeter < 0)
			{
				return getElementByProperty(target.split('/'), "id", thisApp.parent);
			}
			
			var locator:String=target.substring(0,locatorDelimeter); 
			target=target.substring(locatorDelimeter + 1);
			
			// id is the default
			if(locator == "")
			{
				return getElementByProperty(target.split('/'), "id", thisApp.parent);
			}
			
			try
			{
				var myFunction:Function=this["locateElementBy" + locator];
				if (myFunction != null)
				{
					return myFunction.call(this, target);
				}	
			}
			catch(e:Error)
			{
				trace(e.message);
			}
			return getElementByProperty(target.split('/'), locator, thisApp.parent);
		} 
		
		/**
		 * getElementByCustomTarget()
		 *
		 *	Description:
		 * 		locate the Flex Component object by using a target specifier which allows
		 *		for user-definable nested component references that not assume a specific 
		 *		property type (such as ID).
		 *		
		 *	Target Specifier Grammar:
		 *		specifier 		= component-spec[/component-spec[/component-spec]...]
		 *		component-spec 	= propertyName:targetValue
		 *		propertyName 	= a property defined for the specific component
		 *		targetValue 	= the value of the property to be used to match.
		 *						  The targetValue must be unique within all siblings of the parent container. 
		 */ 
		public function getElementByCustomTarget(searchPath:Array, searchScope:Object):Object
		{
			var current:String = searchPath[searchPath.length - 1];
			var property:String = "id";
			var element:String = current;
			
			var locatorDelimeter:int = current.indexOf(":") 
			if(locatorDelimeter >= 0)
			{
				// locator = "myProperty:hello"
				property = current.substring(0, locatorDelimeter); 
				element = current.substring(locatorDelimeter + 1);
			}
			
			if(searchPath.length > 1)
			{
				// build list of ancestors to pass to next iteration of the locator function 
				var narrowSearchPath:Array = new Array();
				for(var i:int = 0; i < searchPath.length - 1; i++)
				{
					narrowSearchPath.push(searchPath[i]);
				} 
				searchScope = getElementByCustomTarget(narrowSearchPath, searchScope);
			}
			return searchForTarget(element, property, searchScope);
		}
		
		/**
		 * @param
		 * @return
		 */
		public function getElementByProperty(searchPath:Array, property:String, searchScope:Object):Object
		{
			if(searchPath.length > 1)
			{
				// build list of ancestors to pass to next iteration of the locator function 
				var narrowSearchPath:Array = new Array();
				for(var i:int = 0; i < searchPath.length - 1; i++)
				{
					narrowSearchPath.push(searchPath[i]);
				} 
				searchScope = getElementByProperty(narrowSearchPath, property, searchScope);
			}
			return searchForTarget(searchPath[searchPath.length - 1], property, searchScope);
		}
		
		/**
		 * @param
		 * @return
		 */
		private function searchForTarget(element:String, property:String, root:Object):Object
		{
			var parents:Array = new Array();
			var currentNode:AppTreeNode = new AppTreeNode(root);
			var sibTravers:Boolean = false;
			
			while(isNotTargetNode(element, property, currentNode.child))
			{
				if(hasFirstChild(currentNode) && ! sibTravers)
				{
					parents.push(currentNode);
					currentNode = firstNode;
				}
				else if(hasNextNode(currentNode, parents[parents.length - 1].child))
				{
					currentNode = nextNode;
					sibTravers = false;
				}
				else
				{
					currentNode = parents.pop();
					sibTravers = true;
				}
				if(currentNode.child == root)
				{
					return null
				}
			}
			parents = null;
			if(currentNode.child == root)
			{
				return null
			}
			return currentNode.child;
		}
		
		/**
		 * @param
		 * @return
		 */
		private function isNotTargetNode(element:String, property:String, node:Object):Boolean
		{
			return ! ((node.hasOwnProperty(property) && node[property] == element) || node.name == element);
		}
		
		/**
		 * @param
		 * @return
		 */
		private function hasFirstChild(node:AppTreeNode):Boolean
		{
			if(node.child.hasOwnProperty("numChildren") && node.child.numChildren > 0)
			{
				firstNode = new AppTreeNode(node.child.getChildAt(0), 0, false);
				return true;
			}
			if(node.child.hasOwnProperty("rawChildren") && node.child.rawChildren.numChildren > 0)
			{
				firstNode = new AppTreeNode(node.child.rawChildren.getChildAt(0), 0, true);
				return true;
			}
			return false;
		}
		
		private function isChild(child:Object, parent:Object):Boolean
		{
			// this looks weird but its bacause getChildIndex will throw and exception 
			// instead of returning -1 as it should if child does not exist within it 
			try
			{
				parent.getChildIndex(child);
				return true;
			}catch(e:Error){}
			return false;
		}
		
		/**
		 * Finds out if an object is not a ContentPane. This can be dtermined quickly by checking if
		 * the qualified class name is "mx.core::FlexSprite".
		 * 
		 * @param  child  the object to check
		 * @return true if the object is not a "mx.core::FlexSprite", otherwise false.
		 */
		private function isNotContentPane(child:Object):Boolean
		{
			return getQualifiedClassName(child) != "mx.core::FlexSprite";
		}
		
		/**
		 * Find out if the object has a sibling node on the tree that has no been visited yet or
		 * is not a ContentPane.
		 *  
		 * @param  node  The current node the algorithm is positioned on in the application object model
		 * @param  parent  The parent object of the node
		 * @return  true is there is a next-node available, otherwise false.
		 */
		private function hasNextNode(node:AppTreeNode, parent:Object):Boolean
		{
			var i:int;
			
			if(node.isRaw)
			{
				return gotoNextRaw(node, parent);
			}
			else
			{
				if(node.index < parent.numChildren - 1)
				{
					i = node.index + 1;
					// get the next unvisited child
					nextNode = new AppTreeNode(parent.getChildAt(i), i, false);
					return true;
				}
				return gotoNextRaw(node, parent);
			}
			return false;
		}
		
		/**
		 * Find out if the object has a sibling node on the tree that has no been visited yet or
		 * is not a ContentPane. The node must be a rawChild of the parent node.
		 *  
		 * @param  node  The current node the algorithm is positioned on in the application object model
		 * @param  parent  The parent object of the node
		 * @return  true is there is a next-node available, otherwise false.
		 */
		private function gotoNextRaw(node:AppTreeNode, parent:Object):Boolean
		{
			var i:int = 0;
			if(node.isRaw)
			{
				i = node.index + 1;
			}
			if(parent.hasOwnProperty("rawChildren") && i < parent.rawChildren.numChildren)
			{
				var child:Object;
				while(i < parent.rawChildren.numChildren)
				{
					child = parent.rawChildren.getChildAt(i);
					if(isNotContentPane(child) && ! isChild(child, parent))
					{
						nextNode = new AppTreeNode(child, i, true);
						return true;
					}
					i++;
				}
			}
			return false;
		}
		
		/**
		 * @param
		 * @return
		 */
		public function setTooltipsToID():void
		{
			var parents:Array = new Array();
			var currentNode:AppTreeNode = new AppTreeNode(thisApp.parent);
			var sibTravers:Boolean = false;

			do
			{
				if(hasFirstChild(currentNode) && ! sibTravers)
				{
					parents.push(currentNode);
					currentNode = firstNode;
					assignID(currentNode.child);
				}
				else if(hasNextNode(currentNode, parents[parents.length - 1].child))
				{
					currentNode = nextNode;
					assignID(currentNode.child);
					sibTravers = false;
				}
				else
				{
					currentNode = parents.pop();
					sibTravers = true;
				}
			} while(currentNode.child != thisApp.parent);
			
			parents = null;
		}
		
		/**
		 * 
		 * @param
		 * @return
		 * 
		 */
		private function assignID(node:Object):void
		{
			if(node.hasOwnProperty("id") && node.hasOwnProperty("toolTip"))
			{
				if(node.id == null)
				{
					trace(node.toString().match("\\w+$")[0]);
					node.id = node.toString().match("\\w+$")[0];
				}
				node.toolTip = node.id;
			}
		}
		
		/**
		 * Find a UIComponent using its id attribute, wherever it is in the application
		 * @param  id  id attribute of the UIComponent to return
		 * @return  The UIComponent corresponding to the id, or null if not found
		 */		
		public function getWidgetById(id:String):Object
		{
			var component:Object = getElement(id);
			if(! component)
			{
				throw new Error("Component with id '" + id + "' could not be found");
			}
			return component;
		}
	}
}