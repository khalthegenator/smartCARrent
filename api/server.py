#!/usr/bin/env python3
"""
SmartCar Rent API Server
Python Flask API for Tanzania Car Rental Application
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import datetime
import uuid
import json
import os
import sqlite3

app = Flask(__name__)
CORS(app)

# SQLite Database for persistence
DATABASE_FILE = 'smartcar_rent.db'

# Database initialization
def init_db():
    """Initialize SQLite database"""
    conn = sqlite3.connect(DATABASE_FILE)
    cursor = conn.cursor()
    
    # Create users table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            full_name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            phone_number TEXT,
            location TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    # Create cars table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS cars (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            model TEXT NOT NULL,
            year TEXT NOT NULL,
            price REAL NOT NULL,
            description TEXT,
            type TEXT,
            transmission TEXT,
            fuel TEXT,
            condition TEXT,
            location TEXT,
            color TEXT,
            mileage TEXT,
            images TEXT,
            listing_type TEXT DEFAULT 'Rental',
            status TEXT DEFAULT 'active',
            views INTEGER DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users (id)
        )
    ''')
    
    # Add rental_duration column if it doesn't exist
    cursor.execute("PRAGMA table_info(cars)")
    columns = [column[1] for column in cursor.fetchall()]
    if 'rental_duration' not in columns:
        cursor.execute("ALTER TABLE cars ADD COLUMN rental_duration TEXT DEFAULT 'Daily'")
        print("Added rental_duration column to cars table")
    
    conn.commit()
    conn.close()
    print("SQLite database initialized")

# Database helper functions
def get_db_connection():
    """Get database connection"""
    conn = sqlite3.connect(DATABASE_FILE)
    conn.row_factory = sqlite3.Row
    return conn

def generate_token():
    """Generate authentication token"""
    return f"token_{datetime.datetime.now().timestamp()}_{uuid.uuid4().hex[:8]}"

def create_user(userData):
    """Create and save new user"""
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        cursor.execute('''
            INSERT INTO users (full_name, email, password, phone_number, location)
            VALUES (?, ?, ?, ?, ?)
        ''', (
            userData['full_name'],
            userData['email'],
            userData['password'],
            userData.get('phone_number', '+255123456789'),
            userData.get('location', 'Dar es Salaam')
        ))
        
        user_id = cursor.lastrowid
        
        # Get created user
        cursor.execute('SELECT id, full_name, email, phone_number, location, created_at FROM users WHERE id = ?', (user_id,))
        user = dict(cursor.fetchone())
        
        conn.commit()
        print(f"✅ User created in database: {userData['email']}")
        return user, None
        
    except sqlite3.IntegrityError:
        conn.rollback()
        return None, "User with this email already exists"
    except Exception as e:
        conn.rollback()
        return None, f"Database error: {str(e)}"
    finally:
        conn.close()

def find_user(email):
    """Find user by email"""
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        cursor.execute('SELECT id, full_name, email, phone_number, location, created_at, password FROM users WHERE email = ?', (email,))
        user = cursor.fetchone()
        
        if user:
            return dict(user)
        return None
    except Exception as e:
        print(f"❌ Database error: {str(e)}")
        return None
    finally:
        conn.close()

def verify_user(email, password):
    """Verify user credentials"""
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        cursor.execute('SELECT id, full_name, email, phone_number, location, created_at, password FROM users WHERE email = ?', (email,))
        user = cursor.fetchone()
        
        if not user:
            return None, "unregistered"
        
        if user['password'] != password:
            return None, "invalid_password"
        
        user_dict = dict(user)
        # Remove password from returned user data
        del user_dict['password']
        return user_dict, "success"
    except Exception as e:
        print(f"Database error: {str(e)}")
        return None, "database_error"
    finally:
        conn.close()

def get_user_cars(user_id):
    """Get all cars for a specific user"""
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        cursor.execute('SELECT * FROM cars WHERE user_id = ? ORDER BY created_at DESC', (user_id,))
        cars = []
        for row in cursor.fetchall():
            car = dict(row)
            if car['images']:
                car['images'] = json.loads(car['images'])
            cars.append(car)
        
        print(f"📋 Retrieved {len(cars)} cars for user {user_id}")
        return cars
    except Exception as e:
        print(f"❌ Database error: {str(e)}")
        return []
    finally:
        conn.close()

# Routes
@app.route('/health.php', methods=['GET'])
def health_check():
    return jsonify({
        'status': 'ok',
        'message': 'SmartCar Rent API is running',
        'server': 'Python Flask',
        'database': 'SQLite Database (Persistent)',
        'database_file': DATABASE_FILE
    })

@app.route('/register.php', methods=['POST'])
def register_user():
    try:
        data = request.get_json()
        full_name = data.get('full_name', '').strip()
        email = data.get('email', '').strip()
        password = data.get('password', '').strip()
        phone_number = data.get('phone_number', '+255123456789').strip()
        location = data.get('location', 'Dar es Salaam').strip()
        
        # Validation
        if not full_name or not email or not password:
            return jsonify({
                'message': 'Full name, email, and password are required'
            }), 400
        
        if len(password) < 6:
            return jsonify({
                'message': 'Password must be at least 6 characters'
            }), 400
        
        if '@' not in email:
            return jsonify({
                'message': 'Please enter a valid email address'
            }), 400
        
        # Create user in SQLite database
        user, error = create_user({
            'full_name': full_name,
            'email': email,
            'password': password,
            'phone_number': phone_number,
            'location': location
        })
        
        if error:
            return jsonify({
                'message': error
            }), 400
        
        token = generate_token()
        
        return jsonify({
            'status': 'success',
            'message': 'User registered successfully',
            'user': user,
            'token': token
        }), 201
        
    except Exception as e:
        print(f"❌ Registration error: {str(e)}")
        return jsonify({
            'message': f'Registration failed: {str(e)}'
        }), 500

@app.route('/login.php', methods=['POST'])
def login_user():
    try:
        data = request.get_json()
        email = data.get('email', '').strip()
        password = data.get('password', '').strip()
        
        # Validation
        if not email or not password:
            return jsonify({
                'message': 'Email and password are required'
            }), 400
        
        if len(password) < 6:
            return jsonify({
                'message': 'Password must be at least 6 characters'
            }), 400
        
        if '@' not in email:
            return jsonify({
                'message': 'Please enter a valid email address'
            }), 400
        
        # Verify user credentials in SQLite database
        user, status = verify_user(email, password)
        
        if status == "unregistered":
            return jsonify({
                'message': 'This email is not registered. Please register first to create an account.'
            }), 401
        elif status == "invalid_password":
            return jsonify({
                'message': 'Invalid password. Please check your password and try again.'
            }), 401
        elif status == "database_error":
            return jsonify({
                'message': 'Database error occurred. Please try again later.'
            }), 500
        elif not user:
            return jsonify({
                'message': 'Authentication failed. Please try again.'
            }), 401
        
        token = generate_token()
        
        print(f"✅ User authenticated and logged in: {email}")
        
        return jsonify({
            'status': 'success',
            'message': 'Login successful',
            'user': user,
            'token': token
        })
        
    except Exception as e:
        print(f"❌ Login error: {str(e)}")
        return jsonify({
            'message': f'Login failed: {str(e)}'
        }), 500

@app.route('/cars.php', methods=['GET'])
def get_user_cars():
    try:
        user_id = request.args.get('user_id')
        
        if not user_id:
            return jsonify({
                'message': 'User ID is required'
            }), 400
        
        # Get user's cars from SQLite database
        user_cars = get_user_cars_from_db(user_id)
        
        return jsonify({
            'status': 'success',
            'cars': user_cars
        })
        
    except Exception as e:
        print(f"❌ Get user cars error: {str(e)}")
        return jsonify({
            'message': f'Failed to get user cars: {str(e)}'
        }), 500

@app.route('/api/cars', methods=['POST'])
def post_car():
    try:
        data = request.get_json()
        
        # Validation
        required_fields = ['user_id', 'title', 'model', 'year', 'price', 'description', 'type', 'transmission', 'fuel', 'condition', 'location', 'color', 'mileage', 'images', 'listing_type', 'rental_duration']
        for field in required_fields:
            if field not in data or data[field] is None:
                return jsonify({
                    'message': f'{field} is required'
                }), 400
        
        # Insert car into database
        conn = get_db_connection()
        cursor = conn.cursor()
        
        try:
            cursor.execute('''
                INSERT INTO cars (user_id, title, model, year, price, description, type, transmission, fuel, condition, location, color, mileage, images, listing_type, rental_duration, status, views)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                data['user_id'],
                data['title'],
                data['model'],
                data['year'],
                data['price'],
                data['description'],
                data['type'],
                data['transmission'],
                data['fuel'],
                data['condition'],
                data['location'],
                data['color'],
                data['mileage'],
                json.dumps(data['images']),
                data['listing_type'],
                data['rental_duration'],
                data.get('status', 'active'),
                data.get('views', 0)
            ))
            
            car_id = cursor.lastrowid
            
            # Get created car
            cursor.execute('SELECT * FROM cars WHERE id = ?', (car_id,))
            car = dict(cursor.fetchone())
            
            # Parse images back to list
            if car['images']:
                car['images'] = json.loads(car['images'])
            
            conn.commit()
            print(f"✅ Car posted: {data['title']} by user {data['user_id']}")
            
            return jsonify({
                'status': 'success',
                'message': 'Car posted successfully',
                'car': car
            }), 201
            
        except Exception as e:
            conn.rollback()
            return jsonify({
                'message': f'Database error: {str(e)}'
            }), 500
        finally:
            conn.close()
            
    except Exception as e:
        print(f"❌ Post car error: {str(e)}")
        return jsonify({
            'message': f'Failed to post car: {str(e)}'
        }), 500

@app.route('/api/users/<int:user_id>/cars', methods=['GET'])
def get_user_cars_api(user_id):
    """Get all cars for a specific user via API"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.execute('SELECT * FROM cars WHERE user_id = ? ORDER BY created_at DESC', (user_id,))
        cars = cursor.fetchall()
        
        # Convert images from JSON string back to list
        cars_list = []
        for car in cars:
            car_dict = dict(car)
            try:
                car_dict['images'] = json.loads(car_dict['images'])
            except:
                car_dict['images'] = []
            cars_list.append(car_dict)
        
        conn.close()
        
        return jsonify({
            'status': 'success',
            'cars': cars_list
        })
        
    except Exception as e:
        print(f"Error getting user cars: {str(e)}")
        return jsonify({
            'message': f'Failed to get user cars: {str(e)}'
        }), 500

@app.route('/api/cars', methods=['GET'])
def get_all_cars():
    """Get all cars (for browse page)"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.execute('SELECT * FROM cars WHERE status = "active" ORDER BY created_at DESC')
        cars = cursor.fetchall()
        
        # Convert images from JSON string back to list
        cars_list = []
        for car in cars:
            car_dict = dict(car)
            try:
                car_dict['images'] = json.loads(car_dict['images'])
            except:
                car_dict['images'] = []
            cars_list.append(car_dict)
        
        conn.close()
        
        return jsonify({
            'status': 'success',
            'cars': cars_list
        })
        
    except Exception as e:
        print(f"Error getting all cars: {str(e)}")
        return jsonify({
            'message': f'Failed to get cars: {str(e)}'
        }), 500

@app.route('/api/cars/<int:car_id>', methods=['GET'])
def get_car_by_id(car_id):
    """Get a specific car by ID"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.execute('SELECT * FROM cars WHERE id = ?', (car_id,))
        car = cursor.fetchone()
        
        if not car:
            conn.close()
            return jsonify({
                'message': 'Car not found'
            }), 404
        
        # Convert images from JSON string back to list
        car_dict = dict(car)
        try:
            car_dict['images'] = json.loads(car_dict['images'])
        except:
            car_dict['images'] = []
        
        conn.close()
        
        return jsonify({
            'status': 'success',
            'car': car_dict
        })
        
    except Exception as e:
        print(f"Error getting car: {str(e)}")
        return jsonify({
            'message': f'Failed to get car: {str(e)}'
        }), 500

@app.route('/api/cars/<int:car_id>', methods=['PUT'])
def update_car(car_id):
    """Update a car"""
    try:
        data = request.get_json()
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Check if car exists
        cursor.execute('SELECT * FROM cars WHERE id = ?', (car_id,))
        car = cursor.fetchone()
        
        if not car:
            conn.close()
            return jsonify({
                'message': 'Car not found'
            }), 404
        
        # Update car
        cursor.execute('''
            UPDATE cars SET 
                title = ?, model = ?, year = ?, price = ?, description = ?, 
                type = ?, transmission = ?, fuel = ?, condition = ?, 
                location = ?, color = ?, mileage = ?, images = ?, 
                listing_type = ?, rental_duration = ?
            WHERE id = ?
        ''', (
            data.get('title', car['title']),
            data.get('model', car['model']),
            data.get('year', car['year']),
            data.get('price', car['price']),
            data.get('description', car['description']),
            data.get('type', car['type']),
            data.get('transmission', car['transmission']),
            data.get('fuel', car['fuel']),
            data.get('condition', car['condition']),
            data.get('location', car['location']),
            data.get('color', car['color']),
            data.get('mileage', car['mileage']),
            json.dumps(data.get('images', json.loads(car['images']))),
            data.get('listing_type', car['listing_type']),
            data.get('rental_duration', car['rental_duration']),
            car_id
        ))
        
        conn.commit()
        
        # Get updated car
        cursor.execute('SELECT * FROM cars WHERE id = ?', (car_id,))
        updated_car = cursor.fetchone()
        
        # Convert images from JSON string back to list
        car_dict = dict(updated_car)
        try:
            car_dict['images'] = json.loads(car_dict['images'])
        except:
            car_dict['images'] = []
        
        conn.close()
        
        print(f"Car updated: {car_id}")
        
        return jsonify({
            'status': 'success',
            'message': 'Car updated successfully',
            'car': car_dict
        })
        
    except Exception as e:
        print(f"Update car error: {str(e)}")
        return jsonify({
            'message': f'Failed to update car: {str(e)}'
        }), 500

@app.route('/api/cars/<int:car_id>', methods=['DELETE'])
def delete_car(car_id):
    """Delete a car"""
    try:
        print(f"Backend: ===== DELETE START =====")
        print(f"Backend: Delete request for car_id: {car_id} (type: {type(car_id)})")
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # First, let's see all cars for this user to understand the issue
        cursor.execute('SELECT id, title, model, user_id FROM cars ORDER BY id')
        all_cars = cursor.fetchall()
        print(f"Backend: All cars in database: {len(all_cars)}")
        for car in all_cars:
            print(f"  - ID: {car[0]}, Title: {car[1]}, Model: {car[2]}, User: {car[3]}")
        
        # Check if car exists
        cursor.execute('SELECT * FROM cars WHERE id = ?', (car_id,))
        car = cursor.fetchone()
        
        if not car:
            print(f"Backend: Car {car_id} not found")
            conn.close()
            return jsonify({
                'message': 'Car not found'
            }), 404
        
        print(f"Backend: Found car to delete: {dict(car)}")
        
        # Check how many cars exist before deletion
        cursor.execute('SELECT COUNT(*) FROM cars')
        total_before = cursor.fetchone()[0]
        print(f"Backend: Total cars before deletion: {total_before}")
        
        # Delete the car
        print(f"Backend: Executing DELETE FROM cars WHERE id = {car_id}")
        cursor.execute('DELETE FROM cars WHERE id = ?', (car_id,))
        
        # Check how many rows were affected
        rows_affected = cursor.rowcount
        print(f"Backend: Rows affected by DELETE: {rows_affected}")
        
        # Check how many cars exist after deletion
        cursor.execute('SELECT COUNT(*) FROM cars')
        total_after = cursor.fetchone()[0]
        print(f"Backend: Total cars after deletion: {total_after}")
        print(f"Backend: Cars deleted: {total_before - total_after}")
        
        # Show remaining cars
        cursor.execute('SELECT id, title, model, user_id FROM cars ORDER BY id')
        remaining_cars = cursor.fetchall()
        print(f"Backend: Remaining cars: {len(remaining_cars)}")
        for car in remaining_cars:
            print(f"  - ID: {car[0]}, Title: {car[1]}, Model: {car[2]}, User: {car[3]}")
        conn.commit()
        conn.close()
        
        print(f"✅ Car deleted: {car_id}")
        
        return jsonify({
            'status': 'success',
            'message': 'Car deleted successfully'
        })
        
    except Exception as e:
        print(f"❌ Delete car error: {str(e)}")
        return jsonify({
            'message': f'Failed to delete car: {str(e)}'
        }), 500

if __name__ == '__main__':
    # Initialize SQLite database
    init_db()
    
    print("🚀 Starting SmartCar Rent API Server...")
    print("📡 Server running on http://localhost:3000")
    print("📋 Available endpoints:")
    print("   POST http://localhost:3000/register.php - Register user")
    print("   POST http://localhost:3000/login.php - Login user")
    print("   POST http://localhost:3000/api/cars - Post car")
    print("   GET  http://localhost:3000/api/cars - Get all cars")
    print("   GET  http://localhost:3000/api/cars/{car_id} - Get car by ID")
    print("   PUT  http://localhost:3000/api/cars/{car_id} - Update car")
    print("   GET  http://localhost:3000/api/users/{user_id}/cars - Get user cars")
    print("   DELETE http://localhost:3000/api/cars/{car_id} - Delete car")
    print("   GET  http://localhost:3000/health.php - Health check")
    print("📊 Database: SQLite (Persistent)")
    print(f"🗄️ Database file: {DATABASE_FILE}")
    print("🔧 Ready to accept requests from Flutter app!")
    
    app.run(host='0.0.0.0', port=3000, debug=True)
