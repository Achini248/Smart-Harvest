# backend/app.py
# Smart Harvest — Main Flask Application Factory

import os
from flask import Flask, jsonify
from flask_cors import CORS
from config import Config
from database import init_firebase

# ── Blueprints ─────────────────────────────────────────────────────────────────
from routes.auth_routes         import auth_bp
from routes.crop_routes         import crop_bp
from routes.marketplace_routes  import market_bp
from routes.price_routes        import price_bp
from routes.weather_routes      import weather_bp
from routes.notification_routes import notif_bp
from routes.chat_routes         import chat_bp
from routes.analytics_routes    import analytics_bp
from routes.dashboard_routes    import dashboard_bp
from routes.news_routes         import news_bp
from routes.surplus_routes      import surplus_bp


def create_app(config_object=Config) -> Flask:
    app = Flask(__name__)
    app.config.from_object(config_object)

    # ── CORS ───────────────────────────────────────────────────────────────────
    # Config.get_cors_origins() returns regex strings in dev so that Flutter web
    # (which uses a random port like :52733) is never CORS-blocked.
    CORS(app, resources={
        r"/api/*": {
            "origins":       Config.get_cors_origins(),
            "methods":       ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
            "allow_headers": ["Content-Type", "Authorization"],
            "supports_credentials": False,
        }
    })

    # ── Firebase / Firestore ───────────────────────────────────────────────────
    # init_firebase will raise FileNotFoundError with clear instructions
    # if serviceAccountKey.json is missing — no silent ADC fallback on local dev.
    with app.app_context():
        init_firebase(app)

    # ── SMTP startup warning ───────────────────────────────────────────────────
    if not Config.SMTP_USER or not Config.SMTP_PASSWORD:
        app.logger.warning(
            "\n"
            "╔══════════════════════════════════════════════════════════════╗\n"
            "║  ⚠  SMTP NOT CONFIGURED — OTP emails will NOT be sent       ║\n"
            "║                                                              ║\n"
            "║  Set these environment variables (or in backend/.env):      ║\n"
            "║    SMTP_USER     = your_gmail@gmail.com                     ║\n"
            "║    SMTP_PASSWORD = your_16_char_app_password                ║\n"
            "║    SMTP_FROM     = your_gmail@gmail.com                     ║\n"
            "║                                                              ║\n"
            "║  Gmail App Password guide:                                  ║\n"
            "║  myaccount.google.com → Security → App passwords            ║\n"
            "╚══════════════════════════════════════════════════════════════╝\n"
        )

    # ── Register Blueprints ────────────────────────────────────────────────────
    for bp in [
        auth_bp, crop_bp, market_bp, price_bp,
        weather_bp, notif_bp, chat_bp,
        analytics_bp, dashboard_bp,
        news_bp, surplus_bp,
    ]:
        app.register_blueprint(bp)

    # ── Health Check ───────────────────────────────────────────────────────────
    @app.route("/health")
    def health():
        return jsonify({"status": "ok", "service": "smart-harvest-api"})

    # ── Global Error Handlers ──────────────────────────────────────────────────
    @app.errorhandler(404)
    def not_found(e):
        return jsonify({"success": False, "error": "Not found", "code": 404}), 404

    @app.errorhandler(405)
    def method_not_allowed(e):
        return jsonify({"success": False, "error": "Method not allowed", "code": 405}), 405

    @app.errorhandler(500)
    def internal_error(e):
        return jsonify({"success": False, "error": "Internal server error", "code": 500}), 500

    @app.errorhandler(Exception)
    def unhandled(e):
        app.logger.error(f"Unhandled: {e}", exc_info=True)
        return jsonify({"success": False, "error": "Unexpected error", "code": 500}), 500

    return app


if __name__ == "__main__":
    application = create_app()
    application.run(host="0.0.0.0", port=5000, debug=True)
