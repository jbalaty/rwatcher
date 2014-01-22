#/bin/sh

echo 'Compiling assets'
RAILS_ENV=production
rake assets:precompile
if [ "$?" == "0"  ]
then
	BRANCH=`git rev-parse --abbrev-ref HEAD`
	echo "Forcing assets add into current branch ($BRANCH)"
	git add public/assets --force
	git commit -m"Build script - precompiled assets"
fi
