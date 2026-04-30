<?php
// Test: SQL injection detection

// VULNERABLE: Direct superglobal to query
$id = $_GET['id'];
$pdo = new PDO("mysql:host=localhost;dbname=test", "root", "");
$pdo->query("SELECT * FROM users WHERE id = " . $id); // BAD

// VULNERABLE: Through variable
$name = $_POST['name'];
$sql = "SELECT * FROM users WHERE name = '" . $name . "'";
$pdo->exec($sql); // BAD

// SAFE: Using prepared statement with bound parameters
$stmt = $pdo->prepare("SELECT * FROM users WHERE id = ?");
$stmt->execute([$_GET['id']]); // GOOD

// SAFE: Using intval
$safe_id = intval($_GET['id']);
$pdo->query("SELECT * FROM users WHERE id = " . $safe_id); // GOOD

// VULNERABLE: mysqli
$conn = new mysqli("localhost", "root", "", "test");
$conn->query("SELECT * FROM users WHERE id = " . $_GET['id']); // BAD

// SAFE: real_escape_string
$escaped = $conn->real_escape_string($_GET['name']);
$conn->query("SELECT * FROM users WHERE name = '" . $escaped . "'"); // GOOD
