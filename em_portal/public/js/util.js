/*******************************************************************************
' Nome........: stopDrawing
' Objetivo....: 
' 
' Entrada.....: string
' Observação..:
' Atualizações: [01]   Data: 27/06/2016 13:10   Autor: Paulo Mann
*******************************************************************************/

function stopDrawing(string)
{
  var list = document.getElementsByTagName("a");
  var cancelLink = null;
  for(var i = 0; i < list.length; i++)
  {
    if(list[i].title.localeCompare(string) == 0)
    {
      cancelLink = list[i];
    }
  }
  console.log(cancelLink);
  if(cancelLink)
    cancelLink.click();
}