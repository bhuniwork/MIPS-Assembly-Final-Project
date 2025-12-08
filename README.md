Wordle in MIPS Assembly

Authors: Jerry Lam, Brandon Ho, Christopher Tjahja, Duve Rodriguez-Garcia
CS 2640, Fall 2025

Description: This project implements a simplified version of the game Wordle using MIPS assembly in the MARS simulator. The game randomly selects a five-letter word from a predefined list and gives the player up to six attempts to guess it. The program checks each guess for: correct letter in correct postiion, correct letter in wrong position, and wrong letter in wrong position. It also includes input validation to ensure that each guess consists of exactly 5 alphabetic letters.

Known Issues:
- Duplicate letters in the guess may be marked incorrectly because the current implementation does not track per-letter frequencies.
- The randomization depends on system time, so running the program quickly repeatedly may result in the same word as the secret word.
- Guesses are not checked against a dictionary. 
