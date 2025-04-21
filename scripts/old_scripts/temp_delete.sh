#!/bin/bash

# Array of folder paths to be deleted (the main folder, not the BDMV folder)
folders=(
    "/mnt/user/data/media/movies/The Banshees of Inisherin (2022) {tmdb-674324}/The Banshees of Inisherin (2022)"
    "/mnt/user/data/media/movies/The Incredible Hulk (2008) {tmdb-1724}/The Incredible Hulk (2008)"
    "/mnt/user/data/media/movies/Pearl (2022) {tmdb-949423}/Pearl (2022)"
    "/mnt/user/data/media/movies/Maleficent (2014) {tmdb-102651}/Maleficent (2014)"
    "/mnt/user/data/media/movies/Mission - Impossible - Dead Reckoning Part One (2023) {tmdb-575264}/Mission - Impossible - Dead Reckoning Part One (2023)"
    "/mnt/user/data/media/movies/Kingsman - The Golden Circle (2017) {tmdb-343668}/Kingsman - The Golden Circle (2017)"
    "/mnt/user/data/media/movies/Jerry & Marge Go Large (2022) {tmdb-843847}/Jerry & Marge Go Large (2022)"
    "/mnt/user/data/media/movies/DC League of Super-Pets (2022) {tmdb-539681}/DC League of Super-Pets (2022)"
    "/mnt/user/data/media/movies/Captain Marvel (2019) {tmdb-299537}/Captain Marvel (2019)"
    "/mnt/user/data/media/movies/Avengers - Endgame (2019) {tmdb-299534}/Avengers - Endgame (2019)"
    "/mnt/user/data/media/movies/Men in Black 3 (2012) {tmdb-41154}/Men in Black 3 (2012)"
    "/mnt/user/data/media/movies/Hellboy (2019) {tmdb-456740}/Hellboy (2019)"
    "/mnt/user/data/media/movies/Oceans Thirteen (2007) {tmdb-298}"
)

# Loop through each folder and delete the entire folder
for folder in "${folders[@]}"; do
    echo "Deleting folder: $folder"
    rm -rf "$folder"
    echo "Deleted: $folder"
done

echo "All specified folders have been deleted."
