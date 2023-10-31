CREATE SCHEMA ksiegowosc;
CREATE TABLE pracownicy (
	id_pracownika int NOT NULL PRIMARY KEY,
	imie varchar(30),
	nazwisko varchar(30),
	adres varchar(30)
);

CREATE TABLE pensja (
	id_pensji int NOT NULL PRIMARY KEY,
	stanowisko varchar(30),
	kwota decimal(8, 2)
);

CREATE TABLE premia (
	id_premii int NOT NULL PRIMARY KEY,
	rodzaj varchar(30),
	kwota decimal(8, 2)
);

INSERT INTO pracownicy VALUES
(1, 'Jerzy', 'Struna', 'Rze'),
(2, 'Janusz', 'Kowalski', 'Krk'),
(3, 'Ewa', 'Lipska', 'Krk'),
(4, 'Iwona', 'Król', 'Kat'),
(5, 'Dawid', 'Skok', 'Krk'),
(6, 'Jadwiga', 'Gminna', 'Poz'),
(7, 'Ala', 'Noc', 'Krk'),
(8, 'Szymon', 'Dawidowicz', 'Wrc'),
(9, 'Ela', 'Rodzinna', 'Krk'),
(10, 'Mateusz', 'Wdowiak', 'Wad');

INSERT INTO pensja VALUES
(1, 'Kierownik', 2040.19),
(2, 'Menedżer', 3000.00),
(3, 'Telemarketer', 600.00),
(4, 'Dostawca', 5000.40),
(5, 'Sprzedawca', 1500.00),
(6, 'Marketingowiec', 1500.01),
(7, 'Informatyk', 1499.99),
(8, 'Kontroler', 2999.99),
(9, 'Analityk', 5000.00),
(10, 'Kosmonauta', 180000.00);

INSERT INTO premia VALUES
(21, 'Za nic', 100.00),
(22, 'Zachowanie', 300.00),
(23, 'Wyniki', 400.00),
(24, 'Spryt', 500.00),
(25, 'Wygląd', 1500.00),
(26, 'Decyzja', 200.00),
(27, 'Szybkość', 100.00),
(28, 'Perswazja', 219.99),
(29, 'Kompetencje', 5.00),
(30, 'Punktualność', 10.00);

-- 5a --
SELECT id_pracownika, nazwisko FROM pracownicy;

-- 5d --
SELECT id_pracownika, imie, nazwisko FROM pracownicy WHERE imie LIKE 'J%';

-- 5e --
SELECT id_pracownika, imie, nazwisko FROM pracownicy WHERE imie LIKE '%a' AND (nazwisko LIKE '%n%'
OR nazwisko LIKE '%N%');

-- 5f --