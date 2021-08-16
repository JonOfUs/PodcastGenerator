#!/bin/bash 
#author: Jonathan FLueren

#
#	DEAL WITH INPUT
#


strToReplace=""

usage="This tool is able to create a .chapters file readable by JonOfUs's chapter support in PodcastGenerator.\nAs input it needs a folder with .mp3 files (e.g. audiobook CD folder with one .mp3 per chapter).\nFrom this .mp3 list the tool creates a .chapters file in .csv format with chapters per line as well as chapter timestamps (HH:mm:ss).\n\nUsage:\n$0 [-r \"text to replace\"] {path to output file .chapters}} [{path to mp3 input folder}]\n"

if [ $1 == "--help" ]; then
  printf "${usage}"
  exit
fi

filename_param=$1
input_param=$2

if [ $1 == "-r" ]; then
  strToReplace=${2/\"/}
  filename_param=$3
  input_param=$4
fi

if [ -z "$filename_param" ]; then
  printf "Error - no output file specified.\n\n${usage}"
  exit
fi

if [ -z "$input_param" ]; then
  # choose current directory, if none is given
  input_param=$(pwd -P)
fi

# check input directory existence
if [[ ! -d "$input_param" ]]; then
  printf "Error - input directory not existing.\n\n${usage}"
  exit
fi

# normalize directory
if [ "/" != "${input_param: -1}" ]; then
  input_param="${input_param}/"
fi



#
#	ACTUAL ALGORITHM
#

path=$input_param
filename=$filename_param

duration=0.0

# output format: "start,title\n501,SomeTitle\n603,SomeOtherTitle\n...

echo "start,title" > "${filename}"


# set field separator for FOR-loop so that it isn't SPACE
IFS=$(echo -en "\n\b")

for file in ${path}*.mp3
do
  
  # remove path, .mp3 ext & strToReplace from filename
  normalized_file=${file##*/}
  normalized_file=${normalized_file/.mp3/}
  normalized_file=${normalized_file/"${strToReplace}"/}

  printf "%0.3f,${normalized_file}\n" ${duration} >> "${filename}"
  printf "%0.3f,${normalized_file}\n" ${duration}

  # calculate duration using ffprobe
  next_duration=$(ffprobe -v quiet -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${file}")
  # add floating point numbers using bc
  duration=$(echo "${duration} + ${next_duration}" | bc)

done
