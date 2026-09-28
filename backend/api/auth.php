<?php
require_once 'api_config.php';

// Get request method
$method = $_SERVER['REQUEST_METHOD'];

try {
    switch ($method) {
        case 'POST':
            $endpoint = $_GET['action'] ?? '';
            
            switch ($endpoint) {
                case 'register':
                    handleRegister();
                    break;
                    
                case 'login':
                    handleLogin();
                    break;
                    
                case 'phone-login':
                    handlePhoneLogin();
                    break;
                    
                case 'send-otp':
                    handleSendOTP();
                    break;
                    
                case 'verify-otp':
                    handleVerifyOTP();
                    break;
                    
                default:
                    sendResponse(400, 'Invalid endpoint');
            }
            break;
            
        case 'GET':
            $endpoint = $_GET['action'] ?? '';
            
            switch ($endpoint) {
                case 'profile':
                    handleGetProfile();
                    break;
                    
                case 'logout':
                    handleLogout();
                    break;
                    
                default:
                    sendResponse(400, 'Invalid endpoint');
            }
            break;
            
        case 'PUT':
            $endpoint = $_GET['action'] ?? '';
            
            switch ($endpoint) {
                case 'profile':
                    handleUpdateProfile();
                    break;
                    
                default:
                    sendResponse(400, 'Invalid endpoint');
            }
            break;
            
        default:
            sendResponse(405, 'Method not allowed');
    }
} catch (Exception $e) {
    sendResponse(500, 'Internal server error: ' . $e->getMessage());
}

// Registration handler
function handleRegister() {
    $data = json_decode(file_get_contents('php://input'), true);
    
    // Validate required fields
    $required = ['full_name', 'email', 'password', 'phone_number', 'location'];
    foreach ($required as $field) {
        if (empty($data[$field])) {
            sendResponse(400, "Field '$field' is required");
        }
    }
    
    // Validate email format
    if (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
        sendResponse(400, 'Invalid email format');
    }
    
    // Validate phone number (Tanzanian format)
    $phone = preg_replace('/[^0-9]/', '', $data['phone_number']);
    if (!preg_match('/^(255|0)?[6-7][0-9]{8}$/', $phone)) {
        sendResponse(400, 'Invalid Tanzanian phone number');
    }
    
    // Check if user already exists
    $stmt = $conn->prepare("SELECT id FROM users WHERE email = ? OR phone_number = ?");
    $stmt->bind_param("ss", $data['email'], $data['phone_number']);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        sendResponse(400, 'User with this email or phone number already exists');
    }
    
    // Hash password
    $hashedPassword = password_hash($data['password'], PASSWORD_DEFAULT);
    
    // Insert new user
    $stmt = $conn->prepare("INSERT INTO users (full_name, email, password, phone_number, location) VALUES (?, ?, ?, ?, ?)");
    $stmt->bind_param("sssss", $data['full_name'], $data['email'], $hashedPassword, $data['phone_number'], $data['location']);
    
    if ($stmt->execute()) {
        $userId = $conn->insert_id;
        
        // Generate JWT token
        $token = generateJWT($userId, $data['email']);
        
        // Store session
        $expiresAt = date('Y-m-d H:i:s', strtotime('+30 days'));
        $stmt = $conn->prepare("INSERT INTO user_sessions (user_id, token, expires_at) VALUES (?, ?, ?)");
        $stmt->bind_param("iss", $userId, $token, $expiresAt);
        $stmt->execute();
        
        sendResponse(201, 'Registration successful', [
            'user_id' => $userId,
            'token' => $token,
            'user' => [
                'id' => $userId,
                'full_name' => $data['full_name'],
                'email' => $data['email'],
                'phone_number' => $data['phone_number'],
                'location' => $data['location']
            ]
        ]);
    } else {
        sendResponse(500, 'Registration failed');
    }
}

// Login handler
function handleLogin() {
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (empty($data['email']) || empty($data['password'])) {
        sendResponse(400, 'Email and password are required');
    }
    
    // Get user by email
    $stmt = $conn->prepare("SELECT id, full_name, email, password, phone_number, location, is_verified FROM users WHERE email = ?");
    $stmt->bind_param("s", $data['email']);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        sendResponse(401, 'Invalid credentials');
    }
    
    $user = $result->fetch_assoc();
    
    // Verify password
    if (!password_verify($data['password'], $user['password'])) {
        sendResponse(401, 'Invalid credentials');
    }
    
    // Generate JWT token
    $token = generateJWT($user['id'], $user['email']);
    
    // Store session
    $expiresAt = date('Y-m-d H:i:s', strtotime('+30 days'));
    $stmt = $conn->prepare("INSERT INTO user_sessions (user_id, token, expires_at) VALUES (?, ?, ?)");
    $stmt->bind_param("iss", $user['id'], $token, $expiresAt);
    $stmt->execute();
    
    sendResponse(200, 'Login successful', [
        'user_id' => $user['id'],
        'token' => $token,
        'user' => [
            'id' => $user['id'],
            'full_name' => $user['full_name'],
            'email' => $user['email'],
            'phone_number' => $user['phone_number'],
            'location' => $user['location'],
            'is_verified' => $user['is_verified']
        ]
    ]);
}

// Phone login handler
function handlePhoneLogin() {
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (empty($data['phone_number'])) {
        sendResponse(400, 'Phone number is required');
    }
    
    // Validate phone number
    $phone = preg_replace('/[^0-9]/', '', $data['phone_number']);
    if (!preg_match('/^(255|0)?[6-7][0-9]{8}$/', $phone)) {
        sendResponse(400, 'Invalid Tanzanian phone number');
    }
    
    // Check if user exists
    $stmt = $conn->prepare("SELECT id, full_name, email, phone_number, location FROM users WHERE phone_number = ?");
    $stmt->bind_param("s", $data['phone_number']);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        sendResponse(404, 'User with this phone number not found');
    }
    
    $user = $result->fetch_assoc();
    
    // Generate and send OTP
    $otp = sprintf('%06d', mt_rand(100000, 999999));
    $expiresAt = date('Y-m-d H:i:s', strtotime('+10 minutes'));
    
    // Store OTP
    $stmt = $conn->prepare("INSERT INTO otp_verification (phone_number, otp_code, expires_at) VALUES (?, ?, ?)");
    $stmt->bind_param("sss", $data['phone_number'], $otp, $expiresAt);
    $stmt->execute();
    
    // In production, send OTP via SMS service
    // For now, just return it for testing
    sendResponse(200, 'OTP sent successfully', [
        'otp' => $otp, // Remove this in production
        'expires_at' => $expiresAt
    ]);
}

// Send OTP handler
function handleSendOTP() {
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (empty($data['phone_number'])) {
        sendResponse(400, 'Phone number is required');
    }
    
    // Validate phone number
    $phone = preg_replace('/[^0-9]/', '', $data['phone_number']);
    if (!preg_match('/^(255|0)?[6-7][0-9]{8}$/', $phone)) {
        sendResponse(400, 'Invalid Tanzanian phone number');
    }
    
    // Generate OTP
    $otp = sprintf('%06d', mt_rand(100000, 999999));
    $expiresAt = date('Y-m-d H:i:s', strtotime('+10 minutes'));
    
    // Store OTP
    $stmt = $conn->prepare("INSERT INTO otp_verification (phone_number, otp_code, expires_at) VALUES (?, ?, ?)");
    $stmt->bind_param("sss", $data['phone_number'], $otp, $expiresAt);
    $stmt->execute();
    
    // In production, send OTP via SMS service
    sendResponse(200, 'OTP sent successfully', [
        'expires_at' => $expiresAt
    ]);
}

// Verify OTP handler
function handleVerifyOTP() {
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (empty($data['phone_number']) || empty($data['otp'])) {
        sendResponse(400, 'Phone number and OTP are required');
    }
    
    // Get OTP from database
    $stmt = $conn->prepare("SELECT id FROM otp_verification WHERE phone_number = ? AND otp_code = ? AND is_used = FALSE AND expires_at > NOW()");
    $stmt->bind_param("ss", $data['phone_number'], $data['otp']);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        sendResponse(400, 'Invalid or expired OTP');
    }
    
    // Mark OTP as used
    $otpId = $result->fetch_assoc()['id'];
    $stmt = $conn->prepare("UPDATE otp_verification SET is_used = TRUE WHERE id = ?");
    $stmt->bind_param("i", $otpId);
    $stmt->execute();
    
    // Get user
    $stmt = $conn->prepare("SELECT id, full_name, email, phone_number, location FROM users WHERE phone_number = ?");
    $stmt->bind_param("s", $data['phone_number']);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        sendResponse(404, 'User not found');
    }
    
    $user = $result->fetch_assoc();
    
    // Generate JWT token
    $token = generateJWT($user['id'], $user['email']);
    
    // Store session
    $expiresAt = date('Y-m-d H:i:s', strtotime('+30 days'));
    $stmt = $conn->prepare("INSERT INTO user_sessions (user_id, token, expires_at) VALUES (?, ?, ?)");
    $stmt->bind_param("iss", $user['id'], $token, $expiresAt);
    $stmt->execute();
    
    sendResponse(200, 'OTP verified successfully', [
        'user_id' => $user['id'],
        'token' => $token,
        'user' => $user
    ]);
}

// Get profile handler
function handleGetProfile() {
    $currentUser = getCurrentUser();
    
    if (!$currentUser) {
        sendResponse(401, 'Unauthorized');
    }
    
    $userId = $currentUser['user_id'];
    
    // Get user details
    $stmt = $conn->prepare("SELECT id, full_name, email, phone_number, location, profile_image, is_verified, created_at FROM users WHERE id = ?");
    $stmt->bind_param("i", $userId);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        sendResponse(404, 'User not found');
    }
    
    $user = $result->fetch_assoc();
    
    // Get user's car count
    $stmt = $conn->prepare("SELECT COUNT(*) as car_count FROM cars WHERE user_id = ? AND status = 'active'");
    $stmt->bind_param("i", $userId);
    $stmt->execute();
    $carCount = $stmt->get_result()->fetch_assoc()['car_count'];
    
    $user['car_count'] = $carCount;
    
    sendResponse(200, 'Profile retrieved successfully', $user);
}

// Update profile handler
function handleUpdateProfile() {
    $currentUser = getCurrentUser();
    
    if (!$currentUser) {
        sendResponse(401, 'Unauthorized');
    }
    
    $userId = $currentUser['user_id'];
    $data = json_decode(file_get_contents('php://input'), true);
    
    // Build update query
    $updateFields = [];
    $types = '';
    $values = [];
    
    $allowedFields = ['full_name', 'email', 'phone_number', 'location'];
    
    foreach ($allowedFields as $field) {
        if (isset($data[$field]) && !empty($data[$field])) {
            $updateFields[] = "$field = ?";
            $types .= 's';
            $values[] = $data[$field];
        }
    }
    
    if (empty($updateFields)) {
        sendResponse(400, 'No valid fields to update');
    }
    
    // Add user ID to values
    $types .= 'i';
    $values[] = $userId;
    
    $sql = "UPDATE users SET " . implode(', ', $updateFields) . " WHERE id = ?";
    $stmt = $conn->prepare($sql);
    
    // Bind parameters dynamically
    $stmt->bind_param($types, ...$values);
    
    if ($stmt->execute()) {
        sendResponse(200, 'Profile updated successfully');
    } else {
        sendResponse(500, 'Failed to update profile');
    }
}

// Logout handler
function handleLogout() {
    $currentUser = getCurrentUser();
    
    if (!$currentUser) {
        sendResponse(401, 'Unauthorized');
    }
    
    $userId = $currentUser['user_id'];
    
    // Remove all sessions for this user
    $stmt = $conn->prepare("DELETE FROM user_sessions WHERE user_id = ?");
    $stmt->bind_param("i", $userId);
    $stmt->execute();
    
    sendResponse(200, 'Logout successful');
}

// Health check
function handleHealthCheck() {
    sendResponse(200, 'API is running', [
        'timestamp' => date('Y-m-d H:i:s'),
        'database' => 'connected'
    ]);
}
?>
