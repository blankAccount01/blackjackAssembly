# About blackjackAssembly

Its a simple blackjack demo written in assembly in order to fit it onto a QR Code. It targets Linux x86_64 computers.  

Controls are H to hit and F to fold. The program file size is ~2.1kb as the conversion to base64 increases the file size by up to 33%. The QR code points to a data url that downloads and decodes the base64. 

Some notable limitations are that Aces are not included and cards are generated randomly opposed to being pulled from the card. These were done to keep the logic short. This is my first project with assembly so there may be but not limited to memory leaks, memory corruption, memory overflow and invalid memory access. 

# Insallation from QR code

How to install zbar-tools:
```
sudo apt update
sudo apt install zbar-tools
```

To scan, run
```
zbarimg output.png > main
```
Make sure to give the file the proper permissions
```
chmod +x main
```


# Insallation from building .asm file

How to install nasm:
```
sudo apt update
sudo apt install nasm
```

To compile, run
```
nasm -f elf64 main.asm -o main.o
ld -z noseparate-code main.o -o main
```

# Pictures
Intro Screen:
<p align="center"><img width="458" alt="image" src="https://github.com/user-attachments/assets/3640dac1-7077-435d-8ce2-44670b274bf3" /></p>

Demo:
<p align="center"><img width="458" alt="image" src="https://github.com/user-attachments/assets/f772626f-6ffb-462b-8b14-f0657b7c3f8e" /></p>

# Details
Time taken: 11 hours (plus countless hours debuging arghhh)<br>
Written in assembly <br>
