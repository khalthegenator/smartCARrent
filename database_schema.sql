-- SmartCar Rent Database Schema
-- MySQL Database for Tanzania Car Rental Application

-- Create database
CREATE DATABASE IF NOT EXISTS smart_car_rent;

-- Use the database
USE smart_car_rent;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL, -- In production, this should be hashed
    phone_number VARCHAR(20),
    location VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Cars table
CREATE TABLE IF NOT EXISTS cars (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    model VARCHAR(255) NOT NULL,
    year VARCHAR(10) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    description TEXT,
    type VARCHAR(50) NOT NULL,
    transmission VARCHAR(50),
    fuel VARCHAR(50),
    condition VARCHAR(50),
    location VARCHAR(255),
    color VARCHAR(50),
    mileage INT,
    images JSON,
    listing_type ENUM('Rental', 'Sell') DEFAULT 'Rental',
    status ENUM('active', 'inactive', 'sold', 'rented') DEFAULT 'active',
    views INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_cars_user_id ON cars(user_id);
CREATE INDEX idx_cars_status ON cars(status);
CREATE INDEX idx_cars_type ON cars(type);
CREATE INDEX idx_cars_location ON cars(location);

-- Sample data for testing
INSERT INTO users (full_name, email, password, phone_number, location) VALUES 
('John Doe', 'john@example.com', 'password123', '+255123456789', 'Dar es Salaam'),
('Jane Smith', 'jane@example.com', 'password123', '+255987654321', 'Arusha');

-- Note: In production, always hash passwords using bcrypt or similar
-- Example: INSERT INTO users (full_name, email, password, phone_number, location) VALUES 
-- ('John Doe', 'john@example.com', '$2b$12$...hashedPassword...', '+255123456789', 'Dar es Salaam');
