
/****** Object:  StoredProcedure [dbo].[VerEstadisticasFlujoPorVista]    Script Date: 15/02/2022 10:28:21 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER    PROCEDURE   [dbo].[VerEstadisticasFlujoPorVista]
	@Clave nvarchar(100),
	@Variables nvarchar (MAX) ,
	@IdIdioma INT = 1 
AS
    DECLARE  @vista INT = 0 
	DECLARE  @IdFlujo INT = 0 
	DECLARE  @IdTarea INT = 0 
	DECLARE  @IdGrupo  INT = 0 
	DECLARE  @IdSocio INT = 0 
	DECLARE  @Mes INT = 0 

    SELECT  @vista=Valor FROM dbo.ObtenerListaPorNombreValorEspecial (@Variables,'=',',')  WHERE Variable='vista'

    SELECT  @IdFlujo=COUNT(Valor)  FROM dbo.ObtenerListaPorNombreValorEspecial (@Variables,'=',',')  WHERE Variable='IdFlujo'
    SELECT  @IdTarea=COUNT(Valor)  FROM dbo.ObtenerListaPorNombreValorEspecial (@Variables,'=',',')  WHERE Variable='IdTarea'
	SELECT  @IdGrupo=COUNT(Valor) FROM dbo.ObtenerListaPorNombreValorEspecial (@Variables,'=',',')  WHERE Variable='IdGrupo'
    SELECT  @IdSocio=COUNT(Valor)  FROM dbo.ObtenerListaPorNombreValorEspecial (@Variables,'=',',')  WHERE Variable='IdSocio'
    SELECT  @Mes=COUNT(Valor)  FROM dbo.ObtenerListaPorNombreValorEspecial (@Variables,'=',',')  WHERE Variable='Mes'

	PRINT  ( @vista)
	PRINT  ( @IdFlujo)
	PRINT  ( @IdTarea)
	PRINT  ( @IdGrupo)
	PRINT  ( @IdSocio)
	PRINT  ( @Mes)

	IF @vista=1 OR @vista='' OR @vista is  null -- 'tarea'
	   --- por tarea 
	    SELECT CONVERT(INT,H.IdTarea) as id  , CONVERT( nvarchar (MAX),A.Clave) AS  clave , A.Nombre AS concepto, count(*) as cuenta , ISNULL( SUM( CONVERT(int , I.importe / 1000 ) ),0) as importe 
		FROM  FlujoTrabajo F WITH (NOLOCK)
		INNER  JOIN  FlujoTrabajoHistorial  H WITH (NOLOCK) ON F.IdFlujoTrabajo=H.IdFlujoTrabajo 
		INNER  JOIN FlujoTrabajoInstancia  I WITH (NOLOCK) ON I.IdInstancia=H.IdInstancia
		LEFT  OUTER  JOIN  FlujoTrabajoActividad A  WITH  (NOLOCK) ON  A.IdActividad=H.IdActividad
		--LEFT  OUTER  JOIN  FlujoTrabajoEstatus  E WITH  (NOLOCK) ON E.IdEstatus=I.IdEstatus
		INNER  JOIN  FlujoTrabajoTarea T WITH (NOLOCK) ON T.IdTarea=H.IdTarea 

	    LEFT  JOIN  Cliente  C WITH (NOLOCK) ON C.Id=I.Numero
		LEFT  JOIN  CuentaUsuario  U  WITH (NOLOCK) ON U.IdUsuario=C.idSocio 
		LEFT  JOIN  Persona P  WITH (NOLOCK) ON P.IdUsuario=U.IdUsuario
		LEFT  JOIN  Grupo  G  WITH (NOLOCK) ON G.IdGrupo=U.grupos			
		LEFT  JOIN  Suscripcion  S  WITH (NOLOCK) ON S.IdSuscriptor=C.idSuscriptor	

		--WHERE  ( F.Clave=@Clave  OR  @Clave='' )
		 /*   AND H.IdEstatusTarea in ('0', '1', '2') */
		WHERE /* F.Clave=@Clave   AND */ H.IdEstatusTarea in ('0', '1', '2')  
		AND   (F.IdFlujoTrabajo  IN  (SELECT  CONVERT(INT,Valor) FROM dbo.ObtenerListaPorNombreValorEspecial (@Variables,'=',',')  WHERE Variable='IdFlujo' )  OR @IdFlujo =0 )
		AND (
			( H.IdTarea IN  (SELECT  CONVERT(INT,Valor) FROM dbo.ObtenerListaPorNombreValorEspecial (@Variables,'=',',')  WHERE Variable='IdTarea' )  AND @IdTarea >0 )
			OR (  G.IdGrupo IN  (SELECT  CONVERT(INT,Valor) FROM dbo.ObtenerListaPorNombreValorEspecial (@Variables,'=',',')  WHERE Variable='IdGrupo' ) AND @IdGrupo>0 )
			OR (  C.idSocio IN  (SELECT  CONVERT(INT,Valor) FROM dbo.ObtenerListaPorNombreValorEspecial (@Variables,'=',',')  WHERE Variable='IdSocio' ) AND @IdSocio >0)
			OR (  DATEPART(mm,isnull( H.fechaInicio ,H.fecharegistro))  IN  (SELECT  CONVERT(INT,Valor) FROM dbo.ObtenerListaPorNombreValorEspecial (@Variables,'=',',')  WHERE Variable='Tiempo' ) AND @Mes >0)
			OR (  @IdTarea=0  AND @IdGrupo=0 AND @IdSocio =0 AND @Mes =0   )
		)
		GROUP BY H.IdTarea,A.Clave, A.Nombre 
	ELSE IF @vista=2 ---'grupo'

	   --- por GRUPO 
	    SELECT CONVERT(INT,G.IdGrupo) as id , CONVERT( nvarchar (MAX),G.Nombre)  AS  clave , G.Nombre AS concepto, count(*) as cuenta ,  ISNULL( SUM( CONVERT(int , I.importe / 1000 ) ),0) as importe 
		FROM  FlujoTrabajo F WITH (NOLOCK)
		INNER  JOIN  FlujoTrabajoHistorial  H WITH (NOLOCK) ON F.IdFlujoTrabajo=H.IdFlujoTrabajo 
		INNER  JOIN FlujoTrabajoInstancia  I WITH (NOLOCK) ON I.IdInstancia=H.IdInstancia
		LEFT  OUTER  JOIN  FlujoTrabajoActividad A  WITH  (NOLOCK) ON  A.IdActividad=H.IdActividad
		--LEFT  OUTER  JOIN  FlujoTrabajoEstatus  E WITH  (NOLOCK) ON E.IdEstatus=I.IdEstatus
		INNER  JOIN  FlujoTrabajoTarea T WITH (NOLOCK) ON T.IdTarea=H.IdTarea 

	    LEFT  JOIN  Cliente  C WITH (NOLOCK) ON C.Id=I.Numero
		LEFT  JOIN  CuentaUsuario  U  WITH (NOLOCK) ON U.IdUsuario=C.idSocio 
		LEFT  JOIN  Persona P  WITH (NOLOCK) ON P.IdUsuario=U.IdUsuario
		LEFT  JOIN  Grupo  G  WITH (NOLOCK) ON G.IdGrupo=U.grupos			
		LEFT  JOIN  Suscripcion  S  WITH (NOLOCK) ON S.IdSuscriptor=C.idSuscriptor	
		WHERE /* F.Clave=@Clave   AND */ H.IdEstatusTarea in ('0', '1', '2')  
		AND   (F.IdFlujoTrabajo  IN  (SELECT  CONVERT(INT,Valor) FROM dbo.ObtenerListaPorNombreValorEspecial (@Variables,'=',',')  WHERE Variable='IdFlujo' )  OR @IdFlujo =0 )
		AND (
			( H.IdTarea IN  (SELECT  CONVERT(INT,Valor) FROM dbo.ObtenerListaPorNombreValorEspecial (@Variables,'=',',')  WHERE Variable='IdTarea' )  AND @IdTarea >0 )
			OR (  G.IdGrupo IN  (SELECT  CONVERT(INT,Valor) FROM dbo.ObtenerListaPorNombreValorEspecial (@Variables,'=',',')  WHERE Variable='IdGrupo' ) AND @IdGrupo>0 )
			OR (  C.idSocio IN  (SELECT  CONVERT(INT,Valor) FROM dbo.ObtenerListaPorNombreValorEspecial (@Variables,'=',',')  WHERE Variable='IdSocio' ) AND @IdSocio >0)
			OR (  DATEPART(mm,isnull( H.fechaInicio ,H.fecharegistro))  IN  (SELECT  CONVERT(INT,Valor) FROM dbo.ObtenerListaPorNombreValorEspecial (@Variables,'=',',')  WHERE Variable='Tiempo' ) AND @Mes >0)
			OR (  @IdTarea=0  AND @IdGrupo=0 AND @IdSocio =0 AND @Mes =0   )
		)
		GROUP BY G.IdGrupo,G.Nombre	
	ELSE IF @vista=3 --- 'socio'
	   --- por soco 
	    SELECT   CONVERT(INT,U.IdUsuario) as id , CONVERT( nvarchar (MAX),U.Cuenta)  AS  clave  , P.Nombre AS concepto, count(*) as cuenta , ISNULL( SUM( CONVERT(int , I.importe / 1000 ) ),0) as importe 
		FROM  FlujoTrabajo F WITH (NOLOCK)
		INNER  JOIN  FlujoTrabajoHistorial  H WITH (NOLOCK) ON F.IdFlujoTrabajo=H.IdFlujoTrabajo 
		INNER  JOIN FlujoTrabajoInstancia  I WITH (NOLOCK) ON I.IdInstancia=H.IdInstancia
		LEFT  OUTER  JOIN  FlujoTrabajoActividad A  WITH  (NOLOCK) ON  A.IdActividad=H.IdActividad
		--LEFT  OUTER  JOIN  FlujoTrabajoEstatus  E WITH  (NOLOCK) ON E.IdEstatus=I.IdEstatus
		INNER  JOIN  FlujoTrabajoTarea T WITH (NOLOCK) ON T.IdTarea=H.IdTarea 

		--LEFT  OUTER  JOIN  Persona  P  WITH (NOLOCK) ON P.Id=I.Numero
	 --   LEFT  OUTER   JOIN  Suscripcion  S  WITH (NOLOCK) ON S.id=P.idSuscriptor
		--lEFT  OUTER   JOIN  Usuario  U  WITH (NOLOCK) ON U.idSuscriptor=P.idSuscriptor   
		--LEFT  OUTER   JOIN  Grupo  G  WITH (NOLOCK) ON G.id=U.grupos  	

		LEFT  JOIN  Cliente  C WITH (NOLOCK) ON C.Id=I.Numero
		LEFT  JOIN  CuentaUsuario  U  WITH (NOLOCK) ON U.IdUsuario=C.idSocio 
		LEFT  JOIN  Persona P  WITH (NOLOCK) ON P.IdUsuario=U.IdUsuario
		LEFT  JOIN  Grupo  G  WITH (NOLOCK) ON G.IdGrupo=U.grupos			
		LEFT  JOIN  Suscripcion  S  WITH (NOLOCK) ON S.IdSuscriptor=C.idSuscriptor

		WHERE /* F.Clave=@Clave   AND */ H.IdEstatusTarea in ('0', '1', '2')  
		AND   (F.IdFlujoTrabajo  IN  (SELECT  CONVERT(INT,Valor) FROM dbo.ObtenerListaPorNombreValorEspecial (@Variables,'=',',')  WHERE Variable='IdFlujo' )  OR @IdFlujo =0 )
		AND (
			( H.IdTarea IN  (SELECT  CONVERT(INT,Valor) FROM dbo.ObtenerListaPorNombreValorEspecial (@Variables,'=',',')  WHERE Variable='IdTarea' )  AND @IdTarea >0 )
			OR (  G.IdGrupo IN  (SELECT  CONVERT(INT,Valor) FROM dbo.ObtenerListaPorNombreValorEspecial (@Variables,'=',',')  WHERE Variable='IdGrupo' ) AND @IdGrupo>0 )
			OR (  C.idSocio IN  (SELECT  CONVERT(INT,Valor) FROM dbo.ObtenerListaPorNombreValorEspecial (@Variables,'=',',')  WHERE Variable='IdSocio' ) AND @IdSocio >0)
			OR (  DATEPART(mm,isnull( H.fechaInicio ,H.fecharegistro))  IN  (SELECT  CONVERT(INT,Valor) FROM dbo.ObtenerListaPorNombreValorEspecial (@Variables,'=',',')  WHERE Variable='Tiempo' ) AND @Mes >0)
			OR (  @IdTarea=0  AND @IdGrupo=0 AND @IdSocio =0 AND @Mes =0   )
		)
		GROUP BY U.IdUsuario,U.Cuenta,P.Nombre
	ELSE IF @vista=4 --- 'tiempo'

	    SELECT CONVERT(INT,DATEPART(mm,isnull( H.fechaInicio ,H.fecharegistro)))  as id,CONVERT( nvarchar (MAX),DATEPART(mm,isnull( H.fechaInicio ,H.fecharegistro))) as clave , CONVERT( nvarchar (MAX),DATEPART(mm,isnull( H.fechaInicio ,H.fecharegistro))) AS concepto, count(*) as cuenta ,  ISNULL( SUM( CONVERT(int , I.importe / 1000 ) ),0) as importe 
		FROM  FlujoTrabajo F WITH (NOLOCK)
		INNER  JOIN  FlujoTrabajoHistorial  H WITH (NOLOCK) ON F.IdFlujoTrabajo=H.IdFlujoTrabajo 
		INNER  JOIN FlujoTrabajoInstancia  I WITH (NOLOCK) ON I.IdInstancia=H.IdInstancia
		LEFT  OUTER  JOIN  FlujoTrabajoActividad A  WITH  (NOLOCK) ON  A.IdActividad=H.IdActividad
		--LEFT  OUTER  JOIN  FlujoTrabajoEstatus  E WITH  (NOLOCK) ON E.IdEstatus=I.IdEstatus
		INNER  JOIN  FlujoTrabajoTarea T WITH (NOLOCK) ON T.IdTarea=H.IdTarea 

	    LEFT  JOIN  Cliente  C WITH (NOLOCK) ON C.Id=I.Numero
		LEFT  JOIN  CuentaUsuario  U  WITH (NOLOCK) ON U.IdUsuario=C.idSocio 
		LEFT  JOIN  Persona P  WITH (NOLOCK) ON P.IdUsuario=U.IdUsuario
		LEFT  JOIN  Grupo  G  WITH (NOLOCK) ON G.IdGrupo=U.grupos			
		LEFT  JOIN  Suscripcion  S  WITH (NOLOCK) ON S.IdSuscriptor=C.idSuscriptor	
		WHERE /* F.Clave=@Clave   AND */ H.IdEstatusTarea in ('0', '1', '2')  
		AND   (F.IdFlujoTrabajo  IN  (SELECT  CONVERT(INT,Valor) FROM dbo.ObtenerListaPorNombreValorEspecial (@Variables,'=',',')  WHERE Variable='IdFlujo' )  OR @IdFlujo =0 )
		AND (
			( H.IdTarea IN  (SELECT  CONVERT(INT,Valor) FROM dbo.ObtenerListaPorNombreValorEspecial (@Variables,'=',',')  WHERE Variable='IdTarea' )  AND @IdTarea >0 )
			OR (  G.IdGrupo IN  (SELECT  CONVERT(INT,Valor) FROM dbo.ObtenerListaPorNombreValorEspecial (@Variables,'=',',')  WHERE Variable='IdGrupo' ) AND @IdGrupo>0 )
			OR (  C.idSocio IN  (SELECT  CONVERT(INT,Valor) FROM dbo.ObtenerListaPorNombreValorEspecial (@Variables,'=',',')  WHERE Variable='IdSocio' ) AND @IdSocio >0)
			OR (  DATEPART(mm,isnull( H.fechaInicio ,H.fecharegistro))  IN  (SELECT  CONVERT(INT,Valor) FROM dbo.ObtenerListaPorNombreValorEspecial (@Variables,'=',',')  WHERE Variable='Tiempo' ) AND @Mes >0)
			OR (  @IdTarea=0  AND @IdGrupo=0 AND @IdSocio =0 AND @Mes =0   )
		)
		GROUP BY DATEPART(mm,isnull( H.fechaInicio ,H.fecharegistro))


