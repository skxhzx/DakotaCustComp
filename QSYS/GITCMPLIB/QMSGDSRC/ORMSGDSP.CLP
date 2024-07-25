/*------------------------------------------------------------------*/
/*  Spanish Version                                                 */
/*  Message ID's should be identical to ORMSGD                      */
/*------------------------------------------------------------------*/
/*                                                                  */
/*  ORMSGD      Create PIRMSGF Message Descriptions ORpppnn         */
/*                 where ppp = Program number (ie 110)              */
/*                       nn  = Error message id (01-99)             */
/*                                                                  */
/*  15 February 1993                                                */
/*  Dave Sommerville                                                */
/*                                                                  */
/*  07/03/02  RH  4.16  Add OR12201 message for returns.            */
/*  07/03/02  RH  4.16  Add OR12202 message for returns.            */
/*  12/14/04  RH  5.00  Add OR12203 message for returns.            */
/*  05/24/06  DAS 5.00  Changed &MSGF to PIRMSGSP                   */
/*  08/20/07  RH  5.10  Add OR12204 message for returns.            */
/*  03/20/09  RH  5.20  Add OR12205 Subs not allowed.               */
/*------------------------------------------------------------------*/

             PGM        PARM(&OPT)

             DCL        VAR(&MSGID) TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSGF) TYPE(*CHAR) LEN(10) VALUE(PIRMSGFSP)
             DCL        VAR(&MSGFLIB) TYPE(*CHAR) LEN(10) VALUE(*LIBL)
             DCL        VAR(&OPT) TYPE(*CHAR) LEN(7)
             DCL        VAR(&STATMSG) TYPE(*CHAR) LEN(128)
             DCL        VAR(&CREATE) TYPE(*CHAR) LEN(8) VALUE('Creating')

/*  OR13021 Order number must greater than zero. */

             CHGVAR     VAR(&MSGID) VALUE('OR13021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El numero de pedido debe ser mayor +
                          que cero.') SECLVL('Causa . . . . . :    +
                          El numero de pedido es un campo requerido. +
                          Por eso, debe ser mas grande que cero. &N +
                          Recobro . . . :   Incorpore un numero de +
                          pedido mas grande que cero.') SEV(30)
             ENDDO

/*  OR11221 Invalide order type entered. */

             CHGVAR     VAR(&MSGID) VALUE('OR11221')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El tipo de pedido debe ser '' '' o +
                          ''T''.') SECLVL('Causa . . . . . :   El +
                          tipo de pedido no es '' '' o ''T''. &N +
                          Recobro . . . :   Incorpore '' '' por un +
                          pedido normal o ''T'' por una +
                          transferencia.') SEV(30)
             ENDDO

/*  OR12201 Customer order already returned.  */

             CHGVAR     VAR(&MSGID) VALUE('OR12201')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG( +
                          'Pedido ya vuelto.') SECLVL('Causa . . . +
                          . . :   El pedido se ha vuelto ya. +
                          Recobro  . . . : Incorpore un pedido +
                          diferente e intente otra vez.') +
                          SEV(30) +
                          FMT((*DEC 3))
             ENDDO

/*  OR12202 Correspondng item and ordered item must be different.  */

             CHGVAR     VAR(&MSGID) VALUE('OR12202')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG( +
                          'El producto correspondiente no puede ser +
                          el producto pedido.') SECLVL('Causa . . . +
                          . . :   Un producto correspondiente no +
                          puede ser lo mismo como un producto pedido +
                          Recobro  . . . :   Incorpore un producto +
                          correspondiente que es diferente e intente +
                          otra vez.') SEV(30) +
                          FMT((*DEC 3))
             ENDDO

/* TRANSLATE */
/*  OR12203 Disposition code must impact inventory.  */

             CHGVAR     VAR(&MSGID) VALUE('OR12203')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG( +
                          'Disposition must impact inv.') +
                          SECLVL('Cause . . . . . :   Disposition +
                          must impact inventory. +
                          Recovery  . . . :   Enter a different +
                          code and try again.') SEV(30) +
                          FMT((*DEC 3))
             ENDDO


/* TRANSLATE */
/*  OR12204 Item not found on order.  */

             CHGVAR     VAR(&MSGID) VALUE('OR12204')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG( +
                          'Item not found on order.') +
                          SECLVL('Cause . . . . . :   Item not +
                          found on order. +
                          Recovery  . . . :   Enter a different +
                          item or order and try again.') SEV(30) +
                          FMT((*DEC 3))
             ENDDO
/*  OR12205 Subs not allowed.         */

             CHGVAR     VAR(&MSGID) VALUE('OR12205')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG( +
                          'No permite el sustituto.') +
                          SECLVL('Cause . . . . . :   No permite +
                          el sustituto. +
                          Recovery  . . . :   No permite sustituto +
                          de producto.') SEV(30) +
                          FMT((*DEC 3))
             ENDDO


/*  OR13022 Warning: Order number not found in picking file. */

             CHGVAR     VAR(&MSGID) VALUE('OR13022')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Aviso: El numero de pedido no fue +
                          encontrado en el archivo de escoger.') +
                          SECLVL('Causa . . . . . :   El numero +
                          incorporado no fue encontrado en el +
                          archivo de escoger. &N Recobro . . . :    +
                          Incorpore Enter para utilizar este numero +
                          de pedido o incorpore un numero +
                          nuevo.') SEV(00)
             ENDDO

/*  OR34021 Batch number not found in picking file. */

             CHGVAR     VAR(&MSGID) VALUE('OR34021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La hornada no existe en el archivo de +
                          escoger.') SECLVL('Causa . . . . . :   El +
                          numero de hornada incorporado no fue +
                          encontrado en el archivo de escoger. &N +
                          Recobro . . . :   Incorpore un numero de +
                          hornada que ya se ha escogido.') SEV(30)
             ENDDO

/*  OR35021 Batch number not found in summary file. */

             CHGVAR     VAR(&MSGID) VALUE('OR35021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La hornada no existe en el archivo +
                          sumario.') SECLVL('Causa . . . . . :   El +
                          numero de hornada incorporado no fue +
                          encontrado en el archivo sumario. &N +
                          Recobro . . . :   Las anotaciones sumarias +
                          de hornadas son creadas cuando los rotulos +
                          son impresos. Reimprima los rotulos por la +
                          hornada o incorpore un numero de la +
                          hornada para un grupo de rotulos que ya se +
                          han impreso.') SEV(30)
             ENDDO

/*  OR50019 No open orders found for warehouse. */

             CHGVAR     VAR(&MSGID) VALUE('OR50019')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG(' +
                          Ningunos pedidos libres encontrados para +
                          el almacen.') SECLVL('Causa . . . . . :    +
                          Ningunos pedidos libres fueron encontrados +
                          para el almacen &1. &N Recobro . . . :    +
                          Incorpore un almacen diferente e intente +
                          otra vez.') SEV(30) +
                          FMT((*DEC 3))
             ENDDO

/*  OR50020 No open orders found for route. */

             CHGVAR     VAR(&MSGID) VALUE('OR50020')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG(' +
                          Ningunos pedidos libres fueron encontrados +
                          para la ruta.') SECLVL('Causa . . . . . . +
                          :   Ningunos pedidos libres fueron +
                          encontrados para la ruta &2 en el almacen +
                          &1. &N Recobro . . . :   Incorpore una +
                          ruta diferente o *ALL para seleccionar +
                          todas las rutas del almacen.') SEV(30) +
                          FMT((*DEC 3) (*CHAR 5))
             ENDDO

/*  OR50021 Allocating stock from slots. */

             CHGVAR     VAR(&MSGID) VALUE('OR50021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Asignando inventario de los slots.') +
                          SEV(00)
             ENDDO

/*  OR50022 Building pallets.*/

             CHGVAR     VAR(&MSGID) VALUE('OR50022')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Construyendo las paletas.') SEV(00)
             ENDDO

/*  OR50023 Picking stock from slots. */

             CHGVAR     VAR(&MSGID) VALUE('OR50023')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Escogiendo inventario de los +
                          slots.') SEV(00)
             ENDDO

/*  OR50024 Printing labels. */

             CHGVAR     VAR(&MSGID) VALUE('OR50024')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Imprimiendo los rotulos.') SEV(00)
             ENDDO

/*  OR50025 Printing loading sheet. */

             CHGVAR     VAR(&MSGID) VALUE('OR50025')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Imprimiendo la hoja de cargar.') +
                          SEV(00)
             ENDDO

/*  OR50026 Printing pallet summary. */

             CHGVAR     VAR(&MSGID) VALUE('OR50026')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Imprimiendo el sumario de paleta.') +
                          SEV(00)
             ENDDO

/*  OR51021 No new orders exist to be picked. */

             CHGVAR     VAR(&MSGID) VALUE('OR51021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          hay pedidos nuevos en el archivo.') +
                          SECLVL('Causa . . . . . :   No hubo +
                          ningunos pedidios nuevos encontrados en el +
                          archivo de pedidos de clientes. &N Recobro +
                          . . . :    Reciba los pedidos del cliente +
                          e intente otra vez.') SEV(30)
             ENDDO

/*  OR54521 No records exist for warehouse/batch/route. */

             CHGVAR     VAR(&MSGID) VALUE('OR54521')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          hay anotaciones que existen por la +
                          combinacion de almacen/hornada/ruta.') +
                          SECLVL('Causa . . . . . :   Ningunas +
                          anotaciones de rotulo fueron encontrados +
                          por almacen &1, hornada &2, ruta &3. &N +
                          Recobro . . . :   Incorpore una +
                          combinacion diferente de almacen/hornada/ +
                          ruta e intente otra vez.') +
                          SEV(30) FMT((*DEC 3) (*DEC 7) +
                          (*CHAR 5))
             ENDDO

/*  OR54522 Batch is not a customer picking batch. */

             CHGVAR     VAR(&MSGID) VALUE('OR54522')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La hornada &1 no es una hornada de +
                          cliente de escoger.') SECLVL('Causa . . . +
                          . . :   La hornada &1 es de tipo &2 en +
                          lugar de *PICK. &N Recobro  . . . : +
                          Incorpore un numero de la hornada de +
                          escoger del cliente.') SEV(30) FMT((*DEC +
                          7) (*CHAR 8))
             ENDDO

/*  OR54523 Batch is not a transfer picking batch. */

             CHGVAR     VAR(&MSGID) VALUE('OR54523')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La hornada &1 no es una hornada de +
                          escoger de transferencia.') SECLVL('Causa +
                          . . . . . :   La hornada &1 es de tipo &2 +
                          en luger de *TFRPICK. &N Recobro . . . :  +
                          Incorpore un numero de la hornada de +
                          escoger de cliente.') SEV(30) FMT((*DEC +
                          7) (*CHAR 8))
             ENDDO

             RETURN
             ENDPGM
