CREATE SCHEMA ksiegowosc;
CREATE TABLE pracownicy (
	id_pracownika int NOT NULL PRIMARY KEY,
	imie varchar(30),
	nazwisko varchar(30),
	adres varchar(30),
	
);
CREATE TABLE Persons (
    PersonID int,
    LastName varchar(255),
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255)
);