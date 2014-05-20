#include maps\mp\_utility;
#include common_scripts\utility;

index_of( find, array )
{
	for( i = 0; i < array.size; i++ )
	{
		if( find == array[i] )
			return i;
	}
}
