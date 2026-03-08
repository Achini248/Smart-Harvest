from flask import Flask
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from models.user_model import db
from routes.auth_routes import auth_bp

# Create the Flask application instance
app = Flask(__name__)

# Enable CORS to allow the frontend application to communicate with the backend
CORS(app)

# Database configuration (SQLite database)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///smart_harvest.db'

# Secret key used to sign and verify JWT tokens
app.config['JWT_SECRET_KEY'] = 'smart-harvest-key-2026'

# Initialize SQLAlchemy with the Flask app
db.init_app(app)

# Initialize JWT authentication
jwt = JWTManager(app)

# Create database tables if they do not already exist
with app.app_context():
    db.create_all()

# Register authentication routes with the prefix /api/auth
# Example: /api/auth/login , /api/auth/register
app.register_blueprint(auth_bp, url_prefix='/api/auth')

# Run the Flask development server
if __name__ == '__main__':
    app.run(debug=True)