<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="css/pp-songlist.css">
</head>
<body>
    <br>
    
<?php


if ( isset($_POST["qtype"]) && !empty($_POST["qtype"]) ) {
    $qtype = $_POST['qtype'];
}

if ( isset($_POST["sstring"]) && !empty($_POST["sstring"])) {
    $sstring = $_POST['sstring'];
    $search_array = split(" ", $sstring);
    $search_terms = count($search_array);
}

if ( isset($_GET["qtype"]) && !empty($_GET["qtype"]) ) {
    $qtype = $_GET['qtype'];
}

if ( isset($_GET["sstring"]) && !empty($_GET["sstring"])) {
    $sstring = $_GET['sstring'];
}

include "config.php";
include "db.php";

echo<<<END

<form id="transaction" action="songlist.php" method="post">
    <label for="sstring">Search</label>
    <input type="text" name="sstring" size="50">
    <input type="submit" value="Submit"><br><br>
    <input type="hidden" name="qtype" value="search">
</form>
END;

echo "<b>Browse Artists: </b>";
echo "<a href=\"songlist.php?qtype=artist_list&sstring=number\">0 - 9</a>";


foreach (range('A', 'Z') as $char) {
    echo " | ";
    echo "<a href=\"songlist.php?qtype=artist_list&sstring=" . $char . "\">" . $char . "</a>";
}

echo "<br><hr>";

if( $qtype == "search" ) {
    
    if ( $search_terms > 1 ) {
        $loop_count = 0;
        foreach ( $search_array as $item ) {
            if( $loop_count < 1 ) {
                $wStr = " concat(artist,' ',title) LIKE '%" . $item . "%'";
                $loop_count = 1;
            }
            else {
                $wStr = $wStr . " AND concat(artist,' ',title) LIKE '%" . $item . "%'";
            }
        }
       
        $SQL = "SELECT artist, title FROM songlist WHERE " . $wStr;

    }
    else {
        $SQL = "SELECT artist, title FROM songlist WHERE concat(artist,' ',title) LIKE '%" . $sstring . "%'";
    }

}
elseif( $qtype == "artist_list" && $sstring <> "number" ) {
    
    $SQL = "SELECT artist, title FROM songlist WHERE artist LIKE '" . $sstring . "%'";  

}
elseif( $qtype == "artist_list" && $sstring == "number" ) {

    $wStr = " artist LIKE '0%'";
    foreach (range(1, 9) as $char) {
        $wStr = $wStr . " OR artist LIKE '$char%'";
    }

    $SQL = "SELECT artist, title FROM songlist WHERE $wStr"; 

}
elseif( $qtype == "artist_list_all" ) {

     $SQL = "SELECT DISTINCT(artist) FROM songlist ORDER BY artist";
     
}

if( strlen($SQL) > 0 ) {

    if (!$result = $dbh->query($SQL)) {
        echo "Sorry, the website is experiencing problems.";
        exit;
    }

}


echo<<<END
    <table  class="zui-table zui-table-zebra zui-table-horizontal">
        <thead>
            <tr>
                <th>Artist</th>
                <th>Title</th>
            </tr>
        </thead>
        <tbody>
END;


$count = 0;
while ($myrow = $result->fetch_assoc()) {
        
    print "<tr>
            <td>" . $myrow['artist'] . "</td>
            <td>" . $myrow['title'] . "</td>
        </tr>\n";
        
}
echo "</tbody>
    </table>";



?>