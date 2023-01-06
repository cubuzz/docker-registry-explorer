# docker-registry-explorer
A simple script that simplifies exploring registries through the docker registry api. Requires Registry V2.

## Usage
Run ui.rb from the `bin/` folder.

## Commands

?                         | Display this help
q!                        | Close this app
conn: <registry url>      | Connect to registry
auth_uname: <username> | Set your username
auth_passwd: <password> | Set your password
c!                        | Update your connection
r:                        | Get all repositories
t: <repository>           | List available tags
m: <repository> <tag>     | Get manifest by tag
msha: <repository> <sha>  | Get manifest by SHA256
dmsha! <repository> <sha> | DELETE manifest by SHA256
=====================================================
housekeeper!              | Search for images without
                          | tags. Note that this may
                          | take a while...

## Author's note
This was one of my first open source projects when I started to really get into coding, and despite not being much, I hope this helps someone :)
I do not intend to maintain this repository any further - if the need arises I'll rework this app.
