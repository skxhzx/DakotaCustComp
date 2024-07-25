/*------------------------------------------------------------------*/
/*  Spanish Version                                                 */
/*  Message ID's should be identical to POMSGD                      */
/*------------------------------------------------------------------*/
/*                                                                  */
/*  POMSGD      Create PIRMSGF Message Descriptions POpppnn         */
/*                 where ppp = Program number (ie 110)              */
/*                       nn  = Error message id (01-99)             */
/*              Receiving error messages                            */
/*                                                                  */
/*  15 February 1993                                                */
/*  Dave Sommerville                                                */
/*  02/19/98  RH  4.09  Add PO23601 message.                        */
/*  12/07/98  RH  4.10  Add PO14404 message.                        */
/*  10/11/99  DAS 4.13  Add PO14405 message.                        */
/*  10/16/00  DAS 4.14  Add PO11001 message.                        */
/*  12/15/00  HNK 4.15  Add PO11402 message.                        */
/*  03/06/01  RH  4.15a Add PO13229 message.                        */
/*  09/24/01  DAS 4.16  Revised MSG of PO13228 and PO13229.         */
/*                      Added identifier to end of message.         */
/*  09/24/01  DAS 4.16  Add PO13230 message.                        */
/*                      Add PO13231 message.                        */
/*                      Add PO13232 message.                        */
/*                      Add PO13233 message.                        */
/*                                                                  */
/*  10/06/01  DAS 4.16a Add PO13234 message.                        */
/*  12/01/01  MLB 4.16  Add PO13235 message.                        */
/*                      Add PO13236 message.                        */
/*                      Add PO13237 message.                        */
/*                      Add PO13238 message.                        */
/*                      Add PO13239 message.                        */
/*                      Add PO13240 message.                        */
/*                      Add PO13241 message.                        */
/*                                                                  */
/*  02/14/03  MLB 4.17  Add PO13242 message.                        */
/*  04/02/03  MLB 4.17a Add PO13243 message.                        */
/*  04/03/03  MLB 4.17a Add PO13244 message.                        */
/*  04/03/03  MLB 4.17a Add PO13245 message.                        */
/*  04/03/03  MLB 4.17a Add PO13246 message.                        */
/*  04/09/03  RH  4.17b Add PO20035 message.                        */
/*  05/27/03  RH  4.17c Add PO23201 message.                        */
/*  01/06/04  RH  4.17d Add PO20036 message.                        */
/*  06/29/04  MLB 4.17e Add PO13247 message.                        */
/*                                                                  */
/*  11/10/04  MLB 5.00  Replaced msg text on message id's with      */
/*                      correct msg text on PO13230-PO13234.        */
/*                      Added new msgid: PO13248.                   */
/*  09/24/01  DAS 5.00  Original change was V4.16 missed in update  */
/*                      Revised MSG of PO13228 and PO13229.         */
/*                      Added identifier to end of message.         */
/*  10/21/05  DAS 5.00  Added PO11003, PO11004, PO12001 and PO12002.*/
/*  05/24/06  DAS 5.00  Changed &MSGF to PIRMSGSP                   */
/*                                                                  */
/*  10/09/07  MLB 5.10b Add PO13249 message.                        */
/*  01/13/08  LMC 5.10C Add PO13250 message.                        */
/*                                                                  */
/*  05/08/17  MLB 7.10  Add PO23215 message.                        */
/*                                                                  */
/*------------------------------------------------------------------*/

             PGM        PARM(&OPT)

             DCL        VAR(&MSGID) TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGF) TYPE(*CHAR) LEN(10) VALUE(PIRMSGFSP)
             DCL        VAR(&MSGFLIB) TYPE(*CHAR) LEN(10) +
                        VALUE('*LIBL')
             DCL        VAR(&OPT) TYPE(*CHAR) LEN(7)
             DCL        VAR(&STATMSG) TYPE(*CHAR) LEN(128)
             DCL        VAR(&CREATE) TYPE(*CHAR) LEN(8) VALUE('Creating')

/*  PO11001 Cannot mark PO for export. Detail lines not marked. */

             CHGVAR     VAR(&MSGID) VALUE('PO11001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No puede marcar PO para exportar-
                          Algunas lineas de detalles no marcadas.') +
                          SECLVL('''Causa . . . . . :   Un PO no +
                          puede ser marcado para exportar hasta todas +
                          las lineas de detalles son marcadas. &N +
                          Recobro . . . :   Trabaje con el detalle +
                          del PO y tenga cuidado que todas las lineas +
                          son marcadas. Algunas que no son marcadas +
                          pueden ser marcadas por recibirlas o por +
                          usar la opcion ''X'' para marcar a mano las +
                          lineas que no fueron recibidas.''') SEV(30)
             ENDDO

/*  PO11001 Cannot mark PO for export. Detail lines not marked. */

             CHGVAR     VAR(&MSGID) VALUE('PO11001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No puede marcar PO <exportar>; unas +
                          lineas de detalles no son marcadas.') +
                          SECLVL('''Causa . . . . . :   Un PO no +
                          puede ser marcado <exportar> hasta que +
                          todas las lineas esten marcadas. &N Recobro  . . +
                          . :   Trabaje con el detalle de PO y este +
                          seguro que todas las lineas han sido marcadas. +
                          Los que no son marcadas pueden ser marcadas +
                          por recibirlas o por usar la opcion ''x'' +
                          para marcarlas manualmente los que no +
                          fueron recibidas.''') SEV(30)
             ENDDO

/*  PO11002 Cannot mark PO for export. Lumper info not entered. */

             CHGVAR     VAR(&MSGID) VALUE('PO11002')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No puede marcar PO <exportar>. No +
                          incorporo info de Lumper.') SECLVL('Causa . . . . +
                          . :   Un PO no puede ser marcado <exportar> +
                          hasta que incorpore info de Lumper. &N +
                          Recobro  . . . :   Tome opcion 15 e incorpore +
                          la informacion de Lumper.') SEV(30)
             ENDDO

/*  PO11003 HACCP info not allowed for PO */

             CHGVAR     VAR(&MSGID) VALUE('PO11003')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No se permite info de HACCP de &1') +
                          SECLVL('Causa . . . . . :   Ninguno de los +
                          productos de PO &1 permiten incorporar +
                          informacion de HACCP. &N Recobro  . . . :   +
                          Identifique el producto que permitira` +
                          informacion de HACCP y cambie la categoria +
                          del producto a una que permite incorporar +
                          informacion de HACCP.') SEV(30) +
                          FMT((*CHAR 9))
             ENDDO

/*  PO11004 HACCP info must be entered before receiving item */

             CHGVAR     VAR(&MSGID) VALUE('PO11004')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Hay que incorporar informacion de HACCP +
                          antes de trabajar con detalle.') SECLVL('Causa +
                          . . . . . : No incorporo informacion de +
                          HACCP de PO &1. Sin embargo, la categoria +
                          del producto &2 requiere que incorpore +
                          informacion de HACCP del PO.  &N Recobro  . . +
                          . :   Incorpore la informacion de HACCP o +
                          cambie la categoria del producto &2. ') +
                          SEV(30) FMT((*CHAR 9) (*CHAR 15))
             ENDDO

/*  PO11401 Cannot delete PO marked as 'Ready for export'. */

             CHGVAR     VAR(&MSGID) VALUE('PO11401')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No puede borrar un PO que esta listo +
                          para exportar.') SECLVL('Causa . . . . . +
                          :   Este PO es marcado como Listo para +
                          exportar. &N Recobro . . . :   Demarque el +
                          PO e intente otra vez.') SEV(30)
             ENDDO

/*  PO11402 Cannot delete PO - Some items received.        */

             CHGVAR     VAR(&MSGID) VALUE('PO11402')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No puede borrar PO - algunos productos +
                          recibidos.') SECLVL('Cause . . . . . :   +
                          Algunos productos ya recibidos por este PO +
                          &N Recobro  . . . :   Establezca contacto +
                          con el director de DP.') SEV(30)
             ENDDO

/*  PO11621 Printing receiving document for P.O. */

             CHGVAR     VAR(&MSGID) VALUE('PO11621')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Imprimiendo documento de recibir +
                          del PO &1.') SEV(00) FMT((*DEC 9 0))
             ENDDO

/*  PO12001 HACCP info not allowed for item */

             CHGVAR     VAR(&MSGID) VALUE('PO12001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No se permite info de HACCP de &1') +
                          SECLVL('Causa . . . . . :   La categoria +
                          de producto &1 no permite incorporar +
                          informacion de HACCP. &N Recobro  . +
                          . . :   Cambie la informacion de categoria +
                          de producto &1.') SEV(30) FMT((*CHAR 15))
             ENDDO

/*  PO12002 HACCP info must be entered before receiving item */

             CHGVAR     VAR(&MSGID) VALUE('PO12002')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Hay que incorporar info de HACCP antes de +
                          recibir producto.') SECLVL('Causa . . . . . +
                          :   No incorporo informacion de HACCP de +
                          producto &1, pero la categoria de producto +
                          &1 identifica que hay que incorporar la +
                          informacion de HACCP antes de recibir. +
                          &N Recobro  . . . :   Incorpore la +
                          informacion de HACCP antes de recibir +
                          o cambie la categoria del producto. +
                          ') SEV(30) FMT((*CHAR 15))
             ENDDO

/*  PO12003 HACCP HDR info must be entered before receiving item */

             CHGVAR     VAR(&MSGID) VALUE('PO12003')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Hay que incorporar informacion principal +
                          de HACCP antes de recibir producto.') SECLVL+
                          ('Causa. . . . . :  No ha incorporado la +
                          informacion principal de HACCP por la categoria +
                          de 1 o mas productos de PO &1.  &N Recobro +
                          . . . :  Use Opcion 11 para incorporar la +
                          informacion principal de HACCP por la +
                          categoria del producto o use la opcion Item +
                          Category Maintenance para fijar el Flag de +
                          informacion principal a ''No'' antes de +
                          recibir el producto.') SEV(30) FMT((*CHAR 15))
             ENDDO

/*  PO12221 Special order already exists for this item. */

             CHGVAR     VAR(&MSGID) VALUE('PO12221')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          producto existe actualmente como un pedido +
                          especial.') SECLVL('Causa . . . . . :  Este +
                          producto ha sido definido ya como un pedido +
                          especial. &N Recobro . . . :   Incorpore un +
                          producto que no es un pedido especial o +
                          remueva el pedido especial que hay.') SEV(30)
             ENDDO

/*  PO12401 Cannot delete a line, if some qty received.    */

             CHGVAR     VAR(&MSGID) VALUE('PO12401')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No puede borrar una linea si alguna +
                          cantidad es recibida.') SECLVL('Causa . . +
                          . . . :   La cantidad ha sido recibido por +
                          este producto. &N Recobro . . . :   No hay +
                          recobro.') SEV(30)
             ENDDO

/*  PO13212 Item and slot types do not match. */

             CHGVAR     VAR(&MSGID) VALUE('PO13212')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Los +
                          tipos de producto y slot no corresponden.') +
                          SECLVL('Causa . . . . . :   Un producto +
                          solamente puede ser guardado en un slot que +
                          es de lo mismo tipo (PIR/Fixed). Este tipo +
                          de producto (&1) no corresponde al tipo de +
                          slot (&)2. &N Recobro  . . . :   Seleccione +
                          un slot que es de lo mismo tipo que el +
                          producto.') SEV(30) +
                          FMT((*CHAR 5) (*CHAR 5))
             ENDDO

/*  PO13214 Fixed slot is reserved for a different item. */

             CHGVAR     VAR(&MSGID) VALUE('PO13214')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Slot fijo es reservado por producto +
                          &1.') SECLVL('Causa . . . . . :   El slot +
                          incorporado es reservado por un producto +
                          differente (&1). &N Recobro . . . :   +
                          Seleccione un slot vacio o un slot que no +
                          esta ocupado ya por el producto &1.') +
                          SEV(30) FMT((*CHAR 15))
             ENDDO

/*  PO13221 Slot is already occupied with a different item. */

             CHGVAR     VAR(&MSGID) VALUE('PO13221')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          slot ya esta ocupado por producto diferente+
                          .') SECLVL('Causa . . . . . :   El slot +
                          incorporado ya continene el producto &1. +
                          &N Recobro . . . :   Incorpore un slot +
                          differente o usa el programa de ajustar el +
                          inventario para vaciar el slot.') +
                          SEV(30) FMT((*CHAR 15))
             ENDDO

/*  PO13222 This item has already been received in full. */

             CHGVAR     VAR(&MSGID) VALUE('PO13222')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Todo +
                          este producto ha sido recibido ya.') +
                          SECLVL('Causa . . . . . :   La cantidad +
                          recibida por este producto es mas grande +
                          que o tan grande como la cantidad pedida. +
                          &N Recobro . . . :   Verifique que no +
                          duplica una incorporacion anterior y luego +
                          incorpore la cantidad recibida.') SEV(00)
             ENDDO

/*  PO13223  Total quantity received is greater than qty ordered. */

             CHGVAR     VAR(&MSGID) VALUE('PO13223')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Aviso: El total de cantidad recibida +
                          es mas grande que la cantidad pedida.') +
                          SECLVL('Causa . . . . . :   El total de la +
                          cantidad recibida (&1) es mas grande que la +
                          cantidad ordenada (&2). &N Recobro  . . . +
                          :   Este es solamente un aviso, accion no +
                          es necesario.') SEV(00) FMT((*DEC 5 0) +
                          (*DEC 5 0))
             ENDDO

/*  PO13224  Slot does not exist within entered department. */

             CHGVAR     VAR(&MSGID) VALUE('PO13224')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La combinacion de departamento y slot +
                          no existe.') SECLVL('Causa . . . . . :   El +
                          numero de slot incorporado no existe en el +
                          departamento incorporado. &N Recobro  . . +
                          . :   Incorpore la combinacion correcta del +
                          departamento y slot.') SEV(30)
             ENDDO

/*  PO13225 Item and slot designation areas do not match */

             CHGVAR     VAR(&MSGID) VALUE('PO13225')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Las +
                          areas designadas de producto y slot no +
                          corresponden.') SECLVL('Causa . . . . . :   +
                          Un producto solamente puede ser guardado en +
                          un slot con una area designada +
                          correspondiente. El area designada para el +
                          producto (&1) no corresponde al area +
                          designada para el slot (&2). &N Recobro . . +
                          . :   Seleccione un slot que tiene la misma +
                          area designada como el producto +
                          tiene.') SEV(30) FMT((*CHAR 5) (*CHAR 5))
             ENDDO

/*  PO13226 Cannot receive an item, if PO is 'Ready for export'. */

             CHGVAR     VAR(&MSGID) VALUE('PO13226')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No puede recibir un producto si el PO +
                          esta lista para exportar.') SECLVL('Causa . +
                          . . . . :   Este PO es marcado como listo +
                          para exportar. &N Recobro . . . :   +
                          Demarque el PO e intente otra +
                          vez.') SEV(30)
             ENDDO

/*  PO13227 Slot must be a verified slot or contain item to place item in it. */

             CHGVAR     VAR(&MSGID) VALUE('PO13227')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          slot incorporado para guardar debe ser +
                          verificado antes.') SECLVL('''Causa . . . +
                          . . :   El slot seleccionado tiene un +
                          estado d ''Z''. &N Recobro . . . :   +
                          Verifique el slot e intente otra vez, o +
                          incorpore un slot diferente.''') SEV(30)
             ENDDO

/*  PO13228 Item cannot be accepted.                     */

             CHGVAR     VAR(&MSGID) VALUE('PO13228')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          producto no puede ser aceptado- fecha de +
                          manufactura.') SECLVL('Causa . . . . . :   +
                          El producto tiene una longevidad de +
                          fabricante de (&1) dias. Con una fecha de +
                          manufactura de (&2), el producto expirara +
                          el (&3). La fecha aceptada mas tarde para +
                          recibir es (&4) con tal que el distribudor +
                          necesite &5 dias para vender y el usuario +
                          necesite &6 dias para vender. &N Recobro . +
                          . . :   No reciba el producto. El producto +
                          puede ser recibido por medio de cambiar los +
                          dias de longeividad del fabricante, dias +
                          del usuario, pero el producto necesitara +
                          ser vendido mas +
                          rapido.') SEV(30) FMT((*DEC 3) (*DEC +
                          7) (*DEC 7 0) (*DEC 7 0) (*DEC 3 0) (*DEC +
                          3 0))
             ENDDO

/*  PO13229 Item cannot be accepted. Use by date         */

             CHGVAR     VAR(&MSGID) VALUE('PO13229')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          producto no puede ser aceptado - fecha de +
                          usa antes.') SECLVL('Causa . . . . . :  El +
                          producto tiene una fecha de usa antes de +
                          (&1). El distribuidor necesita &2 dias para +
                          vender y el usuario necesita &3 dias para +
                          vender. El producto debe ser vendido el +
                          (&4). &N Recobro . . . :   No reciba el +
                          producto. El producto puede ser recibido +
                          por medio de cambiar los dias de +
                          distribuidor y los dias de usuario pero el +
                          producto necesitara ser vendido mas +
                          rapido.') SEV(30) FMT((*DEC 7) (*DEC 3 0) +
                          (*DEC 3 0) (*DEC 7 0))
             ENDDO

/*  PO13230 Item cannot be accepted. Expiration date     */

             CHGVAR     VAR(&MSGID) VALUE('PO13230')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          producto no puede ser aceptado- fecha de +
                          expiracion.') SECLVL('Causa . . . . . :   +
                          No puede aceptar un producto que tiene una +
                          fecha de expiracion (&1) mas temprano que +
                          la fecha de expiracion actual de exceso. &N +
                          Recobro . . . :   Ninguno. No puede recibir +
                          el +
                          producto.') SEV(30) FMT((*DEC 9) (*DEC 9 0))
             ENDDO

/*  PO13231 Warning: Ealier expiration date     */

             CHGVAR     VAR(&MSGID) VALUE('PO13231')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Aviso: fecha de experacion mas +
                          temprano. Oprima F20 para pasar sobre.') +
                          SECLVL('Causa . . . . . :   La fecha de +
                          expiracion incorporada (&1) viene antes de +
                          la fecha de expiracion actual de exceso. &N +
                          Recobro . . . :   Oprima F20 para pasar +
                          sobre el aviso y recibir el +
                          producto.') SEV(30) FMT((*DEC 9) +
                          (*DEC 9 0))
             ENDDO

/*  PO13232 Item cannot be accepted. Calculated expiration date */

             CHGVAR     VAR(&MSGID) VALUE('PO13232')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          producto no puede ser aceptado - fecha de +
                          expiracion calculada.') SECLVL('Causa . . +
                          . . . :   No puede aceptar un producto que +
                          tiene una fecha de expiracion (&1) mas +
                          temprano que la fecha de la expiracion de +
                          exceso (&2). La fecha de expiracion fue +
                          calculada con la ecuacion: fecha del +
                          fabricante + longevidad del fabricante - +
                          dias del usuario para vender. &N Recobro . +
                          . . :   Ninguno. No puede recibir el +
                          producto.') SEV(30) +
                          FMT((*DEC 9) (*DEC 9 0))
             ENDDO

/*  PO13233 Warning: Ealier calculated expiration date     */

             CHGVAR     VAR(&MSGID) VALUE('PO13233')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Aviso: Fecha de expiracion calculada +
                          mas temprano. Oprima F20 para pasar +
                          sobre.') SECLVL('Causa . . . . . :   La +
                          fecha de expiracion incorporada (&1) viene +
                          antes de la expiracion actual de exceso +
                          (&2). La fecha de expiracion fue calculada +
                          con la ecuacion: fecha del fabricante + +
                          longevidad del fabricante - dias del +
                          usuario para vender. &N Recobro . . . : +
                          Oprima F20 para pasar sobre el aviso y +
                          recibir el +
                          producto.') SEV(30) FMT((*DEC 9) (*DEC 9 0))
             ENDDO

/*  PO13234 CW must be zero when receiving avg. */

             CHGVAR     VAR(&MSGID) VALUE('PO13234')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          CW debe ser nada cuando determina el +
                          promedio de la incorporacion del CW por +
                          "primera vez solamente".') SECLVL('''Causa +
                          . . . . . :   La opcion del CW recibido es +
                          fija a "primera vez solamente." A causa de +
                          este, cuando la bandera del promedio es +
                          fija a ''Y'', el campo de la incorporacion +
                          de CW debe ser fijo a nada. &N Recobro . . +
                          . :   Cambie la incorporacion de CW a +
                          nada.''') SEV(30)
             ENDDO

/*  Individual p/o-&1 not removed from Super P/O-&2. */

             CHGVAR     VAR(&MSGID) VALUE('PO13235')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El PO individual &1 no fue removido +
                          del super PO-&2.') SECLVL('Causa . . . . . +
                          :   No hay mas informacion. &N Recobro . . +
                          . :   Establezca contacto con el director +
                          de DP.') +
                          SEV(30) FMT((*CHAR 9) (*CHAR 9))
             ENDDO

/*  PO13236 Position to x not found on Super P/O. */

             CHGVAR     VAR(&MSGID) VALUE('PO13236')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La posicion a-&1 &3 no fue encontrdo +
                          en super PO-&2.') SECLVL('Causa . . . . . +
                          :   La posicion a-&1 con un valor de &2 fue +
                          mas que el &1s en el Super PO-&2.  &N +
                          Recobro  . . . :   Cambie la posicion a- +
                          &1 a algo menos que &3 e intente otra +
                          vez.') SEV(30) +
                          FMT((*CHAR 4) (*CHAR 9) (*CHAR 15))
             ENDDO

/*  PO13237 Option 13=Work w/Super P/O not allowed.      */

             CHGVAR     VAR(&MSGID) VALUE('PO13237')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La opcion 13=Trabajar con super PO no +
                          es permitida con los PO individuales.') +
                          SECLVL('Causa . . . . . :   El usuario ha +
                          seleccionado la opcion para trabajar con +
                          el super PO. Esta opcion no es valida por +
                          los PO individuales. Un super PO es +
                          identificado por medio de un numero del PO +
                          empezando con SPxxxxxxx donde x=un numero +
                          unico. &N Recobro . . . :   Remueva la +
                          opcion 13=Trabajar con super PO del PO +
                          individual. Entonces fije a los PO que +
                          empieza con SP e intente otra +
                          vez.') SEV(30) +
                          FMT(*NONE)
             ENDDO

/*  PO13238 Option 8=Mark not allowed for Individual P/O's. */

             CHGVAR     VAR(&MSGID) VALUE('PO13238')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La opcion 8=Marcar para exportar no es +
                          permitida para los PO individuals que son +
                          ajuntados a un super PO.') SECLVL('Causa . +
                          . . . . :   El usuario ha seleccionado un +
                          PO individual para sermarcado para +
                          exportar. No es permitido por los PO que +
                          son ajuntados a un super PO. &N Recobro . . +
                          . :   Remueva la opcion del PO individual y +
                          marque el super PO para exportar. Si el PO +
                          individual necesita ser exportado +
                          inmediatamente, remueva el PO del super PO +
                          e intente otra vez.') +
                          SEV(30) FMT(*NONE)
             ENDDO

/*  PO13239 Option 9=UnMark not allowed for individual P/O's. */

             CHGVAR     VAR(&MSGID) VALUE('PO13239')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La opcion 9=Desmarcar no es permitida +
                          por los PO individuales ajuntados a un +
                          super PO.') SECLVL('Causa . . . . . :  El +
                          usuario ha seleccionado un PO individual +
                          para ser desmarcado. Este no es permitido +
                          por los PO ajuntados a un super P/O. +
                          &N Recobro  . . . :   Remueva esta opcion +
                          del PO individual y entonces desmarque el +
                          super PO. Si este PO no esta listo para +
                          exportar, remuevalo del super PO. Luego +
                          use 9=Desmarcar para proteger el PO de +
                          exportacion hasta esta listo para exportar +
                          Entonces intente otra +
                          vez.') SEV(30) FMT(*NONE)
             ENDDO

/*  PO13240 Option 11=HACCP Info not allowed for Super P/O's. */

             CHGVAR     VAR(&MSGID) VALUE('PO13240')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La informacion de opcion 11=HACCP no +
                          es permitida por el super PO.') +
                          SECLVL('Causa . . . . . :   El usuario ha +
                          seleccionado un super PO para incorporar la +
                          informacion del HACCP. Este no es permitido +
                          por los super PO. &N Recobro . . . Elija +
                          un PO individual que no es en el formato de +
                          SPxxxxxxx donde x=un numero unico. Entonces +
                          intente otra vez.') SEV(30) +
                          FMT(*NONE)
             ENDDO

/*  PO13241 P/O-XXXXXXXXX Removed from Super P/O. */

             CHGVAR     VAR(&MSGID) VALUE('PO13241')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('P/O-&1 removido de super PO-&2 con +
                          exito.') SECLVL('Causa . . . . . :   El +
                          usuario selecciono` un PO individual &1 +
                          para ser removido del super PO-&2. &N +
                          Recobro  . . . :   Si este PO fue removido +
                          en error, entonces use F6=Anadir los PO +
                          individuales para reanadir el PO al super +
                          PO. De otro modo, no necesita hacer +
                          nada.') SEV(00) +
                          FMT((*CHAR 9) (*CHAR 9))
             ENDDO

/*  PO13242 Super P/O at Export status. Additions not allowed. */

             CHGVAR     VAR(&MSGID) VALUE('PO13242')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El super PO &1 marcado para exportar. +
                          Adiciones no permitidas.') SECLVL('Causa . +
                          . . . . :   El usuario selecciono` F6=PO +
                          individual para anadir mas PO individuales +
                          al super PO. El super PO &1 esta al estado +
                          de Listo para exportar y adiciones no son +
                          permitidas. &N Recobro . . . :   El usuario +
                          puede hacer las opciones: 1.) Sale del +
                          super PO nuevo y seleccione un super PO que +
                          no esta al estado de Listo para exportar. +
                          2.) Seleccione la opcion 9=Desmarcar para +
                          este super PO y regresa para anadir los PO +
                          individuales. 3.) Crea un super PO nuevo y +
                          anade los PO individuales al super P/O +
                          nuevo.') SEV(30) FMT((*CHAR 9))
             ENDDO

/*  PO13243 Item cannot be accepted. expiration date # of days out   */

             CHGVAR     VAR(&MSGID) VALUE('PO13243')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          producto no puede ser aceptado - fecha de +
                          expiracion.') SECLVL('Causa . . . . . :   +
                          El producto tiene una fecha de expiracion +
                          de (&1). La fecha no puede ser &2 numero de +
                          dias faltado. &N Recobro . . . :   No +
                          recibe el producto. El producto puede ser +
                          recibido por medio de cambiar el numero de +
                          dias +
                          faltado.') SEV(30) FMT((*DEC 7) (*DEC 3 0))
             ENDDO

/*  PO13244 PO Exception code not entered.                                    */

             CHGVAR     VAR(&MSGID) VALUE('PO13244')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          codigo de excepcion del PO no +
                          incorporado.') SECLVL('Causa . . . . . : El +
                          codigo de excepcion del PO no fue +
                          incorporado con las cantidades de +
                          excepcion. &N Recobro . . . :   Incorpore +
                          un codigo de excepcion valido u oprima +
                          F4=Inicitar para mostrar una lista de +
                          codigos de excepcion validos. Entonces +
                          intente otra vez.') +
                          SEV(30) FMT(*NONE)
             ENDDO

/*  PO13245 PO Exception quantities not entered.                             */

             CHGVAR     VAR(&MSGID) VALUE('PO13245')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('La +
                          cantidad de excepcion de PO no incorporado +
                          con codigo de excepcion &1.') SECLVL('Causa +
                          . . . . . :   Ningunas cantidades fueron +
                          incorporadas con un codigo de excepcion de +
                          PO &1. &N Recobro . . . :   Incorpore las +
                          cantidades positivas con un codigo de +
                          excepcion valida. Entonces intente otra +
                          vez.') SEV(30) FMT((*CHAR 2))
             ENDDO

/*  PO13246 Total quantity is greater than quantity ordered.                 */

             CHGVAR     VAR(&MSGID) VALUE('PO13246')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La cantidad total &1.&2.&3 es mas +
                          grande que la cantidad pedida &4.&5.&6.') +
                          SECLVL('Causa . . . . . :   El usuario ha +
                          incorporado un cantidad total que es mas +
                          grande que la cantidad pedida. La cantidad +
                          total incluye la cantidad recibida. &N +
                          Recobro . . . :  Incorpore una cantidad que +
                          es menos que la cantidad pedid u oprima +
                          F20=Pasar sobre aviso para aceptar la +
                          cantidad incorporada. Entonces intente otra +
                          vez.') SEV(30) FMT((*DEC 5) (*DEC 5) +
                          (*DEC 5) (*DEC 5) (*DEC 5) (*DEC 5))
             ENDDO

/*  PO13247 Super P/O at wrong status or not found. P/O not added.           */

             CHGVAR     VAR(&MSGID) VALUE('PO13247')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('SuperP/O-&1 al estado incorrecto o no fue +
                          encontrado. P/O-&2 no anadido.') SECLVL('Causa +
                           . . . . . Es posible que marcara el SuperP/O +
                          &1 <exportar> o alguien ha borrado el Super+
                          P/O. Cuando marca el SuperP/O <exportar>, +
                          las adiciones ya no son permitidas. +
                          &N Recobro  . . . Vuelva al programa +
                          Purchase Order Maintenance y desmarque el +
                          SuperP/O <exportar>, entonces vuelva a +
                          anadir los p/o''s individuales y continuar. +
                          Si el SuperP/O ya no exista, oprima F7=+
                          SuperP/O para crear un nuevo SuperP/O y +
                          continuar.') SEV(30) FMT((*CHAR +
                          10) (*CHAR 10) (*DEC 5) (*DEC 5) (*DEC 5) +
                          (*DEC 5))
             ENDDO

/*  PO13248 Option 70=Export p/o not allowed for individual p/o's on Super */

             CHGVAR     VAR(&MSGID) VALUE('PO13248')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Opcion 70=Export p/o no es permitido por +
                          p/o''s individuales unidos al Super+
                          P/O.') SEV(30) FMT(*NONE)
             ENDDO

/* TRANSLATE                                                         */
/*  PO13249 Option 17=P/O Total Qty/Wgt not allowed for Super P/O's. */

             CHGVAR     VAR(&MSGID) VALUE('PO13249')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Opcion 17=Total Ctd/Pso no permite el + for +
                          Super P/O.') SECLVL('Causa . . . . . :   +
                          Usuario ha seleccionado un Super P/O para +  l Qty/ +
                          mostrar info. de Peso Total. No se permite +
                          para super P/O''s. &N Recobro  . . . :  +
                          Quita esta opcion del Super P/O. Seleccione +
                          un P/O individual que no es en la forma de +
                          SPxxxxxxx donde x=a numero unico. Entonces +
                          intenta otra vez.') SEV(30) +
                          FMT(*NONE)
             ENDDO
/* TRANSLATE                                                         */
/*  PO13250 CMD11 - MFR Decipher program - Date sensitive items only */

             CHGVAR     VAR(&MSGID) VALUE('PO13250')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('CMD11 is only allowed for Date +
                          Sensitive Items.') SECLVL('Cause . . . . +
                          . :   Item being received is not date +
                          sensitive.') SEV(30) FMT(*NONE)
             ENDDO

/*  PO14221  Quantity entered greater than slot quantity. */

             CHGVAR     VAR(&MSGID) VALUE('PO14221')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La cantidad de ajustamiento es mas +
                          grande que la cantidad del slot.') +
                          SECLVL('Causa . . . . . :   La cantidad de +
                          ajustamiento incorporada (&1) es mas grande +
                          que la cantidad del slot (&2). &N Recobro +
                          . . . :   Incorpore una cantidad de +
                          ajustamiento que es menos que o igual a la +
                          cantidad del slot.') SEV(30) +
                          FMT((*DEC 5 0) (*DEC 5 0))
             ENDDO

/*  PO14222  Slot does not contain item. */

             CHGVAR     VAR(&MSGID) VALUE('PO14222')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Slot +
                          no contiene el producto &1.') SECLVL('Causa +
                          . . . . . :   El slot incorporado no +
                          contiene el producto &1. &N Recobro  . . . +
                          :   Incorpore un slot que contiene &1.') +
                          SEV(30) FMT((*CHAR 15))
             ENDDO

/*  PO14223  Quantity entered greater than quantity received. */

             CHGVAR     VAR(&MSGID) VALUE('PO14223')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La cantidad de ajustamiento es mas +
                          grande que la cantidad recibida.') +
                          SECLVL('Causa . . . . . :   La cantidad de +
                          ajustamiento (&1) es mas grande que la +
                          cantidad recibida &2. &N Recobro . . . :    +
                          Incorpore una cantidad de ajustamiento que +
                          es menos que o igual a la cantidad +
                          recibida.') +
                          SEV(30) FMT((*DEC 5 0) (*DEC 5 0))
             ENDDO

/*  PO14401 Record selected does not exist. */

             CHGVAR     VAR(&MSGID) VALUE('PO14401')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('La +
                          anotacion de transaccion no existe.') +
                          SECLVL('Causa . . . . . :   La anotacion +
                          seleccionada no puede ser encontrado en el +
                          archivo de PIRTRAN.  &N Recobro . . . :    +
                          Establezca contacto con el director de +
                          DP.') SEV(40)
             ENDDO

/*  PO14402 Cannot delete closed transaction. */

             CHGVAR     VAR(&MSGID) VALUE('PO14402')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No puede borrar una transaccion +
                          cerrada.') SECLVL('Causa . . . . . :   La +
                          anotacion seleccionada no pude ser borrada +
                          porque esta cerrada.  &N Recobro . . . :   +
                          No hay recobro.') SEV(40)
             ENDDO

/*  PO14403 Cannot delete transactions, if PO is ready to export. */

             CHGVAR     VAR(&MSGID) VALUE('PO14403')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No puede borrar la transaccion si el +
                          PO esta listo para exportar.') +
                          SECLVL('Causa . . . . . :   El PO de esta +
                          transaccion esta listo para exportar. &N +
                          Recobro . . . :   Desmarque el PO e intente +
                          otra vez.') SEV(30)
             ENDDO

/*  PO14404 Cannot delete transaction, transaction qty allocated. */

             CHGVAR     VAR(&MSGID) VALUE('PO14404')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No puede borrar esta transaccion si la +
                          cantidad de transaccion ya esta asignada.') +
                          SECLVL('Causa . . . . . :   La cantidad de +
                          esta transaccion ya esta asignada. &N +
                          Recobro . . . :   No hay +
                          recobro.') SEV(40)
             ENDDO

/*  PO14405 Cannot delete transaction, Transaction started. */

             CHGVAR     VAR(&MSGID) VALUE('PO14405')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No puede borrar la transaccion -la +
                          transaction ya ha empezado.') +
                          SECLVL('Causa . . . . . : La transaccion +
                          ya ha sido empezada por otro usuario. &N +
                          Recobro  . . . :   Insiste en que el +
                          usuario salga de la transaccion e intente +
                          otra vez.') SEV(30)
             ENDDO

/*  PO15021  P.O. number must be entered. */

             CHGVAR     VAR(&MSGID) VALUE('PO15021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          numero del PO debe ser incorporado.') +
                          SECLVL('Causa . . . . . :   El numero de PO +
                          es obligatorio para recibir. &N Recobro . . +
                          . :   Incorpore un numero de PO y +
                          continue.') SEV(30)
             ENDDO

/*  PO31521 Receiving document has been printed. */

             CHGVAR     VAR(&MSGID) VALUE('PO31521')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El documento de recibir ha sido +
                          impreso.') SEV(00)
             ENDDO

/*  PO20022 Dock # must be entered. */

             CHGVAR     VAR(&MSGID) VALUE('PO20022')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          muelle debe ser incorporado.') +
                          SECLVL('Causa . . . . . :   El numero de +
                          muelle es obligatorio para recibir. &N +
                          Recobro . . . :   Incorpore el numero y +
                          continue.') SEV(30)
             ENDDO

/*  PO20023 UPC must be entered. */

             CHGVAR     VAR(&MSGID) VALUE('PO20023')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          UPC debe ser incorporado.') SECLVL('Causa . +
                          . . . . :   El codigo de UPC es obligatorio +
                          para recibir. &N Recobro  . . . :   +
                          Incorpore el codigo de UPC y +
                          continue.') SEV(30)
             ENDDO

/*  PO20026 Line not in PO. */

             CHGVAR     VAR(&MSGID) VALUE('PO20026')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Linea +
                          no esta en el PO.') SECLVL('Causa . . . . . +
                          :   El numero de linea no esta en el PO. &N +
                          Recobro  . . . :   Incorpore un numero de +
                          linea por este PO o F4 por la lista y +
                          continue.') SEV(30)
             ENDDO

/*  PO20027 Item not in PO. */

             CHGVAR     VAR(&MSGID) VALUE('PO20027')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          producto no esta en el PO.') SECLVL('Causa +
                          . . . . . :   El producto no esta en el PO. +
                          &N Recobro . . . :   Incorpore un producto +
                          por este PO o f4 por la lista y +
                          continuar.') SEV(30)
             ENDDO

/*  PO20028 Different UPC entered. */

             CHGVAR     VAR(&MSGID) VALUE('PO200289')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG(' +
                          UPC diferente.') SECLVL('Causa . . . . . :  +
                          El UPC incorporado es diferente. &N Recobro +
                          . . . :   Incorpore el codigo de UPC para +
                          corresponder al UPC para ser +
                          verificado.') SEV(30)
             ENDDO

/*  PO20029 UPC not on file. */

             CHGVAR     VAR(&MSGID) VALUE('PO20029')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('UPC no esta en el archivo.') SEV(30)
             ENDDO

/*  PO20030 Line or item must be entered. */

             CHGVAR     VAR(&MSGID) VALUE('PO20030')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('La +
                          linea o producto debe ser incorporado.') +
                          SECLVL('Causa . . . . . :   La linea de PO +
                          es obligatorio para recibir. &N Recobro . +
                          . . :   Incorpore la linea del PO o +
                          producto y continue.') SEV(30)
             ENDDO

/*  PO20031 UPC already exists for item/vendor. */

             CHGVAR     VAR(&MSGID) VALUE('PO20031')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          producto/vendedor ya tiene el UPC.') +
                          SECLVL('Causa . . . . . :   El UPC ya +
                          existe del producto/vendedor. &N Recobro . +
                          . . :   Incorpore un numero del producto +
                          nuevo o revisa producto actual en el +
                          archivo de UPC.') SEV(30)
             ENDDO

/*  PO20032 No UPC entered. */

             CHGVAR     VAR(&MSGID) VALUE('PO20032')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('UPC no incorporado.') SEV(00)
             ENDDO

/*  PO20033 Licnese # required. */

             CHGVAR     VAR(&MSGID) VALUE('PO20033')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          numero de licencia es requerido.') +
                          SECLVL('Causa . . . . . :   El numero de +
                          licencia es requerido para recibir. &N +
                          Recobro . . . :   Incorpore el numero de +
                          licencia y continue.') SEV(30)
             ENDDO

/*  PO20034 License already exists. */

             CHGVAR     VAR(&MSGID) VALUE('PO20034')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('La +
                          licencia ya existe.') SECLVL('Causa . . . . +
                          . :   La licencia ya existe. &N Recobro . +
                          . . :   Incorpore nuevo numero de +
                          licencia.') SEV(30)
             ENDDO

/*  PO20035 Multiple items for UPC. */

             CHGVAR     VAR(&MSGID) VALUE('PO20035')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG(' +
                          Productos multiples de UPC.') +
                          SECLVL('Causa . . . . . :   Productos +
                          multiples de UPC. &N Recobro . . . :   No +
                          reciba usando el UPC.') SEV(30)
             ENDDO

/*  PO20036 Scanned license too long. */

             CHGVAR     VAR(&MSGID) VALUE('PO20036')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG(' +
                          Licencia larga.') SECLVL('Causa . . . . . : +
                          Licencia escandida demasiada larga. &N Recobro +
                          . . . :   Incorpore licencia nueva.') SEV(30)
             ENDDO


/*  PO21001 Catch weight average must be 'N' when multiple qtys are entered. */

             CHGVAR     VAR(&MSGID) VALUE('PO21001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          promedio del CW debe ser N.') SECLVL('Causa +
                          . . . . . :   Cantidades multiples y +
                          unidades de medidas fueron incorporadas. &N + +
                          Recobro . . . :   Incorpore N por el +
                          promedio del CW o reciba solamente una +
                          cantidad y unidad de medida.') SEV(30)
             ENDDO

/*  PO23201 UPC code already exists for vendor/item. */

             CHGVAR     VAR(&MSGID) VALUE('PO23201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG(' +
                          UPC existe.') SECLVL('Causa . . . . . :   +
                          UPC ya existe por el numero del producto +
                          del vendedor. &N Recobro . . . :   No +
                          incorpore el codigo del UPC.') SEV(30)
             ENDDO

/*  PO23215 PO: &1 inuse on Retalix by &2. Receipt cancelled.        (710 A) */
             CHGVAR     VAR(&MSGID) VALUE('PO23215')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG( +
                          'PO: &1 inuse on Retalix by &2. +
                           &3 cancelled.') +
                          SECLVL('Cause . . . . . :   Receiving has +
                          been cancelled because PO: &1 is being updated +
                          by user &2 on Retalix.  &N Recovery  . . +
                          . :  Contact user &2 and have them complete +
                          their update of PO: &1 so that receiving +
                           can be started. Then try your request again.') +
                           SEV(30) FMT((*CHAR 9) (*CHAR 10) (*CHAR 15))
             ENDDO


/*  PO23601  Total quantity must equal quantity received. */

             CHGVAR     VAR(&MSGID) VALUE('PO23601')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El total de la cantidad &3 debe ser +
                          igual a la cantidad recibida.') +
                          SECLVL('Causa . . . . . :   El total de la +
                          cantidad incorporada por las paletas (&1) +
                          no es igual a la cantidad recibida (&2). +
                          &N Recobro . . . :   Corijja la cantidad +
                          de las paletas.') +
                          SEV(30) FMT((*DEC 7) (*DEC 7) (*CHAR 5))
             ENDDO

             RETURN
             ENDPGM
