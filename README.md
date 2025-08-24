# Flutter aplikacija za seminarski rad iz predmeta Razvoj Softvera 2

Aplikacija je razvijena kao dio seminarskog rada za predmet Razvoj Softvera 2.

Aplikacija je razvijena korištenjem tehnologija .NET i Flutter. Mobilna aplikacija podržava Android, dok desktop funkcioniše na Windows platformi.  
Aplikaciju je moguće pokrenuti i na iOS-u i Linuxu, ali ove platforme nisu bile prioritet tokom razvoja, što može rezultirati nepredviđenim greškama.  

## Opis
Aplikacija prvobitno ima namjenju pomoći svakom korisniku da pronađe željenu nekretninu za rentanje. Tako da ideja ove aplikacije zaMene jeste mogućnost
bukiranja stanova odnosno nekretnina po želji, gdje imamo nekretnine po gradovima gdje svaki korisnik može birati odgovarajuću nekretninu, popratit ocjenje iste i
uvidjeti da li mu sve odgovora kroz recenzije, slike i detaljni opis. Korisniku je omogućeno da kroz color themed kalendar vidi kad je određena nekretnina slobodna i kad nije,
shodno tim može birati kad želi check in odraditi i check out. Također je implementira sistem preporuke tj. content-based algoritam gdje ako korisnik nije bukirao nekretninu, dobije kroz
top ponude 5 najeftinijih nekretnina, ili ako je odradio već jednom bukiranje neke nekretnine dobije listu sa sličnim nekretninama što je već izabrao i platio.

---

👤 1. Users (korisnici)
Korisnici koji se registruju kao korisnici ove aplikacije imaju sljedeće mogućnosti:

- Rezervacija i prijava na aplikaciju
- Mogućnost pregleda nekretnina po gradovima i filtering
- Mogućnost pregleda opcija, opisa, recenzija, komentara i ocjena nekretnina
- Mogućnost ostavljanja komentara i ocjena
- Mogućnost plaćanja kroz paypal sistem
- Odabir datuma kroz kalendar
- Edit profila (ime, prezime, username kao i slika profila)
- Pregled notifikacija (kad odradi booking određenog stana, dobijemo notifikaciju)
- Pregled broja telefona i imena agenta koji je vlasnik nekretnine
- Pregled prethodni bukiranih nekretnina kroz polje favorites
- Pregled svih bukiranih aktivnih nekretnina

---

🏢 2. Admin (vlasnici aplikacije tj agenti)
Korisnici kojima se automatski dodjeljuje role Admin imaju sljedeće mogućnosti:

- Manipulacija sadržaja na aplikaciji
- Dodavanje novih nekretnina
- Editovanje postojići nekretnina
- Brisanje nekretnina
- Pregled svih nekretnina i filtering
- Pregled svih recenzija, brisanje i editovanje neželjenih recenzija i ocjena
- Pregled dashboard polja, odnosno statistike (Top ponude, najskuplji stan, najviše bukiran stan)
- Pregled statistike kroz chartove

---

✅ Zaključak
Aplikacija pruža efikasan sistem za upravljanje nekretninama. Mogućnost odabira, filtriranja i pronalaska omiljene odnosno željene nekretnine za razne vrste korisnika.

## Instalacija i konfiguracija

### Prije samog početka, moramo se uvjeriti da imamo sljedeće stvari instalirane:
- [Docker instalacija i pokretanje](https://www.docker.com/)
- [Rabbit MQ instalacija](https://www.rabbitmq.com/docs/install-windows#installer)
- Flutter
- Android Emulator koji je u sklopu Android studija

### Prvo treba da namjestimo API okruženje, a to ćemo uraditi u sljedećim koracima.
- Klonirati projekat sa github repozitorija
- (https://github.com/AmigosLP/FIT-RS2-2025)
- Otvorite glavni projekta
- Ubaciti .env file u folder
- Otvorite konzolu
- Upisati komandu `docker compose up`
- Sacekati da docker završi (Može potrajati do par minuta), molim za strpljenje. 

### Ako odaberemo zamene_desktop pratite sljedeće korake:
- Ako koristite windows omogućite Developer mode
- Otvorite IDE po vašem izboru
- Instalirajte potrebne dependencies:
- `flutter pub get`
- Pokrenite aplikaciju na Android Virtual Device iz Android Emulatora
- Pokrenite aplikaciju
- `flutter run -d windows`

### Ako odaberemo zamene_mobile pratite sljedeće korake:
- Otvorite IDE po vašem izboru
- Instalirajte potrebne dependencies:
- `flutter pub get`
- Pokrenite aplikaciju
- `flutter run`

## Pokretanje preko fit-app-build
Ako pokrećemo aplikaciju preko build (zipovano) foldera unutar projekta, sve što trebamo jeste:
- Extract 7zip folder da imamo sve fajlove
- Na admin strani pokrenuti .exe file i pokrenut ćemo zamene_desktop
- Drag and Drop APK fajl u AVD emulator na zamene_mobile i time ćemo pristupit aplikaciji i moći se logirati.

## Password za extract apk build-a
`fit`

## Kredencijali
Za desktop dio sljedeci kredencijali su dostupni
### Admin
`username: admin`
`password: AdminZaMene22`

### Za mobilnu aplikaciju su sljedeći kredencijali
### Korisnici
Kroz seed podataka, imate mogućnost pregleda raznih korisnika, neki od tih su:

`ime: Amila`
`prezime: Delić`
`email: amila.delic@gmail.com`
`password: AmilaPass22!`
`username: amila_d`

`ime: Sara`
`prezime: Begović`
`email: sara.begovic@gmail.com`
`password: SaraPass22!`
`username: sara_b`

`ime: Damir`
`prezime: Begić`
`email: damir.begic@gmail.com`
`password: DamirPass22!`
`username: damir_b`

### Bitno je napomenuti da su ovo seed korisnici, svi koji žele isprobati aplikaciju imaju mogućnost registracije i logiranja sebe kao korisnika, i koristešenja validnih kredencijala.

### Prilikom logina, kredencijali koji se unose su username i password!

## Paypal kredencijali
`email: rszamene@personal.example.com`
`password: 3J@w@GH?`
