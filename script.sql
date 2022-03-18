CREATE DATABASE sistema_universidade

USE sistema_universidade
GO

CREATE TABLE ALUNO(
	ra int identity (1,1) not null,
	cpf varchar (14) not null,
	nome varchar(50) not null,
	telefone varchar(14),

	CONSTRAINT PK_ALUNO PRIMARY KEY (ra)
)
GO

CREATE TABLE DISCIPLINA(
	codigo_disciplina int identity not null,
	Nome varchar(50) not null,
	carga_horaria int not null,

	CONSTRAINT PK_DISCIPLINA PRIMARY KEY (codigo_disciplina)
)
GO

CREATE TABLE MATRICULA(
	ra_aluno int not null,
	codigo_disciplina int not null,
	nota1 float not null, 
	nota2 float not null,
	substitutiva float null,
	media float null,
	faltas int not null,
	situacao varchar(30) null,
	carga_horaria int not null,
	semestre int not null,
	ano int not null,


	CONSTRAINT FK_MATRICULA_ALUNO FOREIGN KEY (ra_aluno) REFERENCES ALUNO (ra),
	CONSTRAINT FK_MATRICULA_DISCIPLINA FOREIGN KEY (codigo_disciplina) REFERENCES Disciplina (codigo_disciplina),

	CONSTRAINT PK_MATRICULA PRIMARY KEY	(ra_aluno, codigo_disciplina, semestre, ano),
)
GO
​
-- INSERÇÕES

INSERT INTO ALUNO 
VALUES 
('442.414.158-65', 'Victor Hugo Hernandez', '(16)99715-6357'),
('309.716.971-75', 'Mateus Elias Martins', '(62)98289-9496'),
('383.500.279-16', 'Rafaela Carolina Baptista', '(84)3514-9940'),
('149.448.049-20', 'Yuri Vicente Tomás Santos', '(49)3862-8289'),
('753.054.683-02', 'Fábio Gabriel Kevin Almada', '(22)99230-3280')

INSERT INTO Disciplina
VALUES 
('BANCO DE DADOS 1', 60), 
('BANCO DE DADOS 2', 50), 
('PROGRAMAÇÃO C#', 80), 
('ESTRUTURA DE DADOS', 60)

select * from MATRICULA

DELETE FROM MATRICULA

INSERT INTO MATRICULA (ra_aluno, codigo_disciplina, nota1, nota2, semestre, ano, faltas, carga_horaria)
VALUES 
(8, 1, 5.0, 8.0, 1, 2021, 2, 60),
(9, 1, 5.0, 8.0, 1, 2021, 40, 60),
(10, 1, 1.0, 2.0, 1, 2021, 2, 60),
(11, 1, 3.0, 6.0, 1, 2021, 40, 60)

--trigger
ALTER TRIGGER tr_Calcula_media
ON dbo.MATRICULA
AFTER INSERT
AS
BEGIN

	DECLARE
		@ra_aluno int,
		@codigo_disciplina int,
		@nota1 float,
		@nota2 float,
		@substitutiva float,
		@faltas int,
		@situacao varchar(30), 
		@media float,
		@nova_media float,
		@carga_horaria int
	SELECT
		@ra_aluno = ra_aluno,
		@codigo_disciplina = codigo_disciplina,
		@nota1 = nota1,
		@nota2 = nota2,
		@faltas = faltas,
		@situacao = situacao,
		@carga_horaria = carga_horaria
	FROM MATRICULA

	SET @media = (@nota1 + @nota2) / 2
	UPDATE MATRICULA
	SET media= @media
	WHERE ra_aluno = @ra_aluno AND codigo_disciplina = @codigo_disciplina

	IF (@Media > 5)
	BEGIN
		UPDATE MATRICULA 
		SET situacao = 'Aprovado'
		WHERE ra_aluno = @ra_aluno
	END

	ELSE
		BEGIN
		UPDATE MATRICULA
		SET substitutiva = 6.0
		WHERE ra_aluno = @ra_aluno AND codigo_disciplina = @codigo_disciplina
	END

	SELECT
		@substitutiva = @substitutiva
	FROM MATRICULA

	IF (@nota1 <= @nota2 AND @nota1 < @substitutiva)
	BEGIN
		SET @nova_media = (@substitutiva + @nota2) / 2
		UPDATE MATRICULA
		SET media = @nova_media
		WHERE ra_aluno = @ra_aluno AND codigo_disciplina = @codigo_disciplina
	END
		ELSE IF (@nota2 <= @nota1 AND @nota2 < @substitutiva)
			BEGIN
				SET @nova_media = (@nota1 + @substitutiva) / 2
				UPDATE MATRICULA
				SET media = @nova_media
				WHERE ra_aluno = @ra_aluno AND codigo_disciplina = @codigo_disciplina
			END
				ELSE
				BEGIN
					SET @nova_media = @media
				END

	IF (@nova_media <= 5) 
	BEGIN
		UPDATE MATRICULA
		SET situacao = 'Reprovado por Nota'
		WHERE ra_aluno = @ra_aluno AND codigo_disciplina = @codigo_disciplina
	END

	ELSE IF (@nova_media > 5 AND @faltas < (@carga_horaria*0.25))
		BEGIN
			UPDATE MATRICULA
			SET situacao = 'Aprovado'
			WHERE ra_aluno = @ra_aluno AND codigo_disciplina = @codigo_disciplina
		END
			ELSE 
				BEGIN
					UPDATE MATRICULA
					SET situacao = 'Reprovado por Falta'
					WHERE ra_aluno = @ra_aluno AND codigo_disciplina = @codigo_disciplina
				END
END

--CONSULTAS
Select ALUNO.ra, ALUNO.nome, DISCIPLINA.NOME, MATRICULA.nota1, MATRICULA.nota2, MATRICULA.substitutiva, MATRICULA.media, MATRICULA.faltas, MATRICULA.situacao
FROM Aluno JOIN MATRICULA ON AlUNO.ra = MATRICULA.ra_aluno
			JOIN DISCIPLINA ON DISCIPLINA.codigo_disciplina = MATRICULA.codigo_disciplina
where ano = 2021

Select ALUNO.ra, ALUNO.nome, DISCIPLINA.NOME, MATRICULA.nota1, MATRICULA.nota2, MATRICULA.substitutiva, MATRICULA.media, MATRICULA.faltas, MATRICULA.situacao
FROM Aluno JOIN MATRICULA ON AlUNO.ra = MATRICULA.ra_aluno
			JOIN DISCIPLINA ON DISCIPLINA.codigo_disciplina = MATRICULA.codigo_disciplina
where Aluno.nome = 'Victor Hugo Hernandez' and MATRICULA.semestre = 2

Select ALUNO.ra, ALUNO.nome, DISCIPLINA.NOME, MATRICULA.nota1, MATRICULA.nota2, MATRICULA.substitutiva, MATRICULA.media
FROM Aluno JOIN MATRICULA ON AlUNO.ra = MATRICULA.ra_aluno
			JOIN DISCIPLINA ON DISCIPLINA.codigo_disciplina = MATRICULA.codigo_disciplina
where MATRICULA.media < 5
