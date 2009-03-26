package org.axiis.layouts.scale
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * A scale that deals with categorical data. The categories are assumed to be
	 * sorted alphabetically.
	 */
	public class CategoricalScale extends AbstractScale implements IScale
	{
		/**
		 * A sorted list of all unique possible values found within the dataProvider
		 */
		private var uniqueValues:Array = [];
		
		/**
		 * Update uniqueValues, computedMaxValue, and computedMinValue.
		 */
		override public function validate():void
		{
			super.validate();
			uniqueValues = extractUniqueValues();
			if(uniqueValues.length > 0)
			{
				computedMinValue = uniqueValues[0];
				computedMaxValue = uniqueValues[uniqueValues.length - 1];
			}				
		}
		
		/**
		 * Converts a value to layout-space. If the value is not represented within
		 * the dataProvider, NaN is returned.
		 */
		override public function valueToLayout(value:Object):Number
		{
			if(invalidated)
				validate();
				
			var valueIndex:Number = uniqueValues.indexOf(value);
			if(valueIndex == -1)
				return NaN;
			
			var percentage:Number = (valueIndex + 1) / uniqueValues.length;
			var toReturn:Number = percentage * (maxLayout - minLayout) + minLayout;
			trace(value +" " +toReturn + " " + percentage + " " + valueIndex);
			return toReturn;
		}
		
		/**
		 * Converts a layout position to a value from the dataProvider. The layout
		 * position is clamped between minLayout and maxLayout before the
		 * translation takes place.
		 */
		override public function layoutToValue(layout:Number):Object
		{ 
			if (invalidated)
				validate();
				
			var layoutDelta:Number = maxLayout - minLayout;
			var layoutPercentage:Number = (layout - layoutDelta) / (layoutDelta);
			var index:Number = Math.round(layoutPercentage * uniqueValues.length) - 1;
			index = Math.max(0,Math.min(uniqueValues.length - 1,index));
			return uniqueValues[index];
		}
		
		/**
		 * Builds a sorted array of the unique values found within the dataProvider.
		 * Excludes values that fall alphabetically outside the user specified range
		 * of minLayout to maxLayout. 
		 */
		private function extractUniqueValues():Array
		{
			var toReturn:Array = [];
			for each(var o:Object in dataProvider)
			{
				var currValue:Object = dataField == null ? o : o[dataField];
				if((toReturn.indexOf(currValue) == -1)	// Check if the value isn't in the array
					&& (userMinValue == null || currValue >= userMinValue) // Check if the value is in bounds
					&& (userMaxValue == null || currValue <= userMaxValue))
				{
					toReturn.push(currValue);
				}
			}
			toReturn.sort();
			return toReturn;
		}
	}
}