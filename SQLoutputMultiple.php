
<?php
$servername = "localhost";  // Replace with your MySQL server name
$username = *********;     // Replace with your MySQL username
$password = *********;     // Replace with your MySQL password
$dbname = **********;       // Replace with your MySQL database name

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Perform query and generate JSON data
if ($_POST['function'] == 'mySQLFunction') {
    $params = array();
    foreach ($_POST as $keyword => $value) {
        if (strpos($keyword, 'param') === 0) {
            // Only include parameters with names starting with "param"
            $params[] = $value;
        }
    }

    // Build the SQL query dynamically
    $placeholders = implode(',', array_fill(0, count($params), '?'));
    $sql = "SELECT keyword, weighting FROM output WHERE keyword IN ($placeholders)";
    
    $stmt = $conn->prepare($sql);
    $stmt->bind_param(str_repeat('s', count($params)), ...$params);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        // If results are found, build the JSON array from the query results
        $rows = array();
        while($row = $result->fetch_assoc()) {
            $rows[] = $row;
        }
    } else {
        // If no results are found, build the JSON array with a weighting of 0.5 for all keywords
        $rows = array();
        foreach ($params as $param) {
            $rows[] = array('keyword' => $param, 'weighting' => 0.5);
        }
    }
    
    header('Content-Type: application/json');
    echo json_encode($rows);
}

$conn->close();
?>
