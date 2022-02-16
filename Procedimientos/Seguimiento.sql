USE [DB_A72B95_drp]
GO
/****** Object:  StoredProcedure [dbo].[Seguimiento]    Script Date: 15/02/2022 10:29:34 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER  PROCEDURE [dbo].[Seguimiento]
    @Clave nvarchar(100),
    @Identificador nvarchar(150) ,
	@IdIdioma INT = 1 
AS

SELECT 
T.Orden,A.Nombre AS Actividad, E.Nombre  AS [Estatus  Instancia], C.Valor   AS  [Estatus Tarea],  H.FechaInicio, H.FechaTernimacion , H.TiempoActividad, A.TiempoLimite, TiempoActividad-A.TiempoLimite as  ProductividadTiempo, H.Referencia, H.IdUsuario, H.IdEquipo, H.Observacion 
FROM   FlujoTrabajo F WITH (NOLOCK)
INNER  JOIN  FlujoTrabajoTarea T WITH (NOLOCK) ON T.IdFlujoTrabajo=F.IdFlujoTrabajo
LEFT  OUTER  JOIN  FlujoTrabajoInstancia  I WITH (NOLOCK) ON I.IdFlujoTrabajo=T.IdFlujoTrabajo
LEFT  OUTER  JOIN  FlujoTrabajoHistorial H WITH (NOLOCK) ON H.IdInstancia=I.IdInstancia AND  H.IdTarea=T.IdTarea
LEFT  OUTER  JOIN  FlujoTrabajoActividad A  WITH  (NOLOCK) ON A.IdActividad=T.IdActividad
LEFT  OUTER JOIN   FlujoTrabajoEstatus  E WITH  (NOLOCK) ON H.IdEstatus=E.IdEstatus
LEFT  OUTER JOIN  ElementoCatalogo  C WITH (NOLOCK) ON IdCatalogo=7141 AND  C.Id=H.IdEstatusTarea   AND IdIdioma=@IdIdioma 
WHERE  F.Clave=@Clave AND ( I.Identificador=@Identificador  OR I.Identificador  IS NULL )
AND( H.Activo=1 OR H.Activo IS NULL) AND ( A.Activo=1 OR A.Activo IS NULL) 
ORDER BY 1,5
