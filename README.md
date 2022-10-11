# Apostrophe Sync

Bohemica made companion for syncing MongoDB database and /uploads folder from local device to a development server.

## Předpoklady:

Skripty potřebují funknční prostředí `bash`, utility `rsync`, `mongodump`, `mongorestore` a funkční `ssh` připojení na vzdálený server.

## Použití:

Hlavní spouštěcí skript je `aposync.sh` Jeho samostané spuštění vám dá na výběr z dostupných příkazů a zadáním čísla v závorkách jeden z příkaů spustíte. Pokud si číslo příkazu pamatujete, můžete jej zadat rovnou jako vstupní parametr `aposync.sh N`, nebo `aposync.sh N -y` pro přeskočení potvrzovací hlášky.

`aposync.sh` pouze spouští zbylé obsažené skripty:
- `sync-up.sh` na nahrání databáze, z lokálního prostředí na vzdálené
- `sync-down.sh` na stažení databáze, ze vzdáleného prostředí na lokální
- `files-up.sh` na nahrání nových souborů, z lokálního prostředí na vzdálené
  - `-d`, `--dry` které neprovedete synchronizaci ale pouze vypíše nové soubory oproti vzdálenému adresáři
  - `-f`, `--force` které zároveň smaže soubory na vzdáleném adresáři, které neexistují v lokálním
- `files-down.sh` na stažení nových souborů, ze vzdáleného prostředí na lokální
  - `-d`, `--dry` které neprovedete synchronizaci ale pouze vypíše nové soubory oproti lokálnímu adresáři

Pro koretkní funkci skriptů je třeba mít plně vyplněný soubor `.env` podle šablony `.env.example`.
