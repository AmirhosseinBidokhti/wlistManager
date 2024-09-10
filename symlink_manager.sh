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

# Function to create a symlink interactively using fzf
create_symlink() {
  while true; do
    echo -e "${BLUE}Navigating to select the source file within ${YELLOW}$1${BLUE}...${NC}"

    # Use fzf to navigate the given directory and select a file
    source=$(find "$1" -type f | fzf --prompt="Select the source file: " --height=15)

    # Handle quit input
    check_exit "$source"

    if [ -z "$source" ]; then
      echo -e "${RED}No source file selected. Exiting.${NC}"
      break
    fi

    echo -e "${GREEN}Source file selected: $source${NC}"

    # Now prompt the user for the destination path or folder
    echo -e "${BLUE}Please enter the destination path for the symbolic link (or 'q' to quit):${NC}"
    read destination_path

    # Handle quit input
    check_exit "$destination_path"

    # Ensure the entered destination path exists or create it interactively
    if [ ! -d "$destination_path" ]; then
      echo -e "${RED}Error: The destination path does not exist. Exiting.${NC}"
      break
    fi

    echo -e "${BLUE}Navigating to select or enter the name of the new symbolic link...${NC}"

    # Use fzf to navigate directories for destination folder
    destination_folder=$(find "$destination_path" -type d | fzf --prompt="Select the destination directory: " --height=15)

    # Handle quit input
    check_exit "$destination_folder"

    if [ -z "$destination_folder" ]; then
      echo -e "${RED}No destination directory selected. Exiting.${NC}"
      break
    fi

    echo -e "${GREEN}Destination directory selected: $destination_folder${NC}"

    # Ask the user for the name of the symlink to be created in the selected directory
    echo -e "${BLUE}Please enter the name for the symlink to be created (or press enter for default name, or 'q' to quit):${NC}"
    read symlink_name

    # Handle quit input
    check_exit "$symlink_name"

    # If no symlink name is provided, use the default (last part of the source path)
    if [ -z "$symlink_name" ]; then
      symlink_name=$(basename "$source")
      echo -e "${YELLOW}No name provided. Using default symlink name: $symlink_name${NC}"
    fi

    # Full path of the symlink
    link="$destination_folder/$symlink_name"

    if [ -e "$link" ]; then
      echo -e "${RED}Error: The destination path already exists. Please provide a different name.${NC}"
      continue
    fi

    # Create the symbolic link
    ln -s "$source" "$link"
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}Success: '$source' has been successfully linked as '$link'.${NC}"
    else
      echo -e "${RED}Error: Failed to create the symbolic link. Please check the paths and try again.${NC}"
    fi

    # Ask if they want to create another symlink or quit
    echo -e "${BLUE}Do you want to create another symlink? (y/n):${NC}"
    read choice
    check_exit "$choice"
    if [ "$choice" != "y" ]; then
      echo -e "${YELLOW}Exiting the symlink creation mode. Goodbye!${NC}"
      break
    fi
  done
}

# Function to delete symbolic links interactively using fzf
remove_symlink() {
  echo -e "${BLUE}Searching for symbolic links within ${YELLOW}$1${BLUE}...${NC}"

  # Find all symbolic links in the specified directory and subdirectories
  symlinks=$(find "$1" -type l)

  if [ -z "$symlinks" ]; then
    echo -e "${RED}No symbolic links found in $1. Exiting.${NC}"
    return
  fi

  # Let the user interactively select one or more symbolic links to delete
  selected_symlinks=$(echo "$symlinks" | fzf --multi --prompt="Select symbolic links to delete: " --height=10)

  # Handle quit input
  check_exit "$selected_symlinks"

  if [ -z "$selected_symlinks" ]; then
    echo -e "${RED}No symbolic links selected. Exiting.${NC}"
    return
  fi

  # Delete the selected symbolic links
  for link in $selected_symlinks; do
    if [ -L "$link" ]; then
      rm "$link"
      if [ $? -eq 0 ]; then
        echo -e "${GREEN}Success: The symbolic link '$link' has been deleted.${NC}"
      else
        echo -e "${RED}Error: Failed to delete the symbolic link '$link'.${NC}"
      fi
    else
      echo -e "${RED}Error: '$link' is not a symbolic link.${NC}"
    fi
  done
}

# Main script logic
if [ $# -lt 1 ]; then
  echo -e "${YELLOW}Usage: $0 <directory> [-remove]${NC}"
  exit 1
fi

TARGET_DIR=$1

# Check if the provided directory exists
if [ ! -d "$TARGET_DIR" ]; then
  echo -e "${RED}Error: The directory '$TARGET_DIR' does not exist.${NC}"
  exit 1
fi

# Handle the -remove flag for symbolic link deletion
if [ "$2" == "-remove" ]; then
  echo -e "${YELLOW}Entering symbolic link deletion mode for directory: $TARGET_DIR${NC}"
  remove_symlink "$TARGET_DIR"
else
  echo -e "${YELLOW}Entering symbolic link creation mode for directory: $TARGET_DIR${NC}"
  create_symlink "$TARGET_DIR"
fi
