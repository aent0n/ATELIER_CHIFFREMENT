import os
import sys
from cryptography.fernet import Fernet

def main():
    if len(sys.argv) != 4:
        print("Usage: python fernet_atelier1.py [encrypt|decrypt] <input_file> <output_file>")
        sys.exit(1)

    mode = sys.argv[1]
    input_file = sys.argv[2]
    output_file = sys.argv[3]

    # La clé est stockée dans une variable d'environnement (Secret GitHub)
    key = os.environ.get("GITHUB_SECRET_FERNET_KEY")
    if not key:
        print("❌ GITHUB_SECRET_FERNET_KEY n'est pas défini dans les variables d'environnement.")
        sys.exit(1)

    f = Fernet(key.encode('utf-8'))

    with open(input_file, "rb") as f_in:
        data = f_in.read()

    if mode == "encrypt":
        result = f.encrypt(data)
        with open(output_file, "wb") as f_out:
            f_out.write(result)
        print(f"✅ Fichier chiffré dans {output_file}")
    elif mode == "decrypt":
        result = f.decrypt(data)
        with open(output_file, "wb") as f_out:
            f_out.write(result)
        print(f"✅ Fichier déchiffré dans {output_file}")
    else:
        print("Mode inconnu.")

if __name__ == '__main__':
    main()
