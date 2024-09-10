#!/bin/bash

# Colors for formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Exit message function
function check_exit() {
  if [[ "$1" == "q" || "$1" == "quit" ]]; then
    echo -e "${YELLOW}Exiting... Goodbye!${NC}"
    exit 0
  fi
}

# Function to merge files interactively
merge_files() {
  local dir=$1
  local chosen_files=()
  local user_input=""

  while [[ "$user_input" != "d" ]]; do
    echo -e "${BLUE}Navigating to select files within ${YELLOW}$dir${BLUE}...${NC}"
    
    # Prompt user for input or fzf selection
    echo -e "${BLUE}Select files to merge (press Enter to select, type 'd' to finish, or 'n' for new directory):${NC}"
    read -p "" user_input

    # Handle 'done' or 'newdir' inputs outside fzf
    if [[ "$user_input" == "d" ]]; then
      if [ ${#chosen_files[@]} -eq 0 ]; then
        echo -e "${RED}No files selected. Exiting.${NC}"
        exit 1
      fi
      break
    elif [[ "$user_input" == "n" ]]; then
      echo -e "${YELLOW}Please enter the new directory path:${NC}"
      read new_dir

      # Check exit condition for new directory input
      check_exit "$new_dir"

      # Validate new directory path
      if [ -d "$new_dir" ]; then
        dir="$new_dir"
        echo -e "${GREEN}Switched to new directory: $dir${NC}"
        continue
      else
        echo -e "${RED}Invalid directory. Please enter a valid path.${NC}"
        continue
      fi
    fi

    # Use fzf to select a file from the directory
    selected_file=$(find "$dir" -type f | fzf --prompt="Select files to merge: " --height=15)

    # If no file selected (user pressed ESC or exited fzf)
    if [[ -z "$selected_file" ]]; then
      echo -e "${RED}No file selected. Please select a valid file.${NC}"
      continue
    fi

    # Append selected files to the chosen_files array
    if [[ -f "$selected_file" && ! " ${chosen_files[@]} " =~ " ${selected_file} " ]]; then
      chosen_files+=("$selected_file")
      echo -e "${GREEN}Added: $selected_file${NC}"
    else
      echo -e "${RED}File is already selected or not valid.${NC}"
    fi

    echo -e "${GREEN}Files selected so far:${NC}"
    for file in "${chosen_files[@]}"; do
      echo -e "\t- $file"
    done

    echo -e "${BLUE}Keep selecting files or press 'd' to finish or 'n' to switch directories.${NC}"
  done

  # Merge selected files and ensure unique lines
  echo -e "${BLUE}Merging selected files...${NC}"
  temp_file=$(mktemp)

  for file in "${chosen_files[@]}"; do
    if [ -f "$file" ];then
      cat "$file" >> "$temp_file"
    else
      echo -e "${RED}Warning: '$file' is not a valid file.${NC}"
    fi
  done

  # Deduplicate and save to new file
  echo -e "${BLUE}Please enter the directory where the merged file should be saved (or 'q' to quit):${NC}"
  read destination_path

  # Handle quit input
  check_exit "$destination_path"

  # Ensure the entered destination directory exists
  if [ ! -d "$destination_path" ]; then
    echo -e "${RED}Error: The directory does not exist. Please create the directory first.${NC}"
    exit 1
  fi

  echo -e "${BLUE}Please enter the name for the merged file (or 'q' to quit):${NC}"
  read merged_file_name

  # Handle quit input
  check_exit "$merged_file_name"

  # Full path of the new merged file
  merged_file="$destination_path/$merged_file_name"

  # Create and write to the merged file
  sort "$temp_file" | uniq > "$merged_file"

  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Success: Merged file has been created and saved as '$merged_file'.${NC}"
    rm "$temp_file"
  else
    echo -e "${RED}Error: Failed to create the merged file. Please check the paths and try again.${NC}"
  fi
}

# Main script logic
if [ $# -lt 1 ]; then
  echo -e "${YELLOW}Usage: $0 <directory>${NC}"
  exit 1
fi

TARGET_DIR=$1

# Check if the provided directory exists
if [ ! -d "$TARGET_DIR" ]; then
  echo -e "${RED}Error: The directory '$TARGET_DIR' does not exist.${NC}"
  exit 1
fi

# Start the file merging process
echo -e "${YELLOW}Starting the file merging tool for directory: $TARGET_DIR${NC}"
merge_files "$TARGET_DIR"
