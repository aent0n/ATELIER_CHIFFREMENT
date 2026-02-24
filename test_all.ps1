$ErrorActionPreference = "Stop"

function Write-Step ($msg) {
    Write-Host "`n[+] STEP: $msg" -ForegroundColor Cyan
}

function Write-Info ($msg) {
    Write-Host "    -> $msg" -ForegroundColor Gray
}

function Write-Success ($msg) {
    Write-Host "    => [SUCCESS] $msg" -ForegroundColor Green
}

function Write-Data ($msg) {
    Write-Host "       $msg" -ForegroundColor Yellow
}

Write-Host "===========================================================" -ForegroundColor Magenta
Write-Host "                  DEBUT DES ATELIERS " -ForegroundColor Magenta
Write-Host "===========================================================" -ForegroundColor Magenta

# Create a test secret file
Write-Step "Génération du fichier secret intial"
$secretMsg = "Message Top secret ! Preuve de dechiffrement ok."
$secretMsg | Out-File -Encoding utf8 "secret.txt"
Write-Info "Fichier 'secret.txt' créé."
Write-Data "Contenu brut : '$secretMsg'"


Write-Host "`n===========================================================" -ForegroundColor Magenta
Write-Host " ATELIER 1 : FERNET & GITHUB SECRETS" -ForegroundColor Magenta
Write-Host "===========================================================" -ForegroundColor Magenta

Write-Step "Génération d'une clé Fernet symétrique 256-bits (encodée Base64)"
$key = python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
Write-Info "Clé générée par la lib cryptography.fernet"
Write-Data "Valeur de la clé : $key"

Write-Step "Injection de la clé dans les variables d'environnement"
$env:SECRET_FERNET_KEY = $key
Write-Info "Secret GitHub : `$env:SECRET_FERNET_KEY configuré."

Write-Step "Chiffrement du fichier secret.txt -> secret_atelier1.enc"
Write-Info "Appel de : python3 app/fernet_atelier1.py encrypt secret.txt secret_atelier1.enc"
python3 app/fernet_atelier1.py encrypt secret.txt secret_atelier1.enc
Write-Info "Vérification de l'existence du fichier chiffré..."
if (Test-Path secret_atelier1.enc) {
    Write-Success "Fichier secret_atelier1.enc généré avec succès."
    $encSize = (Get-Item secret_atelier1.enc).Length
    Write-Data "Taille du ciphertext Fernet : $encSize octets."
}

Write-Step "Déchiffrement du fichier secret_atelier1.enc -> secret_atelier1_dec.txt"
Write-Info "Appel de : python3 app/fernet_atelier1.py decrypt secret_atelier1.enc secret_atelier1_dec.txt"
python3 app/fernet_atelier1.py decrypt secret_atelier1.enc secret_atelier1_dec.txt

Write-Step "ATELIER 1 - Lecture du fichier clair"
$dec1 = Get-Content secret_atelier1_dec.txt
Write-Data "Contenu déchiffré : '$dec1'"
if ($dec1 -eq $secretMsg) {
    Write-Success "intégrité validée - le texte correspond"
} else {
    Write-Host "    => [ECHEC] Le texte ne correspond pas !" -ForegroundColor Red
}


Write-Host "`n===========================================================" -ForegroundColor Magenta
Write-Host " ATELIER 2 : PYNACL SECRETBOX" -ForegroundColor Magenta
Write-Host "===========================================================" -ForegroundColor Magenta

Write-Step "Génération d'une clé secrète via PyNaCl (32 octets / 256 bits)"
Write-Info "Appel de : python3 app/secretbox_atelier2.py generate_key"
$nacl_key_output = python3 app/secretbox_atelier2.py generate_key
$nacl_key_hex = ($nacl_key_output -split " : ")[1]
Write-Info "Clé générée via nacl.utils.random(32)"
Write-Data "Valeur de la clé (hexadécimal) : $nacl_key_hex"

Write-Step "Chiffrement du fichier secret.txt -> secret_atelier2.enc"
Write-Info "Appel de : python3 app/secretbox_atelier2.py encrypt <KEY> secret.txt secret_atelier2.enc"
python3 app/secretbox_atelier2.py encrypt $nacl_key_hex secret.txt secret_atelier2.enc
if (Test-Path secret_atelier2.enc) {
    Write-Success "Fichier chiffré secret_atelier2.enc généré avec succès."
    $encSize2 = (Get-Item secret_atelier2.enc).Length
    Write-Data "Taille du ciphertext PyNaCl : $encSize2 octets."
}

Write-Step "Déchiffrement du fichier secret_atelier2.enc -> secret_atelier2_dec.txt"
Write-Info "Appel de : python3 app/secretbox_atelier2.py decrypt <KEY> secret_atelier2.enc secret_atelier2_dec.txt"
python3 app/secretbox_atelier2.py decrypt $nacl_key_hex secret_atelier2.enc secret_atelier2_dec.txt

Write-Step "ATELIER 2 - Lecture du fichier clair"
$dec2 = Get-Content secret_atelier2_dec.txt
Write-Data "Contenu déchiffré : '$dec2'"
if ($dec2 -eq $secretMsg) {
    Write-Success "intégrité validée - le texte correspond"
} else {
    Write-Host "    => [ECHEC] Le texte ne correspond pas !" -ForegroundColor Red
}

Write-Host "`n===========================================================" -ForegroundColor Magenta
Write-Host " TOUS LES ATELIERS SONT VALIDÉS AVEC SUCCÈS" -ForegroundColor Magenta
Write-Host "===========================================================" -ForegroundColor Magenta
