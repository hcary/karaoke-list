<?php

$search = $_GET['sparam'];

include "config.php";
include "db.php";


echo "";
if ( strlen($search) ) {
    $SQL = "SELECT artist, title FROM songlist WHERE artist LIKE '%" . $search . "%' OR title LIKE '%" . $search . "%'";
    echo $SQL . "<br>";
}
else {
    $SQL = "SELECT artist, title FROM songlist";
}

    if (!$result = $dbh->query($SQL)) {
        echo "Sorry, the website is experiencing problems.";
        exit;
    }

echo "<table>";
while ($myrow = $result->fetch_assoc()) {
    print "<tr><td>" . $myrow[artist] . "</td><td>" . $myrow[title] . "</td></tr>";
}
echo "</table>";



?>