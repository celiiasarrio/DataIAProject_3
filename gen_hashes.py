import bcrypt

passwords = {
    'daadgi': 'Da7!kLm92Q',
    'joallu': 'Jo4#vRt81P',
    'gebaad': 'Ge9$uNx34L',
    'cabesa': 'Ca2@pWd67M',
    'inbupe': 'In8!yQs53K',
    'pagaes': 'Pa6#zHt28R',
    'maazlo': 'Ma3$eJv74N',
    'jomama': 'Jo1@xBc95T',
    'japlro': 'Ja5!mYu46H',
    'sareva': 'Sa7#nKi83D',
    'jogrhe': 'Jo8$hPw52C',
    'cesaco': 'Ce4@tLq67B',
    'jaloru': 'Ja9!rMx31F',
    'feorma': 'Fe2#vNd84S',
}

for k, v in passwords.items():
    hashed = bcrypt.hashpw(v.encode(), bcrypt.gensalt(12)).decode()
    print(f"{k}: {hashed}")
