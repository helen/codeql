<?php
// Test: Reflected XSS detection

// VULNERABLE: Direct echo of user input
echo $_GET['name']; // BAD

// VULNERABLE: Through variable
$input = $_POST['data'];
echo $input; // BAD

// VULNERABLE: String concatenation
echo "<h1>" . $_GET['title'] . "</h1>"; // BAD

// SAFE: htmlspecialchars
echo htmlspecialchars($_GET['name']); // GOOD

// SAFE: htmlentities
echo htmlentities($_POST['data']); // GOOD

// SAFE: intval
echo intval($_GET['id']); // GOOD

// SAFE: json_encode
echo json_encode($_GET['data']); // GOOD
