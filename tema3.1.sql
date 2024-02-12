	/**
	*PK no FK--Client
	*PK + FK---Abonament
	*2 PK------creare_pachet
	*/

	insert into Tables(Name)values
	('Client'),
	('Abonament'),
	('creare_pachet');
	delete from Tables;

	go
	--Pk no FK
	create VIEW view_client as
	select c.nume, c.email,c.nr_tel from client c;
	go

	--pk si fk
	create VIEW view_abonament as 
	select c.nume,c.email,a.id_abonament
	from client c 
	inner join Abonament a
	on c.user_id = a.client_id;
	go

	--2 fk
	create view view_creare_pachet as
	select s.tip_servici,cp.pret,p.nume
	from creare_pachet  cp
	inner join serviciu s
	on s.id_service = cp.id_service
	inner join pachet p
	on p.id_pachet = cp.id_pachete
	group by cp.pret,s.tip_servici,p.nume;
	go


	insert into Views values
	('view_client'),
	('view_abonament'),
	('view_creare_pachet');

	select * from TestViews;

	insert into TestViews Values()
	delete from Views;
	DELETE FROM TestViews;

	--adaugam testele in tabela tests
	insert into Tests values
	('Client_Test'),
	('Abonament_Test'),
	('Creare_Pachet_Test')
	go
	select * from Tests;
	delete from  Tests where TestID > 3; 
	select * from Tables
	
	insert into TestTables values
	(1,10,10,1),
	(1,11,10,2),
	(1,12,10,4);
	go
	select * from TestTables

	insert into TestViews values
	(1,16),
	(1,17),
	(1,18);

	select * from TestViews

	use telecomunicatii

	go
	create procedure inserare_test_Client
	@NoOfRows INT
	as
	begin
		set nocount on;
		
		DECLARE @nume nvarchar(100);
		DECLARE @email nvarchar(100);
		DECLARE @nr_tel varchar(100);
		DECLARE @adresa varchar(100);
		declare @data_nasterii datetime;
		Declare @n int = 0;
		declare @last_id int  = (select MAX(client.user_id) from client)
		while @n < @NoOfRows
		begin 
			set @last_id = @last_id + 1;
			set @nume ='test_user' + convert(varchar(10),@last_id);
			set @email = 'test_mail' + convert(varchar(10),@last_id) + '@gmail.com';
			set @nr_tel = '11223346';
			set @adresa = 'infratirii 3/11A'
			set @data_nasterii = '10/10/2003';
			insert into client(nume,email,nr_tel,adresa,data_nasterii)values
			(@nume,@email,@nr_tel,@adresa,@data_nasterii);
			set @n = @n + 1;
		end
		PRINT 'S-au adaugat' + convert(varchar(10),@NoOfRows)+'valori';
		end
		go
		go

	--pentru abonamente

	drop procedure inserare_test_Abonament;
	go
		create procedure inserare_test_Abonament
		@NoOfRows int 
		as 
		begin
			set nocount on;
			declare @client_id int = (select top 1 c.user_id from client c);
			declare @pachet_id int = (select top 1 p.id_pachet from pachet p);
			declare @inceput datetime;
			declare @sfarsit datetime;
			declare @n int  = 0;
			declare @last_id int = 
			(select MAX(Abonament.id_abonament) from Abonament);


			WHILE @n < @NoOfRows
			begin
				set @last_id = @last_id + 1;
				set @inceput = '10/10/2021';
				set @sfarsit = '10/10/2025';
				insert into Abonament( data_inceput,data_sfarsit,client_id,pachet_id)values
				(@inceput,@sfarsit,@client_id,@pachet_id);	
				set @n = @n + 1;
			end
				print 's-au adaugat'+ convert(varchar(10),@NoOFRows);
		end
		go
		select * from Tables;
		go
	create procedure inserare_test_creare_pachet
	@NoOfRows INT
	as
	begin
		declare @id_pachete int= (select top 1  pc.id_pachete from creare_pachet pc);
		declare @id_service int = (select top 1 pc.id_service from creare_pachet pc);
		declare @pret int = 50;
		declare @n int = 0;
	while @n < @NoOfRows
	begin
		insert into creare_pachet(id_pachete,id_service,pret) values
		(@id_pachete,@id_service,@pret)
		set @pret =@pret + 1;
		set @n = @n + 1;
	end
	print 's-au adaugat' + convert(nvarchar(10),@NoOfRows)+ 'inregistrari';
end
go
use Telecomunicatii
go
select * from Tables;
go
create or alter procedure delete_test_client
as
	begin
	delete from client;
	print 's-au sters' +convert(varchar(10),@@ROWCOUNT) +'clienti';
	end
	go
create or alter procedure delete_test_abonament
as
	begin
	delete from Abonament;
	print 's-au sters' + convert(varchar(10),@@ROWCOUNT) + 'Abonamente';
	end
	go
	CREATE or alter PROCEDURE delete_test_Creare_pachet
	as 
		begin
		
		delete from creare_pachet;
		end
	go
	select * from Tests
	go
	SELECT * FROM TABLES;
	go
	create or alter procedure inserare_test_general
	@idTest int, @idRun int
	as
	begin
		declare @numeTest nvarchar(50) = (select Tests.Name from Tests  WHERE Tests.TestID = @idTest);
		declare @numeTabela NVARCHAR(50);
		declare @NoOfRows int;
		declare @TableID Int;
		declare @procedura NVARCHAR(50);
	
	declare cursorTab CURSOR FORWARD_ONLY FOR
	SELECT Tab.Name,Test.NoOfRows,Tab.TableID FROM TestTables Test
	inner join Tables Tab ON Test.TableID = Tab.TableID
	WHERE Test.TestID = @idTest
	order by Test.Position;
	open cursorTab;
	FETCH NEXT FROM cursorTab into @numeTabela,@NoOfRows,@TableID;
	while(@@FETCH_STATUS=0)
	BEGIN
		set @procedura =  N'inserare_test_'+@numeTabela;
		Declare @start_time DATETIME;
		SET @start_time = GETDATE();
		execute @procedura @NoOfRows;
		declare @end_time DATETIME;
		set @end_time = GETDATE();
		insert into TestRunTables(TestRunID,TableID,StartAt,EndAt) values(@idRun,@TableID,@start_time,@end_time);
		FETCH NEXT FROM cursorTab INTO @numeTabela,@NoOfRows, @TableID;
	end

	close cursorTab;
	DEALLOCATE cursorTab;
	end
	go
	EXECUTE inserare_test_general 1;
	select * from Client;
	GO
	drop procedure stergere_test_general;
create procedure stergere_test_general
@idTest int
as
	begin
		DECLARE @NumeTest nvarchar(50) =(SELECT T.Name from Tests T where T.TestID = @idTest);
		declare @numeTabela nvarchar(50);
		declare @NoOfRows int;
		declare @procedure nvarchar(50);

		declare cursorTab cursor FORWARD_ONLY FOR
			SELECT Tab.Name,Test.NoOfRows FROM TestTables Test
			inner join Tables Tab on Test.TableID = Tab.TableID
			where Test.TestID = @idTest
			ORDER BY Test.Position desc;
			open cursorTab;

			Fetch next from cursorTab into @numeTabela,@NoOfRows;
			while(@@FETCH_STATUS = 0)
			BEGIN 
				set @procedure = N'delete_test_'+@numeTabela;
				execute @procedure;
				fetch next from cursorTab into @numeTabela,@NoOfRows;
			end

		
			close cursorTab;
			deallocate cursorTab;
			end

		go
		execute stergere_test_general 1;
		drop procedure stergere_test_general;
		select * from Client;
		go

		drop procedure view_test_gen;
		create or alter procedure view_test_gen
		@idTest int ,@idRun int
		as
		begin
			--declare @viewName nvarchar(50) = (select V.Name from Views  V 
				--								inner join TestViews TV on TV.ViewID= V.ViewID
					--							WHERE TV.TestID =@idTest);
	--			declare @comanda nvarchar(55) = N'select * from ' + @viewName;
--				execute (@comanda);
			Declare cursortab cursor FORWARD_ONLY FOR
			SELECT Tab.Name,Tab.ViewID from TestViews Test
			INNER JOIN Views Tab on Test.ViewID = Tab.ViewID
			WHERE Test.TestID=@idTest;
			OPEN cursortab;

			DECLARE @nume_view as varchar(50);
			declare @id_view as int;
			fetch next from cursortab into @nume_view,@id_view;
			while @@FETCH_STATUS = 0
			BEGIN
				declare @comanda nvarchar(55) =N'SELECT * FROM ' + @nume_view;
				INSERT INTO TestRunViews(TestRunID,ViewID,StartAt,EndAt) values(@idRun,@id_view,GETDATE(),GETDATE());
				EXECUTE (@comanda);
				Update TestRunViews set EndAt = GETDATE() WHERE (TestRunID = @idRun and ViewID = @id_view);
				FETCH NEXT FROM cursortab into @nume_view,@id_view;
				end
				close cursortab;
				deallocate cursortab;
			end
			go
			execute view_test_gen 1;
			go
			drop procedure run_test
			go
		create or alter procedure run_test
		@idTest int 
		as 
		begin
			declare @startTime DATETIME;
			declare @interTime DATETIME;
			declare @endTime DATETIME;
			declare @tabe_temporar TABLE(ID INT);
			SET @startTime = GETDATE();
			SET @endTime = GETDATE();

			execute stergere_test_general @idTest;
			--execute inserare_test_general @idTest;

			--set @interTime = GETDATE();

			--execute view_test_gen @idTest;
			--set @endTime = GETDATE();

			Declare @testName nvarchar(50) = 
			(select T.Name from Tests T where T.TestID =@idTest);
			insert into TestRuns
			output INSERTED.TestRunID INTO @tabe_temporar
			 Values(@testName,@startTime,@endTime);
			 DECLARE @IDRun int;
			 select @IDRun = ID from @tabe_temporar;
			 execute  inserare_test_general @idTest, @IDRun;
			 execute view_test_gen @idTest,@IDRun;
			 update TestRuns set EndAt = GETDATE() WHERE TestRunID = @idRun;
			--declare @viewID int = (select V.ViewID from Views V 
			--inner join TestViews TV on TV.ViewID =V.ViewID 
			--WHERE TV.TestID =@idTest);
			--DECLARE @tableID INT =
		--(SELECT TB.TableID FROM Tests T
		--INNER JOIN TestTables TT ON T.TestID = TT.TestID
		--INNER JOIN Tables TB ON TB.TableID = TT.TableID
		--WHERE T.TestID = @idTest and 
		--.Name like '%' + TB.Name + '%');
			--declare @testRunID  int =(select top 1 T.TestRunID from TestRuns T
			--where T.Description = @testName
			--ORDER BY T.TestRunID DESC);
			--INSERT INTO TestRunTables VALUES (@testRunID, @tableID, @startTime, @interTime);
			--INSERT INTO TestRunViews VALUES (@testRunID, @viewID, @interTime, @endTime);

				PRINT CHAR(10) + '***TEST COMPLETAT CU SUCCES IN ' + 
		 CONVERT(VARCHAR(10), DATEDIFF(millisecond, @startTime, @endTime)) +
		 ' milisecunde.***'
END
GO
SELECT * FROM TestRuns;
delete from TestRuns;


EXECUTE run_test 1;


use Telecomunicatii;
SELECT * FROM Tables;
SELECT * FROM TestRuns;
SELECT * FROM TestRunTables;
SELECT * FROM TestRunViews;
SELECT * FROM Tests;
SELECT * FROM TestTables;

SELECT * FROM TestViews;
SELECT * FROM Views;



DELETE FROM Tables;
		

	



