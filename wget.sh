#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
SEPARATOR="=============================="
TIMEOUT=10
MAX_RETRIES=3
LOG_FILE="script_log.txt"

log_message() {
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $1" >> "$LOG_FILE"
}

validate_url() {
    if [[ ! "$1" =~ ^https?:// ]]; then
        echo -e "${RED}Invalid URL format. Please make sure the URL starts with http:// or https://.${NC}"
        return 1
    fi
    return 0
}

download_file() {
    local url=$1
    local retries=0
    echo -e "${GREEN}Downloading file from $url...${NC}"
    while [ $retries -lt $MAX_RETRIES ]; do
        wget --timeout=$TIMEOUT "$url"
        if [ $? -eq 0 ]; then
            log_message "File downloaded successfully from $url."
            echo -e "${GREEN}Download successful!${NC}"
            return 0
        else
            echo -e "${RED}Download failed. Retrying... (${retries + 1}/${MAX_RETRIES})${NC}"
            retries=$((retries + 1))
            sleep 2
        fi
    done
    log_message "Download failed after $MAX_RETRIES attempts from $url."
    echo -e "${RED}Download failed after $MAX_RETRIES attempts. Please check the URL or your network connection.${NC}"
    return 1
}

check_website_status() {
    local url=$1
    echo -e "${GREEN}Checking website status for $url...${NC}"
    wget --spider --timeout=$TIMEOUT "$url" 2>&1 | grep -i 'HTTP' >/dev/null
    if [ $? -eq 0 ]; then
        log_message "Website $url is online."
        echo -e "${GREEN}Website is online.${NC}"
    else
        log_message "Website $url is down or unreachable."
        echo -e "${RED}Website is down or unreachable.${NC}"
    fi
}

while true; do
    echo -e "${BLUE}$SEPARATOR${NC}"
    echo -e "${GREEN}Select an option:${NC}"
    echo -e "${BLUE}$SEPARATOR${NC}"
    echo -e "${YELLOW}1.${NC} Download a file"
    echo -e "${YELLOW}2.${NC} Check website status"
    echo -e "${YELLOW}3.${NC} Exit"
    echo -e "${BLUE}$SEPARATOR${NC}"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            read -p "Enter URL to download: " url
            if validate_url "$url"; then
                download_file "$url"
            fi
            read -p "Press enter to continue..."
            ;;
        2)
            read -p "Enter website URL to check: " url
            if validate_url "$url"; then
                check_website_status "$url"
            fi
            read -p "Press enter to continue..."
            ;;
        3)
            read -p "Are you sure you want to exit? (y/n): " confirm
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                echo -e "${GREEN}Exiting...${NC}"
                log_message "Exiting script."
                break
            fi
            ;;
        *)
            echo -e "${RED}Invalid choice, please try again.${NC}"
            read -p "Press enter to continue..."
            ;;
    esac
done
