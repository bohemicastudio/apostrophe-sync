# Apostrophe Sync

### An ApostropheCMS companion script for syncing MongoDB database collections and `/uploads` folder contents between local and remote environments.

## Prerequisites:
- `bash`
- `rsync`
- `mongodump` & `mongorestore`- they can be installed as a part of the [MongoDB Database Tools](https://www.mongodb.com/docs/database-tools/installation/installation/)
- correctly set environmental variables inside the `aposync.config.js` in order to connect via SSH client

## How to use:

1. Add the package with `npm` or `yarn` to your project: `npm install @bohemicastudio/aposync`
2. Run `aposync init` to create the configuration file `aposync.config.js` in the root folder of your project and set the necessary variables inside.
3. Run `aposync` command in your terminal to access an action overview menu.
4. Input the numeric code inside the square brackets to run the desired action.
   - If you remember the code number you can enter it with the command e.g. `aposync 101` or `aposync 101 -y` to skip the confirmation.
5. Now relax and let the script do the work for you.

## Configuration:

`aposync.sh` - the main script file that serves as a crossroad for executing the subscripts:
- `db-up.sh` - transfers MongoDB collection from a local to a remote environment
- `db-down.sh` - transfers MongoDB collection from a remote to local environment
- `files-up.sh` - transfers local "uploads" files to a remote environment
  - `-d`, `--dry` - only executes a test run and lists files missing in the remote folder
  - `-f`, `--force` - deletes remote files that don't exist locally
- `files-down.sh` - transfers remote "uploads" files to a local environment
  - `-d`, `--dry` - only executes a test run and lists files missing in the local folder
- `restore-local.sh` - restores local MongoDB collection from a chosen local backup/dump file 
- `restore-remote.sh` - restores remote MongoDB collection from a chosen remote backup/dump file
- `list-local.sh` - lists all local MongoDB backup files
- `list-remote.sh` - lists all remote MongoDB backup files
- `backup-local.sh` - creates a MongoDB backup file locally
- `backup-remote.sh` - creates a MongoDB backup file remotely
