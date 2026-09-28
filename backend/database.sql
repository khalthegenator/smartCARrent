-- SmartCar Rent Database Schema
-- MySQL Database for Tanzanian Car Rental Platform

-- Create database
CREATE DATABASE IF NOT EXISTS smartcar_rent;
USE smartcar_rent;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    location VARCHAR(100) NOT NULL,
    profile_image VARCHAR(255) NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_phone (phone_number),
    INDEX idx_location (location)
);

-- Cars table
CREATE TABLE IF NOT EXISTS cars (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    model VARCHAR(100) NOT NULL,
    year INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    description TEXT NOT NULL,
    type VARCHAR(50) NOT NULL, -- Sedan, SUV, Off-road, etc.
    transmission VARCHAR(20) NOT NULL, -- Manual, Automatic
    fuel VARCHAR(20) NOT NULL, -- Petrol, Diesel, Hybrid, Electric
    condition VARCHAR(20) NOT NULL, -- New, Used, Refurbished
    location VARCHAR(100) NOT NULL,
    color VARCHAR(50) NOT NULL,
    mileage INT NULL,
    status ENUM('active', 'inactive', 'sold', 'paused') DEFAULT 'active',
    views INT DEFAULT 0,
    favorites INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_type (type),
    INDEX idx_transmission (transmission),
    INDEX idx_location (location),
    INDEX idx_status (status),
    INDEX idx_price (price),
    INDEX idx_created_at (created_at),
    FULLTEXT idx_search (title, model, description)
);

-- Car images table
CREATE TABLE IF NOT EXISTS car_images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    car_id INT NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (car_id) REFERENCES cars(id) ON DELETE CASCADE,
    INDEX idx_car_id (car_id),
    INDEX idx_primary (is_primary)
);

-- User favorites table
CREATE TABLE IF NOT EXISTS user_favorites (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    car_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_favorite (user_id, car_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (car_id) REFERENCES cars(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_car_id (car_id)
);

-- OTP verification table
CREATE TABLE IF NOT EXISTS otp_verification (
    id INT AUTO_INCREMENT PRIMARY KEY,
    phone_number VARCHAR(20) NOT NULL,
    otp_code VARCHAR(6) NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_phone (phone_number),
    INDEX idx_otp (otp_code),
    INDEX idx_expires (expires_at)
);

-- User sessions table
CREATE TABLE IF NOT EXISTS user_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token VARCHAR(500) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_token (token),
    INDEX idx_expires (expires_at)
);

-- Car views tracking table
CREATE TABLE IF NOT EXISTS car_views (
    id INT AUTO_INCREMENT PRIMARY KEY,
    car_id INT NOT NULL,
    user_id INT NULL,
    ip_address VARCHAR(45) NOT NULL,
    user_agent TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (car_id) REFERENCES cars(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_car_id (car_id),
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
);

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('info', 'success', 'warning', 'error') DEFAULT 'info',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_is_read (is_read),
    INDEX idx_type (type)
);

-- Insert sample data for testing
INSERT INTO users (full_name, email, password, phone_number, location, is_verified) VALUES
('John Doe', 'john@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '0712345678', 'Dar es Salaam', TRUE),
('Jane Smith', 'jane@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '0756789012', 'Arusha', TRUE);

-- Insert sample cars
INSERT INTO cars (user_id, title, model, year, price, description, type, transmission, fuel, condition, location, color, mileage) VALUES
(1, 'Toyota Land Cruiser Prado', 'Land Cruiser', 2022, 120000.00, 'Well maintained Toyota Land Cruiser Prado in excellent condition. Features include 4WD, leather seats, sunroof, and more.', 'SUV', 'Automatic', 'Petrol', 'Used', 'Dar es Salaam', 'Silver', 45000),
(1, 'Toyota Corolla', 'Corolla', 2021, 45000.00, 'Fuel efficient Toyota Corolla with low mileage. Perfect for city driving and daily commute.', 'Sedan', 'Manual', 'Petrol', 'Used', 'Dar es Salaam', 'White', 25000),
(2, 'Toyota Hilux', 'Hilux', 2020, 95000.00, 'Strong and reliable Toyota Hilux pickup truck. Great for both work and personal use.', 'Pickup', 'Manual', 'Diesel', 'Used', 'Arusha', 'Black', 60000);

-- Insert sample car images
INSERT INTO car_images (car_id, image_url, is_primary) VALUES
(1, 'uploads/car1_1.jpg', TRUE),
(1, 'uploads/car1_2.jpg', FALSE),
(1, 'uploads/car1_3.jpg', FALSE),
(2, 'uploads/car2_1.jpg', TRUE),
(2, 'uploads/car2_2.jpg', FALSE),
(3, 'uploads/car3_1.jpg', TRUE),
(3, 'uploads/car3_2.jpg', FALSE);

-- Create stored procedures for common operations

DELIMITER //

-- Procedure to get user's cars with images
CREATE PROCEDURE GetUserCars(IN user_id_param INT)
BEGIN
    SELECT 
        c.*,
        GROUP_CONCAT(ci.image_url) as images,
        COUNT(ci.id) as image_count
    FROM cars c
    LEFT JOIN car_images ci ON c.id = ci.car_id
    WHERE c.user_id = user_id_param AND c.status = 'active'
    GROUP BY c.id
    ORDER BY c.created_at DESC;
END //

-- Procedure to get cars with filters
CREATE PROCEDURE GetCarsWithFilters(
    IN type_param VARCHAR(50),
    IN transmission_param VARCHAR(20),
    IN location_param VARCHAR(100),
    IN search_param VARCHAR(255),
    IN limit_param INT,
    IN offset_param INT
)
BEGIN
    SELECT 
        c.*,
        u.full_name as seller_name,
        u.phone_number as seller_phone,
        GROUP_CONCAT(ci.image_url) as images,
        COUNT(ci.id) as image_count
    FROM cars c
    JOIN users u ON c.user_id = u.id
    LEFT JOIN car_images ci ON c.id = ci.car_id
    WHERE c.status = 'active'
        AND (type_param IS NULL OR c.type = type_param)
        AND (transmission_param IS NULL OR c.transmission = transmission_param)
        AND (location_param IS NULL OR c.location = location_param)
        AND (search_param IS NULL OR 
            c.title LIKE CONCAT('%', search_param, '%') OR
            c.model LIKE CONCAT('%', search_param, '%') OR
            c.description LIKE CONCAT('%', search_param, '%')
        )
    GROUP BY c.id
    ORDER BY c.created_at DESC
    LIMIT limit_param OFFSET offset_param;
END //

-- Procedure to increment car views
CREATE PROCEDURE IncrementCarViews(IN car_id_param INT, IN ip_param VARCHAR(45))
BEGIN
    -- Check if this IP has viewed this car today
    IF NOT EXISTS (
        SELECT 1 FROM car_views 
        WHERE car_id = car_id_param 
        AND ip_address = ip_param 
        AND DATE(created_at) = CURDATE()
    ) THEN
        -- Increment views in cars table
        UPDATE cars SET views = views + 1 WHERE id = car_id_param;
        
        -- Add view record
        INSERT INTO car_views (car_id, ip_address) VALUES (car_id_param, ip_param);
    END IF;
END //

DELIMITER ;

-- Create triggers for automatic updates

DELIMITER //

-- Trigger to update car count when car is added/removed
CREATE TRIGGER after_car_insert
AFTER INSERT ON cars
FOR EACH ROW
BEGIN
    -- Update user's car count (you might want to add a car_count column to users table)
    -- This is a placeholder for any additional logic needed
END //

-- Trigger to clean up expired OTP codes
CREATE TRIGGER cleanup_expired_otp
AFTER INSERT ON otp_verification
FOR EACH ROW
BEGIN
    DELETE FROM otp_verification WHERE expires_at < NOW();
END //

DELIMITER ;

-- Create views for complex queries

CREATE VIEW car_details_view AS
SELECT 
    c.id,
    c.title,
    c.model,
    c.year,
    c.price,
    c.description,
    c.type,
    c.transmission,
    c.fuel,
    c.condition,
    c.location,
    c.color,
    c.mileage,
    c.status,
    c.views,
    c.favorites,
    c.created_at,
    c.updated_at,
    u.full_name as seller_name,
    u.email as seller_email,
    u.phone_number as seller_phone,
    u.location as seller_location,
    GROUP_CONCAT(ci.image_url) as images,
    COUNT(ci.id) as image_count
FROM cars c
JOIN users u ON c.user_id = u.id
LEFT JOIN car_images ci ON c.id = ci.car_id
GROUP BY c.id, u.id;

-- Create indexes for better performance
CREATE INDEX idx_cars_search ON cars(title, model, description);
CREATE INDEX idx_users_location_verified ON users(location, is_verified);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read);

-- Set up foreign key constraints
ALTER TABLE cars ADD CONSTRAINT fk_cars_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE car_images ADD CONSTRAINT fk_car_images_car FOREIGN KEY (car_id) REFERENCES cars(id) ON DELETE CASCADE;
ALTER TABLE user_favorites ADD CONSTRAINT fk_favorites_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE user_favorites ADD CONSTRAINT fk_favorites_car FOREIGN KEY (car_id) REFERENCES cars(id) ON DELETE CASCADE;
ALTER TABLE otp_verification ADD CONSTRAINT fk_otp_user FOREIGN KEY (phone_number) REFERENCES users(phone_number) ON DELETE CASCADE;
ALTER TABLE user_sessions ADD CONSTRAINT fk_sessions_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE car_views ADD CONSTRAINT fk_views_car FOREIGN KEY (car_id) REFERENCES cars(id) ON DELETE CASCADE;
ALTER TABLE car_views ADD CONSTRAINT fk_views_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE notifications ADD CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Final setup
SELECT 'SmartCar Rent Database setup completed successfully!' as message;
