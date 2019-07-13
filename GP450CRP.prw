#include "rwmake.ch"
/*
+----------+----------+-------+-------------------------+------+--------+
|Programa  | GP450CRP | Autor | Luana                   | Data |17.11.11|
+----------+----------+-------+-------------------------+------+--------+
|Descricao |P.E para mudar sequenciamento para sispag de liquidos do gpe|
+----------+------------------------------------------------------------+
| Uso      | MP10                                                       |
+-----------------------------------------------------------------------+
|           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            |
+------------+--------+-------------------------------------------------+
|PROGRAMADOR | DATA   | MOTIVO DA ALTERACAO                             |
+------------+--------+-------------------------------------------------+
+------------+--------+-------------------------------------------------+
*/
User Function GP450CRP()

Local cSeqAtu:=GetMv("MV_SQSPAG")
Local cSeqNew

cSeqNew:=cSeqAtu + 1

PutMv("MV_SQSPAG",cSeqNew)



MsgBox(OemToAnsi("A Sequência do Arquivo foi " + cValtoChar(cSeqAtu) + ", o contador automático foi atualizado para " + cValtoChar(cSeqNew) + "!"),OemToAnsi("Seq.SISPAG"),"INFO")

return()