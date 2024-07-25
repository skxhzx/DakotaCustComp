/*------------------------------------------------------------------*/
/*  Spanish Version                                                 */
/*  Message ID's should be identical to RCMSGD                      */
/*------------------------------------------------------------------*/
/*                                                                  */
/*  PIRMSGFRC   Create PIRMSGF Message Descriptions RCpppnn         */
/*                 where ppp = Program number (ie 110)              */
/*                       nn  = Error message id (01-99)             */
/*              Receiving error messages                            */
/*                                                                  */
/*  15 February 1993                                                */
/*  Dave Sommerville                                                */
/*                                                                  */
/*  Note:                                                           */
/*   The following types of messages should begin with msgid 70:    */
/*     - Locked records.                                            */
/*     - Non-existing records.                                      */
/*     - Error writting/updating records.                           */
/*                                                                  */
/*   07/15/98  RH  4.09  add messages RC20003 & RC20004             */
/*   08/23/99  MLB 4.12  Add message RC16021                        */
/*   07/15/00  RRH 4.14a Add message RC20005                        */
/*   07/18/00  RRH 4.14b Add message RC20006                        */
/*   06/29/01  RRH 4.15i Add message RC20007                        */
/*   02/02/02  MLB 4.16  Revised message text for RC20005.          */
/*   02/20/02  MLB 4.15  Add message RC20008                        */
/*   03/01/02  DAS 4.16b Add message RC16022                        */
/*   10/01/03  RH  4.17a Add message RC20009                        */
/*   10/27/03  MLB 4.17b Add message RC20010, RC20011.              */
/*   11/11/03  MLB 4.17c Add message RC20012, RC20013.              */
/*   12/16/03  MLB 4.17d Add message RC20014, RC20015, RC20016.     */
/*   11/23/04  RH  5.00a Add message RC20017                        */
/*   12/18/03  RH  5.00b Add message RC20018                        */
/*   12/29/04  RH  5.00c Add message RC16023                        */
/*   02/15/05  RH  5.00d Add message RC20019                        */
/*   03/30/05  MLB 5.00e Add message RC20020                        */
/*   03/06/06  RH  5.00f Shorten RC20002 to better fit rf screen    */
/*  05/24/06  DAS 5.00  Changed &MSGF to PIRMSGSP                   */
/*   11/25/08  DAS 5.20a Added missing message RC20021.             */
/*                       Added message RC20022 - RC20029.           */
/*   10/09/12  DAS 6.40a Added message RC16024                      */
/*   09/22/15  MLB 7.00  Added message RC20030.                     */
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

/*  RC11501 Invalid option */

             CHGVAR     VAR(&MSGID) VALUE('RC11501')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Opcion invalida enviada al RC115 +
                          &1.') SECLVL('Causa . . . . . :  La opcion +
                          &1 no es valida para el programa RC115. &N +
                          Recobro . . . :   Establezca contacto con +
                          el director de DP para recibir mas +
                          instrucciones.') SEV(30) FMT((*CHAR 8))
             ENDDO

/*  RC11502 Batch in use  */

             CHGVAR     VAR(&MSGID) VALUE('RC11502')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Otro usuario esta usando la hornada +
                          &1.') SECLVL('Causa . . . . . :   +
                          Otro usuario ya esta trabajando con la +
                          hornada &1. &N Recobro  . . . :   Espere +
                          hasta que el otro usuario termine e intente +
                          otra vez.') SEV(30) FMT((*DEC 7))
             ENDDO

/*  RC11503 Status code indicates that batch is in use  */

             CHGVAR     VAR(&MSGID) VALUE('RC11503')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          estado de la hornada &1 indica que se esta +
                          usandola ya.') SECLVL('''Causa . . . . . +
                          :   Otro usuario ya esta trabajando con la +
                          hornada &1. El estado de la hornada debe +
                          indicar lo que se hace a la hornada. Los +
                          codigos estados: S=Suspender, E=Revisar +
                          D=Borrar, L=Haciendo una lista, +
                          P=Anunciado, V=Verificado, C=Completado. +
                          El estado de hornada debe ser ''S'' o +
                          ''V'' para que pueda trabajar con el. Una +
                          hornada puede ser anunciada solamente +
                          despues de una lista revisada ha impreso +
                          sin errores que fija el estado a ''V''. +
                          &N Recobro . . . :   Espere hasta que el otro +
                          usuario termine e intente otra vez.''') +
                          SEV(30) FMT((*DEC 7))
             ENDDO

/*  RC11504 Posting not allowed */

             CHGVAR     VAR(&MSGID) VALUE('RC11504')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La hornada debe ser verificada antes +
                          de anunciarla.') SECLVL('Causa . . . . . +
                          :   La hornada &1 no puede ser anunciada +
                          antes de verificarla. &N Recobro . . . : +
                          Haga la opcion 9 para imprimir la lista de +
                          verificacion. Cuando esta lista imprima +
                          sin errores entonces la hornada sera +
                          marcada como verificada.') +
                          SEV(30) FMT((*DEC 7))
             ENDDO

/*  RC13071 Record not added to receiving batch detail file  */

             CHGVAR     VAR(&MSGID) VALUE('RC13071')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Esta +
                          anotacion no fue anadida al archivo de +
                          detalle de recepcion de la hornada.') +
                          SECLVL('Causa . . . . . :   Un error +
                          ocurrio mientras tratando de anadir esta +
                          anotacion al archivo de detalle de +
                          recepcion de la hornada. &N Recobro . . . +
                          :   Establezca contacto con el director de +
                          DP para recibir mas instrucciones.') SEV(40)
             ENDDO

/*  RC13072 Record not updated in receiving batch detail file  */

             CHGVAR     VAR(&MSGID) VALUE('RC13072')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Esta +
                          anotacion no fue puesta al dia en el +
                          archivo de detalle de recepcion de la +
                          hornada.') SECLVL('Causa . . . . . : Un +
                          error ocurrio mientras tratando de poner +
                          al dia la anotacion al archivo de detalle +
                          de recepcion de la hornada. &N Recobro . . +
                          . :   Establezca contacto con el director +
                          de DP para recibir mas +
                          instrucciones.') SEV(40)
             ENDDO

/*  RC13073 Purchase order does not exist. */

             CHGVAR     VAR(&MSGID) VALUE('RC13073')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El PO &1 no existe.') SECLVL('Causa +
                          . . . . . :   El PO &1 no existe en el +
                          archivo de los PO. &N Recobro . . . :   +
                          Incorpore un numero de PO que ya se ha +
                          definido.') +
                          SEV(40) FMT((*DEC 9 0))
             ENDDO

/*  RC13074 Item does not exist in purchase order.  */

             CHGVAR     VAR(&MSGID) VALUE('RC13074')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          producto &2 no existe en el PO &1.') +
                          SECLVL('Causa . . . . . :   El PO &1 no +
                          contiene el producto &2. &N +
                          Recovery  . . . :   Incorpore un numero +
                          de producto que es una parte del PO &1 o +
                          incorpore un numero nuevo de PO.') +
                          SEV(40) FMT((*DEC 9 0) (*CHAR 15))
             ENDDO

/*  RC13075 BATRC record is locked.  */

             CHGVAR     VAR(&MSGID) VALUE('RC13075')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El producto de detalle esta cerrado +
                          actualmente por otro usuario.') +
                          SECLVL('Causa . . . . . :   Otro usuario +
                          esta usando el producto de detalle +
                          escogido y no puede ser compartido. &N +
                          Recobro . . . :  Seleccione otro producto +
                          de detalle o espere hasta el otro usuario +
                          termina e intente otra vez.') SEV(40)
             ENDDO

/*  RC13076 Detail item not found in receiving batch file.  */

             CHGVAR     VAR(&MSGID) VALUE('RC13076')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Producto de detalle no encontrado.') +
                          SECLVL('Causa . . . . . :   El producto de +
                          detalle seleccionado no existe en el +
                          archivo de hornada de recepcion. &N +
                          Recobro . . . :   Oprima F5 para refrescar +
                          la pantalla y seleccione otro producto de +
                          detalle.') SEV(40)
             ENDDO

/*  RC15520 Item put away successfully. */

             CHGVAR     VAR(&MSGID) VALUE('RC15520')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          piezas guardadas en &2 paletas por +
                          producto.') SECLVL('No hay mas +
                          informacion.') +
                          SEV(00) FMT((*DEC 5 0) (*DEC 3 0) (*CHAR 15))
             ENDDO

/*  RC15521 Item does not exist. */

             CHGVAR     VAR(&MSGID) VALUE('RC15521')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('El +
                          producto &1 no existe.') SECLVL('Causa . +
                          . . . . :   El producto &1 no exist en el +
                          archivo principal del producto. &N Recobro +
                          . . . :   Incorpore un numero que existe e +
                          intente otra vez.') SEV(40) FMT((*CHAR 15))
             ENDDO

/*  RC15522 Tie/High definitions do not exist for item. */

             CHGVAR     VAR(&MSGID) VALUE('RC15522')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('La definicion de Tie/High no existe +
                          del producto &1.') SECLVL('Causa . . +
                          . . . :   El producto &1 no tiene ningunas +
                          definiciones de Tie/High definidas. &N +
                          Recobro . . . : Use mantenimiento de +
                          producto para definir por lo menos una +
                          definicion de Tie High por el producto +
                          &1.') SEV(40) FMT((*CHAR 15))
             ENDDO

/*  RC15523 Receiving options do not exist. */

             CHGVAR     VAR(&MSGID) VALUE('RC15523')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Opciones de recepcion no existen.') +
                          SECLVL('Causa . . . . . :   Las opciones +
                          de recepcion no encontradas. &N Recobro . +
                          . . :   Vaya al menu de administracion e +
                          incorpore las opciones de +
                          recepcion.') SEV(40)
             ENDDO

/*  RC15524 No slots available for put away. */

             CHGVAR     VAR(&MSGID) VALUE('RC15524')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Ningunos +
                          slots disponibles para guardar.') +
                          SECLVL('Causa . . . . . :   No encontro +
                          ningunos slots verificados que +
                          corresponden a las definiciones de Tie/ +
                          High del producto. &N Recobro . . . : +
                          Solamente los slots verificados que tienen +
                          una definicion de Tie/High que corresponde +
                          puden ser buscados. Deba verificar algunos +
                          de los slots o puede definir otras +
                          definiciones de Tie/High del producto +
                          en los casos donde hay slots verificados +
                          disponibles.') SEV(40)
             ENDDO

/*  RC15525 Not enough slots available for put away. */

             CHGVAR     VAR(&MSGID) VALUE('RC15525')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No  +
                          hay bastante slots disponibles para +
                          guardar.') SECLVL('Causa . . . . . :   No +
                          hubo bastante slots verificados +
                          encontrados que corresponden a las +
                          definiciones de Tie/High por el producto. +
                          &N Recobro . . . :   Solamente buscara los +
                          slots verificados que tienen una +
                          definicion correspondiente de Tie/High +
                          definido por el producto. Deba verificar +
                          algunos de los slots o puede definir otras +
                          definiciones de Tie/High por el producto +
                          en los casos donde hay slots verificados +
                          disponibles.') SEV(40)
             ENDDO

/*  RC15526 No slots available for put away in same aisle. */

             CHGVAR     VAR(&MSGID) VALUE('RC15526')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          hay bastante slots disponibles para guardar +
                          en el mismo pasillo.') +
                          SECLVL('Causa . . . . . :   No hubo slots +
                          verificados encontrados que corresponden +
                          al pasillo actual del producto. &N +
                          Recobro  . . . :   Solamente buscara slots +
                          verificados que tienen una definicion de +
                          Tigh/High de pasillo correspondiente +
                          definida por el producto. Verifique +
                          algunos de los slots o defina otras +
                          definiciones de Tie/High por el producto +
                          en los casos donde hay slots verificados +
                          disponibles.') SEV(40)
             ENDDO

/*  RC15527 Not enough slots available for put away in same aisle. */

             CHGVAR     VAR(&MSGID) VALUE('RC15527')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          hay bastante slots disponibles para guardar +
                          en el mismo pasillo.') +
                          SECLVL('Causa . . . . . :   No hubo +
                          bastante slots verificados encontrados que +
                          corresponden a las definiciones de +
                          Tie/High y pasillo por el producto. &N +
                          Recobro . . . :   Solamente buscara los +
                          slots verificados que tienen una +
                          definicion correspondiente de Tie/High de +
                          pasillo definido por el producto. Deba +
                          verificar algunos de los slots o puede +
                          definir otras definiciones de Tie/High en +
                          los casos donde hay slots verificados +
                          disponibles.') SEV(40)
             ENDDO

/*  RC16020 Item put away successfully. */

             CHGVAR     VAR(&MSGID) VALUE('RC16020')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          piezas guardadas en &2 paletas por el +
                          producto.') SECLVL('No hay mas +
                          informacion.') +
                          SEV(00) FMT((*CHAR 10) (*DEC 3 0) (*CHAR 15))
             ENDDO

/*  RC16021 xxx of yyy Pick slots assigned.  */

             CHGVAR     VAR(&MSGID) VALUE('RC16021')

             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          slots de escoger asignados automaticos al +
                          producto &3 al total de &2 slots de +
                          escoger.') SECLVL('Causa . . . . . :   El +
                          valor del sistema es fijo a ''Y'' para +
                          permitir la asignacion automatica de los +
                          slots de escoger. El numero de los slots +
                          de escoger es fijo a &2 por este producto. +
                          &N Recobro . . . :   Si el numero de slots +
                          asignados es menos que &2, haga uno de lo +
                          siguiente: 1.) Busque slots no verificados +
                          y verifiquelos. Haga el mantenimiento de +
                          slot y asigne el producto a los slots +
                          correctos. 2.) Continue la recepcion, no +
                          nececita hacer nada.') +
                          SEV(00) FMT((*DEC 5) (*DEC 5) (*CHAR 15))
             ENDDO


/*  RC16022 No pick slot found for crossdock */

             CHGVAR     VAR(&MSGID) VALUE('RC16022')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG(' +
                          Ningun slot de escoger fue encontrado +
                          para recibir la cantidad de crossdock.') +
                          SECLVL('Causa . . . . . :    El producto +
                          que esta recibiendo tiene una cantidad +
                          de crossdock. La cantidad de crossdock +
                          solamente puede ser guardada en un slot de +
                          escoger. Sin embargo, un slot de escgoer +
                          no fue enocontrado por el producto. &N +
                          Recobro . . . :   Cree un slot de escoger +
                          por el producto e intente otra vez.') +
                          SEV(40)
             ENDDO

/*  RC16023 No pick slot for Special Receive */

             CHGVAR     VAR(&MSGID) VALUE('RC16023')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          encontro` pick slot para hacer el recibo +
                          especial.') SECLVL('Causa . . . . . :   +
                          El producto que Ud. esta recibiendo usando +
                          el recibo especial no tiene un pick slot. +
                          El recibo especial requiere que el producto +
                          este en un pick slot. &N +
                          Recobro  . . . :   Cree un pick slot +
                          del producto e intente otra vez.') +
                          SEV(40)
             ENDDO

/*  RC16024 No Tie/High definition large enough for qty.   640aA*/

             CHGVAR     VAR(&MSGID) VALUE('RC16024')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          Tie/High definition large enough for +
                          quantity &1') SECLVL('Cause . . . . . :   +
                          Single pallet is being received that is +
                          not allowed to be split and none of the +
                          tie/high definitions are large enough to +
                          hold the quantity being received, &1. &N +
                          Recovery  . . . :   Use item maintenance +
                          to define at least one tie/high +
                          definition that is equal to or greater +
                          than &1') SEV(40) FMT((*DEC 5 0))
             ENDDO

/*  RC20030 Putaway completed successfully. */

             CHGVAR     VAR(&MSGID) VALUE('RC20030')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Lic: &1 +
                          putaway to slot &2.') +
                          SECLVL('Cause . . . . . :   +
                          Lic: &1 successfully transfered to slot +
                          &2.  &N Recovery  . . . :   No recovery.  +
                          This is an informational message.') +
                          SEV(10) FMT((*CHAR 15) (*CHAR 12))
             ENDDO

/*  RC20001 Scanned slot is invalid.(To slot)  */

             CHGVAR     VAR(&MSGID) VALUE('RC20001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Slot invalido.') SECLVL('Causa . . . +
                          . . :   El numero de slot incorporado/ +
                          escandido es diferente que el slot de +
                          guardar &1.  &N Recovery  . . . :   Ponga +
                          el producto en el slot &1 e incorpore/ +
                          escanda el slot &1.') SEV(30) FMT((*CHAR 12))
             ENDDO

/*  RC20002 Transaction is closed.         */

             CHGVAR     VAR(&MSGID) VALUE('RC20002')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Transaccion esta cerrada o iniciada +
                          por otro usuario.') SECLVL('Causa . . . +
                          . . :   La transaccion &1 esta cerrada o +
                          iniciada por otro usuario.  &N Recobro . +
                          . . . :   Incorpore/Escanda otra licencia +
                          e intente otra vez.') SEV(30) +
                          FMT((*DEC 7 0))
             ENDDO

/*  RC20003 Quantity must be > 0.          */

             CHGVAR     VAR(&MSGID) VALUE('RC20003')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cantidad invalida.') +
                          SECLVL('Causa . . . . . +
                          :   La cantidad no puede ser mas grande +
                          que 0. &N Recobro . . . :  Incorpore una +
                          cantidad nueva.') +
                          SEV(30)
             ENDDO

/*  RC20004 Quantity can't be > than qty to be put away  */

             CHGVAR     VAR(&MSGID) VALUE('RC20004')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Cantidad invalida.') +
                          SECLVL('Causa . . . . . +
                          :   La cantidad no puede ser mas grande +
                          que la cantidad de guardar. +
                          &N Recobro . . . :   Incorpore una +
                          cantidad nueva.') +
                          SEV(30)
             ENDDO

/*  RC20005 Invalid slot, put in overflow      */

             CHGVAR     VAR(&MSGID) VALUE('RC20005')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

 /*  This line is the message before the 4.16 change.                (416)  */
 /*                       MSG('Slot invalido-ponga en sobrellena.') +(416)  */
             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Producto mas viejo en el inventario. +
                          Pongalo en la sobrellena.') SECLVL('Causa +
                          . . . . . :   Los slots de sobrellena +
                          existen por el slot de escoger escandido. +
                          No puede ponerlos en el slot de escoger. +
                          &N Recobro . . . :   Ponga el producto en +
                          un slot de sobrellena.') +
                          SEV(30)
             ENDDO

/*  RC20006 Slot must match item designation code.   */

             CHGVAR     VAR(&MSGID) VALUE('RC20006')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El slot debe corresponder a la +
                          designacion de producto.') SECLVL('Causa +
                          . . . . . :   La designacion de producto +
                          no corresponde al codigo de designacion de +
                          producto de HARD. &N Recobro  . . . :   +
                          Ponga el producto en el slot que +
                          corresponde al codigo de designacion de +
                          producto.') SEV(30)
             ENDDO

/*  RC20007 Invalid slot, slot inactive        */

             CHGVAR     VAR(&MSGID) VALUE('RC20007')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Slot invaldio, slot inactivo.') +
                          SECLVL('Causa . . . . . :   El slot +
                          escandido es inactivo. No puede ponder el +
                          producto en un slot inactivo. +
                          &N Recobro  . . . :   Ponga el producto +
                          en otro slot') +
                          SEV(30)
             ENDDO

/*  RC20008 Label / License already scanned in. */

             CHGVAR     VAR(&MSGID) VALUE('RC20008')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('&1 +
                          ya escandido por &3.') SECLVL('Causa +
                          . . . . . :   &1 numero &2 ya ha sido +
                          escandido por otro usuario. &N +
                          Recobro  . . . :   Verifique que el numero +
                          escandido es correcto o escanda un numero +
                          nuevo e intente otra vez.') +
                          SEV(30) FMT((*CHAR 10) (*DEC 7 0) (*CHAR 10))
             ENDDO

/*  RC20009 Must stage total remaining quantity */

             CHGVAR     VAR(&MSGID) VALUE('RC20009')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('El total de preparar &1 queda.') SECLVL+
                          ('Causa. . . :   Hay que preparar el total de +
                          la cantidad de &1 que queda. +
                          &N Recobro  . . . :   Cambie la cantidad al +
                          total de &1 que +
                          queda.') SEV(30) FMT((*DEC 7 0))
             ENDDO

/*  RC20010 Pallet position must be greater than zero. */

             CHGVAR     VAR(&MSGID) VALUE('RC20010')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Posicion de paleta debe ser > 0.') +
                          SECLVL('Causa . . . :   El usuario incorporo +
                          una posicion de paleta que es menos que o +
                          igual a cero. &N Recobro  . . . :   Cambie +
                          el valor incorporado por la posicion de +
                          paleta a un valor mas grande que cero.') +
                          SEV(30) FMT(*NONE)
             ENDDO

/*  RC20011 Pallet position greater than slot maximum. */

             CHGVAR     VAR(&MSGID) VALUE('RC20011')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Posicion de paleta debe ser <= &2.') +
                          SECLVL('Causa . . . :   El usuario incorporo +
                          una posicion de paleta &1 que es mas grande +
                          que la posicion de paleta maxima &2. &N +
                          Recobro  . . . :   Cambie el valor incorporado +
                          por la posicion de paleta a un valor que es +
                          menos que o igual a &2.') SEV(30) +
                          FMT((*DEC 3 0) (*DEC 3))
             ENDDO

/*  RC20012 License not found in tracking files. */

             CHGVAR     VAR(&MSGID) VALUE('RC20012')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Licencia &1 no encontrado en archivos de +
                          rastrear.') SECLVL('Causa . . . :   El usuario +
                          escandio la licencia  &1 y no fue encontrado en +
                          los archivos de rastrear licencias. &N +
                          Recobro  . . . :   Escanda otra licencia en la +
                          paleta ubicada en el slot &2. Entonces intente +
                          otra vez.') SEV(30) +
                          FMT((*CHAR 15 0) (*CHAR 12))
             ENDDO

/*  RC20013 License not found in scanned slot. */

             CHGVAR     VAR(&MSGID) VALUE('RC20013')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('License &1 not found in scanned slot +
                          &2.') SECLVL('Causa . . . :   La licencia +
                          escandida &1 no esta ubicada en el slot &2. +
                          &N Recobro  . . . :   Escanda nueva licencia +
                          que esta ubicada en el slot &2. Entonces intente +
                          otra vez.') SEV(30) FMT((*CHAR 15 0) +
                          (*CHAR 12))
             ENDDO

/*  RC20014 No room in pushback slot. Merge item onto pallet. */

             CHGVAR     VAR(&MSGID) VALUE('RC20014')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('No +
                          hay espacio en slot de pushback. Combine producto +
                          en la paleta.') SECLVL('Causa . . . :   No hay +
                          espacio en el slot de pushback. &N Recobro  +
                          . . . :   Combine el producto en la paleta que +
                          existe o escanda un slot nuevo. Entonces intente +
                          otra vez.') SEV(30)
             ENDDO

/*  RC20015 Scan license on front pallet in slot.                          */

             CHGVAR     VAR(&MSGID) VALUE('RC20015')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Escanda +
                          licencia en paleta anterior en slot &2.') +
                          SECLVL('Causa . . . :   La licencia &1 +
                          escandida esta ubicada en la posicion de paleta +
                          &3 en slot &2. &N Recobro  . . . :   Escanda +
                          una licencia que esta ubicada en la posicion +
                          1 en slot &2. Entonces intente +
                          otra vez.') SEV(30) FMT((*CHAR 15) +
                          (*CHAR 12) (*DEC 3 0))
             ENDDO

/*  RC20016 Scan license on pallet on floor.                               */

             CHGVAR     VAR(&MSGID) VALUE('RC20016')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Escanda +
                          licencia en pallet que esta en el suelo.') +
                          SECLVL('Causa . . . :   La licencia escandida +
                          &1 esta ubicada en la posicion de paleta &3 +
                          en slot &2. &N Recobro  . . . :   Escanda una +
                          licencia que esta ubicada en el suelo y +
                          empiece el proceso de guardar. Entonces intente +
                          otra vez.') SEV(30) FMT((*CHAR 15) (*CHAR +
                          12) (*DEC 3 0))
             ENDDO

/*  RC20017 Invalid slot, virtual slot.        */

             CHGVAR     VAR(&MSGID) VALUE('RC20017')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Slot invalido porque es virtual.') +
                          SECLVL('Causa . . . . . :   El slot escandido +
                          es un slot virtual. No puede escandir un +
                          slot virtual. +
                          &N Recobro  . . . :   Escanda el slot de +
                          base para ver la ubicacion.') +
                          SEV(30)
             ENDDO

/*  RC20018 Can not put in pick slot */

             CHGVAR     VAR(&MSGID) VALUE('RC20018')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('No puede poner en pick slot.') +
                          SECLVL('Causa . . . :   Hay que poner el +
                          producto especial en el slot de sobrellena. +
                          &N Recobro  . . . :   +
                          Ponga el producto en el slot de sobrellena.') +
                           SEV(30)
             ENDDO

/*  RC20019 License already scanned in. */

             CHGVAR     VAR(&MSGID) VALUE('RC20019')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Licencia ya escandida por &2.') +
                          SECLVL('Causa . . . . . :   El numero de +
                          licencia &1 ya ha sido escandido por el +
                          usuario &2. &N Recobro  . . . :   Verifique +
                          que el numero escandido es correcto o escanda +
                          un numero nuevo e intente otra +
                          vez.') SEV(30) FMT((*CHAR 15) (*CHAR 10))
             ENDDO

/*  RC20020 Slot not in &2 section. */

             CHGVAR     VAR(&MSGID) VALUE('RC20020')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) MSG('Slot +
                          no esta en seccion &2.') SECLVL('Causa . . . +
                          . . :   El slot-&1 no esta en la misma +
                          seccion como el producto (&3). &N Recobro  . +
                          . . :   Escanda un slot nuevo que esta en la +
                          seccion &2 e intente otra vez.') +
                          SEV(30) FMT((*CHAR 12) (*CHAR 5) (*CHAR 5))
             ENDDO

/*  RC20021 License deleted */

             CHGVAR     VAR(&MSGID) VALUE('RC20021')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('License &1 is deleted and cannot be +
                          used') SECLVL('Cause . . . . . :   +
                          License &1 is deleted. &N Recovery  . . . +
                          :   Contact receiving clerk.') SEV(30) +
                          FMT((*CHAR 15))
             ENDDO

/*  RC20022 License not found in LICACTIVE */

/* TRANSLATE */
             CHGVAR     VAR(&MSGID) VALUE('RC20022')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('License &1 not found in LICACTIVE +
                          file') SECLVL('Cause . . . . . :   +
                          License &1 was not found in the LICACTIVE +
                          file. &N Recovery  . . . :   Verify +
                          correct license was scanned, then contact +
                          tech suppor.') SEV(30) FMT((*CHAR 15))
             ENDDO

/*  RC20023 License not found in LICINFO */

/* TRANSLATE */
             CHGVAR     VAR(&MSGID) VALUE('RC20023')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('License &1 not found in LICINFO +
                          file') SECLVL('Cause . . . . . :   +
                          License &1 was not found in the LICINFO +
                          file. &N Recovery  . . . :   Verify +
                          correct license was scanned, then contact +
                          tech suppor.') SEV(30) FMT((*CHAR 15))
             ENDDO

/*  RC20024 License not in a RCV or STG location */

/* TRANSLATE */
             CHGVAR     VAR(&MSGID) VALUE('RC20024')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('License &1 not in receiving dock or +
                          stage location') SECLVL('Cause . . . . . +
                          :   License &1 is in slot &2. For putaway +
                          a license must reside in a receiving dock +
                          (RCV) or stage (STG) location. &N +
                          Recovery  . . . :   Use a the transfer +
                          program to move this license.') SEV(30) +
                          FMT((*CHAR 15) (*CHAR 12))
             ENDDO

/*  RC20025 License slot not found */

/* TRANSLATE */
             CHGVAR     VAR(&MSGID) VALUE('RC20025')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('License slot &2 not found for +
                          license &1') SECLVL('Cause . . . . . :   +
                          The LICACTIVE record for license &1 is +
                          associated with slot &2, but that slot +
                          does not exist. &N Recovery  . . . :   +
                          Contact support.') SEV(30) FMT((*CHAR 15) +
                          (*CHAR 12))
             ENDDO

/*  RC20026 License slot not active */

/* TRANSLATE */
             CHGVAR     VAR(&MSGID) VALUE('RC20026')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('License slot &2 not active') +
                          SECLVL('Cause . . . . . :   The LICACTIVE +
                          record for license &1 is associated with +
                          slot &2, but that slot has a non-active +
                          status of &3. &N Recovery  . . . :   +
                          Contact support.') SEV(30) FMT((*CHAR 15) +
                          (*CHAR 12) (*CHAR 1))
             ENDDO

/*  RC20027 Wrong item found in license slot */

/* TRANSLATE */
             CHGVAR     VAR(&MSGID) VALUE('RC20027')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Wrong item found in license slot +
                          &2') SECLVL('Cause . . . . . :   The +
                          LICACTIVE record for license &1 is +
                          associated with item &3 and slot &2, but +
                          that slot contains item &4 instead. &N +
                          Recovery  . . . :   Contact support.') +
                          SEV(30) FMT((*CHAR 15) (*CHAR 12) (*CHAR +
                          15) (*CHAR 15))
             ENDDO

/*  RC20028 License transaction not found */

/* TRANSLATE */
             CHGVAR     VAR(&MSGID) VALUE('RC20028')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('License transaction &2 not found') +
                          SECLVL('Cause . . . . . :   The LICACTIVE +
                          record for license &1 is associated with +
                          transaction &2, but that transaction was +
                          not found. &N Recovery  . . . :   Contact +
                          support.') SEV(30) FMT((*CHAR 15) (*DEC 7))
             ENDDO

/*  RC20029 License transaction not a putaway transaction */

/* TRANSLATE */
             CHGVAR     VAR(&MSGID) VALUE('RC20029')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('License transaction &2 not a putaway +
                          transaction') SECLVL('Cause . . . . . :   +
                          The LICACTIVE record for license &1 is +
                          associated with transaction &2, but that +
                          transaction is not a putaway transaction. +
                          Instead it has a type of &3. &N Recovery  +
                          . . . :   Contact support.') SEV(30) +
                          FMT((*CHAR 15) (*DEC 7) (*CHAR 6))
             ENDDO

/*  RL21001 Batch not found. */

             CHGVAR     VAR(&MSGID) VALUE('RL21001')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Hornada &1 no encontrada.') +
                          SECLVL('Causa . . . . . :   La hornada &1 +
                          no fue encontrada en este almacen. &N +
                          Recobro . . . :   Incorpore un numero +
                          valido de la hornada e intente otra +
                          vez.') SEV(30) FMT((*DEC 7))
             ENDDO

/*  RL21002 Batch is not a receiving batch. */

             CHGVAR     VAR(&MSGID) VALUE('RL21002')
             IF         COND((&OPT *EQ '*ALL') *OR (&OPT *EQ +
                          &MSGID)) THEN(DO)

             CHGVAR     VAR(&STATMSG) VALUE(&CREATE *BCAT &MSGID)
             MSG        MESSAGE(&STATMSG)

             RMVMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF)
             MONMSG     MSGID(CPF2419)

             ADDMSGD    MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSG('Hornada &1 no es una hornada de +
                          recepcion.') SECLVL('Causa . . . . . +
                          : La hornada &1 es del tipo &2 en lugar de +
                          *RCVLBL. &N Recobro . . . : Incorpore un +
                          numero de hornada de recepcion.') +
                          SEV(30) FMT((*DEC 7) (*CHAR 8))
             ENDDO

             RETURN
             ENDPGM
