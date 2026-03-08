from models.user_model import db, User
from flask_jwt_extended import create_access_token

# Function to register a new user
def register_user(username, email, password):
    
    # Check if a user with the same email already exists in the database
    if User.query.filter_by(email=email).first():
        return {"error": "User with this email already exists"}, 400
    
    # Create a new User object
    new_user = User(username=username, email=email)
    
    # Hash and set the user's password
    new_user.set_password(password)
    
    # Add the new user to the database session
    db.session.add(new_user)
    
    # Commit the changes to save the user in the database
    db.session.commit()
    
    # Return success message
    return {"message": "User registered successfully!"}, 201


# Function to authenticate a user during login
def login_user(email, password):
    
    # Search for the user in the database using the email
    user = User.query.filter_by(email=email).first()
    
    # Check if the user exists and if the password is correct
    if user and user.check_password(password):
        
        # Generate a JWT access token using the user ID
        token = create_access_token(identity=str(user.id))
        
        # Return the token and username to the client
        return {"token": token, "username": user.username}, 200
    
    # Return error if email or password is incorrect
    return {"error": "Invalid email or password"}, 401