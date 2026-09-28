<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: *");

// Database Configuration
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'smartcar_rent');

// Create database connection
$conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Set charset
$conn->set_charset("utf8mb4");

// API Configuration
define('API_BASE_URL', 'https://api.smartcarrent.co.tz');
define('JWT_SECRET', 'your_jwt_secret_key_here');
define('UPLOAD_PATH', '../uploads/');

// Helper function to send JSON response
function sendResponse($status, $message, $data = null) {
    $response = [
        'status' => $status,
        'message' => $message,
        'data' => $data
    ];
    
    header('Content-Type: application/json');
    echo json_encode($response);
    exit();
}

// Helper function to validate input
function validateInput($data) {
    return htmlspecialchars(strip_tags(trim($data)));
}

// Helper function to generate JWT token
function generateJWT($userId, $email) {
    $header = json_encode(['typ' => 'JWT', 'alg' => 'HS256']);
    $payload = json_encode([
        'user_id' => $userId,
        'email' => $email,
        'iat' => time(),
        'exp' => time() + (86400 * 30) // 30 days
    ]);
    
    $base64UrlHeader = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
    $base64UrlPayload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload));
    
    $signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, JWT_SECRET, true);
    $base64UrlSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));
    
    return $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;
}

// Helper function to verify JWT token
function verifyJWT($token) {
    $parts = explode('.', $token);
    if (count($parts) != 3) {
        return false;
    }
    
    $header = base64_decode(str_replace(['-', '_'], ['+', '/'], $parts[0]));
    $payload = base64_decode(str_replace(['-', '_'], ['+', '/'], $parts[1]));
    $signature = $parts[2];
    
    $payloadArray = json_decode($payload, true);
    if (!$payloadArray || time() > $payloadArray['exp']) {
        return false;
    }
    
    $base64UrlHeader = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
    $base64UrlPayload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload));
    
    $expectedSignature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, JWT_SECRET, true);
    $base64UrlExpectedSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($expectedSignature));
    
    return hash_equals($signature, $base64UrlExpectedSignature) ? $payloadArray : false;
}

// Helper function to get current user from JWT
function getCurrentUser() {
    $headers = getallheaders();
    $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';
    
    if (strpos($authHeader, 'Bearer ') === 0) {
        $token = substr($authHeader, 7);
        $payload = verifyJWT($token);
        
        if ($payload) {
            return $payload;
        }
    }
    
    return null;
}

// Helper function to handle file upload
function handleFileUpload($file, $allowedTypes = ['jpg', 'jpeg', 'png', 'gif']) {
    if (!isset($file) || $file['error'] !== UPLOAD_ERR_OK) {
        throw new Exception('File upload error');
    }
    
    $fileName = $file['name'];
    $fileSize = $file['size'];
    $fileTmpName = $file['tmp_name'];
    $fileType = pathinfo($fileName, PATHINFO_EXTENSION);
    
    // Validate file type
    if (!in_array(strtolower($fileType), $allowedTypes)) {
        throw new Exception('Invalid file type');
    }
    
    // Validate file size (5MB max)
    if ($fileSize > 5 * 1024 * 1024) {
        throw new Exception('File too large');
    }
    
    // Generate unique filename
    $newFileName = uniqid() . '.' . $fileType;
    $uploadPath = UPLOAD_PATH . $newFileName;
    
    // Move file to upload directory
    if (!move_uploaded_file($fileTmpName, $uploadPath)) {
        throw new Exception('Failed to move uploaded file');
    }
    
    return [
        'filename' => $newFileName,
        'path' => $uploadPath,
        'url' => API_BASE_URL . '/uploads/' . $newFileName
    ];
}
?>
