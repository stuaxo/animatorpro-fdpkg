# Download AnimatorAKA.zip [1] into this directory and run.
# [1] https://github.com/AnimatorPro/Animator-Pro/downloads

mkdir build
cd build

unzip ../AnimatorAKA.zip
mv AnimatorAKA PROGS

mkdir APPINFO
mkdir LINKS
mkdir PROGS
mkdir SOURCE


cd LINKS
echo "PROGS\ANIMATOR\V.EXE" > ANIMATOR.BAT
echo "PROGS\ANIMATOR\CROP.EXE" > ANIMCROP.BAT
echo "PROGS\ANIMATOR\PLAY.EXE" > ANIMPLAY.BAT
cd ..


zip -9 -k -r ANIMATOR.ZIP APPINFO LINKS PROGS SOURCE
