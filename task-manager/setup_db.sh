#!/bin/bash

# Configuration
# If .env exists, we can extract values, otherwise use defaults
if [ -f .env ]; then
    source .env
fi

DB_NAME="${DB_NAME:-task_manager_db}"
DB_USER="${DB_USER:-task_user}"
DB_PASS="${DB_PASSWORD:-secure_password_123}"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting MySQL Setup...${NC}"
echo "Using Database: $DB_NAME"
echo "Using User: $DB_USER"
# Mask password in logs but show it later
echo "Using Password: ****" 

# Function to install MySQL on macOS
install_mysql_mac() {
    if ! command -v mysql &> /dev/null; then
        echo "MySQL not found. Installing via Homebrew..."
        brew install mysql
        brew services start mysql
        echo "Waiting for MySQL to start..."
        sleep 5
    else
        echo "MySQL is already installed."
        if ! brew services list | grep -q "mysql.*started"; then
            brew services start mysql
             echo "Waiting for MySQL to start..."
            sleep 5
        fi
    fi
}

# Function to install MySQL on Ubuntu/Debian (EC2)
install_mysql_linux() {
    if command -v apt-get &> /dev/null; then
        echo "Updating apt..."
        sudo apt-get update
        echo "Installing MySQL via apt..."
        sudo apt-get install -y mysql-server
        sudo systemctl start mysql
        sudo systemctl enable mysql
    elif command -v yum &> /dev/null; then
        echo "Installing MySQL via yum (Amazon Linux 2)..."
        sudo yum update -y
        sudo yum install -y mysql-server
        # On Amazon Linux 2, the service might be mysqld or mariadb
        sudo systemctl start mysqld || sudo systemctl start mariadb
        sudo systemctl enable mysqld || sudo systemctl enable mariadb
    elif command -v dnf &> /dev/null; then
        echo "Installing MySQL via dnf (Amazon Linux 2023)..."
        sudo dnf update -y
        sudo dnf install -y mysql-server
        sudo systemctl start mysqld
        sudo systemctl enable mysqld
    else
        echo "Could not detect package manager (apt/yum/dnf). Please install MySQL manually."
        exit 1
    fi
}

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    install_mysql_mac
elif [[ -f /etc/debian_version ]]; then
    install_mysql_linux
else
    echo "Unsupported OS. Please install MySQL manually."
    exit 1
fi

# Create Database and User
echo -e "${GREEN}Configuring Database and User...${NC}"

# SQL commands to create DB and User
SQL_COMMANDS="
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
"

# Execute SQL
# Try without sudo first (macOS usually works this way if installed via brew)
echo "Executing SQL commands..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    mysql -u root -e "$SQL_COMMANDS" || mysql -u root -p -e "$SQL_COMMANDS"
else
    # On Linux, root might require sudo
    sudo mysql -e "$SQL_COMMANDS"
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Database setup successful!${NC}"
else
    echo -e "${RED}Database setup encountered an error.${NC}"
    echo "This might be due to root password requirements. You can run this command manually:"
    echo "mysql -u root -p -e \"$SQL_COMMANDS\""
fi

echo -e "${GREEN}Setup Complete!${NC}"
echo "---------------------------------------------------"
echo "Database Credentials Configured:"
echo "Database: $DB_NAME"
echo "User:     $DB_USER"
echo "Password: $DB_PASS"
echo "---------------------------------------------------"
echo "If you need to change the password later, run:"
echo "ALTER USER '$DB_USER'@'localhost' IDENTIFIED BY 'new_password';"
echo "And update your .env file accordingly."
echo "---------------------------------------------------"

echo ""
echo "Updating configuration file..."

# Update .env file
if [ -f .env ]; then
    # Update .env if it exists
    sed -i.bak "s/DB_USER=.*/DB_USER=$DB_USER/" .env
    sed -i.bak "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASS/" .env
    sed -i.bak "s/DB_NAME=.*/DB_NAME=$DB_NAME/" .env
    # Remove backup file created by sed
    rm .env.bak
    echo "Updated .env file with new credentials."
else
    echo "Warning: .env file not found."
fi
