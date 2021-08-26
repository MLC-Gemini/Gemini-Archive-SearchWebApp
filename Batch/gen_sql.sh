TOWERFILE=$1
echo "begin"
while IFS=, read new_scandate scanoperator documentcategory boxid batchid bundleid ifnds ifnid numberofpages barparta barpartb backlogflag linked ;
do
	scandate=`echo $new_scandate|cut -c 1-10`
	echo "
	INSERT INTO towerimage_wk VALUES( 
		'$scandate', 
		'$scanoperator', 
		'$documentcategory', 
		'$boxid', 
		'$batchid', 
		'$bundleid', 
		$ifnds, 
		$ifnid, 
		$numberofpages, 
		'$barparta', 
		'$barpartb', 
		'$backlogflag', 
		0, 
		to_date('$new_scandate','yyyy-mm-dd hh24:mi:ss'),null,null 
	);
	"
done < $TOWERFILE
echo "	
	bundle_populate();
	commit;
end;
/ 
quit
/"
