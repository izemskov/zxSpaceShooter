cd C:\build\zxSpaceShooter\src\

echo ---------           Compile           ---------
sjasmplus C:\build\zxSpaceShooter\src\MAIN.asm

echo ---------           Running           ---------
"C:\Program Files (x86)\Spectaculator\Spectaculator.exe" C:\build\zxSpaceShooter\src\game.sna
