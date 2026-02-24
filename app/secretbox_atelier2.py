import sys
import nacl.secret
import nacl.utils

def main():
    if len(sys.argv) < 2:
        print("Usage: python secretbox_atelier2.py [generate_key|encrypt|decrypt] ...")
        sys.exit(1)

    mode = sys.argv[1]

    if mode == "generate_key":
        key = nacl.utils.random(nacl.secret.SecretBox.KEY_SIZE)
        print("Clé générée (hex) :", key.hex())
    elif mode == "encrypt":
        if len(sys.argv) != 5:
            print("Usage: python secretbox_atelier2.py encrypt <key_hex> <input_file> <output_file>")
            sys.exit(1)
        key = bytes.fromhex(sys.argv[2])
        input_file = sys.argv[3]
        output_file = sys.argv[4]
        
        box = nacl.secret.SecretBox(key)
        with open(input_file, "rb") as f_in:
            data = f_in.read()
            
        encrypted = box.encrypt(data)
        with open(output_file, "wb") as f_out:
            f_out.write(encrypted)
        print(f"✅ Fichier chiffré dans {output_file}")
        
    elif mode == "decrypt":
        if len(sys.argv) != 5:
            print("Usage: python secretbox_atelier2.py decrypt <key_hex> <input_file> <output_file>")
            sys.exit(1)
        key = bytes.fromhex(sys.argv[2])
        input_file = sys.argv[3]
        output_file = sys.argv[4]
        
        box = nacl.secret.SecretBox(key)
        with open(input_file, "rb") as f_in:
            encrypted = f_in.read()
            
        decrypted = box.decrypt(encrypted)
        with open(output_file, "wb") as f_out:
            f_out.write(decrypted)
        print(f"✅ Fichier déchiffré dans {output_file}")

if __name__ == '__main__':
    main()
