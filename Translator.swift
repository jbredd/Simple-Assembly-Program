
struct Translator {
    static let registers = ["r1": 1, "r2": 2, "r3": 3, "r4": 4, "r5": 5, "r6": 6, "r7": 7, "r8": 8, "r9": 9]
    static let instructions = ["halt": 0, "clrr": 1, "clrx": 2, "clrm": 3, "clrb": 4, "movir": 5, "movrr": 6, "movrm": 7, "movmr": 8, "movxr": 9, "movar": 10, "movb": 11, "addir": 12, "addrr": 13, "addmr": 14, "addxr": 15, "subir": 16, "subrr": 17, "submr": 18, "subxr": 19, "mulir": 20, "mulrr": 21, "mulmr": 22, "mulxr": 23, "divir": 24, "divrr": 25, "divmr": 26, "divxr": 27, "jmp": 28, "sojz": 29, "sojnz": 30, "aojz": 31, "aojnz": 32, "cmpir": 33, "cmprr": 34, "cmpmr": 35, "jmpn": 36, "jmpz": 37, "jmpp": 38, "jsr": 39, "ret": 40, "push": 41, "pop": 42, "stackc": 43, "outci": 44, "outcr": 45, "outcx": 46, "outcb": 47, "readi": 48, "printi": 49, "readc": 50, "readln": 51, "brk": 52, "movrx": 53, "movxx": 54, "outs": 55, "nop": 56, "jmpne": 57]
}
