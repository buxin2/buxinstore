from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager
from flask_migrate import Migrate
from flask_mail import Mail

# Initialize extensions
db = SQLAlchemy()
login_manager = LoginManager()
migrate = None  # Will be initialized in init_extensions
mail = Mail()

def init_extensions(app):
    """Initialize all extensions with the given Flask app"""
    global migrate
    
    # Only initialize if not already done
    if not hasattr(app, 'extensions') or 'sqlalchemy' not in app.extensions:
        db.init_app(app)
    
    # Initialize other extensions
    login_manager.init_app(app)
    login_manager.login_view = 'login'
    
    # Initialize Flask-Migrate
    if migrate is None:
        migrate = Migrate(app, db)
    
    # Initialize Flask-Mail (only if MAIL_SERVER configured)
    try:
        if app.config.get('MAIL_SERVER'):
            mail.init_app(app)
            app.logger.info(f"✅ Flask-Mail initialized: {app.config.get('MAIL_SERVER')}:{app.config.get('MAIL_PORT')}")
        else:
            app.logger.warning("⚠️ Flask-Mail not initialized: MAIL_SERVER not configured")
    except Exception as e:
        app.logger.error(f"❌ Failed to initialize Flask-Mail: {str(e)}")
        import traceback
        app.logger.error(traceback.format_exc())
    
    return app
