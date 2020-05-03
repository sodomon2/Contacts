PRAGMA foreign_keys = on;

CREATE TABLE usuarios(
    id_usuario		integer primary key AUTOINCREMENT,
    usuario		varchar(16) not null,       -- usuario es un string
    contrasena		varchar(16) default null,   -- contraseña es un string
    estatus		varchar(1) not null check (estatus in ('f','t')) default 't'
);

CREATE UNIQUE INDEX usuarios_nombre on usuarios (usuario);
CREATE TABLE contactos(
    id_contacto		integer primary key AUTOINCREMENT,
    nombre		varchar(16) not null,     -- nombre es un string
    numero		smallint not null,        -- numero es un entero
    lugar		varchar(16) default null, -- tipo es un string
    fecha_registro	datetime default (datetime('now','localtime'))
);