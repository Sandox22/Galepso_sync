<?php
function array2json2($arr) 
{ 
 ini_set('memory_limit', '2048M');

    if(function_exists('json_encode')) 
		return json_encode($arr); //Lastest versions of PHP already has this functionality.
	
	 
    $parts = array(); 
    $is_list = false; 
	

    //Find out if the given array is a numerical array 
    $keys = array_keys($arr); 
    $max_length = count($arr)-1; 
    if(($keys[0] == 0) and ($keys[$max_length] == $max_length)) 
	{//See if the first key is 0 and last key is length - 1 
        $is_list = false; 
        for($i=0; $i<count($keys); $i++)
		{ //See if each key correspondes to its position 
            if($i != $keys[$i])
			{ //A key fails at position check. 
                $is_list = false; //It is an associative array. 				
                break; 
            } 
        } 
    } 
    foreach($arr as $key => $value)
	{ 

        if(is_array($value))
		{ //Custom handling for arrays 		
            if($is_list)
			{
				$parts[] = array2json2($value); /* :RECURSION: */ 
			
			}
            else
			{
				$parts[] = '"' . $key . '":' . array2json2($value); /* :RECURSION: */ 
				
			}
        } 
		else
		{ 
		
            $str = ''; 
            if(!$is_list) 
			$str = '"' . $key . '":'; 

            //Custom handling for multiple data types 
            //if(is_numeric($value)) $str .= $value; //Numbers 
			if(is_numeric($value)) $str .='"' . addslashes($value) . '"'; //Numbers 
            elseif($value === false) $str .= 'false'; //The booleans 
            elseif($value === true) $str .= 'true'; 
            else $str .= '"' . addslashes($value) . '"'; //All other things 
            // :TODO: Is there any more datatype we should be in the lookout for? (Object?) 

            $parts[] = $str; 
        } 
    } 
	
    $json = implode(',',$parts); 
     	
	
		
    if($is_list)
	{
	 	return '[' . $json . ']';//Return numerical JSON 
	}
	else	
	{		
    	return '{' . trim($json) . '}';//Return associative JSON	
	}
} 
function prettyPrint2( $json )
{
    if (!is_string($json)) {
    if (phpversion() && phpversion() >= 5.4) {
      return json_encode($json, JSON_PRETTY_PRINT);
    }
    $json = json_encode($json);
  }
  $result      = '';
  $pos         = 0;               // indentation level
  $strLen      = strlen($json);
  $indentStr   = "\t";
  $newLine     = "\n";
  $prevChar    = '';
  $outOfQuotes = true;

  for ($i = 0; $i < $strLen; $i++) {
    // Grab the next character in the string
    $char = substr($json, $i, 1);

    // Are we inside a quoted string?
    if ($char == '"' && $prevChar != '\\') {
      $outOfQuotes = !$outOfQuotes;
    }
    // If this character is the end of an element,
    // output a new line and indent the next line
    else if (($char == '}' || $char == ']') && $outOfQuotes) {
      $result .= $newLine;
      $pos--;
      for ($j = 0; $j < $pos; $j++) {
        $result .= $indentStr;
      }
    }
    // eat all non-essential whitespace in the input as we do our own here and it would only mess up our process
    else if ($outOfQuotes && false !== strpos(" \t\r\n", $char)) {
      continue;
    }

    // Add the character to the result string
    $result .= $char;
    // always add a space after a field colon:
    if ($char == ':' && $outOfQuotes) {
      $result .= ' ';
    }

    // If the last character was the beginning of an element,
    // output a new line and indent the next line
    if (($char == ',' || $char == '{' || $char == '[') && $outOfQuotes) {
      $result .= $newLine;
      if ($char == '{' || $char == '[') {
        $pos++;
      }
      for ($j = 0; $j < $pos; $j++) {
        $result .= $indentStr;
      }
    }
    $prevChar = $char;
  }

  return $result;
}
function convertArrayKeysToUtf82(array $array) { 
    $convertedArray = array(); 
    foreach($array as $key => $value) { 
      if(!mb_check_encoding($value, 'UTF-8')) 
	  	$value = utf8_encode($value); 
		
      if(is_array($value)) $value = $this->convertArrayKeysToUtf82($value);
      	$convertedArray[$key] = $value; 
    } 
    return $convertedArray; 
  } 
?>