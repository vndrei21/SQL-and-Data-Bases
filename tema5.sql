Use telecomunicatii
----VALIDATIONS-----
go
create or alter function VALIDARE_STRING(@nume nvarchar(100))
	returns int 
	as
	begin
		if LEN(@nume) > 3 
		begin
			return 1
		end
		return 0
	end
go
create or alter function Validare_IDcompanie(@idcompanie bigint)
	returns int
	as
	begin
		if EXISTS(select * from Furnizor where @idcompanie = id_companie)
		begin
			return 1
		end
		return 0
	end
go
create or alter function Validate_IDServiciu(@idserviciu bigint)
	returns int
	as
	begin
		if EXISTS(select * from serviciu where @idserviciu = id_service)
		begin
			return 1
		end
		return 0
	end
go
create or alter function VALIDATE_IDPACHET(@idpachet bigint)
returns int
as
begin
	if EXISTS(select * from pachet where @idpachet = id_pachet)
		begin
		return 1
		end
		return 0
	end
go
------Crud-Serviciu-------
CREATE OR ALTER PROCEDURE Create_Serviciu
	(@tip_servici varchar(100),
	@id_companie bigint,
	@rezultat int output
	)
	as
	begin
		if dbo.VALIDARE_STRING(@tip_servici) = 1
		and dbo.Validare_IDcompanie(@id_companie) = 1
		begin
			INSERT INTO dbo.serviciu(tip_servici,id_companie)
			values (@tip_servici,@id_companie);
			set @rezultat = 1;
		end
		else begin set @rezultat = 0;
			end
	end
go
DECLARE @rez int;
select * from Furnizor
exec dbo.Create_Serviciu 'tipul',1,@rez OUTPUT;
print @rez
select * from serviciu
go
Create or alter procedure Read_serviciu
(@idservice bigint,
@tipservice varchar(100),
@idcompanie bigint
)
as
begin
	select * from serviciu where @idservice = id_service and @idcompanie = id_companie and @tipservice = tip_servici;
end	
go
DECLARE @rez int;
exec dbo.Read_serviciu 7,'tipul',1;
print @rez
select * from serviciu
go
CREATE OR ALTER PROCEDURE Update_Serviciu
(@idservici bigint,
@tipservici varchar(100),
@idcompanie bigint,
@rezultat int output
)
as begin
	if dbo.VALIDARE_STRING(@tipservici) = 1 and
		dbo.Validare_IDcompanie(@idcompanie) = 1 and
		dbo.Validate_IDServiciu(@idservici) = 1
	begin
		update serviciu
		set tip_servici = @tipservici where id_service = @idservici and id_companie=@idcompanie;
		set @rezultat = 1;
	end
	else begin set @rezultat = 0;
		end
end
go
DECLARE @rez int;
exec dbo.Update_Serviciu 7,'tip_now',1,@rez;
PRINT( @rez);
select* from serviciu
GO
create or alter procedure Delete_servici
(@idserviciu int,
@rezultat int output)
as 
begin
	if	dbo.Validate_IDServiciu(@idserviciu) = 1
		begin
			delete from serviciu where @idserviciu = id_service
			set @rezultat = 1
		end
		else begin set @rezultat = 0
		end
end
go
DECLARE @rez int;
exec dbo.Delete_servici 7,@rez;
print @rez
select* from serviciu
go
-----CRUD CREARE_PACHET--------
Create or alter procedure Create_CP
	(@idpachete bigint,
	@idservice bigint,
	@pret int,
	@rezultat int output
	)
	as
	begin
		if dbo.VALIDATE_IDPACHET(@idpachete) = 1 and
		dbo.Validate_IDServiciu(@idservice) = 1 
		begin
			insert into creare_pachet(id_pachete,id_service,pret)values
			(@idpachete,@idservice,@pret);
			set @rezultat = 1
		end
		else begin set @rezultat = 0
		end
	end
go
DECLARE @rez int;
exec dbo.Create_CP 1,1,134,@rez;
print @rez
select * from creare_pachet
select * from pachet
select * from serviciu
go
create or alter procedure Read_CP
	(@idpachete bigint,
	@idservice bigint
	)
	as 
	begin
	select * from creare_pachet where @idpachete = id_pachete and @idservice = id_service;
	end
go
DECLARE @rez int;
exec dbo.Read_CP 1,1;
print @rez
select * from creare_pachet
go
create or alter procedure Update_CP
	(
	@idpachete bigint,
	@idservice bigint,
	@pret int,
	@rezultat int output
	)
	as 
	begin
		if dbo.VALIDATE_IDPACHET(@idpachete) =  1 and
		 dbo.Validate_IDServiciu(@idservice)  = 1
		 begin
			update creare_pachet
			set pret = @pret where @idpachete = id_pachete and @idservice = id_service;
			set @rezultat = 1;
		end
		else begin set @rezultat = 0;
		end
	end
go
DECLARE @rez int;
exec dbo.Update_CP 1,1,76,@rez;
print @rez
select * from creare_pachet
go
create or alter procedure Delete_CP
(@idpachet bigint,
@idservice bigint,
@rezultat int 
)
as begin
	if dbo.VALIDATE_IDPACHET(@idpachet) = 1 and
		dbo.Validate_IDServiciu(@idservice) = 1
		begin
			delete from creare_pachet where id_pachete = @idpachet and id_service = @idservice;
			set @rezultat = 1
		end
		else begin set @rezultat = 0
				end
		if @rezultat = 1 
		begin 
			print('Stergere efectuata cu succes!')
		end
		else begin
			print('Nu s-a facut stergerea!')
			end
	end
	go
DECLARE @rez int;
exec dbo.Delete_CP 1,1,@rez;
print @rez
select * from creare_pachet
go
---Crud Pachet
create or alter procedure insert_pachet
(
@nume nvarchar(100),
@rezultat int output
)
as begin
	if  dbo.VALIDARE_STRING(@nume) = 1
		begin
		insert into pachet(nume) values(@nume);
		set @rezultat = 1;
		end
		else begin set @rezultat = 0;
		end
	end
go
DECLARE @rez int;
exec dbo.insert_pachet 'Cel mai bun pachet',@rez;
print @rez
select * from pachet
go

	create or alter procedure Read_Pachet
	@idpachet bigint
	as
	begin
		select * from pachet where @idpachet = id_pachet;
end
go
DECLARE @rez int;
exec dbo.Read_Pachet 1;
print @rez
select * from pachet
go
go
create or alter procedure update_pachet
	(@idpachet bigint,
	@nume nvarchar(100),
	@rezultat int output
	)
	as begin
		if dbo.VALIDATE_IDPACHET(@idpachet) = 1 
		begin
			update pachet
			set nume = @nume where @idpachet = id_pachet;
			set @rezultat = 1;
		end
		else begin set @rezultat = 0
		end
	end
go
DECLARE @rez int;
exec dbo.update_pachet 1,'Nume now',@rez;
print @rez
select * from pachet
go
create or alter procedure delete_pachet
(@idpachet bigint,
@rezultat int)
	as begin
		if dbo.VALIDATE_IDPACHET(@idpachet) = 1
		begin
			delete from pachet where id_pachet = @idpachet;
			set @rezultat = 1;
			end
			else begin set @rezultat = 0;
			end
		if  @rezultat = 1
		begin
			print('stergere realizata cu succes');
		end
		else begin print('Nu s-a realizat stergerea');
		end
	end
go
declare @rez int;
exec dbo.delete_pachet 1,@rez;
select* from pachet
go
---Views---
create or alter view ViewServiciiPachete as
select
	s.id_service,
	s.tip_servici as TIPSERVICI,
	p.pret
	from serviciu s
	join creare_pachet p on s.id_service = p.id_service;
go
select * from ViewServiciiPachete
go
create or alter view ViewInfoPachete as
select
	s.tip_servici as TIPSERVICI,
	cp.pret as pret,
	p.nume as nume
	from serviciu s
	join creare_pachet cp on cp.id_service = s.id_service
	join pachet p on cp.id_pachete = p.id_pachet;
go
select * from ViewInfoPachete

go
CREATE NONCLUSTERED INDEX N_IDX_SERVICIU
on dbo.serviciu(id_service)
include (tip_servici);
go
CREATE NONCLUSTERED INDEX N_IDX_CREARE_PACHET
on dbo.creare_pachet(id_pachete,id_service)
include(pret)
go
create NONCLUSTERED INDEX N_IDX_PACHET
on dbo.pachet(id_pachet)
include (nume)
go



