#!/bin/bash

# ./perforator.sh paths.txt localhost:3000 user password

path_file=${1-news_paths.txt}

host=${2-127.0.0.1:3000}

username=${3-username}
password=${4-password}

timeout=${5-60}

build_sha="NO_KNOWN_BUILD" # Replace this with your build boxes env variable.

build_sha_prefix=${build_sha:0:8}

start_time=`date`

curl_output_format="<td>%{http_code}</td><td>%{time_starttransfer}</td><td>%{time_total}</td><td>%{size_download}</td>\n"

current_build_tmp_directory="tmp/$build_sha_prefix"
current_build_tmp_file="$current_build_tmp_directory/tmp"

# Check if the path file exists. Exit with 1 if not.
if [ ! -f $path_file ]; then
    echo "Need a file of paths."; exit 1
fi

# Check if the path file is blank
if [ ! $(cat $path_file | wc -l) -gt 0 ]; then
    echo "Need to have some paths in the passed in file."; exit 1
fi

# Create a tmp directory so it doesn't blow up when spitting stuff out.
mkdir -p $current_build_tmp_directory
mkdir -p "tmp"

# Where the results go!
output_file="tmp/http_perf_result_$build_sha_prefix.html"

# Create the output file if it doesn't exist.
if [ ! -f $output_file ]; then
    touch $output_file
fi

# Log in, and store the cookies for each request to the build's tmp area.
curl --silent --output $current_build_tmp_directory/out -c $current_build_tmp_directory/cookies -d "user[username]="$username"&user[password]="$password $host"/users/sign_in?unauthenticated=true"

echo "<table>" >> $current_build_tmp_file
echo "<tr><th colspan='4'>$start_time</th></tr>" >> $current_build_tmp_file
echo "<tr><th colspan='4'>$build_sha</th></tr>" >> $current_build_tmp_file
echo "<tr><th>URL</th><th>Response Code</th><th>Pretransfer time</th><th>Total Time</th><th>Size Downloaded</th></tr>" >> $current_build_tmp_file

for url in $(cat $path_file | sort); do
    echo "<tr>" >> $current_build_tmp_file
    echo "<td>$host$url</td>" >> $current_build_tmp_file
    echo "`curl -w $curl_output_format --silent --output $current_build_tmp_directory/out -b $current_build_tmp_directory/cookies -m $timeout $host$url`" >> $current_build_tmp_file
    echo "</tr>" >> $current_build_tmp_file
done

echo "</table>" >> $current_build_tmp_file

cat $current_build_tmp_file | cat - $output_file > "$current_build_tmp_directory/results" && mv "$current_build_tmp_directory/results" $output_file

# Clean it on up!
rm -r $current_build_tmp_directory