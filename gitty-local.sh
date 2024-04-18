#!/bin/bash


# TODO:: CLI args or a config file

LOCAL_DIR="gofetch";
LOCAL_PATH="/home/david/gitty";

REMOTE_DIR="$LOCAL_DIR.git";
REMOTE_PATH_1="git@davidsenack.com";
REMOTE_PATH_2="/var/www/git";

DEFAULT_BRANCH="main";
GITTY_DIR=$PWD;

# Check if directory exists in location, if not create it.
if [ ! -d $LOCAL_PATH/$LOCAL_DIR ]; then
    mkdir $LOCAL_PATH/$LOCAL_DIR;
fi

# TODO:: Error if file already exists - it should notify the user and quit. Do the checks
# before any directories are created. 

# Go into directory on path and git init.
git init $LOCAL_PATH/$LOCAL_DIR;

# Create placeholder gitty README
echo "# Welcome to Gitty!" >> $LOCAL_PATH/$LOCAL_DIR/README.md;
echo "Gitty is a simple set of helper scripts for git-server/stagit management \
    for self-hosted repos." >> $LOCAL_PATH/$LOCAL_DIR/README.md;

# TODO:: Set default branch on local

# Set remote to git-server instance
cd $LOCAL_PATH/$LOCAL_DIR; 
git remote add origin $REMOTE_PATH_1:$REMOTE_PATH_2/$REMOTE_DIR;

# Create remote directory and initalize bare repo
ssh $REMOTE_PATH_1 "if [ ! -d $REMOTE_PATH_2/$REMOTE_DIR ]; then mkdir $REMOTE_PATH_2/$REMOTE_DIR; fi";
ssh $REMOTE_PATH_1 "cd $REMOTE_PATH_2/$REMOTE_DIR && git init --bare $REMOTE_PATH_2/$REMOTE_DIR";

# Change back to gitty dir and copy post-receive hook to remote
cd -;
scp "${PWD}/post-receive" $REMOTE_PATH_1:$REMOTE_PATH_2/$REMOTE_DIR/hooks;
ssh $REMOTE_PATH_1 "chmod 777 $REMOTE_PATH_2/$REMOTE_DIR/hooks/post-receive";

# ------ SERVER SIDE ------
#
# Set variables and write to post-receive

echo "#!/bin/bash" >> $GITTY_DIR/vars;
echo "" >> $GITTY_DIR/vars;
echo "LOCAL_DIR="$LOCAL_DIR"" >> $GITTY_DIR/vars; 
echo "LOCAL_PATH="$LOCAL_PATH"" >> $GITTY_DIR/vars;

# Add tmp to post-receive
cat $GITTY_DIR/vars $GITTY_DIR/post-receive > $GITTY_DIR/temp && mv $GITTY_DIR/temp $GITTY_DIR/post-receive;


#----- CLIENT SIDE -----

# Push local to remote
cd $LOCAL_PATH/$LOCAL_DIR;
git add .;
git commit -m "initalize project with gitty";
git push -u origin $DEFAULT_BRANCH;

