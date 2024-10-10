#!/bin/bash
# Get date and time
DATE=$(date +"%m-%d-%y")


######################## BOT INFO ############################
BOT_TOKEN="7451127149:AAG9hq_TuQwTc4mJxO0QFVMmoTpeW2HDzyU"
CHAT_ID="-4506720222"

 
# Function to send a file to Telegram
send_file() {
 local file_path="$1"
 local caption="$2"
 curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendDocument" \
 -F "chat_id=$CHAT_ID" \
 -F "document=@$file_path" \
 -F "caption=$caption"
}

