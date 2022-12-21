# Apostrophe Sync

### An easy-to-use ApostropheCMS companion script for syncing MongoDB database `/uploads` folder from a local device to a remote server.

## Prerequisites:
- `bash`
- `rsync`
- `mongodump` & `mongorestore`- they can be installed as a part of the [MongoDB Database Tools](https://www.mongodb.com/docs/database-tools/installation/installation/)
- correctly set `.env` variables to connect via the `ssh`

## How to use:

1. Add the package via npm or yarn to your project: `npm install @bohemicastudio/aposync`
2. Create `aposync.config.js` file in the root folder of your project with `aposync init` command and set necessary variables. See the next section for more information.
3. Run `aposync` command in your terminal to access an action overview menu.
4. Input the numeric code inside the square brackets to run the desired action.
   - If you remember the code number you can enter it with the command e.g. `aposync 101` or `aposync 101 -y` to skip the confirmation.
5. Now relax and let the script do the work for you.

## Configuration:

`aposync.sh` - the main script file that serves as a crossroad for executing the subscripts:
- `db-up.sh` - transfers MongoDB collection from a local to remote/server environment
- `db-down.sh` - transfers MongoDB collection from a remote/server to local environment
- `files-up.sh` - transfers local "uploads" files to a remote/server environment
  - `-d`, `--dry` - only executes a test run and lists files missing in the remote folder
  - `-f`, `--force` - deletes remote files that don't exist locally
- `files-down.sh` - transfers remote/server "uploads" files to a local environment
  - `-d`, `--dry` - only executes a test run and lists files missing in the local folder
- `restore-local.sh` - restores local MongoDB collection from a chosen local backup/dump file 
- `restore-server.sh` - restores remote MongoDB collection from a chosen remote backup/dump file
- `list-local.sh` - lists all local MongoDB backup files
- `list-server.sh` - lists all remote MongoDB backup files
- `backup-local.sh` - creates a MongoDB backup file locally
- `backup-server.sh` - creates a MongoDB backup file remotely
