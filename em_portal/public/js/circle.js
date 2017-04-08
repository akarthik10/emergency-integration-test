/*******************************************************************************
INFORMAÇÕES DE IDENTIFICAÇÃO DA VERSÃO
Versão: 1.0                    Data: 27/06/2016 13:10
Objetivo/Manutenção: 
Autor: Peron Rezende
*******************************************************************************/

/*******************************************************************************
' Nome........: createCircle
' Objetivo....: 
' 
' Entrada.....: radius, color, user
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Peron Rezende
*******************************************************************************/

function createCircle(radius, color, user)
{
  var circle = L.circle(user.getLatLng(), radius, 
  {
    color: color,
    fillColor: color,
    fillOpacity: 0.3
  });
  return circle;
}
