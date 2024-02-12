/*modifica coloana tip din echipamente din Varchar in NVARCHAR*/
Create procedure modifica
AS

Alter Table echipamente
Alter column tip NVarchar(100);
GO
/*Modifica din nvarcahr in varchar*/

create procedure undo_modifica
as 
alter table echipamente
alter column tip varchar(100);
GO

exec modifica
exec undo_modifica

/*Valoare implicita pentru pret*/
CREATE PROCEDURE valoare_implicita_pret
as
alter table echipamente
add constraint pret_nou
default 120 for pret;
go

exec valoare_implicita_pret
exec undo_valoare_implicita_pret

/*sterge valoare implicita pt pret*/
create procedure undo_valoare_implicita_pret
as
alter table echipamente
drop constraint pret_nou;
go
/*creaza un tabel nou*/
create procedure tabel_nou
as
begin 
create table politici
(
id_politici int NOT NULL PRIMARY KEY,
tip varchar(100),
descriere varchar(100),
data_aplicare date

);
end
go

exec tabel_nou
exec undo_tabel_nou

/*sterge tabelul creat*/
create procedure undo_tabel_nou
as
begin
		drop table politici
		end
go
/*creaza un camp nou*/
create procedure camp_nou
as
begin
alter table politici
add echipament_aplicare varchar
end
go
/*sterge un camp nou*/
create procedure undo_camp_nou
as
begin
alter table politici
drop column echipament_aplicare
end
go
drop procedure camp_nou
exec tabel_nou
exec camp_nou
exec undo_camp_nou
exec undo_tabel_nou

/*adaugam constrangerea ca id politici sa fie fk de la id echipament*/
create procedure Foreign_key
AS
BEGIN
alter table politici
add constraint fk_id_echipament
foreign key (id_politici) references echipamente(id_echipament);
end
go
drop procedure Foreign_key

create procedure undo_foreign_key
as 
begin 
alter table politici
drop constraint fk_id_echipament;
end
go
exec tabel_nou
exec Foreign_key
exec undo_foreign_key
exec undo_tabel_nou

use Telecomunicatii

/*tabela in care retinem versiunea curenta a aplicatiei*/
create table VersiuneDB(
Nr_versiune INT default 0);
insert into VersiuneDB
values(0);

/*tabela de udpate de versiuni*/
create table Update_list(
id int primary key,
procedura varchar(100)
);

insert into Update_list(id, procedura) values
(0,'modifica')
(1,'modifica'),
(2,'valoare_implicita_pret'),
(3,'tabel_nou'),
(4,'camp_nou'),
(5,'Foreign_key')

create table undo_update_list(
id int primary key,
procedura varchar(100)
);

insert into undo_update_list(id, procedura) values
(0,'baza')
(1,'undo_modifica'),
(2,'undo_valoare_implicita_pret'),
(3,'undo_tabel_nou'),
(4,'undo_camp_nou'),
(5,'undo_foreign_key')
go

update Update_list
set procedura='valoare_implicita_pret' where id=2;
create procedure main
@versiune int
as 
begin
	if @versiune > 5 or @versiune < 0
	begin
		raiserror('versiune inexistenta',1,16);
		return;
	end
	declare @versiune_actuala as int
	select @versiune_actuala = Nr_versiune
	from VersiuneDB

	print 'versiunea actuala aste : ';
	print @versiune_actuala;
	print 'vrem sa ajungem la versiunea:'
	print @versiune

	if @versiune = @versiune_actuala
	begin
		print'suntem deja la versiunea dorita!'
		return;
	end
	declare @functie as varchar(100);
	declare @indice as int;
	declare @list table(
	id int primary key,
	procedura varchar(100));
	if (@versiune < @versiune_actuala)
	begin
			set @indice = -1;
			insert into @list select id,procedura from undo_update_list
	end
		else
	begin
			set @indice = 1;
			insert into @list select id,procedura from Update_list
	end

		
	while @versiune_actuala != @versiune
	begin
		if @indice = 1
		begin
				set @versiune_actuala =@versiune_actuala + @indice			
				select @functie = procedura from @list where id=@versiune_actuala;
				print @functie
				execute @functie
		end
		else
			begin
				select @functie = procedura from @list where id=@versiune_actuala;
				set @versiune_actuala =@versiune_actuala + @indice			
				print @functie
			execute @functie
		end
	end
	update VersiuneDB
	set Nr_versiune = @versiune_actuala;
	return;
end
go

drop procedure main

exec main 11;
exec undo_modifica
exec undo_foreign_key
exec undo_camp_nou
exec undo_tabel_nou
exec tabel_nou
exec undo_valoare_implicita_pret
select * from VersiuneDB
update VersiuneDB
set Nr_versiune =0;