# Simple Task Manager

A Flask-based Task Manager application with MySQL database, supporting user authentication, task management, and categorization.

## Features
- **User Authentication**: Secure Register, Login, Logout using Flask-Login.
- **Task Management**: Create, View, Update (Complete/Undo), Delete tasks.
- **Categorization**: Organize tasks into custom categories.
- **Modern UI**: Clean, responsive interface.

## Tech Stack
- **Backend**: Python, Flask, Flask-SQLAlchemy
- **Database**: MySQL (PyMySQL)
- **Frontend**: HTML5, CSS3, Jinja2 Templates

## Local Setup

1. **Clone the repository**:
   ```bash
   git clone <your-repo-url>
   cd task-manager
   ```

2. **Run the setup script** (Installs MySQL, sets up DB, configures .env):
   ```bash
   chmod +x setup_db.sh
   ./setup_db.sh
   ```

3. **Install Python dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the application**:
   ```bash
   python application.py
   ```
   Access at `http://127.0.0.1:5000`.

## Deployment (EC2)

1. **Launch an EC2 instance** (Ubuntu or Amazon Linux 2/2023).
2. **Clone the repository**.
3. **Run `setup_db.sh`** to install MySQL and configure credentials automatically.
4. **Install dependencies**: `pip install -r requirements.txt`.
5. **Run the app**: `python application.py` (or use Gunicorn/Nginx for production).

## Project Structure
```
task-manager/
├── application.py    # Main application entry point & routes
├── config.py         # App configuration
├── schema.sql        # Database schema
├── setup_db.sh       # Automated setup script
├── requirements.txt  # Python dependencies
├── .env              # Environment variables (Created by setup_db.sh)
├── templates/        # HTML Templates
└── static/           # CSS & Assets
```
