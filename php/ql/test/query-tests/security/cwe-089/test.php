<?php

// Test: SQL injection via superglobals

// BAD: direct concatenation of user input into SQL query
$name = $_GET['name'];
$query = "SELECT * FROM users WHERE name = '" . $name . "'";
$pdo->query($query);

// BAD: using $_POST
$id = $_POST['id'];
mysqli_query($conn, "DELETE FROM users WHERE id = " . $id);

// GOOD: using prepared statements
$stmt = $pdo->prepare("SELECT * FROM users WHERE name = ?");
$stmt->execute([$_GET['name']]);

// BAD: concatenation into exec
$pdo->exec("DROP TABLE " . $_REQUEST['table']);
